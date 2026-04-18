#!/usr/bin/env nu
use ../forgecode.nu *
use ./test_lib.nu *

set-state (default-state)
assert-eq (forgecode-render-right-prompt) '' 'prompt should be disabled by default'

$env.PROMPT_COMMAND_RIGHT = {|| 'existing-right'}
set-prompt-enabled true
let rendered = (forgecode-render-right-prompt)
assert-contains $rendered 'forge:forge' 'prompt should render agent when enabled'
install-prompt
assert-true ('PROMPT_COMMAND_RIGHT' in $env) 'prompt installer should register right prompt closure'
let rendered_from_env = (do $env.PROMPT_COMMAND_RIGHT)
assert-contains $rendered_from_env 'existing-right' 'prompt installer should compose with existing right prompt'
assert-contains $rendered_from_env 'forge:forge' 'prompt installer should include forge prompt fragment'
print 'prompt tests passed'
