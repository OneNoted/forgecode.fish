source (path dirname (status filename))/test_support.fish
setup_forge_test_env

set -gx FORGE_DISABLE_BACKGROUND 0
set -gx FORGE_BACKGROUND_INLINE 1
__forge_dispatch ': hello world' >/dev/null
assert_eq cid-0003 $_FORGE_CONVERSATION_ID 'conversation id assigned'
assert_eq -p (stub_log_field_from_end 5 argv.0) 'prompt dispatch flag'
assert_eq 'hello world' (stub_log_field_from_end 5 argv.1) 'prompt payload'
assert_eq --cid (stub_log_field_from_end 5 argv.2) 'prompt cid flag'
assert_eq cid-0003 (stub_log_field_from_end 5 argv.3) 'prompt cid value'
assert_eq forge (stub_log_field_from_end 5 agent) 'default agent used'
assert_eq workspace (stub_log_field_from_end 2 argv.0) 'background sync runs after successful prompt'
assert_eq update (stub_log_last_field argv.0) 'background update runs after successful prompt'

set -e FORGE_BACKGROUND_INLINE
set -gx FORGE_DISABLE_BACKGROUND 1
__forge_dispatch ':sage hello again' >/dev/null
assert_eq sage $_FORGE_ACTIVE_AGENT 'explicit agent prompt updates active agent'
assert_eq sage (stub_log_field_from_end 2 agent) 'explicit agent passed to forge'
assert_eq 'hello again' (stub_log_field_from_end 2 argv.1) 'explicit agent prompt payload'

set -l before (stub_log_count)
__forge_dispatch ':sage' >/dev/null
assert_eq sage $_FORGE_ACTIVE_AGENT 'agent switch without prompt'
assert_eq $before (stub_log_count) 'agent switch should not invoke forge prompt'

__forge_dispatch ':review check this' >/dev/null
assert_eq cmd (stub_log_field_from_end 2 argv.0) 'custom command dispatch uses cmd execute'
assert_eq execute (stub_log_field_from_end 2 argv.1) 'custom command execute subcommand'
assert_eq review (stub_log_field_from_end 2 argv.4) 'custom command name forwarded'

set -gx FORGE_DISABLE_BACKGROUND 0
set -gx FORGE_BACKGROUND_INLINE 1
set -gx FORGE_STUB_FAIL_PROMPT 1
set -g _FORGE_CONVERSATION_ID
set -l fail_before (stub_log_count)
__forge_dispatch ': prompt should fail' >/dev/null 2>/dev/null
set -l fail_after (stub_log_count)
assert_eq (math $fail_before + 3) $fail_after 'failed prompt should only create conversation and prompt attempt'
set -e FORGE_STUB_FAIL_PROMPT
set -e FORGE_BACKGROUND_INLINE
set -gx FORGE_DISABLE_BACKGROUND 1

set -l unknown_count (stub_log_count)
__forge_dispatch ':wat nope' >/dev/null
assert_eq $unknown_count (stub_log_count) 'unknown command rejected before shell-out'

assert_eq sage (__forge_alias_normalize ask) 'ask alias'
assert_eq muse (__forge_alias_normalize plan) 'plan alias'
assert_eq workspace-sync (__forge_alias_normalize sync) 'sync alias'
assert_eq suggest (__forge_alias_normalize s) 'suggest alias'

echo 'ok dispatch'
