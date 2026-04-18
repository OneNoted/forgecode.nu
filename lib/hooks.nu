use ./state.nu *

export def --env __forge_pre_execution [] {
  record-pre-execution (commandline)
}

export def --env __forge_pre_prompt [] {
  record-post-prompt
}

export def --env install-hooks [] {
  if ($env.FORGE_NU_HOOKS_INSTALLED? | default false) {
    return
  }

  let hooks = ($env.config.hooks | default { pre_prompt: [], pre_execution: [], env_change: {} })
  let pre_prompt = (($hooks.pre_prompt | default []) | append {|| __forge_pre_prompt })
  let pre_execution = (($hooks.pre_execution | default []) | append {|| __forge_pre_execution })
  let env_change = ($hooks.env_change | default {})
  let pwd_hooks = (($env_change.PWD? | default []) | append {|before, after| $env.FORGE_NU_STATE = (($env.FORGE_NU_STATE? | default (default-state)) | upsert last_pwd $after) })

  $env.config = ($env.config
    | upsert hooks.pre_prompt $pre_prompt
    | upsert hooks.pre_execution $pre_execution
    | upsert hooks.env_change.PWD $pwd_hooks
  )

  $env.FORGE_NU_HOOKS_INSTALLED = true
}
