<h1 align="center">forgecode.fish</h1>

<p align="center">A fish-native Forge shell plugin.<br />Colon-prefixed prompts, agent switching, conversation continuity, tagged files, and an opt-in right prompt without falling back to zsh.</p>

<p align="center">
  <img alt="Status: alpha" src="https://img.shields.io/badge/status-alpha-f59e0b?style=flat-square" />
  <img alt="Platform: fish 3.6+ / 4.x" src="https://img.shields.io/badge/platform-fish%203.6%2B%20%2F%204.x-2563eb?style=flat-square" />
  <img alt="Verification: ENV-1 and ENV-3 executed" src="https://img.shields.io/badge/verification-ENV--1%20%2B%20ENV--3-0f766e?style=flat-square" />
  <img alt="Prompt: opt-in" src="https://img.shields.io/badge/prompt-opt--in-111827?style=flat-square" />
  <img alt="License: Apache-2.0" src="https://img.shields.io/badge/license-Apache--2.0-1d4ed8?style=flat-square" />
</p>

<p align="center">
  <a href="#install"><strong>Install</strong></a>
  ·
  <a href="#first-5-minutes"><strong>First 5 Minutes</strong></a>
  ·
  <a href="docs/PARITY_MATRIX.md"><strong>Parity Matrix</strong></a>
  ·
  <a href="docs/TRACEABILITY_MATRIX.md"><strong>Traceability</strong></a>
  ·
  <a href="docs/VERIFICATION_REPORT.md"><strong>Verification Report</strong></a>
</p>

forgecode.fish ports the approved Forge zsh workflow to fish using fish-native bindings, commandline mutation, completions, history handling, prompt hooks, and shell-local actions. The product goal is parity with the existing `:`-driven Forge workflow, not a fish-specific redesign.

The active implementation lives at the repo root. Planning artifacts under `.omx/plans/` remain in the repo as the contract and verification record for the port.

## What it does

- Turns `: <prompt>` into a Forge prompt dispatch path with conversation continuity.
- Supports explicit agent prompts (`:sage ...`, `:muse ...`) and agent switching via the same colon grammar.
- Keeps session-scoped agent, model, provider, and reasoning overrides inside the current fish session.
- Adds fish-native `:` command picking, `@` file tagging, provider/workspace helpers, editor helpers, and commit helpers.
- Exposes an opt-in right prompt plus fish-native `:doctor` and `:help` surfaces.
- Ships a deterministic stub-backed verification harness with Linux current-fish and fish 3.6.x coverage lanes.

## Install

### Prerequisites

You need:

- `forge`
- `fish` 3.6+
- `fzf`
- either `fd` or `fdfind`
- `python3` for the local verification harness

### Manual install

Copy the plugin directories into your fish config:

```bash
mkdir -p ~/.config/fish/conf.d ~/.config/fish/functions ~/.config/fish/completions
cp conf.d/forgecode.fish ~/.config/fish/conf.d/
cp functions/*.fish ~/.config/fish/functions/
cp completions/forge.fish ~/.config/fish/completions/
```

Open a new fish session or source the plugin directly:

```bash
source ~/.config/fish/conf.d/forgecode.fish
```

### Repo-local install for development

If you are working from this checkout, source the plugin from the repo root:

```bash
source conf.d/forgecode.fish
```

### Arch Linux (AUR)

AUR packaging lives under [`packaging/aur`](packaging/aur/README.md) and follows the same source-of-truth pattern used in the OneNoted desktop repos.

Planned package names:

```bash
yay -S forgecode-fish
# or track HEAD:
yay -S forgecode-fish-git
```

The current package assumptions and publish checklist are documented in [`packaging/aur/README.md`](packaging/aur/README.md).
The intended publish path is GitHub-driven: tracked metadata lives in this repo and `.github/workflows/aur.yml` pushes the matching package repo to AUR once the required secrets are configured.

### Prompt integration

Prompt integration is disabled by default.

Enable it for the current session:

```bash
set -gx FORGE_FISH_PROMPT 1
source conf.d/forgecode.fish
```

That keeps the default install path conservative and avoids taking over an existing fish prompt setup unless you explicitly opt in.

## First 5 Minutes

Source the plugin:

```bash
source conf.d/forgecode.fish
```

Try the core flow:

```bash
: hello from fish
:sage explain this repository
:agent
:new
:conversation
```

Try tagged files and session controls:

```bash
: review @[README.md]
:model
:reasoning-effort
:doctor
:help
```

Key workflow reminders:

- `: <prompt>` sends a prompt with the active agent.
- `:<agent> <prompt>` sends a prompt with an explicit agent.
- `:<agent>` with no prompt switches the active agent.
- `@` + `Tab` inserts `@[path]`.
- non-`:` commands fall through to normal fish execution.

## Verification

Run the full local suite:

```bash
bash scripts/test-fish-plugin.sh
```

Run the named environment lanes:

```bash
bash scripts/run-fish-matrix.sh ENV-1
bash scripts/run-fish-matrix.sh ENV-3
```

Current verification state:

- `ENV-1` — executed locally on Linux / fish 4.6.x
- `ENV-3` — executed in Debian 12 / fish 3.6.0 with an accepted PTY-smoke exception
- `ENV-2` — prepared as an external macOS verification lane and CI job, but not executed in this Linux-only session

## Documentation

- [Parity matrix](docs/PARITY_MATRIX.md)
- [Traceability matrix](docs/TRACEABILITY_MATRIX.md)
- [Known differences](docs/KNOWN_DIFFERENCES.md)
- [Verification report](docs/VERIFICATION_REPORT.md)

## Status

Alpha. The fish-native port is implemented and verified against the approved PRD/test-spec contract, with the remaining published exception being the external macOS verification lane.

## License

Apache-2.0. See [LICENSE](LICENSE).
