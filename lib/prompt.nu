use ./state.nu *

export def forgecode-render-right-prompt [] {
  let state = (get-state)
  if not $state.prompt_enabled {
    return ''
  }

  let agent = $state.active_agent
  let model = ($state.session_model | default 'default')
  let cid = ($state.conversation_id | default 'new')
  let context = if (($state.term_commands | length) > 0) { $' cmds:(($state.term_commands | length))' } else { '' }
  $'forge:($agent) model:($model) cid:($cid)($context)'
}

export def render-right-fragment [fragment?] {
  if $fragment == null {
    return ''
  }

  let description = ($fragment | describe)
  if ($description | str contains 'closure') {
    do $fragment | into string
  } else {
    $fragment | into string
  }
}

export def compose-right-prompt [] {
  let forge = (forgecode-render-right-prompt)
  let original = (render-right-fragment ($env.FORGE_NU_PROMPT_RIGHT_ORIGINAL? | default null))
  if ($forge | is-empty) {
    return $original
  }
  if ($original | is-empty) {
    return $forge
  }
  $'($forge) ($original)'
}

export def --env install-prompt [] {
  let state = (get-state)
  if not $state.prompt_enabled {
    return
  }
  if not ('FORGE_NU_PROMPT_RIGHT_ORIGINAL' in $env) {
    $env.FORGE_NU_PROMPT_RIGHT_ORIGINAL = ($env.PROMPT_COMMAND_RIGHT? | default null)
  }
  $env.PROMPT_COMMAND_RIGHT = {|| compose-right-prompt }
}
