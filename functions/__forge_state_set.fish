function __forge_state_set -a name
    if test -z "$name"
        return 1
    end
    set -e $name
    if test (count $argv) -gt 1
        set -g $name $argv[2..-1]
    else
        set -g $name
    end
end

function __forge_switch_conversation -a conversation_id
    if test -z "$conversation_id"
        return 1
    end
    if set -q _FORGE_CONVERSATION_ID[1]; and test -n "$_FORGE_CONVERSATION_ID"; and test "$_FORGE_CONVERSATION_ID" != "$conversation_id"
        set -g _FORGE_PREVIOUS_CONVERSATION_ID $_FORGE_CONVERSATION_ID
    end
    set -g _FORGE_CONVERSATION_ID "$conversation_id"
    __forge_refresh_prompt_state
end

function __forge_clear_conversation
    if set -q _FORGE_CONVERSATION_ID[1]; and test -n "$_FORGE_CONVERSATION_ID"
        set -g _FORGE_PREVIOUS_CONVERSATION_ID $_FORGE_CONVERSATION_ID
    end
    set -g _FORGE_CONVERSATION_ID
    __forge_refresh_prompt_state
end
