use ../state.nu *
use ../exec.nu *
use ../doctor.nu *

export def --env action-new [input_text?: string] {
  clear-conversation
  set-active-agent 'forge'
  if $input_text == null {
    forge-run banner
    return { effect: 'clear' }
  }

  let cid = (ensure-conversation-id)
  forge-run '-p' $input_text '--cid' $cid
  { effect: 'clear' }
}

export def --env action-info [] {
  let cid = (get-conversation-id)
  if $cid == null {
    forge-run info
  } else {
    forge-run info '--cid' $cid
  }
  { effect: 'clear' }
}

export def --env require-active-conversation [subcommand: string, ...rest: string] {
  let cid = (get-conversation-id)
  if $cid == null {
    error make { msg: 'No active conversation. Start a conversation first or switch with :conversation.' }
  }
  forge-run conversation $subcommand $cid ...$rest
  { effect: 'clear' }
}

export def --env action-dump [kind?: string] {
  if $kind == 'html' {
    require-active-conversation dump '--html'
  } else {
    require-active-conversation dump
  }
}

export def --env action-compact [] { require-active-conversation compact }
export def --env action-retry [] { require-active-conversation retry }

export def --env action-help [] {
  forge-run list command
  { effect: 'clear' }
}

export def --env action-doctor [] {
  print (doctor-summary)
  { effect: 'clear' }
}
