source (path dirname (status filename))/test_support.fish
setup_forge_test_env

__forge_action_conversation cid-0002 >/dev/null
assert_eq cid-0002 $_FORGE_CONVERSATION_ID 'explicit conversation switch'
set -g _FORGE_PREVIOUS_CONVERSATION_ID cid-0001
__forge_action_conversation - >/dev/null
assert_eq cid-0001 $_FORGE_CONVERSATION_ID 'conversation dash toggles to previous conversation'
assert_eq cid-0002 $_FORGE_PREVIOUS_CONVERSATION_ID 'conversation dash swaps current and previous'

set -g _FORGE_CONVERSATION_ID cid-0002
set -e FORGE_FZF_CHOICE
__forge_action_conversation '' >/dev/null
assert_eq cid-0002 $_FORGE_CONVERSATION_ID 'conversation picker defaults to current conversation'

set -g _FORGE_ACTIVE_AGENT muse
__forge_action_agent '' >/dev/null
assert_eq muse $_FORGE_ACTIVE_AGENT 'agent picker defaults to current agent'

__forge_action_clone cid-0002 >/dev/null
assert_eq cid-0003 $_FORGE_CONVERSATION_ID 'clone switches to new conversation'

set -gx FORGE_FZF_CHOICE 'GPT-5 Mini'
__forge_action_session_model '' >/dev/null
assert_eq gpt-5-mini $_FORGE_SESSION_MODEL 'session model set from picker'
assert_eq openai $_FORGE_SESSION_PROVIDER 'session provider set from picker'
set -e FORGE_FZF_CHOICE

__forge_action_config_reload >/dev/null
assert_eq '' "$_FORGE_SESSION_MODEL" 'config reload clears session model'

set -gx FORGE_FZF_CHOICE high
__forge_action_reasoning_effort '' >/dev/null
assert_eq high $_FORGE_SESSION_REASONING_EFFORT 'session reasoning set'
set -e FORGE_FZF_CHOICE

set -gx FORGE_FZF_CHOICE OpenAI
__forge_action_login '' >/dev/null
assert_eq provider (stub_log_last_field argv.0) 'provider login route'
assert_eq login (stub_log_last_field argv.1) 'provider login subcommand'
__forge_action_logout '' >/dev/null
assert_eq logout (stub_log_last_field argv.1) 'provider logout subcommand'
set -e FORGE_FZF_CHOICE

__forge_action_sync >/dev/null
assert_eq workspace (stub_log_last_field argv.0) 'workspace sync route'
assert_eq sync (stub_log_last_field argv.1) 'workspace sync subcommand'

set -gx FORGE_EDITOR_STUB_CONTENT 'draft message'
__forge_action_editor '' >/dev/null
assert_eq ': draft message' $_FORGE_TEST_BUFFER 'editor populates buffer'
set -e FORGE_EDITOR_STUB_CONTENT

__forge_action_suggest 'list files' >/dev/null
assert_eq 'ls -la' $_FORGE_TEST_BUFFER 'suggest replaces buffer'

__forge_action_commit_preview '' >/dev/null
assert_contains $_FORGE_TEST_BUFFER 'git commit -' 'commit preview prepares git command'

__forge_switch_conversation cid-0001
__forge_action_copy >/dev/null
assert_file_contains "$FORGE_CLIPBOARD_FILE" 'hello world' 'copy writes clipboard file'

set -l doctor (__forge_doctor)
assert_contains "$doctor" 'forge' 'doctor reports forge'
assert_contains "$doctor" 'disabled' 'doctor reports prompt state'
assert_contains "$doctor" 'support_floor	ok' 'doctor validates fish support floor'

echo 'ok actions'
