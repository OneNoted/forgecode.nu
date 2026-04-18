export def default-state [] {
  {
    active_agent: 'forge'
    conversation_id: null
    previous_conversation_id: null
    session_model: null
    session_reasoning_effort: null
    prompt_enabled: (env-bool 'FORGE_NU_PROMPT' false)
    term_enabled: (env-bool 'FORGE_TERM' true)
    term_max_commands: (env-int 'FORGE_TERM_MAX_COMMANDS' 5)
    term_commands: []
    term_exit_codes: []
    term_timestamps: []
    last_command: null
    last_exit_code: 0
    last_pwd: $env.PWD
    config_reloaded_at: null
  }
}

export def env-bool [name: string, default: bool] {
  if ($name in $env) {
    let raw = ($env | get $name | into string | str downcase)
    not ($raw in ['0' 'false' 'no' 'off' ''])
  } else {
    $default
  }
}

export def env-int [name: string, default: int] {
  if ($name in $env) {
    try { $env | get $name | into int } catch { $default }
  } else {
    $default
  }
}

export def ensure-state [] {
  if not ('FORGE_NU_STATE' in $env) {
    $env.FORGE_NU_STATE = (default-state)
  }
  $env.FORGE_NU_STATE
}

export def get-state [] {
  ensure-state
}

export def --env set-state [state: record] {
  $env.FORGE_NU_STATE = $state
}

export def --env update-state [updater: closure] {
  let current = (get-state)
  let next = (do $updater $current)
  $env.FORGE_NU_STATE = $next
  $next
}

export def get-active-agent [] { (get-state).active_agent }
export def get-conversation-id [] { (get-state).conversation_id }
export def get-previous-conversation-id [] { (get-state).previous_conversation_id }

export def --env set-active-agent [agent: string] {
  update-state {|state| $state | upsert active_agent $agent }
}

export def --env set-conversation-id [conversation_id?: string] {
  update-state {|state| $state | upsert conversation_id $conversation_id }
}

export def --env switch-conversation [conversation_id: string] {
  update-state {|state|
    let previous = if ($state.conversation_id != null and $state.conversation_id != $conversation_id) {
      $state.conversation_id
    } else {
      $state.previous_conversation_id
    }

    $state
    | upsert previous_conversation_id $previous
    | upsert conversation_id $conversation_id
  }
}

export def --env clear-conversation [] {
  update-state {|state|
    let previous = if $state.conversation_id != null { $state.conversation_id } else { $state.previous_conversation_id }
    $state
    | upsert previous_conversation_id $previous
    | upsert conversation_id null
  }
}

export def --env toggle-conversation [] {
  let state = (get-state)
  if $state.previous_conversation_id == null {
    return $state
  }

  let next = {
    ...$state
    conversation_id: $state.previous_conversation_id
    previous_conversation_id: $state.conversation_id
  }
  set-state $next
  $next
}

export def --env set-session-model [model?: string] {
  update-state {|state| $state | upsert session_model $model }
}


export def --env set-session-reasoning-effort [effort?: string] {
  update-state {|state| $state | upsert session_reasoning_effort $effort }
}

export def --env set-prompt-enabled [enabled: bool] {
  update-state {|state| $state | upsert prompt_enabled $enabled }
}

export def --env record-config-reload [] {
  update-state {|state| $state | upsert config_reloaded_at (date now) }
}

export def --env record-pre-execution [command: string] {
  update-state {|state| $state | upsert last_command $command }
}

export def --env record-post-prompt [] {
  let last_exit = ($env.LAST_EXIT_CODE? | default 0)
  update-state {|state|
    let term_commands = if ($state.term_enabled and $state.last_command != null and ($state.last_command | str trim | is-not-empty)) {
      (($state.term_commands | append $state.last_command) | last $state.term_max_commands)
    } else {
      $state.term_commands
    }
    let term_exit_codes = if ($state.term_enabled and $state.last_command != null and ($state.last_command | str trim | is-not-empty)) {
      (($state.term_exit_codes | append $last_exit) | last $state.term_max_commands)
    } else {
      $state.term_exit_codes
    }
    let term_timestamps = if ($state.term_enabled and $state.last_command != null and ($state.last_command | str trim | is-not-empty)) {
      (($state.term_timestamps | append ((date now) | format date '%s')) | last $state.term_max_commands)
    } else {
      $state.term_timestamps
    }

    $state
    | upsert last_exit_code $last_exit
    | upsert term_commands $term_commands
    | upsert term_exit_codes $term_exit_codes
    | upsert term_timestamps $term_timestamps
    | upsert last_command null
    | upsert last_pwd $env.PWD
  }
}
