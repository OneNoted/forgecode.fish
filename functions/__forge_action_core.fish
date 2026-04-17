function __forge_action_new -a input_text
    __forge_clear_conversation
    set -g _FORGE_ACTIVE_AGENT (__forge_default_agent)

    if test -n "$input_text"
        set -l cid (__forge_ensure_conversation_id)
        if test -n "$cid"
            __forge_exec_interactive -p "$input_text" --cid "$cid"
            set -l prompt_status $status
            if test $prompt_status -eq 0
                __forge_refresh_prompt_state
                __forge_start_background_sync
                __forge_start_background_update
            end
            return $prompt_status
        end
    else
        $_FORGE_BIN banner
    end
end

function __forge_action_info
    if test -n "$_FORGE_CONVERSATION_ID"
        __forge_exec info --cid "$_FORGE_CONVERSATION_ID"
    else
        __forge_exec info
    end
end

function __forge_handle_conversation_command -a subcommand
    if test -z "$_FORGE_CONVERSATION_ID"
        __forge_log error 'No active conversation. Start a conversation first or use :conversation.'
        return 0
    end

    __forge_exec conversation "$subcommand" "$_FORGE_CONVERSATION_ID" $argv[2..-1]
    __forge_refresh_prompt_state
end

function __forge_action_dump -a input_text
    if test "$input_text" = html
        __forge_handle_conversation_command dump --html
    else
        __forge_handle_conversation_command dump
    end
end

function __forge_action_compact
    __forge_handle_conversation_command compact
end

function __forge_action_retry
    __forge_handle_conversation_command retry
end

function __forge_action_help
    __forge_help
end
