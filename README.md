# forgecode.nu

A Nushell-native Forge shell plugin that ports the `:` workflow from the upstream zsh/fish plugins into Nu.

## What this ships

- `forgecode.nu` entrypoint that activates the plugin when loaded
- modular Nu implementation under `lib/`
- Enter interception for `:` commands via `ExecuteHostCommand`
- command/file completion helpers for `:command` and `@[file]`
- session state for active agent, conversation, prompt, and terminal context
- Nu-native diagnostics via `:doctor`
- stub-backed tests plus PTY smoke coverage

## Load during development

```nu
use /absolute/path/to/forgecode.nu *
```

For a persistent local install, place `forgecode.nu` in a Nushell autoload directory and load it from `config.nu`.

## Environment

- `FORGE_BIN` — path to the Forge binary, defaults to `forge`
- `FORGE_NU_PROMPT` — enable the composed right prompt when truthy
- `FORGE_TERM` — enable recent-terminal-context capture, defaults to `true`
- `FORGE_TERM_MAX_COMMANDS` — ring buffer size for terminal context, defaults to `5`

## Command grammar

- `: hello world` — send prompt text with the active/default agent
- `:sage hello world` — send prompt text with an explicit agent
- `:sage` — switch the active agent
- `:new`, `:info`, `:doctor`, `:agent sage`, `:suggest list files`, etc.
- `@[path]` tagging is supported by the shipped completion helpers

## Current Tab status

Interactive Tab takeover is intentionally **not** enabled in this first pass so the plugin does not clobber a user's existing Nushell completion behavior. The repo ships the completion helper logic and tests for it, but the live Tab binding remains a documented follow-up item.

## Verification

```bash
bash scripts/test-nu-plugin.sh
bash scripts/run-nu-matrix.sh ENV-NU-1
python3 tests/pty_smoke.py
```

## Current status

This repository contains the first implementation pass described by the PRD and test spec, with the interactive Tab binding left as an explicit known difference. See `docs/PARITY_MATRIX.md`, `docs/KNOWN_DIFFERENCES.md`, and `docs/TRACEABILITY_MATRIX.md` for coverage details.
