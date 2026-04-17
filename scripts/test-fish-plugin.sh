#!/usr/bin/env bash
set -euo pipefail

fish tests/test_helpers.fish
fish tests/test_dispatch.fish
fish tests/test_core_actions.fish
fish tests/test_actions.fish
fish tests/test_config_workspace_git.fish
fish tests/test_completion.fish
fish tests/test_prompt.fish
fish tests/test_prompt_states.fish
fish tests/test_docs.fish
fish tests/test_known_differences.fish

if [[ "${FORGE_SKIP_PTY:-0}" != "1" ]]; then
  python3 tests/pty_smoke.py
else
  echo "skip pty"
fi
