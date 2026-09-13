import type { APIRoute } from "astro";

const repositoryPattern = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;
const commitPattern = /^[0-9a-fA-F]{40}$/;

export const prerender = false;

export const GET: APIRoute = ({ url }) => {
  const repository = singleValue(url, "repository");
  const pullRequest = singleValue(url, "pull_request");
  const commit = singleValue(url, "commit");

  if (
    !repository ||
    !pullRequest ||
    !commit ||
    !repositoryPattern.test(repository) ||
    !commitPattern.test(commit) ||
    !isPullRequestURL(pullRequest, repository)
  ) {
    return new Response("Invalid signing request", { status: 400 });
  }

  const query = new URLSearchParams({
    repository,
    pull_request: pullRequest,
    commit,
  });

  return new Response(null, {
    status: 302,
    headers: {
      "Cache-Control": "no-store",
      Location: `sigil://sign?${query}`,
    },
  });
};

function singleValue(url: URL, name: string): string | undefined {
  const values = url.searchParams.getAll(name);
  return values.length === 1 && values[0] ? values[0] : undefined;
}

function isPullRequestURL(value: string, repository: string): boolean {
  let url: URL;

  try {
    url = new URL(value);
  } catch {
    return false;
  }

  const [owner, name] = repository.toLowerCase().split("/");
  const parts = url.pathname.split("/").filter(Boolean);

  return (
    url.protocol === "https:" &&
    url.hostname === "github.com" &&
    !url.port &&
    !url.username &&
    !url.password &&
    !url.search &&
    !url.hash &&
    parts.length === 4 &&
    parts[0]?.toLowerCase() === owner &&
    parts[1]?.toLowerCase() === name &&
    parts[2] === "pull" &&
    /^[1-9][0-9]*$/.test(parts[3] ?? "")
  );
}
