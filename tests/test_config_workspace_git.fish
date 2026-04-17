source (path dirname (status filename))/test_support.fish
setup_forge_test_env

set -gx FORGE_FZF_CHOICE 'GPT-5 Mini'
__forge_action_model '' >/dev/null
assert_eq config (stub_log_last_field argv.0) ':config-model hits config command'
assert_eq set (stub_log_last_field argv.1) ':config-model uses config set'
assert_eq model (stub_log_last_field argv.2) ':config-model writes model'

__forge_action_commit_model '' >/dev/null
assert_eq commit (stub_log_last_field argv.2) ':config-commit-model writes commit target'

__forge_action_suggest_model '' >/dev/null
assert_eq suggest (stub_log_last_field argv.2) ':config-suggest-model writes suggest target'
set -e FORGE_FZF_CHOICE

set -gx FORGE_FZF_CHOICE high
__forge_action_config_reasoning_effort '' >/dev/null
assert_eq reasoning-effort (stub_log_last_field argv.2) ':config-reasoning-effort writes reasoning config'
set -e FORGE_FZF_CHOICE

set -l config_output (__forge_action_config)
assert_contains "$config_output" '"model": "gpt-5-mini"' ':config lists current config'

set -gx FORGE_EDITOR_STUB_CONTENT 'provider = "openai"'
__forge_action_config_edit >/dev/null
assert_file_contains "$FORGE_STUB_CONFIG_PATH" 'provider = "openai"' ':config-edit writes config file'
set -e FORGE_EDITOR_STUB_CONTENT

set -l tools_output (__forge_action_tools)
assert_contains "$tools_output" 'tool-alpha' ':tools lists tools for active agent'
set -l skill_output (__forge_action_skill)
assert_contains "$skill_output" 'skill-a' ':skill lists skills'

__forge_action_sync_init >/dev/null
assert_eq init (stub_log_last_field argv.1) ':sync-init routes to workspace init'
__forge_action_sync_status >/dev/null
assert_eq status (stub_log_last_field argv.1) ':sync-status routes to workspace status'
__forge_action_sync_info >/dev/null
assert_eq info (stub_log_last_field argv.1) ':sync-info routes to workspace info'

__forge_action_commit 'extra context' >/dev/null
assert_eq commit (stub_log_last_field argv.0) ':commit uses commit subcommand'
assert_eq --max-diff (stub_log_last_field argv.1) ':commit forwards max diff flag'

echo 'ok config-workspace-git'
