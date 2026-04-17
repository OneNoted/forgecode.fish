source (path dirname (status filename))/test_support.fish
setup_forge_test_env

assert_eq 0 $_FORGE_PROMPT_ENABLED 'prompt disabled by default'
__forge_enable_prompt
assert_eq 1 $_FORGE_PROMPT_ENABLED 'prompt enabled on request'

__forge_dispatch ': hello prompt' >/dev/null
set -l prompt (__forge_prompt_render)
assert_contains "$prompt" 'forge' 'prompt shows active agent'
assert_contains "$prompt" '321 tok' 'prompt shows token count'
assert_contains "$prompt" '$1.23' 'prompt shows cost'

set -gx USE_NERD_FONT 0
set -gx FORGE_CURRENCY_SYMBOL '€'
set -gx FORGE_CURRENCY_RATE 2
set -l prompt_no_icon (__forge_prompt_render)
assert_contains "$prompt_no_icon" '€2.46' 'prompt applies currency conversion'
if string match -q '*󰚩*' "$prompt_no_icon"
    fail 'prompt should omit nerd icon when disabled'
end

echo 'ok prompt'
