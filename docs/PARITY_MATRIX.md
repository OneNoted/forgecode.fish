# Parity Matrix

## Core surfaces

| Surface | fish port status | Notes |
| --- | --- | --- |
| `: <prompt>` | shipped | routes through `__forge_action_default` |
| explicit agent prompt (`:sage`) | shipped | runtime command validation uses `forge list commands --porcelain` |
| agent switch (`:sage`) | shipped | empty prompt sets active agent only |
| `:new`, `:info`, `:dump`, `:compact`, `:retry`, `:help` | shipped | shell-local actions |
| `:conversation`, `:conversation -`, `:clone`, `:copy`, `:rename`, `:conversation-rename` | shipped | fish-native conversation actions |
| `:agent`, `:model`, `:config-model`, `:config-commit-model`, `:config-suggest-model`, `:reasoning-effort`, `:config-reload`, `:config`, `:config-edit`, `:tools`, `:skill` | shipped | session + persistent config helpers |
| `:login`, `:logout`, `:sync`, `:sync-init`, `:sync-status`, `:sync-info` | shipped | provider/workspace actions |
| `:edit`, `:suggest`, `:commit`, `:commit-preview` | shipped | editor + git helpers |
| `:` command picker | shipped | `__forge_complete_command` with query prefill + current-selection positioning |
| `@` file picker | shipped | `__forge_complete_file_ref` inserts `@[path]` |
| right prompt | shipped / opt-in | enabled only with `FORGE_FISH_PROMPT=1` |
| doctor/help entry | shipped | `:doctor`, `:help` |
| background sync/update | shipped | only after successful default prompt dispatch |
| bracketed paste auto-wrap | known difference | documented in `docs/KNOWN_DIFFERENCES.md` |
| custom inline highlighting parity | known difference | documented in `docs/KNOWN_DIFFERENCES.md` |

## Alias coverage

| Alias | Canonical command |
| --- | --- |
| `:ask` | `:sage` |
| `:plan` | `:muse` |
| `:n` | `:new` |
| `:c` | `:conversation` |
| `:r` | `:retry` |
| `:i` | `:info` |
| `:a` | `:agent` |
| `:d` | `:dump` |
| `:m` | `:model` |
| `:cm` | `:config-model` |
| `:cr`, `:mr` | `:config-reload` |
| `:re` | `:reasoning-effort` |
| `:cre` | `:config-reasoning-effort` |
| `:ccm` | `:config-commit-model` |
| `:csm` | `:config-suggest-model` |
| `:t` | `:tools` |
| `:e`, `:env` | `:config` |
| `:ce` | `:config-edit` |
| `:ed` | `:edit` |
| `:s` | `:suggest` |
| `:rn` | `:rename` |
| `:sync` | `:workspace-sync` |
| `:sync-init` | `:workspace-init` |
| `:sync-status` | `:workspace-status` |
| `:sync-info` | `:workspace-info` |
| `:login`, `:provider` | `:provider-login` |
