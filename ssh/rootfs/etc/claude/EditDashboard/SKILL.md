---
name: EditDashboard
description: Get/set Home Assistant Lovelace dashboard configs via the WebSocket API.
  USE when the user asks to edit, update, add, or remove anything on a dashboard.
  NEVER edit .storage/lovelace.* files directly — they will go stale.
---

# EditDashboard

Use `ha-dashboard` to safely read and write Lovelace dashboard configs through the HA WebSocket API — the same path the frontend uses. This avoids stale-data overwrites.

## One-Time Setup

A long-lived HA access token is required:

1. HA UI → Profile (bottom-left) → **Security** tab → **Long-Lived Access Tokens** → Create Token
2. Name it "Claude Dashboard API"
3. Copy the token and save it:
   ```bash
   echo "your_token_here" > /homeassistant/.claude/ha_token
   chmod 600 /homeassistant/.claude/ha_token
   ```

The token is then used automatically by all `ha-dashboard` calls.

## Commands

```bash
ha-dashboard list                   # List all dashboards (url_path + title)
ha-dashboard get <url_path>         # Print config JSON to stdout
ha-dashboard set <url_path>         # Read JSON from stdin and save to HA
```

## Known Dashboard URL Paths

| URL Path                  | Title               |
|---------------------------|---------------------|
| `dashboard-mobile`        | Mobile              |
| `dashboard-temperatures`  | Temperatures        |
| `map`                     | Map                 |

(Run `ha-dashboard list` to get the current authoritative list.)

## Workflow for Editing a Dashboard

Always follow this pattern — GET current config, modify, SET back:

```bash
# 1. Get current config
ha-dashboard get dashboard-mobile > /tmp/dashboard.json

# 2. Inspect it
python3 -m json.tool /tmp/dashboard.json | head -50

# 3. Make targeted edits to /tmp/dashboard.json using the Edit tool

# 4. Validate JSON before saving
python3 -m json.tool /tmp/dashboard.json > /dev/null && echo "JSON valid"

# 5. Save back to HA
ha-dashboard set dashboard-mobile < /tmp/dashboard.json
```

## Rules

- **Always GET first** — never construct a config from scratch or from a stale file read
- **Never write `.storage/lovelace.*` files directly** — HA's in-memory state won't update
- **Validate JSON** before calling `set` to avoid corrupting the dashboard
- Use a temp file (`/tmp/dashboard.json`) as the working copy
- After `set`, the change is live immediately — no reload needed
