# Traceability Matrix

This maps the implemented checks to the approved PRD/test-spec requirements.

| Requirement group | Evidence |
| --- | --- |
| FR-A1..A3 bootstrap/load laziness | `tests/test_helpers.fish`, `fish -ic 'source conf.d/forgecode.fish'` |
| FR-B1..B3 session state + exec env propagation | `tests/test_helpers.fish`, `tests/pty_smoke.py` |
| FR-C1..C7 dispatcher, aliases, history, background gating | `tests/test_dispatch.fish`, `tests/test_core_actions.fish`, `tests/pty_smoke.py` |
| FR-D1..D5 shell-local actions | `tests/test_core_actions.fish`, `tests/test_actions.fish`, `tests/test_config_workspace_git.fish` |
| FR-E1..E3 command/file completion + known paste gap | `tests/test_completion.fish`, `tests/test_known_differences.fish` |
| FR-F1..F3 prompt + lifecycle integration | `tests/test_prompt.fish`, `tests/test_prompt_states.fish`, `tests/pty_smoke.py` |
| FR-G1..G4 docs, parity matrix, doctor, support surfaces | `tests/test_docs.fish`, `tests/test_known_differences.fish`, `tests/test_actions.fish`, `docs/VERIFICATION_REPORT.md`, `scripts/run-fish-matrix.sh` |
| ENV-1 current Linux reference | `bash scripts/run-fish-matrix.sh ENV-1` |
| ENV-3 fish 3.6 compatibility | `bash scripts/run-fish-matrix.sh ENV-3` (Debian 12 Docker runner, PTY smoke accepted exception) |
| ENV-2 current macOS reference | accepted external verification exception in this Linux-only session; CI workflow prepared in `.github/workflows/fish-plugin-matrix.yml` |
