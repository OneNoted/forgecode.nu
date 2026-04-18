use ../state.nu *
use ../exec.nu *

export def --env action-agent [input_text?: string] {
  if $input_text == null {
    forge-run list agents '--porcelain'
    return { effect: 'clear' }
  }

  let agents = (get-agent-catalog | get agent_id? | default [])
  if $input_text not-in $agents {
    error make { msg: $'Agent not found: ($input_text)' }
  }
  set-active-agent $input_text
  { effect: 'clear' }
}

export def --env action-config-model [input_text?: string] {
  if $input_text == null {
    forge-run list models '--porcelain'
    return { effect: 'clear' }
  }
  forge-run config set model default $input_text
  { effect: 'clear' }
}

export def --env action-session-model [input_text?: string] {
  set-session-model $input_text
  { effect: 'clear' }
}

export def --env action-config-reload [] {
  record-config-reload
  forge-run config reload
  { effect: 'clear' }
}

export def --env action-reasoning-effort [input_text?: string] {
  set-session-reasoning-effort $input_text
  { effect: 'clear' }
}

export def --env action-config-reasoning-effort [input_text?: string] {
  forge-run config set reasoning-effort ($input_text | default '')
  { effect: 'clear' }
}

export def --env action-config-commit-model [input_text?: string] {
  if $input_text == null {
    forge-run list models '--porcelain'
    return { effect: 'clear' }
  }
  forge-run config set commit default $input_text
  { effect: 'clear' }
}

export def --env action-config-suggest-model [input_text?: string] {
  if $input_text == null {
    forge-run list models '--porcelain'
    return { effect: 'clear' }
  }
  forge-run config set suggest default $input_text
  { effect: 'clear' }
}

export def --env action-tools [] {
  forge-run tools
  { effect: 'clear' }
}

export def --env action-config [] {
  forge-run config get all
  { effect: 'clear' }
}

export def --env action-config-edit [] {
  forge-run config edit
  { effect: 'clear' }
}

export def --env action-skill [] {
  forge-run skill
  { effect: 'clear' }
}
