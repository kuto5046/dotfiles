# Connection setup

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
