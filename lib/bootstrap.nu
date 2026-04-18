use ./state.nu *
use ./hooks.nu *
use ./prompt.nu *

export def --env install-keybindings [] {
  if ($env.FORGE_NU_KEYBINDINGS_INSTALLED? | default false) {
    return
  }

  let current = ($env.config.keybindings | default [])
  let filtered = ($current | where {|binding| (($binding.name? | default '') != 'forge_enter_dispatch') })
  let extra = [{
    name: 'forge_enter_dispatch'
    modifier: 'none'
    keycode: 'enter'
    mode: ['emacs' 'vi_insert']
    event: { send: 'executehostcommand', cmd: '__forge_enter' }
  }]
  $env.config = ($env.config | upsert keybindings ($filtered ++ $extra))
  $env.FORGE_NU_KEYBINDINGS_INSTALLED = true
}

export def --env forgecode-activate [] {
  ensure-state | ignore
  install-keybindings
  install-hooks
  install-prompt
}
