function __forge_pick_agent -a query current_agent
    set -l output (__forge_get_agents | string collect)
    if test -z "$output"
        return 1
    end
    if set -q FORGE_FZF_MOCK[1]
        __forge_mock_pick "$output" 1 "$query" "$current_agent"
    else
        set -l args --header-lines=1 --prompt='Agent ❯ '
        if test -n "$query"
            set -a args --query="$query"
        else if test -n "$current_agent"
            set -l index (__forge_find_index "$output" "$current_agent" 1)
            set -a args --bind="start:pos($index)"
        end
        printf '%s\n' "$output" | __forge_fzf $args
    end
end

function __forge_pick_model -a prompt_text current_model query
    set -l output (__forge_get_models | string collect)
    if test -z "$output"
        return 1
    end
    if set -q FORGE_FZF_MOCK[1]
        __forge_mock_pick "$output" 1 "$query" "$current_model"
    else
        set -l args --header-lines=1 --prompt="$prompt_text"
        if test -n "$query"
            set -a args --query="$query"
        else if test -n "$current_model"
            set -l index (__forge_find_index "$output" "$current_model" 1)
            set -a args --bind="start:pos($index)"
        end
        printf '%s\n' "$output" | __forge_fzf $args
    end
end

function __forge_pick_reasoning -a prompt_text query current_value
    set -l output 'EFFORT\nnone\nminimal\nlow\nmedium\nhigh\nxhigh\nmax'
    set -l rendered_output (printf '%b' "$output" | string collect)
    if set -q FORGE_FZF_MOCK[1]
        __forge_mock_pick "$rendered_output" 1 "$query" "$current_value"
    else
        set -l args --header-lines=1 --prompt="$prompt_text"
        if test -n "$query"
            set -a args --query="$query"
        else if test -n "$current_value"
            set -l index (__forge_find_index "$rendered_output" "$current_value" 1)
            set -a args --bind="start:pos($index)"
        end
        printf '%s\n' "$rendered_output" | __forge_fzf $args
    end
end

function __forge_action_agent -a input_text
    if test -n "$input_text"
        set -g _FORGE_ACTIVE_AGENT "$input_text"
        return 0
    end

    set -l selected (__forge_pick_agent '' (__forge_get_active_agent))
    if test -n "$selected"
        set -g _FORGE_ACTIVE_AGENT (__forge_field "$selected" 1)
    else
        __forge_log error 'No agents found'
    end
end

function __forge_model_fields -a selected
    echo (__forge_field "$selected" 1)
    echo (__forge_field "$selected" 3)
    echo (__forge_field "$selected" 4)
end

function __forge_action_model -a input_text
    set -l current_model ($_FORGE_BIN config get model 2>/dev/null)
    set -l selected (__forge_pick_model 'Model ❯ ' "$current_model" "$input_text")
    if test -z "$selected"
        return 0
    end
    set -l values (__forge_model_fields "$selected")
    __forge_exec config set model "$values[3]" "$values[1]"
end

function __forge_action_commit_model -a input_text
    set -l current_model ($_FORGE_BIN config get commit 2>/dev/null | tail -n 1)
    set -l selected (__forge_pick_model 'Commit Model ❯ ' "$current_model" "$input_text")
    if test -z "$selected"
        return 0
    end
    set -l values (__forge_model_fields "$selected")
    __forge_exec config set commit "$values[3]" "$values[1]"
end

function __forge_action_suggest_model -a input_text
    set -l current_model ($_FORGE_BIN config get suggest 2>/dev/null | tail -n 1)
    set -l selected (__forge_pick_model 'Suggest Model ❯ ' "$current_model" "$input_text")
    if test -z "$selected"
        return 0
    end
    set -l values (__forge_model_fields "$selected")
    __forge_exec config set suggest "$values[3]" "$values[1]"
end

function __forge_action_session_model -a input_text
    set -l current_model ''
    if test -n "$_FORGE_SESSION_MODEL"
        set current_model $_FORGE_SESSION_MODEL
    else
        set current_model ($_FORGE_BIN config get model 2>/dev/null)
    end
    set -l selected (__forge_pick_model 'Session Model ❯ ' "$current_model" "$input_text")
    if test -z "$selected"
        return 0
    end
    set -l values (__forge_model_fields "$selected")
    set -g _FORGE_SESSION_MODEL "$values[1]"
    set -g _FORGE_SESSION_PROVIDER "$values[3]"
    __forge_refresh_prompt_state
end

function __forge_action_config_reload
    set -g _FORGE_SESSION_MODEL
    set -g _FORGE_SESSION_PROVIDER
    set -g _FORGE_SESSION_REASONING_EFFORT
    __forge_refresh_prompt_state
end

function __forge_action_reasoning_effort -a input_text
    set -l current_value ''
    if test -n "$_FORGE_SESSION_REASONING_EFFORT"
        set current_value $_FORGE_SESSION_REASONING_EFFORT
    else
        set current_value ($_FORGE_BIN config get reasoning-effort 2>/dev/null)
    end
    set -l selected (__forge_pick_reasoning 'Reasoning Effort ❯ ' "$input_text" "$current_value")
    if test -n "$selected"
        set -g _FORGE_SESSION_REASONING_EFFORT "$selected"
    end
end

function __forge_action_config_reasoning_effort -a input_text
    set -l current_value ($_FORGE_BIN config get reasoning-effort 2>/dev/null)
    set -l selected (__forge_pick_reasoning 'Config Reasoning Effort ❯ ' "$input_text" "$current_value")
    if test -n "$selected"
        __forge_exec config set reasoning-effort "$selected"
    end
end

function __forge_action_config
    $_FORGE_BIN config list
end

function __forge_action_config_edit
    set -l editor_cmd nano
    if set -q FORGE_EDITOR[1]
        set editor_cmd $FORGE_EDITOR
    else if set -q EDITOR[1]
        set editor_cmd $EDITOR
    end

    set -l config_path ($_FORGE_BIN config path 2>/dev/null)
    if test -z "$config_path"
        __forge_log error 'Failed to resolve config path'
        return 1
    end
    mkdir -p (path dirname "$config_path")
    touch "$config_path"

    if set -q FORGE_EDITOR_STUB_CONTENT[1]
        printf '%s' "$FORGE_EDITOR_STUB_CONTENT" > "$config_path"
    else if test -r /dev/tty
        eval "$editor_cmd '$config_path'" </dev/tty >/dev/tty 2>/dev/tty
    else
        eval "$editor_cmd '$config_path'"
    end
end

function __forge_action_tools
    __forge_exec list tools (__forge_get_active_agent)
end

function __forge_action_skill
    __forge_exec list skill
end

function __forge_action_sync
    __forge_exec_interactive workspace sync --init .
end

function __forge_action_sync_init
    __forge_exec_interactive workspace init .
end

function __forge_action_sync_status
    __forge_exec workspace status .
end

function __forge_action_sync_info
    __forge_exec workspace info .
end
