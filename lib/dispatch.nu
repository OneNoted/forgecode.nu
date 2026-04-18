use ./aliases.nu *
use ./state.nu *
use ./exec.nu *
use ./actions/core.nu *
use ./actions/conversation.nu *
use ./actions/config.nu *
use ./actions/provider.nu *
use ./actions/editor.nu *
use ./actions/git.nu *

export def parse-command-line [line: string] {
  if not ($line | str starts-with ':') {
    return { kind: 'normal', raw: $line }
  }

  if ($line | str starts-with ': ') {
    return { kind: 'default_prompt', action: null, input_text: ($line | str substring 2..), raw: $line }
  }

  let rest = ($line | str substring 1..)
  let parts = ($rest | split row ' ')
  let action = ($parts | first | default '' | str trim)
  let input_text = ($parts | skip 1 | str join ' ' | str trim)
  {
    kind: 'colon'
    action: (normalize-alias $action)
    input_text: (if ($input_text | is-empty) { null } else { $input_text })
    raw: $line
  }
}

export def command-known [action: string] {
  let builtins = (builtins)
  if $action in $builtins { return true }
  let agents = (get-agent-catalog | get agent_id? | default [])
  if $action in $agents { return true }
  let commands = (get-command-catalog)
  let names = ($commands | get command_name? | default [])
  $action in $names
}

export def command-type [action: string] {
  if $action in (builtins) {
    return 'builtin'
  }
  let agent = (get-agent-catalog | where agent_id == $action | first)
  if $agent != null { return 'agent' }
  let command = (get-command-catalog | where command_name == $action | first)
  if $command == null { return null }
  $command.type | str downcase
}

export def --env default-dispatch [action?, input_text?: string] {
  if $action != null and not (command-known $action) {
    error make { msg: $'Command not found: ($action)' }
  }

  let action_type = if $action == null { null } else { command-type $action }

  if $action != null and $action_type == 'custom' {
    let cid = (ensure-conversation-id)
    if $input_text == null {
      forge-run cmd execute '--cid' $cid $action
    } else {
      forge-run cmd execute '--cid' $cid $action $input_text
    }
    return { effect: 'clear' }
  }

  if $input_text == null {
    if $action != null and $action_type == 'agent' {
      set-active-agent $action
      return { effect: 'clear' }
    }
    if $action == null {
      return { effect: 'clear' }
    }
    error make { msg: $'Command not found: ($action)' }
  }

  let cid = (ensure-conversation-id)
  if $action != null {
    set-active-agent $action
  }
  forge-run '-p' $input_text '--cid' $cid
  { effect: 'clear' }
}

export def --env run-builtin [action: string, input_text?: string] {
  match $action {
    'new' => (action-new $input_text)
    'info' => (action-info)
    'dump' => (action-dump $input_text)
    'compact' => (action-compact)
    'retry' => (action-retry)
    'help' => (action-help)
    'doctor' => (action-doctor)
    'agent' => (action-agent $input_text)
    'conversation' => (action-conversation $input_text)
    'clone' => (action-clone $input_text)
    'copy' => (action-copy)
    'rename' => (if $input_text == null { error make { msg: 'Usage: :rename <name>' } } else { action-rename $input_text })
    'conversation-rename' => {
      let parts = ($input_text | default '' | split row ' ')
      let maybe_id = ($parts | first | default null)
      let rest = ($parts | skip 1)
      if (($rest | length) == 0) {
        action-conversation-rename null ...$parts
      } else {
        action-conversation-rename $maybe_id ...$rest
      }
    }
    'config-model' => (action-config-model $input_text)
    'model' => (action-session-model $input_text)
    'config-reload' => (action-config-reload)
    'reasoning-effort' => (action-reasoning-effort $input_text)
    'config-reasoning-effort' => (action-config-reasoning-effort $input_text)
    'config-commit-model' => (action-config-commit-model $input_text)
    'config-suggest-model' => (action-config-suggest-model $input_text)
    'tools' => (action-tools)
    'config' => (action-config)
    'config-edit' => (action-config-edit)
    'skill' => (action-skill)
    'edit' => (action-edit $input_text)
    'suggest' => (if $input_text == null { error make { msg: 'Usage: :suggest <description>' } } else { action-suggest $input_text })
    'commit' => (action-commit $input_text)
    'commit-preview' => (action-commit-preview $input_text)
    'workspace-sync' => (action-sync)
    'workspace-init' => (action-sync-init)
    'workspace-status' => (action-sync-status)
    'workspace-info' => (action-sync-info)
    'provider-login' => (action-login $input_text)
    'logout' => (action-logout $input_text)
    _ => (default-dispatch $action $input_text)
  }
}

export def --env dispatch-line [line: string] {
  let parsed = (parse-command-line $line)
  if $parsed.kind == 'normal' {
    return { effect: 'accept', buffer: $line }
  }
  if $parsed.kind == 'default_prompt' {
    return (default-dispatch null $parsed.input_text)
  }

  let action = $parsed.action
  if $action in (builtins) {
    return (run-builtin $action $parsed.input_text)
  }
  default-dispatch $action $parsed.input_text
}

export def --env __forge_enter [] {
  let buffer = (commandline)
  let result = (dispatch-line $buffer)
  if ($buffer | str starts-with ':') {
    echo $buffer | history import
  }
  match $result.effect {
    'accept' => { commandline edit --replace --accept $result.buffer }
    'set-buffer' => {
      commandline edit --replace $result.buffer
      commandline set-cursor ($result.buffer | str length)
    }
    _ => { commandline edit --replace '' }
  }
}
