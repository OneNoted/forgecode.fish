source (path dirname (status filename))/test_support.fish
setup_forge_test_env

__forge_enable_prompt
set -l idle_prompt (__forge_prompt_render)
assert_contains "$idle_prompt" 'forge' 'idle prompt still shows agent'
if string match -q '*tok*' "$idle_prompt"
    fail 'idle prompt should not show token count without usage'
end

set -g _FORGE_ACTIVE_AGENT sage
set -l agent_only (__forge_prompt_render)
assert_contains "$agent_only" 'sage' 'prompt reflects active agent with no conversation data'

echo 'ok prompt-states'
