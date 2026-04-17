function __forge_select_conversation_line -a prompt_text query current_id
    set -l output (__forge_get_conversations | string collect)
    if test -z "$output"
        return 1
    end

    if set -q FORGE_FZF_MOCK[1]
        __forge_mock_pick "$output" 1 "$query" "$current_id"
    else
        set -l fzf_args --header-lines=1 --prompt="$prompt_text"
        if test -n "$query"
            set -a fzf_args --query="$query"
        else if test -n "$current_id"
            set -l index (__forge_find_index "$output" "$current_id" 1)
            set -a fzf_args --bind="start:pos($index)"
        end
        printf '%s\n' "$output" | __forge_fzf $fzf_args
    end
end

function __forge_action_conversation -a input_text
    if test "$input_text" = '-'
        if test -n "$_FORGE_PREVIOUS_CONVERSATION_ID"
            set -l tmp $_FORGE_CONVERSATION_ID
            set -g _FORGE_CONVERSATION_ID $_FORGE_PREVIOUS_CONVERSATION_ID
            set -g _FORGE_PREVIOUS_CONVERSATION_ID $tmp
            __forge_exec conversation show "$_FORGE_CONVERSATION_ID"
            __forge_exec conversation info "$_FORGE_CONVERSATION_ID"
            __forge_refresh_prompt_state
            return 0
        end
        set input_text ''
    end

    if test -n "$input_text"
        __forge_switch_conversation "$input_text"
        __forge_exec conversation show "$input_text"
        __forge_exec conversation info "$input_text"
        return 0
    end

    set -l selected (__forge_select_conversation_line 'Conversation ❯ ' '' "$_FORGE_CONVERSATION_ID")
    if test -n "$selected"
        set -l cid (__forge_field "$selected" 1)
        __forge_switch_conversation "$cid"
        __forge_exec conversation show "$cid"
        __forge_exec conversation info "$cid"
    else
        __forge_log error 'No conversations found'
    end
end

function __forge_clone_and_switch -a clone_target
    set -l output ($_FORGE_BIN conversation clone "$clone_target" 2>/dev/null)
    set -l new_id (string trim -- (string split '\n' -- "$output")[-1])
    if test -n "$new_id"
        __forge_switch_conversation "$new_id"
        __forge_exec conversation show "$new_id"
        __forge_exec conversation info "$new_id"
    else
        __forge_log error 'Failed to clone conversation'
    end
end

function __forge_action_clone -a input_text
    if test -n "$input_text"
        __forge_clone_and_switch "$input_text"
        return 0
    end

    set -l selected (__forge_select_conversation_line 'Clone Conversation ❯ ' '' "$_FORGE_CONVERSATION_ID")
    if test -n "$selected"
        __forge_clone_and_switch (__forge_field "$selected" 1)
    else
        __forge_log error 'No conversations found'
    end
end

function __forge_action_copy
    if test -z "$_FORGE_CONVERSATION_ID"
        __forge_log error 'No active conversation. Start a conversation first or use :conversation.'
        return 0
    end

    set -l content ($_FORGE_BIN conversation show --md "$_FORGE_CONVERSATION_ID" 2>/dev/null)
    if test -z "$content"
        __forge_log error 'No assistant message found in the current conversation'
        return 0
    end

    if set -q FORGE_CLIPBOARD_FILE[1]
        printf '%s' "$content" > "$FORGE_CLIPBOARD_FILE"
    else if command -sq pbcopy
        printf '%s' "$content" | pbcopy
    else if command -sq xclip
        printf '%s' "$content" | xclip -selection clipboard
    else if command -sq xsel
        printf '%s' "$content" | xsel --clipboard --input
    else
        __forge_log error 'No clipboard utility found (pbcopy, xclip, or xsel required)'
        return 0
    end

    __forge_log success 'Copied last assistant message to clipboard'
end

function __forge_action_rename -a input_text
    if test -z "$_FORGE_CONVERSATION_ID"
        __forge_log error 'No active conversation. Start a conversation first or use :conversation.'
        return 0
    end
    if test -z "$input_text"
        __forge_log error 'Usage: :rename <name>'
        return 0
    end
    __forge_exec conversation rename "$_FORGE_CONVERSATION_ID" "$input_text"
end

function __forge_action_conversation_rename -a input_text
    if test -n "$input_text"
        set -l split (string split -m 1 ' ' -- "$input_text")
        if test (count $split) -lt 2
            __forge_log error 'Usage: :conversation-rename <id> <name>'
            return 0
        end
        __forge_exec conversation rename "$split[1]" "$split[2]"
        return 0
    end

    set -l selected (__forge_select_conversation_line 'Rename Conversation ❯ ' '' "$_FORGE_CONVERSATION_ID")
    if test -z "$selected"
        __forge_log error 'No conversations found'
        return 0
    end

    set -l cid (__forge_field "$selected" 1)
    if set -q FORGE_RENAME_INPUT[1]
        set -l new_name $FORGE_RENAME_INPUT
    else
        read -P 'Enter new name: ' -l new_name </dev/tty
    end

    if test -n "$new_name"
        __forge_exec conversation rename "$cid" "$new_name"
    else
        __forge_log error 'No name provided, rename cancelled'
    end
end
