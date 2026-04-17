#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

STATE_PATH = Path(os.environ.get('FORGE_STUB_STATE', '/tmp/forge-stub-state.json'))
LOG_PATH = Path(os.environ.get('FORGE_STUB_LOG', '/tmp/forge-stub-log.jsonl'))
CONFIG_PATH = Path(os.environ.get('FORGE_STUB_CONFIG_PATH', '/tmp/forge-test.toml'))


def default_state() -> dict:
    return {
        'next_conversation': 3,
        'current_model': 'gpt-5',
        'current_provider_id': 'openai',
        'current_provider_name': 'OpenAI',
        'reasoning_effort': 'medium',
        'commit_model': {'provider': 'openai', 'model': 'gpt-5-mini'},
        'suggest_model': {'provider': 'openai', 'model': 'gpt-5'},
        'workspace_initialized': True,
        'workspace_indexed': True,
        'conversations': {
            'cid-0001': {'name': 'Alpha', 'content': 'hello world', 'model': 'gpt-5', 'tokens': '321', 'cost': '1.23'},
            'cid-0002': {'name': 'Beta', 'content': 'second thread', 'model': 'gpt-5-mini', 'tokens': '99', 'cost': '0.42'},
        },
    }


def load_state() -> dict:
    if STATE_PATH.exists():
        return json.loads(STATE_PATH.read_text())
    state = default_state()
    save_state(state)
    return state


def save_state(state: dict) -> None:
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state, indent=2, sort_keys=True))


def log_call(argv: list[str], agent: str | None) -> None:
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        'argv': argv,
        'agent': agent,
        'cwd': os.getcwd(),
        'env': {k: os.environ.get(k, '') for k in [
            '_FORGE_TERM_COMMANDS',
            '_FORGE_TERM_EXIT_CODES',
            '_FORGE_TERM_TIMESTAMPS',
            'FORGE_SESSION__MODEL_ID',
            'FORGE_SESSION__PROVIDER_ID',
            'FORGE_REASONING__EFFORT',
        ]},
    }
    with LOG_PATH.open('a', encoding='utf-8') as fh:
        fh.write(json.dumps(payload) + '\n')


def porcelain(header: list[str], rows: list[list[str]]) -> str:
    widths = [len(item) for item in header]
    for row in rows:
        for i, value in enumerate(row):
            widths[i] = max(widths[i], len(str(value)))
    def fmt(row: list[str]) -> str:
        return '  '.join(str(v).ljust(widths[i]) for i, v in enumerate(row))
    return '\n'.join([fmt(header)] + [fmt(row) for row in rows])


def ensure_conv(state: dict, cid: str) -> dict:
    return state['conversations'].setdefault(cid, {'name': cid, 'content': '', 'model': state['current_model'], 'tokens': '0', 'cost': '0.00'})


def main() -> int:
    raw_args = sys.argv[1:]
    agent = None
    if raw_args[:2] == ['--agent', raw_args[1] if len(raw_args) > 1 else '']:
        agent = raw_args[1]
        raw_args = raw_args[2:]
    log_call(raw_args, agent)
    state = load_state()

    if os.environ.get('FORGE_STUB_WORKSPACE_INDEXED') == '0':
        state['workspace_indexed'] = False

    args = raw_args
    if not args:
        return 0

    if args == ['list', 'commands', '--porcelain']:
        print(porcelain(['COMMAND', 'TYPE', 'DESCRIPTION'], [
            ['forge', 'AGENT', 'Default agent'],
            ['sage', 'AGENT', 'Debugging specialist'],
            ['muse', 'AGENT', 'Planning specialist'],
            ['review', 'CUSTOM', 'Review current buffer'],
        ]))
        return 0

    if args == ['list', 'agents', '--porcelain']:
        print(porcelain(['ID', 'TITLE', 'TYPE', 'PROVIDER', 'MODEL', 'REASONING'], [
            ['forge', 'Default', 'AGENT', 'OpenAI', 'gpt-5', 'medium'],
            ['sage', 'Debugger', 'AGENT', 'OpenAI', 'gpt-5', 'high'],
            ['muse', 'Planner', 'AGENT', 'OpenAI', 'gpt-5-mini', 'high'],
        ]))
        return 0

    if args == ['list', 'models', '--porcelain']:
        print(porcelain(['MODEL_ID', 'NAME', 'PROVIDER', 'PROVIDER_ID', 'CONTEXT', 'TOOLS', 'IMAGE'], [
            ['gpt-5', 'GPT-5', 'OpenAI', 'openai', '200k', 'yes', 'yes'],
            ['gpt-5-mini', 'GPT-5 Mini', 'OpenAI', 'openai', '200k', 'yes', 'no'],
            ['sonnet', 'Sonnet', 'Anthropic', 'anthropic', '200k', 'yes', 'no'],
        ]))
        return 0

    if args == ['list', 'provider', '--porcelain']:
        print(porcelain(['DISPLAY', 'PROVIDER_ID', 'STATUS', 'TYPE'], [
            ['OpenAI', 'openai', 'yes', 'cloud'],
            ['Anthropic', 'anthropic', 'no', 'cloud'],
        ]))
        return 0

    if args == ['list', 'skill']:
        print('skill-a\nskill-b')
        return 0

    if args[:2] == ['list', 'tools']:
        print('tool-alpha\ntool-beta')
        return 0

    if args == ['list', 'files', '--porcelain']:
        if os.environ.get('FORGE_STUB_FAIL_LIST_FILES') == '1':
            return 1
        files = os.environ.get('FORGE_STUB_FILES', 'README.md:src/main.fish:docs/guide.md').split(':')
        print('PATH')
        print('\n'.join(files))
        return 0

    if args == ['banner']:
        print('FORGE BANNER')
        return 0

    if args[:2] == ['info', '--cid'] and len(args) >= 3:
        cid = args[2]
        conv = ensure_conv(state, cid)
        print(f"conversation={cid} model={conv['model']}")
        return 0

    if args == ['info']:
        print('forge info')
        return 0

    if args[:2] == ['update', '--no-confirm']:
        print('updated')
        return 0

    if args[:2] == ['conversation', 'new']:
        cid = f"cid-{state['next_conversation']:04d}"
        state['next_conversation'] += 1
        state['conversations'][cid] = {'name': f'Conversation {cid}', 'content': '', 'model': state['current_model'], 'tokens': '0', 'cost': '0.00'}
        save_state(state)
        print(cid)
        return 0

    if args[:3] == ['conversation', 'list', '--porcelain']:
        rows = [[cid, data['name'], data['model']] for cid, data in sorted(state['conversations'].items())]
        print(porcelain(['CID', 'NAME', 'MODEL'], rows))
        return 0

    if args[:3] == ['conversation', 'show', '--md'] and len(args) >= 4:
        cid = args[3]
        conv = ensure_conv(state, cid)
        print(conv['content'])
        return 0

    if args[:2] == ['conversation', 'show'] and len(args) >= 3:
        cid = args[2]
        conv = ensure_conv(state, cid)
        print(conv['content'])
        return 0

    if args[:2] == ['conversation', 'info'] and len(args) >= 3:
        cid = args[2]
        conv = ensure_conv(state, cid)
        print(porcelain(['KEY', 'VALUE'], [
            ['model', conv['model']],
            ['tokens', conv['tokens']],
            ['cost', conv['cost']],
        ]))
        return 0

    if args[:2] == ['conversation', 'clone'] and len(args) >= 3:
        src = ensure_conv(state, args[2])
        cid = f"cid-{state['next_conversation']:04d}"
        state['next_conversation'] += 1
        state['conversations'][cid] = dict(src)
        state['conversations'][cid]['name'] = src['name'] + ' clone'
        save_state(state)
        print(cid)
        return 0

    if args[:2] == ['conversation', 'rename'] and len(args) >= 4:
        cid = args[2]
        ensure_conv(state, cid)['name'] = ' '.join(args[3:])
        save_state(state)
        print(f'renamed {cid}')
        return 0

    if args[:2] == ['conversation', 'compact'] and len(args) >= 3:
        print(f'compacted {args[2]}')
        return 0

    if args[:2] == ['conversation', 'retry'] and len(args) >= 3:
        print(f'retried {args[2]}')
        return 0

    if args[:2] == ['conversation', 'dump'] and len(args) >= 3:
        suffix = ' '.join(args[3:])
        if suffix:
            print(f'dump {args[2]} {suffix}')
        else:
            print(f'dump {args[2]}')
        return 0

    if args[:2] == ['cmd', 'execute']:
        cid = args[args.index('--cid') + 1]
        command_name = args[args.index('--cid') + 2]
        payload = ' '.join(args[args.index('--cid') + 3:])
        conv = ensure_conv(state, cid)
        conv['content'] = f'cmd:{command_name} {payload}'.strip()
        save_state(state)
        print(conv['content'])
        return 0

    if '-p' in args:
        if os.environ.get('FORGE_STUB_FAIL_PROMPT') == '1':
            print('prompt failed', file=sys.stderr)
            return 1
        cid = args[args.index('--cid') + 1] if '--cid' in args else 'cid-0001'
        prompt = args[args.index('-p') + 1]
        conv = ensure_conv(state, cid)
        conv['content'] = prompt
        conv['model'] = os.environ.get('FORGE_SESSION__MODEL_ID', state['current_model'])
        conv['tokens'] = '321'
        conv['cost'] = '1.23'
        save_state(state)
        print(f'prompt:{prompt}')
        return 0

    if args[:2] == ['config', 'get'] and len(args) >= 3:
        key = args[2]
        if key == 'model':
            print(state['current_model'])
        elif key == 'provider':
            print(state['current_provider_name'])
        elif key == 'reasoning-effort':
            print(state['reasoning_effort'])
        elif key == 'commit':
            print(state['commit_model']['provider'])
            print(state['commit_model']['model'])
        elif key == 'suggest':
            print(state['suggest_model']['provider'])
            print(state['suggest_model']['model'])
        elif key == 'path':
            print(CONFIG_PATH)
        return 0

    if args[:2] == ['config', 'path']:
        print(CONFIG_PATH)
        return 0

    if args[:2] == ['config', 'list']:
        print(json.dumps({
            'model': state['current_model'],
            'provider': state['current_provider_name'],
            'reasoning': state['reasoning_effort'],
        }, indent=2))
        return 0

    if args[:3] == ['config', 'set', 'model'] and len(args) >= 5:
        state['current_provider_id'] = args[3]
        state['current_provider_name'] = 'OpenAI' if args[3] == 'openai' else 'Anthropic'
        state['current_model'] = args[4]
        save_state(state)
        print('ok')
        return 0

    if args[:3] == ['config', 'set', 'commit'] and len(args) >= 5:
        state['commit_model'] = {'provider': args[3], 'model': args[4]}
        save_state(state)
        print('ok')
        return 0

    if args[:3] == ['config', 'set', 'suggest'] and len(args) >= 5:
        state['suggest_model'] = {'provider': args[3], 'model': args[4]}
        save_state(state)
        print('ok')
        return 0

    if args[:3] == ['config', 'set', 'reasoning-effort'] and len(args) >= 4:
        state['reasoning_effort'] = args[3]
        save_state(state)
        print('ok')
        return 0

    if args[:2] == ['provider', 'login'] and len(args) >= 3:
        print(f'logged in {args[2]}')
        return 0

    if args[:2] == ['provider', 'logout'] and len(args) >= 3:
        print(f'logged out {args[2]}')
        return 0

    if args[:2] == ['workspace', 'info']:
        if not state['workspace_indexed']:
            return 1
        print('workspace indexed')
        return 0

    if args[:2] == ['workspace', 'sync']:
        print('workspace synced')
        return 0

    if args[:2] == ['workspace', 'init']:
        state['workspace_initialized'] = True
        state['workspace_indexed'] = True
        save_state(state)
        print('workspace initialized')
        return 0

    if args[:2] == ['workspace', 'status']:
        print('workspace status ok')
        return 0

    if args[:1] == ['suggest']:
        print(os.environ.get('FORGE_STUB_SUGGEST', 'ls -la'))
        return 0

    if args[:1] == ['commit']:
        print(os.environ.get('FORGE_STUB_COMMIT_MESSAGE', 'stub commit message'))
        return 0

    print(' '.join(args))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
