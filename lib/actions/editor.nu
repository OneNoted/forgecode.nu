use ../exec.nu *

export def --env action-edit [initial_text?: string] {
  let content = $initial_text | default ''
  { effect: 'set-buffer', buffer: $': ($content)' }
}

export def --env action-suggest [description: string] {
  if ($description | str trim | is-empty) {
    error make { msg: 'Please provide a command description.' }
  }
  let command = (forge-run-lines suggest $description | str trim)
  { effect: 'set-buffer', buffer: $command }
}
