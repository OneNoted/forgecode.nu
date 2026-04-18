#!/usr/bin/env nu
$env.FORGE_BIN = ($env.FORGE_BIN? | default ($env.PWD | path join 'tests' 'stub-forge.py'))
$env.FORGE_STUB_LOG = ($env.FORGE_STUB_LOG? | default ($env.PWD | path join '.forge' 'actions-log.jsonl'))
$env.FORGE_STUB_STATE = ($env.FORGE_STUB_STATE? | default ($env.PWD | path join '.forge' 'actions-state.json'))

use ../forgecode.nu *
use ./test_lib.nu *

clear-stub
set-state (default-state)
dispatch-line ':doctor' | ignore
let report = (doctor-report)
assert-true (($report.nu_version | str length) > 0) 'doctor report should include Nu version'
assert-true ($report.config_path | str contains 'config.nu') 'doctor report should include config path'
assert-eq ((read-log) | length) 0 'Nu doctor should not invoke forge'

clear-stub
set-state (default-state)
dispatch-line ':agent sage' | ignore
assert-eq (get-active-agent) 'sage' 'agent action should set active agent'
let log2 = (read-log)
assert-contains ((($log2 | first | get argv) | str join ' ')) 'list agents --porcelain' 'agent action should validate against agent catalog'

clear-stub
set-state (default-state)
let suggested = (dispatch-line ':suggest list files')
assert-eq $suggested.effect 'set-buffer' 'suggest action should return a replacement buffer'
assert-eq $suggested.buffer 'echo list files' 'suggest action should populate buffer from stub result'

clear-stub
set-state (default-state)
set-conversation-id 'cid-999'
dispatch-line ':info' | ignore
let log3 = (read-log)
assert-contains ((($log3 | last | get argv) | str join ' ')) 'info --cid cid-999' 'info action should pass active conversation id'

print 'action tests passed'
