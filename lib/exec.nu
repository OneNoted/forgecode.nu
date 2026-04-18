use ./state.nu *
use ./porcelain.nu *

export def forge-bin [] {
  $env.FORGE_BIN? | default 'forge'
}

export def unit-separator [] { char --integer 31 }

export def child-env [] {
  let state = (get-state)
  let sep = (unit-separator)
  mut extra = {}
  if $state.session_model != null {
    $extra = ($extra | upsert FORGE_SESSION__MODEL_ID $state.session_model)
  }
  if $state.session_reasoning_effort != null {
    $extra = ($extra | upsert FORGE_REASONING__EFFORT $state.session_reasoning_effort)
  }
  if ($state.term_enabled and (($state.term_commands | length) > 0)) {
    $extra = ($extra
      | upsert _FORGE_TERM_COMMANDS ($state.term_commands | str join $sep)
      | upsert _FORGE_TERM_EXIT_CODES ($state.term_exit_codes | each {|it| $it | into string } | str join $sep)
      | upsert _FORGE_TERM_TIMESTAMPS ($state.term_timestamps | each {|it| $it | into string } | str join $sep)
    )
  }
  $extra
}

export def forge-run-capture [...args: string] {
  with-env (child-env) {
    run-external (forge-bin) '--agent' (get-active-agent) ...$args | complete
  }
}

export def forge-run-lines [...args: string] {
  let result = (forge-run-capture ...$args)
  if $result.exit_code != 0 {
    error make {
      msg: $'forge command failed: ((forge-bin)) ($args | str join " ")'
      label: {
        text: ($result.stderr | default $result.stdout | str trim)
        span: { start: 0, end: 0 }
      }
    }
  }
  $result.stdout | default ''
}

export def forge-run-json [...args: string] {
  forge-run-lines ...$args | from json
}

export def forge-run-porcelain [...args: string] {
  let text = (forge-run-lines ...$args)
  parse-porcelain $text
}

export def forge-run [...args: string] {
  with-env (child-env) {
    run-external (forge-bin) '--agent' (get-active-agent) ...$args
  }
}

export def --env ensure-conversation-id [] {
  let current = (get-conversation-id)
  if $current != null {
    return $current
  }
  let new_id = (forge-run-lines conversation new | str trim)
  switch-conversation $new_id
  $new_id
}

export def get-command-catalog [] {
  forge-run-porcelain list commands '--porcelain'
}

export def get-agent-catalog [] {
  forge-run-porcelain list agents '--porcelain'
}
export def get-model-catalog [] {
  forge-run-porcelain list models '--porcelain'
}

export def get-file-catalog [] {
  forge-run-lines list files '--porcelain' | lines | where {|line| ($line | str trim | is-not-empty) }
}
