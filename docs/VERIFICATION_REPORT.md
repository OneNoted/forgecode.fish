# Verification Report

## Automated checks run in this session
- `fish -ic 'source conf.d/forgecode.fish'`
- `fish -n conf.d/forgecode.fish functions/*.fish tests/*.fish`
- `python3 -m py_compile tests/stub-forge.py tests/pty_smoke.py`
- `bash scripts/test-fish-plugin.sh`
- `bash scripts/run-fish-matrix.sh ENV-1`
- `bash scripts/run-fish-matrix.sh ENV-3`

## Result
All executed checks pass in this session.

## Coverage summary
- Bootstrap/sourceability: `fish -ic` and `tests/test_helpers.fish`
- Dispatcher, alias parity, history, and background gating: `tests/test_dispatch.fish`, `tests/test_core_actions.fish`, `tests/pty_smoke.py`
- Shell-local actions: `tests/test_core_actions.fish`, `tests/test_actions.fish`, `tests/test_config_workspace_git.fish`
- Completion and tagged files: `tests/test_completion.fish`
- Prompt behavior and idle-state rendering: `tests/test_prompt.fish`, `tests/test_prompt_states.fish`
- Docs / parity / known differences: `tests/test_docs.fish`, `tests/test_known_differences.fish`
- Interactive PTY behavior (Enter/Tab/history): `tests/pty_smoke.py`

## Matrix execution
- **ENV-1** — executed on local Linux / fish 4.6.0 via `scripts/run-fish-matrix.sh ENV-1`
- **ENV-3** — executed in a Debian 12 Docker runner with fish 3.6.0 via `scripts/run-fish-matrix.sh ENV-3`
  - accepted exception: PTY smoke is skipped in the containerized compatibility runner because the fish 3.6 Docker environment is used as a non-interactive back-compat floor check; the full PTY smoke remains covered by ENV-1.
- **ENV-2** — accepted external verification exception for this Linux-only session
  - macOS current-fish coverage is wired in `.github/workflows/fish-plugin-matrix.yml`
  - the exact suite is runnable through `scripts/run-fish-matrix.sh ENV-2` on a macOS runner/session

## Remaining manual / external verification
- Execute ENV-2 on macOS to close the remaining external exception.
- Real provider login/editor integrations are still exercised with deterministic stubs rather than live backends.
