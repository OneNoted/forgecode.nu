#!/usr/bin/env python3
import json, os, sys
from pathlib import Path

LOG = Path(os.environ.get('FORGE_STUB_LOG', Path.cwd() / '.forge' / 'stub-log.jsonl'))
STATE = Path(os.environ.get('FORGE_STUB_STATE', Path.cwd() / '.forge' / 'stub-state.json'))


def load_state():
    if STATE.exists():
        return json.loads(STATE.read_text())
    return {"conversation_counter": 0}


def save_state(state):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(state))


def log_call(argv):
    LOG.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "argv": argv,
        "cwd": os.getcwd(),
        "agent": next((argv[i + 1] for i, part in enumerate(argv[:-1]) if part == '--agent'), None),
        "env": {k: os.environ.get(k) for k in [
            'FORGE_SESSION__MODEL_ID', 'FORGE_SESSION__PROVIDER_ID', 'FORGE_REASONING__EFFORT',
            '_FORGE_TERM_COMMANDS', '_FORGE_TERM_EXIT_CODES', '_FORGE_TERM_TIMESTAMPS'
        ] if os.environ.get(k) is not None},
        "stdin_isatty": os.isatty(0),
        "stdout_isatty": os.isatty(1),
    }
    with LOG.open('a', encoding='utf-8') as fh:
        fh.write(json.dumps(payload) + '\n')


def porcelain(header, rows):
    out = ['  '.join(header)]
    for row in rows:
        out.append('  '.join(row))
    return '\n'.join(out)


def main(argv):
    if '--reset' in argv:
        if LOG.exists():
            LOG.unlink()
        if STATE.exists():
            STATE.unlink()
        return 0

    log_call(argv)
    filtered = argv[:]
    if filtered[:2] == ['--agent', filtered[1] if len(filtered) > 1 else None]:
        filtered = filtered[2:]
    elif filtered and filtered[0] == '--agent':
        filtered = filtered[2:]

    if not filtered:
        print('stub forge')
        return 0

    state = load_state()

    match filtered:
        case ['list', 'commands', '--porcelain']:
            print(porcelain(
                ['COMMAND_NAME', 'TYPE', 'DESCRIPTION'],
                [
                    ['sage', 'agent', 'Sage agent'],
                    ['muse', 'agent', 'Muse agent'],
                    ['customize', 'custom', 'Custom workflow'],
                    ['forge', 'agent', 'Default agent'],
                ],
            ))
        case ['list', 'agents', '--porcelain']:
            print(porcelain(
                ['AGENT_ID', 'TITLE', 'PROVIDER', 'MODEL'],
                [
                    ['forge', 'Forge', 'stub', 'default'],
                    ['sage', 'Sage', 'stub', 'reasoner'],
                    ['muse', 'Muse', 'stub', 'planner'],
                ],
            ))
        case ['list', 'models', '--porcelain']:
            print(porcelain(
                ['MODEL_ID', 'MODEL_NAME', 'PROVIDER', 'PROVIDER_ID'],
                [['default', 'Default', 'Stub', 'default'], ['reasoner', 'Reasoner', 'Stub', 'default']],
            ))
        case ['list', 'provider', '--porcelain']:
            print(porcelain(
                ['DISPLAY_NAME', 'PROVIDER_ID', 'STATUS'],
                [['Stub', 'default', 'yes']],
            ))
        case ['list', 'files', '--porcelain']:
            print('src/main.nu\ndocs/README.md\nREADME.md')
        case ['list', 'command']:
            print('help output')
        case ['conversation', 'new']:
            state['conversation_counter'] += 1
            save_state(state)
            print(f"cid-{state['conversation_counter']:03d}")
        case ['conversation', 'list', '--porcelain']:
            print(porcelain(['CONVERSATION_ID', 'TITLE'], [['cid-001', 'First'], ['cid-002', 'Second']]))
        case ['conversation', 'show', '--md', cid]:
            print(f'# Conversation {cid}\n\nLast assistant reply')
        case ['conversation', 'show', cid]:
            print(f'conversation:{cid}')
        case ['conversation', 'info', cid]:
            print(f'info:{cid}')
        case ['conversation', 'clone', cid]:
            state['conversation_counter'] += 1
            save_state(state)
            print(f"cid-{state['conversation_counter']:03d}")
        case ['conversation', 'rename', cid, *name]:
            print(f"renamed:{cid}:{' '.join(name)}")
        case ['conversation', 'dump', cid]:
            print(f'dump:{cid}')
        case ['conversation', 'dump', cid, '--html']:
            print(f'<html>{cid}</html>')
        case ['conversation', 'compact', cid]:
            print(f'compact:{cid}')
        case ['conversation', 'retry', cid]:
            print(f'retry:{cid}')
        case ['cmd', 'execute', '--cid', cid, command]:
            print(f'custom:{command}:{cid}')
        case ['cmd', 'execute', '--cid', cid, command, *rest]:
            print(f"custom:{command}:{cid}:{' '.join(rest)}")
        case ['-p', prompt, '--cid', cid]:
            print(f'prompt:{cid}:{prompt}')
        case ['info']:
            print('info:global')
        case ['info', '--cid', cid]:
            print(f'info:{cid}')
        case ['banner']:
            print('banner')
        case ['doctor']:
            print('doctor')
        case ['tools']:
            print('tools')
        case ['skill']:
            print('skill')
        case ['config', 'reload']:
            print('config reloaded')
        case ['config', 'get', 'all']:
            print('{"provider":"default"}')
        case ['config', 'edit']:
            print('config edit')
        case ['config', 'set', *rest]:
            print('config set ' + ' '.join(rest))
        case ['provider', 'login', provider]:
            print(f'provider login:{provider}')
        case ['provider', 'logout']:
            print('provider logout')
        case ['provider', 'logout', provider]:
            print(f'provider logout:{provider}')
        case ['workspace', 'sync', '--init']:
            print('workspace sync')
        case ['workspace', 'init']:
            print('workspace init')
        case ['workspace', 'status', '.']:
            print('workspace status')
        case ['workspace', 'info', '.']:
            print('workspace info')
        case ['suggest', *desc]:
            print('echo ' + ' '.join(desc))
        case ['commit', '--preview']:
            print('stub commit preview')
        case ['commit', '--preview', *rest]:
            print('stub commit preview ' + ' '.join(rest))
        case ['commit']:
            print('stub commit')
        case ['commit', *rest]:
            print('stub commit ' + ' '.join(rest))
        case ['update', '--no-confirm']:
            print('updated')
        case _:
            print('unhandled:' + ' '.join(filtered), file=sys.stderr)
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv[1:]))
