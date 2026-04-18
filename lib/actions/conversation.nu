use ../state.nu *
use ../exec.nu *

export def --env action-conversation [input_text?: string] {
  if $input_text == '-' {
    let state = (toggle-conversation)
    if $state.conversation_id == null {
      return { effect: 'clear' }
    }
    forge-run conversation show $state.conversation_id
    forge-run conversation info $state.conversation_id
    return { effect: 'clear' }
  }

  if $input_text != null {
    switch-conversation $input_text
    forge-run conversation show $input_text
    forge-run conversation info $input_text
    return { effect: 'clear' }
  }

  forge-run conversation list '--porcelain'
  { effect: 'clear' }
}

export def --env action-clone [conversation_id?: string] {
  let target = if $conversation_id != null { $conversation_id } else { get-conversation-id }
  if $target == null {
    error make { msg: 'No active conversation to clone.' }
  }
  let new_id = (forge-run-lines conversation clone $target | str trim)
  switch-conversation $new_id
  forge-run conversation show $new_id
  { effect: 'clear' }
}

export def --env action-copy [] {
  let cid = (get-conversation-id)
  if $cid == null {
    error make { msg: 'No active conversation to copy from.' }
  }
  let content = (forge-run-lines conversation show '--md' $cid)
  print $content
  { effect: 'clear' }
}

export def --env action-rename [name: string] {
  let cid = (get-conversation-id)
  if $cid == null {
    error make { msg: 'No active conversation to rename.' }
  }
  forge-run conversation rename $cid $name
  { effect: 'clear' }
}

export def --env action-conversation-rename [conversation_id?, ...rest: string] {
  let cid = if $conversation_id != null { $conversation_id } else { get-conversation-id }
  if $cid == null {
    error make { msg: 'No active conversation to rename.' }
  }
  let name = ($rest | str join ' ')
  if ($name | str trim | is-empty) {
    error make { msg: 'Usage: :conversation-rename <id?> <name>' }
  }
  forge-run conversation rename $cid $name
  { effect: 'clear' }
}
