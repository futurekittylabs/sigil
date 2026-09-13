import type { APIRoute } from "astro";

export const prerender = false;

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

function value(url: URL, name: string): string {
  const values = url.searchParams.getAll(name);
  return values.length === 1 ? values[0] : "";
}
