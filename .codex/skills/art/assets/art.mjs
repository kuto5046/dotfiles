#!/usr/bin/env node

// src/cli/main.ts
import { parseArgs } from "node:util";
import { readFile as readFile2, writeFile as writeFile2, stat } from "node:fs/promises";
import { createHash as createHash2, randomUUID as randomUUID2 } from "node:crypto";

// src/cli/browser-auth.ts
import { spawn } from "node:child_process";
import {
  chmod,
  mkdir,
  readFile,
  rename,
  rm,
  writeFile
} from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { createHash, randomUUID } from "node:crypto";
var BrowserAuthError = class extends Error {
  code;
  constructor(code) {
    super(code);
    this.code = code;
  }
};
function sessionPath(base) {
  return join(
    process.env.ART_SESSION_DIR || join(homedir(), ".config", "art", "sessions"),
    createHash("sha256").update(base.origin).digest("hex") + ".json"
  );
}
function tokenExpiry(token) {
  try {
    if (!/^[\w-]+\.[\w-]+\.[\w-]+$/.test(token)) throw new Error();
    const payload = JSON.parse(
      Buffer.from(token.split(".")[1], "base64url").toString()
    );
    if (!Number.isSafeInteger(payload.exp) || payload.exp <= Date.now() / 1e3)
      throw new Error();
    return payload.exp;
  } catch {
    throw new BrowserAuthError("browser_session_expired");
  }
}
async function readSession(base) {
  let session;
  try {
    session = JSON.parse(await readFile(sessionPath(base), "utf8"));
  } catch (error) {
    if (error.code === "ENOENT") return void 0;
    throw new BrowserAuthError("invalid_browser_session");
  }
  if (!session || session.origin !== base.origin || typeof session.token !== "string" || typeof session.sessionId !== "string" || !/^[0-9a-f-]{36}$/.test(session.sessionId))
    throw new BrowserAuthError("invalid_browser_session");
  tokenExpiry(session.token);
  return { token: session.token, sessionId: session.sessionId };
}
async function saveSession(base, token, sessionId) {
  const path = sessionPath(base);
  await mkdir(dirname(path), { recursive: true, mode: 448 });
  await chmod(dirname(path), 448);
  const temporary = path + "." + randomUUID();
  try {
    await writeFile(
      temporary,
      JSON.stringify({ origin: base.origin, token, sessionId }),
      {
        mode: 384,
        flag: "wx"
      }
    );
    await rename(temporary, path);
  } finally {
    await rm(temporary, { force: true });
  }
}
async function deleteSession(base) {
  await rm(sessionPath(base), { force: true });
}
async function browserLogin(base, timeoutSeconds) {
  if (base.protocol !== "https:")
    throw new BrowserAuthError("browser_login_requires_https");
  return new Promise((resolve, reject) => {
    const child = spawn(
      "cloudflared",
      ["access", "login", "--app", base.origin],
      {
        stdio: ["ignore", "pipe", "pipe"],
        shell: false
      }
    );
    let stdout = "", pending = "", failure;
    const shown = /* @__PURE__ */ new Set();
    function line(value) {
      try {
        const url = new URL(value.trim());
        if (url.origin !== base.origin || url.pathname !== "/cdn-cgi/access/cli" || url.username || url.password || !url.searchParams.has("token"))
          return;
        if (!shown.has(url.href)) {
          shown.add(url.href);
          process.stderr.write(
            "Open this URL on your phone to sign in:\n" + url.href + "\n"
          );
        }
      } catch {
      }
    }
    const timer = setTimeout(() => {
      failure = "browser_login_timeout";
      child.kill("SIGKILL");
    }, timeoutSeconds * 1e3);
    const cancel = () => {
      failure = "browser_login_cancelled";
      child.kill("SIGKILL");
    };
    process.once("SIGINT", cancel);
    process.once("SIGTERM", cancel);
    function cleanup() {
      clearTimeout(timer);
      process.removeListener("SIGINT", cancel);
      process.removeListener("SIGTERM", cancel);
    }
    child.stdout.on("data", (data) => {
      stdout += data.toString();
      if (stdout.length > 65536) {
        failure = "invalid_cloudflared_output";
        child.kill("SIGKILL");
      }
    });
    child.stderr.on("data", (data) => {
      pending += data.toString();
      const lines = pending.split(/\r?\n/);
      pending = lines.pop();
      for (const value of lines) line(value);
      if (pending.length > 65536) {
        failure = "invalid_cloudflared_output";
        child.kill("SIGKILL");
      }
    });
    child.once("error", (error) => {
      cleanup();
      reject(
        new BrowserAuthError(
          error.code === "ENOENT" ? "cloudflared_required" : "browser_login_failed"
        )
      );
    });
    child.once("close", (code) => {
      cleanup();
      line(pending);
      if (failure || code !== 0)
        return reject(new BrowserAuthError(failure || "browser_login_failed"));
      const token = stdout.trim();
      try {
        tokenExpiry(token);
        resolve(token);
      } catch {
        reject(new BrowserAuthError("invalid_cloudflared_output"));
      }
    });
  });
}

// src/cli/main.ts
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
  "status",
  "timeout"
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
      "art login [--timeout <seconds>] [--json]\nart logout [--json]\nart doctor [--json]\nart upload <file> (--slug <new> --title <title> | --artifact <id-or-slug> --expected-revision <n>)\nart list [--query <text>] [--tag <tag>] [--limit <n>] [--cursor <cursor>]\nart read|download|inspect|versions <id-or-slug> [--version current|<id>]\nart download <id-or-slug> --output <file> [--force]\nart comments list <id-or-slug> [--version <id>] [--status open|resolved|all]\nAuthentication: ART_BASE_URL, CF_ACCESS_CLIENT_ID, CF_ACCESS_CLIENT_SECRET (or ART_ACCESS_JWT)\n--json emits machine-readable JSON. Exit codes: 0 success, 1 input, 3 auth, 4 conflict, 5 connection, 6 content hash."
    );
    return;
  }
  const base = new URL(process.env.ART_BASE_URL ?? "http://127.0.0.1:8787");
  if (base.username || base.password || base.search || base.hash || base.pathname !== "/" || base.protocol !== "https:" && !(base.protocol === "http:" && ["127.0.0.1", "localhost", "[::1]"].includes(base.hostname)))
    fail("invalid_base_url");
  const [command, argument, third] = positionals;
  if (command === "logout") {
    await deleteSession(base);
    console.log(
      JSON.stringify({
        status: "ok",
        baseUrl: base.origin,
        message: "Saved art session removed; cloudflared cache and explicit credentials are unchanged."
      })
    );
    return;
  }
  const headers = {};
  let authentication;
  let loginToken;
  if (command === "login") {
    const timeout = Number(opt("timeout") ?? 600);
    if (!Number.isInteger(timeout) || timeout < 1 || timeout > 1800)
      fail("invalid_login_timeout");
    loginToken = await browserLogin(base, timeout);
    headers["cf-access-token"] = loginToken;
    headers["Cf-Access-Jwt-Assertion"] = loginToken;
    authentication = "browser";
  } else if (process.env.ART_ACCESS_JWT) {
    headers["Cf-Access-Jwt-Assertion"] = process.env.ART_ACCESS_JWT;
    headers["cf-access-token"] = process.env.ART_ACCESS_JWT;
    authentication = "jwt";
  } else if (process.env.CF_ACCESS_CLIENT_ID && process.env.CF_ACCESS_CLIENT_SECRET) {
    headers["CF-Access-Client-Id"] = process.env.CF_ACCESS_CLIENT_ID;
    headers["CF-Access-Client-Secret"] = process.env.CF_ACCESS_CLIENT_SECRET;
    authentication = "service-token";
  } else {
    const session = await readSession(base);
    if (!session) fail("credentials_required", 3);
    headers["cf-access-token"] = session.token;
    headers["Cf-Access-Jwt-Assertion"] = session.token;
    headers["X-Art-Agent-Session"] = session.sessionId;
    authentication = "browser";
  }
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
      throw new CliError(3, {
        error: "access_login_required",
        action: "Run art login --json."
      });
    if (!response.ok) {
      let data = { error: "request_failed" };
      try {
        data = await response.json();
      } catch {
      }
      throw new CliError(
        [401, 403].includes(response.status) ? 3 : response.status === 409 ? 4 : response.status >= 500 ? 5 : 1,
        {
          ...data,
          httpStatus: response.status,
          ...authentication === "browser" && (response.status === 401 || data.error === "invalid_agent_session") ? { action: "Run art login --json." } : {}
        }
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
  let result;
  if (command === "login") {
    const data = await api("/v1/agent-sessions", { method: "POST" });
    if (data.principal?.kind !== "agent" || typeof data.sessionId !== "string" || !/^[0-9a-f-]{36}$/.test(data.sessionId))
      fail("agent_session_required", 3);
    await saveSession(base, loginToken, data.sessionId);
    result = {
      status: "ok",
      baseUrl: base.origin,
      authentication,
      principal: data.principal,
      expiresAt: new Date(tokenExpiry(loginToken) * 1e3).toISOString()
    };
  } else if (command === "doctor") {
    const data = await api("/v1/me");
    if (!data.principal || !["agent", "human"].includes(data.principal.kind) || typeof data.principal.id !== "string")
      fail("invalid_response", 5);
    if (authentication === "browser" && data.principal.kind !== "agent")
      fail("agent_session_required", 3);
    result = {
      status: "ok",
      baseUrl: base.origin,
      nodeVersion: process.versions.node,
      authentication,
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
    const html = await readFile2(argument);
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
    const requestId = opt("request-id") ?? randomUUID2();
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
      const hash = createHash2("sha256").update(bytes).digest("hex");
      if (hash !== response.headers.get("X-Content-SHA256"))
        fail("content_hash_mismatch", 6);
      if (command === "download") {
        if (!opt("output")) fail("output_required");
        await writeFile2(opt("output"), bytes, {
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
  const data = error instanceof CliError ? error.data : error instanceof BrowserAuthError ? {
    error: error.code,
    action: "Run art login --json (install cloudflared first if missing)."
  } : { error: "invalid_input_or_file" };
  if (asJson) console.log(JSON.stringify(data));
  else
    console.error([String(data.error), data.action].filter(Boolean).join("\n"));
  process.exitCode = error instanceof CliError ? error.code : error instanceof BrowserAuthError ? 3 : 1;
});
