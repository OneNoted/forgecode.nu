use ./exec.nu *

export def token-at-cursor [buffer: string, cursor?: int] {
  let pos = ($cursor | default ($buffer | str length))
  let left = ($buffer | str substring (0..<$pos))
  let token = ($left | split row ' ' | last)
  {
    token: $token
    cursor: $pos
    left: $left
  }
}

export def completion-context [buffer: string, cursor?: int] {
  let token_info = (token-at-cursor $buffer $cursor)
  let token = $token_info.token
  if ($buffer | str starts-with ':') and ($token | str starts-with '@') {
    { kind: 'file', token: $token, cursor: $token_info.cursor }
  } else if (($buffer | str starts-with ':') and ($buffer | str trim | str contains ' ') == false) {
    { kind: 'command', token: ($token | str replace ':' ''), cursor: $token_info.cursor }
  } else {
    { kind: 'default', token: $token, cursor: $token_info.cursor }
  }
}

export def best-match [items: list<string>, query: string] {
  if ($items | is-empty) { return null }
  if ($query | str trim | is-empty) { return ($items | first) }
  ($items | where {|item| $item | str starts-with $query } | first)
}

export def apply-completion [buffer: string, completion: string, cursor?: int] {
  let pos = ($cursor | default ($buffer | str length))
  let left = ($buffer | str substring (0..<$pos))
  let right = ($buffer | str substring $pos..)
  let token = ($left | split row ' ' | last)
  let prefix = ($left | str substring (0..<(($left | str length) - ($token | str length))))
  { buffer: $'($prefix)($completion)($right)', cursor: (($prefix | str length) + ($completion | str length)) }
}

export def complete-command [buffer: string, cursor?: int] {
  let ctx = (completion-context $buffer $cursor)
  if $ctx.kind != 'command' { return null }
  let commands = (get-command-catalog | get command_name? | default [])
  let match = (best-match $commands $ctx.token)
  if $match == null { return null }
  apply-completion $buffer $':($match) ' $ctx.cursor
}

export def complete-file [buffer: string, cursor?: int] {
  let ctx = (completion-context $buffer $cursor)
  if $ctx.kind != 'file' { return null }
  let query = ($ctx.token | str replace '@' '' | str replace '[' '' | str replace ']' '')
  let files = (get-file-catalog)
  let match = (best-match $files $query)
  if $match == null { return null }
  apply-completion $buffer $'@[($match)]' $ctx.cursor
}

export def --env __forge_tab_complete [] {
  let buffer = (commandline)
  let cursor = (commandline get-cursor)
  let completed = (complete-file $buffer $cursor | default (complete-command $buffer $cursor))
  if $completed == null {
    return
  }
  commandline edit --replace $completed.buffer
  commandline set-cursor $completed.cursor
}
