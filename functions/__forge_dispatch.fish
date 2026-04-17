function __forge_command_row -a command_name
    for line in (__forge_data_lines (__forge_get_commands | string collect))
        if test (__forge_field "$line" 1) = "$command_name"
            echo "$line"
            return 0
        end
    end
end

function __forge_action_default -a user_action input_text
    set -l command_type ''
    if test -n "$user_action"
        set -l row (__forge_command_row "$user_action")
        if test -z "$row"
            __forge_log error "Command '$user_action' not found"
            return 0
        end
        set command_type (string lower -- (__forge_field "$row" 2))
        if test "$command_type" = custom
            set -l cid (__forge_ensure_conversation_id)
            if test -n "$input_text"
                __forge_exec cmd execute --cid "$cid" "$user_action" "$input_text"
            else
                __forge_exec cmd execute --cid "$cid" "$user_action"
            end
            __forge_refresh_prompt_state
            return 0
        end
    end

    if test -z "$input_text"
        if test -n "$user_action"
            if test "$command_type" != agent
                __forge_log error "Command '$user_action' not found"
                return 0
            end
            set -g _FORGE_ACTIVE_AGENT "$user_action"
        end
        return 0
    end

    set -l cid (__forge_ensure_conversation_id)
    if test -n "$user_action"
        set -g _FORGE_ACTIVE_AGENT "$user_action"
    end
    __forge_exec_interactive -p "$input_text" --cid "$cid"
    set -l prompt_status $status
    if test $prompt_status -eq 0
        __forge_refresh_prompt_state
        __forge_start_background_sync
        __forge_start_background_update
    end
    return $prompt_status
end

function __forge_dispatch -a buffer
    set -g _FORGE_LAST_BUFFER_ACTION reset

    if not string match -qr '^:' -- "$buffer"
        return 1
    end

    set -l user_action ''
    set -l input_text ''

    if string match -qr '^:\s+' -- "$buffer"
        set input_text (string trim -- (string sub -s 2 -- "$buffer"))
    else
        set -l remainder (string sub -s 2 -- "$buffer")
        set -l pieces (string split -m 1 ' ' -- "$remainder")
        set user_action $pieces[1]
        if test (count $pieces) -gt 1
            set input_text (string trim -- "$pieces[2]")
        end
    end

    if test -n "$user_action"
        set user_action (__forge_alias_normalize "$user_action")
    end

    switch $user_action
        case new
            __forge_action_new "$input_text"
        case info
            __forge_action_info
        case dump
            __forge_action_dump "$input_text"
        case compact
            __forge_action_compact
        case retry
            __forge_action_retry
        case help
            __forge_action_help
        case doctor
            __forge_doctor
        case agent
            __forge_action_agent "$input_text"
        case conversation
            __forge_action_conversation "$input_text"
        case config-model
            __forge_action_model "$input_text"
        case model
            __forge_action_session_model "$input_text"
        case config-reload
            __forge_action_config_reload
        case reasoning-effort
            __forge_action_reasoning_effort "$input_text"
        case config-reasoning-effort
            __forge_action_config_reasoning_effort "$input_text"
        case config-commit-model
            __forge_action_commit_model "$input_text"
        case config-suggest-model
            __forge_action_suggest_model "$input_text"
        case tools
            __forge_action_tools
        case config
            __forge_action_config
        case config-edit
            __forge_action_config_edit
        case skill
            __forge_action_skill
        case edit
            __forge_action_editor "$input_text"
        case commit
            __forge_action_commit "$input_text"
        case commit-preview
            __forge_action_commit_preview "$input_text"
        case suggest
            __forge_action_suggest "$input_text"
        case clone
            __forge_action_clone "$input_text"
        case copy
            __forge_action_copy
        case rename
            __forge_action_rename "$input_text"
        case conversation-rename
            __forge_action_conversation_rename "$input_text"
        case workspace-sync
            __forge_action_sync
        case workspace-init
            __forge_action_sync_init
        case workspace-status
            __forge_action_sync_status
        case workspace-info
            __forge_action_sync_info
        case provider-login
            __forge_action_login "$input_text"
        case logout
            __forge_action_logout "$input_text"
        case ''
            __forge_action_default '' "$input_text"
        case '*'
            __forge_action_default "$user_action" "$input_text"
    end

    if test "$_FORGE_LAST_BUFFER_ACTION" = reset
        __forge_reset_buffer
    end
    return 0
end
