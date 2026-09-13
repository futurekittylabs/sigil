import type { APIRoute } from "astro";
import { env } from "cloudflare:workers";
import { Buffer } from "node:buffer";
import { sign } from "node:crypto";

export const prerender = false;

type Payload = {
  action: "register" | "sign";
  repository: string;
  pull_request: number;
  commit: string;
  expires_at: number;
};

type SignedPayload = {
  payload: Payload;
  public_key: string;
  signature: string;
};

export const GET: APIRoute = ({ url }) => {
  const action = value(url, "action");
  const repository = value(url, "repository");
  const pullRequest = value(url, "pull_request");
  const commit = value(url, "commit");
  if (
    !["register", "sign"].includes(action) ||
    !/^[\w.-]+\/[\w.-]+$/.test(repository) ||
    !/^[1-9]\d*$/.test(pullRequest) ||
    !/^[0-9a-f]{40}$/.test(commit)
  ) {
    return new Response("Invalid signing request", { status: 400 });
  }
  return Response.redirect(
    `sigil://sign?${new URLSearchParams({ action, repository, pull_request: pullRequest, commit })}`,
    302,
  );
};

export const POST: APIRoute = async ({ request }) => {
  const signed = await request.json().catch(() => null);
  if (!isSignedPayload(signed)) {
    return new Response("Invalid signature", { status: 400 });
  }

  const { payload } = signed;
  const body =
    payload.action === "register"
      ? `### Register Sigil signer

Add this key to \`SIGIL_APPROVED_SIGNERS\` in \`.github/workflows/sigil.yml\`:

\`\`\`yaml
SIGIL_APPROVED_SIGNERS: |
  ${signed.public_key}
\`\`\``
      : `<!-- sigil:${Buffer.from(JSON.stringify(signed)).toString("base64url")} -->
### Signed with Sigil

Commit \`${payload.commit}\``;

  try {
    await comment(payload.repository, payload.pull_request, body);
    return new Response(null, { status: 204 });
  } catch (error) {
    console.error(error);
    return new Response("GitHub rejected the signature", { status: 502 });
  }
};

function value(url: URL, name: string): string {
  const values = url.searchParams.getAll(name);
  return values.length === 1 ? values[0] : "";
}

function isSignedPayload(value: unknown): value is SignedPayload {
  if (!value || typeof value !== "object") return false;
  const { payload, public_key, signature } = value as SignedPayload;
  return (
    !!payload &&
    ["register", "sign"].includes(payload.action) &&
    /^[\w.-]+\/[\w.-]+$/.test(payload.repository) &&
    Number.isSafeInteger(payload.pull_request) &&
    payload.pull_request > 0 &&
    /^[0-9a-f]{40}$/.test(payload.commit) &&
    Number.isSafeInteger(payload.expires_at) &&
    /^[A-Za-z0-9_-]{87}$/.test(public_key) &&
    /^[A-Za-z0-9_-]{90,100}$/.test(signature)
  );
}

async function comment(repository: string, pullRequest: number, body: string) {
  const app = appToken();
  const installation = await github<{ id: number }>(
    `/repos/${repository}/installation`,
    app,
  );
  const authorization = await github<{ token: string }>(
    `/app/installations/${installation.id}/access_tokens`,
    app,
    {},
  );
  await github(
    `/repos/${repository}/issues/${pullRequest}/comments`,
    authorization.token,
    { body },
  );
}

function appToken(): string {
  const bindings = env as unknown as {
    GITHUB_APP_ID: string;
    GITHUB_APP_PRIVATE_KEY: string;
  };
  const encode = (value: unknown) =>
    Buffer.from(JSON.stringify(value)).toString("base64url");
  const now = Math.floor(Date.now() / 1000) - 60;
  const message = `${encode({ alg: "RS256", typ: "JWT" })}.${encode({ iat: now, exp: now + 600, iss: bindings.GITHUB_APP_ID })}`;
  return `${message}.${sign("sha256", message, bindings.GITHUB_APP_PRIVATE_KEY).toString("base64url")}`;
}

async function github<T>(
  path: string,
  token: string,
  body?: unknown,
): Promise<T> {
  const response = await fetch(`https://api.github.com${path}`, {
    method: body === undefined ? "GET" : "POST",
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      "User-Agent": "Sigil",
      "X-GitHub-Api-Version": "2022-11-28",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  if (!response.ok) throw new Error(`GitHub returned ${response.status}`);
  return (await response.json()) as T;
}
