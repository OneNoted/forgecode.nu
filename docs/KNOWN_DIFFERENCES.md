# Known Differences

1. Interactive Tab takeover is intentionally deferred in the first pass. The plugin ships completion helper functions and tests, but it does not yet replace Nushell's live Tab binding.
2. Interactive pickers currently use deterministic prefix completion helpers instead of `fzf`-driven menus.
3. The `:edit` action currently seeds the Nu commandline buffer instead of opening `$EDITOR` in a temporary file workflow.
4. Prompt rendering is Nu-native and summary-based; it does not call the upstream `forge zsh rprompt` endpoint.
5. The first implementation pass emphasizes dispatcher parity, host-shell composition, and wrapper correctness over the full interactive picker UX from zsh/fish.
