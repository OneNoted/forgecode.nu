use ./state.nu *
use ./exec.nu *

export def support-floor [] { '0.104.x+' }

export def doctor-report [] {
  let state = (get-state)
  let forge_path = (which (forge-bin) | get -o 0.path | default null)
  {
    nu_version: (version | get version)
    support_floor: (support-floor)
    forge_bin: (forge-bin)
    forge_bin_resolved: $forge_path
    forge_bin_available: ($forge_path != null)
    prompt_enabled: $state.prompt_enabled
    prompt_right_configured: ('PROMPT_COMMAND_RIGHT' in $env)
    keybindings_installed: ($env.FORGE_NU_KEYBINDINGS_INSTALLED? | default false)
    hooks_installed: ($env.FORGE_NU_HOOKS_INSTALLED? | default false)
    active_agent: $state.active_agent
    conversation_id: $state.conversation_id
    config_path: $nu.config-path
    env_path: $nu.env-path
    history_path: $nu.history-path
    vendor_autoload_dirs: $nu.vendor-autoload-dirs
    user_autoload_dirs: $nu.user-autoload-dirs
  }
}

export def doctor-lines [] {
  let report = (doctor-report)
  [
    $'forgecode.nu doctor'
    $'Nu version: ($report.nu_version)'
    $'Support floor: ($report.support_floor)'
    $'Forge binary: ($report.forge_bin)'
    $'Forge binary available: ($report.forge_bin_available)'
    $'Prompt enabled: ($report.prompt_enabled)'
    $'Right prompt configured: ($report.prompt_right_configured)'
    $'Keybindings installed: ($report.keybindings_installed)'
    $'Hooks installed: ($report.hooks_installed)'
    $'Active agent: ($report.active_agent)'
    $'Conversation id: (($report.conversation_id | default "none"))'
    $'Config path: ($report.config_path)'
    $'Env path: ($report.env_path)'
    $'History path: ($report.history_path)'
  ]
}

export def doctor-summary [] {
  doctor-lines | str join (char newline)
}
