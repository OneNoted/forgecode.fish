# forgecode.fish

A fish-shell port of the Forge shell workflow defined by the approved PRD and test spec in `.omx/plans/`.

## Features
- `:` prompt dispatch with active-agent continuity
- fish-native Enter and Tab handling for `:` commands and `@` file refs
- session-scoped agent / model / provider / reasoning overrides
- conversation, workspace, provider, editor, and git helper actions
- opt-in right prompt and fish-native `:doctor` / `:help`
- deterministic stub-backed test harness for parity verification

## Install

### Manual
1. Copy `conf.d/`, `functions/`, and `completions/` into a fish plugin directory.
2. Ensure `forge`, `fzf`, and either `fd` or `fdfind` are available.
3. Start a new fish session or `source conf.d/forgecode.fish`.

### Fisher-compatible
```
mkdir -p ~/.config/fish/functions ~/.config/fish/conf.d ~/.config/fish/completions
cp -R conf.d functions completions ~/.config/fish/
```

## Prompt integration
Prompt integration is disabled by default.

Enable it for the current session:
```
set -gx FORGE_FISH_PROMPT 1
source conf.d/forgecode.fish
```

## Key workflow
- `: <prompt>` — send a prompt with the active agent
- `:sage <prompt>` / `:muse <prompt>` — explicit agent prompt
- `:agent`, `:conversation`, `:model`, `:reasoning-effort` — session controls
- `:doctor`, `:help` — diagnostics and keyboard/help entry points
- `@` + `Tab` — insert tagged file refs as `@[path]`

## Verification
Run the full local suite:
```
bash scripts/test-fish-plugin.sh
```

## Docs
- `docs/PARITY_MATRIX.md`
- `docs/KNOWN_DIFFERENCES.md`
