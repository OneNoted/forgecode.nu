use ../exec.nu *

export def --env action-commit [additional_context?: string] {
  if $additional_context == null {
    forge-run commit
  } else {
    forge-run commit $additional_context
  }
  { effect: 'clear' }
}

export def --env action-commit-preview [additional_context?: string] {
  let message = if $additional_context == null {
    forge-run-lines commit '--preview' | str trim
  } else {
    forge-run-lines commit '--preview' $additional_context | str trim
  }
  { effect: 'set-buffer', buffer: $'git commit -m "($message | str replace -a '"' '\\"')"' }
}
