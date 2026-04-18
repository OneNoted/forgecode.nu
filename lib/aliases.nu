export def normalize-alias [action?: string] {
  if $action == null { return null }
  match $action {
    'ask' => 'sage'
    'plan' => 'muse'
    'n' => 'new'
    'i' => 'info'
    'd' => 'dump'
    'r' => 'retry'
    'a' => 'agent'
    'c' => 'conversation'
    'cm' => 'config-model'
    'm' => 'model'
    'cr' => 'config-reload'
    'mr' => 'config-reload'
    're' => 'reasoning-effort'
    'cre' => 'config-reasoning-effort'
    'ccm' => 'config-commit-model'
    'csm' => 'config-suggest-model'
    't' => 'tools'
    'env' => 'config'
    'e' => 'config'
    'ce' => 'config-edit'
    'ed' => 'edit'
    's' => 'suggest'
    'rn' => 'rename'
    'sync' => 'workspace-sync'
    'sync-init' => 'workspace-init'
    'sync-status' => 'workspace-status'
    'sync-info' => 'workspace-info'
    'provider' => 'provider-login'
    'login' => 'provider-login'
    _ => $action
  }
}

export def builtins [] {
  [
    new info dump compact retry help doctor
    agent conversation clone copy rename conversation-rename
    config-model model config-reload reasoning-effort config-reasoning-effort config-commit-model config-suggest-model
    tools config config-edit skill
    edit suggest commit commit-preview
    workspace-sync workspace-init workspace-status workspace-info
    provider-login logout
  ]
}
