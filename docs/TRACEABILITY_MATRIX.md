# Traceability Matrix

| Requirement / Gate | Implementation | Verification |
| --- | --- | --- |
| Nu-native entrypoint and modular layout | `forgecode.nu`, `lib/*.nu`, `lib/actions/*.nu` | `nu -c 'use ./forgecode.nu *; print "load ok"'` |
| `:` default prompt dispatch | `lib/dispatch.nu::default-dispatch` | `tests/test_dispatch.nu`, `tests/pty_smoke.py` |
| explicit agent prompt and agent switch | `lib/dispatch.nu`, `lib/actions/config.nu` | `tests/test_dispatch.nu` |
| shell-local actions | `lib/actions/*.nu`, `lib/doctor.nu` | `tests/test_actions.nu`, `tests/pty_smoke.py` |
| Enter interception gate | `lib/bootstrap.nu`, `lib/dispatch.nu::__forge_enter` | `tests/pty_smoke.py` |
| history preservation gate | `lib/dispatch.nu::__forge_enter` + `history import` | `tests/pty_smoke.py` |
| terminal-context hook gate | `lib/hooks.nu`, `lib/state.nu`, `lib/exec.nu` | `tests/pty_smoke.py` |
| completion helper logic | `lib/complete.nu` | `tests/test_completion.nu` |
| live Tab takeover | deferred known difference | documented in `docs/KNOWN_DIFFERENCES.md` |
| prompt opt-in and composition | `lib/prompt.nu` | `tests/test_prompt.nu` |
| stubbed Forge harness | `tests/stub-forge.py` | `bash scripts/test-nu-plugin.sh` |
| local verification entrypoint | `scripts/test-nu-plugin.sh` | manual + CI-friendly |
| local Nu matrix lane | `scripts/run-nu-matrix.sh` | `bash scripts/run-nu-matrix.sh ENV-NU-1` |
