#!/usr/bin/env node

// src/cli/main.ts
import { parseArgs } from "node:util";
import { readFile, writeFile, stat } from "node:fs/promises";
import { createHash, randomUUID } from "node:crypto";
var CliError = class extends Error {
  constructor(code, data) {
    super(String(data.error));
    this.code = code;
    this.data = data;
  }
  code;
  data;
};
var strings = [
  "artifact",
  "slug",
  "title",
  "tag",
  "query",
  "limit",
  "cursor",
  "version",
  "output",
  "expected-revision",
  "base-version",
  "message",
  "request-id",
  "status"
];
var options = Object.fromEntries([
  ...strings.map((name) => [
    name,
    { type: "string", ...name === "tag" ? { multiple: true } : {} }
  ]),
  ...["json", "help", "force"].map((name) => [
    name,
    { type: "boolean" }
  ])
]);
var asJson = process.argv.includes("--json");
function fail(error, code = 1) {
  throw new CliError(code, { error });
}
async function run() {
  const parsed = parseArgs({ options, allowPositionals: true });
  const values = parsed.values;
  const positionals = parsed.positionals;
  asJson = Boolean(values.json);
  const opt = (key) => values[key];
  if (values.help || positionals.length === 0) {
    console.log(
      "art doctor [--json]\nart upload <file> (--slug <new> --title <title> | --artifact <id-or-slug> --expected-revision <n>)\nart list [--query <text>] [--tag <tag>] [--limit <n>] [--cursor <cursor>]\nart read|download|inspect|versions <id-or-slug> [--version current|<id>]\nart download <id-or-slug> --output <file> [--force]\nart comments list <id-or-slug> [--version <id>] [--status open|resolved|all]\nAuthentication: ART_BASE_URL, CF_ACCESS_CLIENT_ID, CF_ACCESS_CLIENT_SECRET (or ART_ACCESS_JWT)\n--json emits machine-readable JSON. Exit codes: 0 success, 1 input, 3 auth, 4 conflict, 5 connection, 6 content hash."
    );
    return;
  }
  const base = new URL(process.env.ART_BASE_URL ?? "http://127.0.0.1:8787");
  if (base.username || base.password || base.search || base.hash || base.pathname !== "/" || base.protocol !== "https:" && !(base.protocol === "http:" && ["127.0.0.1", "localhost", "[::1]"].includes(base.hostname)))
    fail("invalid_base_url");
  const headers = {};
  if (process.env.ART_ACCESS_JWT)
    headers["Cf-Access-Jwt-Assertion"] = process.env.ART_ACCESS_JWT;
  else if (process.env.CF_ACCESS_CLIENT_ID && process.env.CF_ACCESS_CLIENT_SECRET) {
    headers["CF-Access-Client-Id"] = process.env.CF_ACCESS_CLIENT_ID;
    headers["CF-Access-Client-Secret"] = process.env.CF_ACCESS_CLIENT_SECRET;
  } else fail("credentials_required", 3);
  async function call(path, init = {}) {
    let response;
    try {
      response = await fetch(new URL(path, base), {
        ...init,
        headers: { ...headers, ...init.headers },
        redirect: "manual",
        signal: AbortSignal.timeout(3e4)
      });
    } catch {
      fail("connection_failed", 5);
    }
    if (response.status >= 300 && response.status < 400)
      fail("access_login_required", 3);
    if (!response.ok) {
      let data = { error: "request_failed" };
      try {
        data = await response.json();
      } catch {
      }
      throw new CliError(
        [401, 403].includes(response.status) ? 3 : response.status === 409 ? 4 : response.status >= 500 ? 5 : 1,
        { ...data, httpStatus: response.status }
      );
    }
    return response;
  }
  async function api(path, init = {}) {
    const response = await call(path, init);
    if (!response.headers.get("Content-Type")?.includes("application/json"))
      fail("unexpected_response", 3);
    try {
      return await response.json();
    } catch {
      fail("invalid_response", 5);
    }
  }
  async function resolve(value) {
    if (!value) fail("artifact_required");
    if (/^[0-9a-f-]{36}$/.test(value))
      return (await api("/v1/artifacts/" + value)).artifact;
    const data = await api(
      "/v1/artifacts?slug=" + encodeURIComponent(value.toLowerCase())
    );
    if (data.artifacts.length !== 1) fail("artifact_not_found");
    return data.artifacts[0];
  }
  const [command, argument, third] = positionals;
  let result;
  if (command === "doctor") {
    const data = await api("/v1/me");
    if (!data.principal || !["agent", "human"].includes(data.principal.kind) || typeof data.principal.id !== "string")
      fail("invalid_response", 5);
    result = {
      status: "ok",
      baseUrl: base.origin,
      nodeVersion: process.versions.node,
      authentication: process.env.ART_ACCESS_JWT ? "jwt" : "service-token",
      principal: data.principal
    };
  } else if (command === "list") {
    const params = new URLSearchParams();
    for (const k of ["query", "limit", "cursor"])
      if (opt(k)) params.set(k, opt(k));
    const tags = values.tag;
    if (tags?.length) {
      if (tags.length > 1) fail("list_accepts_one_tag");
      params.set("tag", tags[0]);
    }
    result = await api("/v1/artifacts?" + params);
  } else if (command === "upload") {
    if (!argument) fail("file_required");
    if ((await stat(argument)).size > 10 * 1024 * 1024) fail("body_too_large");
    const html = await readFile(argument);
    if (opt("artifact") && opt("slug") || !opt("artifact") && !opt("slug"))
      fail("choose_new_slug_or_existing_artifact");
    let artifact, revision;
    if (opt("slug")) {
      if (!opt("title")) fail("title_required");
      artifact = (await api("/v1/artifacts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          slug: opt("slug"),
          title: opt("title"),
          tags: values.tag ?? []
        })
      })).artifact;
      revision = "0";
    } else {
      if (!opt("expected-revision")) fail("expected_revision_required");
      artifact = await resolve(opt("artifact"));
      revision = opt("expected-revision");
    }
    const params = new URLSearchParams({ expectedRevision: revision });
    if (opt("base-version")) params.set("baseVersionId", opt("base-version"));
    if (opt("message")) params.set("message", opt("message"));
    const requestId = opt("request-id") ?? randomUUID();
    try {
      result = await api(`/v1/artifacts/${artifact.id}/versions?${params}`, {
        method: "POST",
        headers: {
          "Content-Type": "text/html; charset=utf-8",
          "Idempotency-Key": requestId
        },
        body: html
      });
      result.requestId = requestId;
      result.url = new URL("/a/" + artifact.slug, base).href;
      result.versionUrl = new URL(
        `/a/${artifact.slug}/versions/${result.version.id}`,
        base
      ).href;
    } catch (error) {
      if (error instanceof CliError) {
        error.data.requestId = requestId;
        error.data.artifactId = artifact.id;
      }
      throw error;
    }
  } else if (["read", "download", "inspect", "versions", "comments"].includes(command)) {
    const artifact = await resolve(command === "comments" ? third : argument), id = artifact.id;
    if (command === "comments" && argument !== "list")
      fail("comments_list_required");
    const params = new URLSearchParams();
    for (const k of ["limit", "cursor", "status"])
      if (opt(k)) params.set(k, opt(k));
    params.set("version", opt("version") ?? "current");
    if (command === "inspect")
      result = await api(`/v1/artifacts/${id}/inspect?${params}`);
    else if (command === "comments")
      result = await api(`/v1/artifacts/${id}/threads?${params}`);
    else if (command === "versions") {
      params.delete("version");
      result = await api(`/v1/artifacts/${id}/versions?${params}`);
    } else {
      const versionId = opt("version") && opt("version") !== "current" ? opt("version") : artifact.currentVersionId;
      if (!versionId) fail("version_not_found");
      const response = await call(
        `/v1/artifacts/${id}/versions/${versionId}/content`
      );
      let bytes;
      try {
        bytes = new Uint8Array(await response.arrayBuffer());
      } catch {
        fail("connection_failed", 5);
      }
      const hash = createHash("sha256").update(bytes).digest("hex");
      if (hash !== response.headers.get("X-Content-SHA256"))
        fail("content_hash_mismatch", 6);
      if (command === "download") {
        if (!opt("output")) fail("output_required");
        await writeFile(opt("output"), bytes, {
          flag: values.force ? "w" : "wx"
        });
        result = {
          artifactId: id,
          versionId,
          sha256: hash,
          byteSize: bytes.length,
          output: opt("output")
        };
      } else if (asJson)
        result = {
          artifactId: id,
          versionId,
          revision: artifact.revision,
          sha256: hash,
          html: new TextDecoder().decode(bytes)
        };
      else {
        process.stdout.write(bytes);
        return;
      }
    }
  } else fail("unknown_command");
  console.log(JSON.stringify(result, null, asJson ? void 0 : 2));
}
run().catch((error) => {
  const data = error instanceof CliError ? error.data : { error: "invalid_input_or_file" };
  if (asJson) console.log(JSON.stringify(data));
  else console.error(String(data.error));
  process.exitCode = error instanceof CliError ? error.code : 1;
});
