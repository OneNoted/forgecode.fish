source (path dirname (status filename))/test_support.fish
setup_forge_test_env

assert_eq 0 (stub_log_count) 'plugin load should not shell out eagerly'
assert_eq forge (__forge_get_active_agent) 'default active agent'

__forge_state_set _FORGE_SESSION_MODEL gpt-5-mini
assert_eq gpt-5-mini (__forge_state_get _FORGE_SESSION_MODEL) 'state set/get works'

set -g _FORGE_TERM_COMMANDS 'ls -la' 'make test'
set -g _FORGE_TERM_EXIT_CODES 0 1
set -g _FORGE_TERM_TIMESTAMPS 10 20
set -g _FORGE_SESSION_PROVIDER openai
set -g _FORGE_SESSION_REASONING_EFFORT high
__forge_exec info >/dev/null

set -l exported_term_commands (stub_log_last_field env._FORGE_TERM_COMMANDS)
assert_contains "$exported_term_commands" 'ls -la' 'command context exported'
assert_eq openai (stub_log_last_field env.FORGE_SESSION__PROVIDER_ID) 'session provider exported'
assert_eq high (stub_log_last_field env.FORGE_REASONING__EFFORT) 'reasoning effort exported'

set -g _FORGE_TERM_MAX_COMMANDS 2
set -g _FORGE_TERM_PENDING_CMD alpha
set -g _FORGE_TERM_PENDING_TS 1
true
__forge_context_postexec
set -g _FORGE_TERM_PENDING_CMD beta
set -g _FORGE_TERM_PENDING_TS 2
true
__forge_context_postexec
set -g _FORGE_TERM_PENDING_CMD gamma
set -g _FORGE_TERM_PENDING_TS 3
true
__forge_context_postexec
assert_eq 2 (count $_FORGE_TERM_COMMANDS) 'ring buffer trims to max size'
assert_eq beta $_FORGE_TERM_COMMANDS[1] 'oldest item trimmed'

echo 'ok helpers'
