#!/usr/bin/env nu
$env.FORGE_BIN = ($env.FORGE_BIN? | default ($env.PWD | path join 'tests' 'stub-forge.py'))
$env.FORGE_STUB_LOG = ($env.FORGE_STUB_LOG? | default ($env.PWD | path join '.forge' 'completion-log.jsonl'))
$env.FORGE_STUB_STATE = ($env.FORGE_STUB_STATE? | default ($env.PWD | path join '.forge' 'completion-state.json'))

use ../forgecode.nu *
use ./test_lib.nu *

let command_ctx = (completion-context ':sa')
assert-eq $command_ctx.kind 'command' 'colon prefix should trigger command completion context'
assert-eq $command_ctx.token 'sa' 'command token should strip colon'

let file_ctx = (completion-context ': add @REA')
assert-eq $file_ctx.kind 'file' 'at-sign token should trigger file completion context'
assert-eq $file_ctx.token '@REA' 'file context should retain raw token'

let completed = (complete-command ':sa')
assert-eq $completed.buffer ':sage ' 'command completion should expand to matching command'

let completed_file = (complete-file ': note @REA')
assert-eq $completed_file.buffer ': note @[README.md]' 'file completion should wrap selected path in @[]'
print 'completion tests passed'
