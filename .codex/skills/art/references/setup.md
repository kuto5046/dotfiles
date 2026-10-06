# Connection setup

## Interactive browser login (new PC / SSH host)

If doctor already succeeds, no additional login is needed. A phone browser's Access login authorizes that browser; it does not configure the agent's execution environment.

Install Node.js 22+ and [cloudflared](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/downloads/) on the machine where commands run. Then:

```sh
node "<skill-dir>/scripts/art.mjs" login --json
node "<skill-dir>/scripts/art.mjs" doctor --json
```

Login captures cloudflared's JWT output and emits only the authentication URL on stderr. Show that URL to the user, who can open it on their phone. Keep the command running until completion (default timeout 600 seconds; `--timeout` accepts 1–1800). JSON stdout contains the outcome, expiry and agent identity, never the JWT. Browser login requires HTTPS and the deployed `POST /v1/agent-sessions` API plus migration 0002.

After verified login, art issues a dedicated CLI session bound to the token fingerprint. The CLI sends both the Access token and `X-Art-Agent-Session`; the server verifies the binding and restricts these requests to agent operations. Invalid or expired CLI session IDs are rejected instead of falling back to human permissions. The token and session ID are saved per Control origin in `~/.config/art/sessions/` (directory 0700, files 0600 on Unix); `ART_SESSION_DIR` can choose another directory. Existing explicit JWT / Service Token credentials take priority over saved sessions. Login itself always performs browser authentication regardless of those explicit credentials.

Ordinary commands never open a browser or silently refresh the token. Expiry or rejection requires `login` again. The duration follows the existing Access application/policy settings; this implementation does not change them to seven days.

`logout --json` removes only art's saved session for the configured origin. It does not revoke the Access session, remove cloudflared's cache, or clear explicit credentials. cloudflared can reuse its own cached authentication on the next login.

Browser authentication retains user credentials in cloudflared's cache, including organization authentication. The CLI session does not make the entire machine a sandboxed agent identity: the underlying user token can still authorize human requests without the CLI session header. Use a Service Token for unattended jobs and when the execution environment must never hold human credentials. Browser requests without the CLI session header retain human permissions, including when the Access token is shared.

## Configuration contract

| Setting                   | Meaning                                                                       |
| ------------------------- | ----------------------------------------------------------------------------- |
| `ART_BASE_URL`            | Control origin; default `https://art-control.h27-kubb.workers.dev`            |
| `CF_ACCESS_CLIENT_ID`     | Environment's Access Service Token Client ID                                  |
| `CF_ACCESS_CLIENT_SECRET` | Service Token Secret                                                          |
| `ART_ACCESS_JWT`          | Optional short-lived verified Access JWT; takes precedence over Service Token |
| `ART_CONFIG_FILE`         | Optional absolute JSON configuration file path, outside the skill             |

Prefer the environment's secret store to inject the two Service Token variables. Do not install Cloudflare admin tokens, R2 keys or render signing keys. Do not print `env`, secret files, or shell traces. Base URLs must be HTTPS origins with no path, query or embedded credentials; loopback HTTP is accepted for a configured local demo.

If the user already has a trusted export-format env file, source it in the same shell that runs the launcher. Do not search broadly through secret directories. On the original art development PC, the repository's `.wrangler/deploy/production-agent.env` is the documented existing setting; that path is not available on other PCs and must not be copied into the skill.

## Optional persistent JSON file

The launcher supports `~/.config/art/config.json` on Windows, macOS and Linux, or a path selected by `ART_CONFIG_FILE`. These are the file's keys (values below are placeholders, not usable credentials):

```json
{
  "ART_BASE_URL": "https://art-control.h27-kubb.workers.dev",
  "CF_ACCESS_CLIENT_ID": "<Client ID>",
  "CF_ACCESS_CLIENT_SECRET": "<Client Secret>"
}
```

Create a config only using credentials provided through an authorized secret mechanism. Store it outside the project and skill directory, with user-only file permissions (0600 / directory 0700 on Unix; the user's private profile directory and an appropriate ACL on Windows). Do not overwrite existing configuration without reading its structure safely and preserving the intended server and credential choice. The launcher parses JSON and never executes the config as code.

Existing environment variables override JSON; an empty env value disables the corresponding file value. To replace an old JWT with Service Token authentication, clear `ART_ACCESS_JWT` in the environment and remove it from the config, or set its env value to empty. Do not use an expired JWT as a persistent connection method.

## Missing or rejected credentials

Run doctor with `--json` after changes. On exit 3, determine whether the settings are missing (`credentials_required`), Access requires login (`access_login_required`), or an identity is denied (`unauthorized` / `forbidden`). Do not automatically replace a legitimate explicit server configuration.

For an environment-specific Service Token, the administrator must:

1. Create a Token in Cloudflare Zero Trust Service credentials with an expiration.
2. Add it to the Control application's **Service Auth** policy.
3. Add its Client ID to `env.production.vars.ACCESS_AGENT_CLIENT_IDS` in `wrangler.control.jsonc`, retaining existing IDs, and deploy Control.
4. Configure the Client ID and Secret in the agent runtime's secret store and check doctor.

Access and the art allowlist both must permit the Token. If the user authorizes these administrative changes and appropriate management capabilities exist, perform them within that scope; otherwise request the missing administrator action. Existing-token CLI setup does not require redeployment. Token changes also change agent identity; retain the original identity when recovering its interrupted upload.

For exit 5, check the configured origin and runtime HTTPS egress. Use the execution environment's normal network approval mechanism if required, without weakening Access. Doctor checks authenticated `/v1/me`; it does not test storage writes.
