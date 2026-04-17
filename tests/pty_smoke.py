#!/usr/bin/env python3
from __future__ import annotations

import errno
import json
import os
import pty
import select
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TMP = Path(tempfile.mkdtemp(prefix='forge-fish-pty-'))
LOG = TMP / 'log.jsonl'
STATE = TMP / 'state.json'
XDG = TMP / 'xdg'
XDG.mkdir(parents=True, exist_ok=True)
HIST_NAME = 'forge-pty'

for path in [LOG, STATE]:
    if path.exists():
        path.unlink()

env = os.environ.copy()
env.update({
    'FORGE_BIN': str(ROOT / 'tests' / 'stub-forge.py'),
    'FORGE_FZF_MOCK': '1',
    'FORGE_STUB_LOG': str(LOG),
    'FORGE_STUB_STATE': str(STATE),
    'XDG_DATA_HOME': str(XDG),
    'fish_history': HIST_NAME,
    'FORGE_DISABLE_BACKGROUND': '1',
    'FORGE_EDIT_DIR': str(TMP / 'edit'),
    'TERM': 'dumb',
})

pid, master = pty.fork()
if pid == 0:
    os.execvpe('fish', ['fish', '-i', '-C', f'source {ROOT / "conf.d" / "forgecode.fish"}'], env)


def read_until(marker: bytes, timeout: float = 5.0) -> bytes:
    end = time.time() + timeout
    buf = b''
    while time.time() < end:
        r, _, _ = select.select([master], [], [], 0.1)
        if not r:
            continue
        try:
            chunk = os.read(master, 4096)
        except OSError as exc:
            if exc.errno == errno.EIO:
                break
            raise
        if not chunk:
            break
        buf += chunk
        if marker in buf:
            break
    return buf


def send(data: str, marker: bytes = b'>', timeout: float = 4.0) -> bytes:
    os.write(master, data.encode())
    time.sleep(0.2)
    return read_until(marker, timeout)


def read_log_rows(timeout: float = 5.0) -> list[dict]:
    end = time.time() + timeout
    while time.time() < end:
        if LOG.exists() and LOG.read_text().strip():
            return [json.loads(line) for line in LOG.read_text().splitlines() if line.strip()]
        time.sleep(0.1)
    return []

startup = read_until(b'>', 8)
assert startup, 'fish did not start under pty'

out = send('echo hi\r', marker=b'hi')
assert b'hi' in out, out.decode(errors='ignore')

send(': hello from pty\r')
rows = read_log_rows()
assert any('-p' in row['argv'] for row in rows), rows

send(':sa\t\r')
send(': follow up\r')
rows = read_log_rows()
assert any(row.get('agent') == 'sage' and row.get('argv', [])[:1] == ['-p'] and 'follow up' in row.get('argv', []) for row in rows), rows

send(': review @REA\t\r')
rows = read_log_rows()
assert any('@[README.md]' in ' '.join(row['argv']) for row in rows), rows

send(':pty-history\r')
time.sleep(0.2)
send('history save\r')
time.sleep(0.2)
os.write(master, b'exit\r')
read_until(b'', 1)
os.close(master)
os.waitpid(pid, 0)

history_dir = XDG / 'fish'
assert history_dir.exists(), history_dir
history_files = list(history_dir.glob('*_history'))
assert history_files, history_dir
history_text = '\n'.join(path.read_text() for path in history_files)
assert ':pty-history' in history_text, history_text

print('ok pty')
