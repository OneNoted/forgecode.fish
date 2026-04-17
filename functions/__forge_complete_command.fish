function __forge_complete_command -a buffer_override
    set -l buffer "$buffer_override"
    if test -z "$buffer"
        set buffer (__forge_get_buffer)
    end

    set -l command_token (string trim -- (string sub -s 2 -- "$buffer"))
    set -l partial (string split -m 1 ' ' -- "$command_token")[1]
    set -l output (__forge_get_commands | string collect)
    if test -z "$output"
        return 1
    end

    set -l selected
    if set -q FORGE_FZF_MOCK[1]
        set selected (__forge_mock_pick "$output" 1 "$partial")
    else
        set selected (printf '%s\n' "$output" | __forge_fzf --header-lines=1 --prompt='Command ❯ ' --query="$partial")
    end
    if test -z "$selected"
        return 1
    end

    set -l command_name (__forge_field "$selected" 1)
    set -g _FORGE_LAST_BUFFER_ACTION preserve
    __forge_set_buffer ":$command_name "
end
