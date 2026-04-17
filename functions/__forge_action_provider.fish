function __forge_pick_provider -a prompt_text filter_status query
    set -l output (__forge_get_providers | string collect)
    if test -z "$output"
        return 1
    end

    set -l lines (__forge_lines_from_output "$output")
    set -l filtered $lines[1]
    for line in $lines[2..-1]
        if test -z "$filter_status"; or string match -iq -- "*$filter_status*" "$line"
            set -a filtered "$line"
        end
    end

    if set -q FORGE_FZF_MOCK[1]
        set -l mock_output (printf '%s\n' $filtered | string collect)
        __forge_mock_pick "$mock_output" 1 "$query"
    else
        set -l args --header-lines=1 --prompt="$prompt_text"
        if test -n "$query"
            set -a args --query="$query"
        end
        printf '%s\n' $filtered | __forge_fzf $args
    end
end

function __forge_action_login -a input_text
    set -l selected (__forge_pick_provider 'Provider ❯ ' '' "$input_text")
    if test -n "$selected"
        __forge_exec_interactive provider login (__forge_field "$selected" 2)
    end
end

function __forge_action_logout -a input_text
    set -l selected (__forge_pick_provider 'Provider Logout ❯ ' yes "$input_text")
    if test -n "$selected"
        __forge_exec provider logout (__forge_field "$selected" 2)
    end
end
