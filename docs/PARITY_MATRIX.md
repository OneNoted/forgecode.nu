# Parity Matrix

| Surface | Status | Notes |
| --- | --- | --- |
| Repo-local Nu entrypoint | shipped | `forgecode.nu` activates on load |
| Modular shell implementation | shipped | `lib/` mirrors upstream concern split |
| `: <prompt>` dispatch | shipped | creates conversation lazily and runs `forge -p ... --cid ...` |
| `:<agent> <prompt>` dispatch | shipped | validates agent/catalog first |
| `:<agent>` active-agent switch | shipped | stored in Nu session state |
| Core shell-local actions | shipped | `new`, `info`, `dump`, `compact`, `retry`, `help`, `doctor` |
| Conversation actions | shipped | `conversation`, `clone`, `copy`, `rename`, `conversation-rename` |
| Config/session actions | partial | session model + reasoning implemented; model/provider pickers still lightweight |
| Provider/workspace actions | shipped | login/logout/sync wrappers present |
| Editor/git actions | partial | `suggest`, `commit`, `commit-preview` implemented; editor action is a buffer stub |
| `@` file tagging helpers | shipped | helper functions + unit tests |
| Command completion helpers | shipped | catalog-backed prefix completion helpers |
| Interactive Tab takeover | deferred | deliberately not installed yet to avoid clobbering user completion |
| Right prompt | shipped | opt-in prompt summary composed with any existing right prompt |
| Recent terminal context env | shipped | `_FORGE_TERM_*` env vars exported to Forge children |
| Hook integration | shipped | `pre_execution`, `pre_prompt`, `env_change.PWD` |
| PTY Enter/history/context smoke | shipped | covered in `tests/pty_smoke.py` |
