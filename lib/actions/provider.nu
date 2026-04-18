use ../exec.nu *

export def --env action-login [provider?: string] {
  if $provider == null {
    forge-run list provider '--porcelain'
  } else {
    forge-run provider login $provider
  }
  { effect: 'clear' }
}

export def --env action-logout [provider?: string] {
  if $provider == null {
    forge-run provider logout
  } else {
    forge-run provider logout $provider
  }
  { effect: 'clear' }
}

export def --env action-sync [] {
  forge-run workspace sync '--init'
  { effect: 'clear' }
}

export def --env action-sync-init [] {
  forge-run workspace init
  { effect: 'clear' }
}

export def --env action-sync-status [] {
  forge-run workspace status .
  { effect: 'clear' }
}

export def --env action-sync-info [] {
  forge-run workspace info .
  { effect: 'clear' }
}
