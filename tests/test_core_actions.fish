source (path dirname (status filename))/test_support.fish
setup_forge_test_env

set -g _FORGE_ACTIVE_AGENT sage
set -g _FORGE_CONVERSATION_ID cid-0002
__forge_action_new '' >/dev/null
assert_eq forge $_FORGE_ACTIVE_AGENT ':new resets active agent'
assert_eq '' "$_FORGE_CONVERSATION_ID" ':new clears active conversation'

set -gx FORGE_DISABLE_BACKGROUND 0
set -gx FORGE_BACKGROUND_INLINE 1
__forge_action_new 'fresh start' >/dev/null
assert_eq cid-0003 $_FORGE_CONVERSATION_ID ':new <prompt> creates a new conversation'
assert_eq -p (stub_log_field_from_end 5 argv.0) ':new <prompt> dispatches prompt'
assert_eq 'fresh start' (stub_log_field_from_end 5 argv.1) ':new <prompt> forwards prompt text'
assert_eq workspace (stub_log_field_from_end 2 argv.0) ':new <prompt> background sync after success'
assert_eq update (stub_log_last_field argv.0) ':new <prompt> background update after success'
set -e FORGE_BACKGROUND_INLINE
set -gx FORGE_DISABLE_BACKGROUND 1

set -g _FORGE_CONVERSATION_ID cid-0001
set -l info_output (__forge_action_info)
assert_contains "$info_output" 'conversation=cid-0001' ':info uses current conversation'

set -l dump_output (__forge_action_dump '')
assert_contains "$dump_output" 'dump cid-0001' ':dump routes to conversation dump'
set -l html_output (__forge_action_dump 'html')
assert_contains "$html_output" '--html' ':dump html forwards html flag'

set -l compact_output (__forge_action_compact)
assert_contains "$compact_output" 'compacted cid-0001' ':compact routes to conversation compact'
set -l retry_output (__forge_action_retry)
assert_contains "$retry_output" 'retried cid-0001' ':retry routes to conversation retry'

set -l help_output (__forge_action_help)
assert_contains "$help_output" 'Forge fish plugin help' ':help renders fish help surface'

echo 'ok core-actions'
