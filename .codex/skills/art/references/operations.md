# art operations

Every example uses `node "<skill-dir>/scripts/art.mjs"`; substitute the installed absolute skill directory. CLI errors return JSON with `--json` and a nonzero exit code.

## Login and local logout

```sh
node "<skill-dir>/scripts/art.mjs" login --timeout 600 --json
node "<skill-dir>/scripts/art.mjs" doctor --json
node "<skill-dir>/scripts/art.mjs" logout --json
```

Only login launches cloudflared and waits for the user's browser authentication. Login URLs appear on stderr; final JSON appears on stdout. See [setup.md](setup.md) for prerequisites, storage, credential precedence and the scope of logout.

## Read and inspect

```sh
node "<skill-dir>/scripts/art.mjs" list --query '週次' --tag report --limit 20 --json
node "<skill-dir>/scripts/art.mjs" inspect weekly-report --json
node "<skill-dir>/scripts/art.mjs" read weekly-report --json
node "<skill-dir>/scripts/art.mjs" download weekly-report --output ./original.html --json
node "<skill-dir>/scripts/art.mjs" versions weekly-report --json
node "<skill-dir>/scripts/art.mjs" comments list weekly-report --version all --status open --json
```

Targets accept slug or UUID. `--version current` is the default; a version UUID selects a historical version. `read` without `--json` writes original HTML to stdout. Download verifies SHA-256 and refuses existing files; use `--force` only for an intended overwrite.

Inspect resolves current once and returns `html`, `threads`, `artifact.revision`, and `version.id`. Comments are fixed to their creation version; `otherVersionUnresolved` summarizes unresolved comments on other versions. Text anchors include `exact` and offsets; element anchors include a path, tag and label. Use these to understand the intended location rather than applying old offsets blindly to a new version.

Follow `nextCursor` with `--cursor` and the same filters. Inspect/list results may be paginated. Threads return the first 50 replies; if `nextCommentsCursor` is present, use authenticated `GET /v1/threads/:threadId/comments?cursor=...` to obtain the rest. Do not claim all feedback was considered until relevant pages have been read. If this uncommon direct API call is needed, load credentials with the same config/env rules as the launcher, send the same Access headers, use HTTPS and do not follow redirects with credentials or print headers. No CLI command currently exposes reply pagination.

## New upload

```sh
node "<skill-dir>/scripts/art.mjs" upload ./report.html \
  --slug weekly-report --title '週次レポート' --tag report \
  --request-id '<unique-key-for-this-operation>' --json
```

Choose a request ID before upload and retain it. Use separate keys for separate versions. The result includes artifact/version metadata, `revision`, `requestId`, fixed `url` and `versionUrl`. An existing slug returns 409 rather than overwriting.

## Revise after inspection

Save/edit the inspected HTML and supply the returned revision and version ID. The values below are illustrative:

```sh
node "<skill-dir>/scripts/art.mjs" upload ./report-v2.html \
  --artifact weekly-report --expected-revision 1 \
  --base-version '<inspect.version.id>' --message 'コメントを反映' \
  --request-id '<unique-key-for-this-revision>' --json
```

201 promotes the revision. A 409 `revision_conflict` can leave the uploaded version ready in history, but does not promote it. Re-inspect and reconcile the current content before a fresh upload. The user can manually select a saved version in the Web UI. Do not increment revision and overwrite intervening changes automatically.

## Recovery

On connection/storage failure, preserve the returned `artifactId` and `requestId` and resend with the same actor, file bytes, expected revision, base version, message and request ID. Retry a transient connection failure once; if it repeats, report recovery details and stop automatic retrying. Once an operation has a definitive success or conflict, reusing the request ID returns that result; it is not a new update.

An interrupted new upload may already have created an artifact. Do not repeat `--slug`; use its `artifactId` with `--artifact` and `--expected-revision 0`. If the creation response was lost, obtain a slug-exact result via authenticated `GET /v1/artifacts?slug=...` (not fuzzy search alone), or list candidates and compare their complete `slug` fields before deciding. Do not adopt an unrelated pre-existing artifact just because its slug matches; inspect history and the operation context. Preserve identity across recovery.

| Exit | Meaning                                                               |
| ---- | --------------------------------------------------------------------- |
| 0    | Success                                                               |
| 1    | Input, file or API request error; launcher config/runtime error       |
| 3    | Missing/invalid credentials, permission denied, Access login required |
| 4    | Slug, revision or idempotency conflict                                |
| 5    | Connection/server/response failure                                    |
| 6    | Content hash mismatch                                                 |

The user's art guide is available at `https://art-control.h27-kubb.workers.dev/a/art-agent-setup` after human Access login. It is a reference link, not a source of credentials.
