#!/usr/bin/env nu
$env.FORGE_BIN = ($env.FORGE_BIN? | default ($env.PWD | path join 'tests' 'stub-forge.py'))
$env.FORGE_STUB_LOG = ($env.FORGE_STUB_LOG? | default ($env.PWD | path join '.forge' 'dispatch-log.jsonl'))
$env.FORGE_STUB_STATE = ($env.FORGE_STUB_STATE? | default ($env.PWD | path join '.forge' 'dispatch-state.json'))

use ../forgecode.nu *
use ./test_lib.nu *

clear-stub
set-state (default-state)
let parsed_alias = (parse-command-line ':ask build the plan')
assert-eq $parsed_alias.action 'sage' 'ask alias should normalize to sage'

let first = (dispatch-line ': hello world')
assert-eq $first.effect 'clear' 'default prompt should clear buffer after dispatch'
assert-eq (get-conversation-id) 'cid-001' 'default prompt should create a conversation id'
let log1 = (read-log)
assert-eq ($log1 | length) 2 'default prompt should create conversation and send prompt'
assert-eq (($log1 | get 0 | get argv) | last) 'new' 'first call should create a conversation'
assert-eq (($log1 | get 1 | get argv) | last) 'cid-001' 'prompt dispatch should use the created conversation id'
assert-contains ((($log1 | get 1 | get argv) | str join ' ')) '-p hello world --cid cid-001' 'prompt dispatch should pass prompt text and cid'

clear-stub
set-state (default-state)
let second = (dispatch-line ':sage explain shell state')
assert-eq $second.effect 'clear' 'agent prompt should clear buffer after dispatch'
assert-eq (get-active-agent) 'sage' 'explicit agent prompt should switch active agent'
let log2 = (read-log)
assert-eq ($log2 | length) 4 'explicit agent prompt should validate catalogs, create a conversation, and send prompt'
assert-eq (($log2 | last | get agent) | default '') 'sage' 'explicit agent dispatch should use selected agent'

clear-stub
set-state (default-state)
let third = (dispatch-line ':sage')
assert-eq $third.effect 'clear' 'agent switch should clear buffer'
assert-eq (get-active-agent) 'sage' 'agent switch should update active agent'
assert-eq ((read-log) | length) 2 'agent switch should validate command and agent catalogs before switching'

clear-stub
set-state (default-state)
let err = (try { dispatch-line ':nope something'; null } catch {|e| $e.msg })
assert-contains $err 'Command not found' 'unknown command should fail locally'
assert-eq ((read-log) | length) 2 'unknown command should only inspect agent/command catalogs'

print 'dispatch tests passed'
