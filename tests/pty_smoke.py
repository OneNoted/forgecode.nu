#!/usr/bin/env python3
import json, os, pty, select, sqlite3, tempfile, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STUB = ROOT / 'tests' / 'stub-forge.py'
FORGE = ROOT / 'forgecode.nu'


def write_config(log_path, state_path, history_path, tab_marker=None):
    fd, path = tempfile.mkstemp(suffix='.nu', text=True)
    cfg = f"""
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true
$env.config.history.max_size = 50
$env.config.history.path = '{history_path}'
$env.FORGE_BIN = '{STUB}'
$env.FORGE_STUB_LOG = '{log_path}'
$env.FORGE_STUB_STATE = '{state_path}'
"""
    if tab_marker:
        cfg += "$env.config.keybindings ++= [{\n"
        cfg += "  name: user_tab_fallback\n"
        cfg += "  modifier: none\n"
        cfg += "  keycode: tab\n"
        cfg += "  mode: [emacs vi_insert]\n"
        cfg += f"  event: {{ send: executehostcommand, cmd: '^touch {tab_marker}' }}\n"
        cfg += "}]\n"
    cfg += f"use {FORGE} *\n"
    os.write(fd, cfg.encode())
    os.close(fd)
    return path


def read_until(fd, needle='', timeout=8.0):
    end = time.time() + timeout
    data = b''
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if not r:
            continue
        chunk = os.read(fd, 4096)
        if b'\x1b[6n' in chunk:
            os.write(fd, b'\x1b[1;1R')
        if not chunk:
            break
        data += chunk
        if needle and needle.encode() in data:
            break
    return data.decode(errors='ignore')


def send(fd, text):
    os.write(fd, text.encode())


def read_log(path):
    if not path.exists():
        return []
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def read_history(path):
    if not path.exists():
        return []
    con = sqlite3.connect(path)
    try:
        return [row[0] for row in con.execute('select command_line from history order by id')]
    finally:
        con.close()


def run_session(commands, with_tab_marker=False):
    with tempfile.TemporaryDirectory() as td:
        log = Path(td) / 'pty-log.jsonl'
        state = Path(td) / 'pty-state.json'
        history = Path(td) / 'history.sqlite3'
        marker = Path(td) / 'tab-fallback-hit'
        cfg = write_config(log, state, history, tab_marker=(marker if with_tab_marker else None))
        try:
            pid, fd = pty.fork()
            if pid == 0:
                os.execvp('nu', ['nu', '--config', cfg])
            try:
                output = read_until(fd, timeout=1.2)
                for command in commands:
                    send(fd, command)
                    time.sleep(1.0)
                    output += read_until(fd, timeout=1.0)
                output += read_until(fd, timeout=1.5)
                try:
                    os.kill(pid, 9)
                except ProcessLookupError:
                    pass
                try:
                    os.waitpid(pid, 0)
                except ChildProcessError:
                    pass
            finally:
                os.close(fd)
        finally:
            os.unlink(cfg)
        return {
            'output': output,
            'log': read_log(log),
            'history': read_history(history),
            'marker_exists': marker.exists(),
        }


def assert_true(value, message):
    if not value:
        raise AssertionError(message)


def main():
    prompt_session = run_session(['print 42\r', ': hello from pty\r'])
    assert_true(any('conversation' in ' '.join(entry['argv']) for entry in prompt_session['log']), 'colon input should create a conversation')
    prompt_calls = [entry for entry in prompt_session['log'] if '-p' in entry['argv']]
    assert_true(prompt_calls, 'colon input should dispatch prompt through plugin path')
    term_commands = prompt_calls[-1]['env'].get('_FORGE_TERM_COMMANDS', '')
    assert_true('print 42' in term_commands, 'terminal context should include recent non-colon command')
    assert_true(': hello from pty' in prompt_session['history'], 'raw colon input should be preserved in history')

    normal_session = run_session(['print 42\r'])
    assert_true('42' in normal_session['output'], 'non-colon input should execute normally')
    assert_true(normal_session['log'] == [], 'non-colon input should not invoke forge stub')

    tab_session = run_session(['xyz\t\r'], with_tab_marker=True)
    assert_true(tab_session['marker_exists'], 'plugin activation should preserve existing Tab behavior when Tab takeover is disabled')

    doctor_session = run_session([':doctor\r'])
    assert_true('forgecode.nu doctor' in doctor_session['output'], 'doctor action should print Nu-specific diagnostics')
    assert_true(doctor_session['log'] == [], 'doctor action should not invoke forge stub')
    print('pty smoke tests passed')


if __name__ == '__main__':
    main()
