function __forge_complete_file_ref -a token_override buffer_override
    set -l token "$token_override"
    if test -z "$token"
        if __forge_commandline_available
            set token (commandline --current-token)
        else
            return 1
        end
    end

    set -l query (string replace -r '^@\[?' '' -- "$token")
    set -l file_output (__forge_get_files | string collect)
    set -l selected
    if set -q FORGE_FZF_MOCK[1]
        set selected (__forge_mock_pick "$file_output" 0 "$query")
    else
        set selected (printf '%s\n' "$file_output" | __forge_fzf --prompt='File ❯ ' --query="$query")
    end
    if test -z "$selected"
        return 1
    end

    set -l replacement "@[$selected]"
    set -g _FORGE_LAST_BUFFER_ACTION preserve

    if __forge_commandline_available
        commandline --current-token --replace -- "$replacement"
        commandline -f repaint
    else
        set -l buffer "$buffer_override"
        if test -z "$buffer"
            set buffer (__forge_get_buffer)
        end
        set -l escaped (string escape --style=regex -- "$token")
        __forge_set_buffer (string replace -r -- "$escaped" "$replacement" "$buffer")
    end
end
