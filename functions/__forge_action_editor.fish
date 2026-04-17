function __forge_action_editor -a initial_text
    set -l editor_cmd nano
    if set -q FORGE_EDITOR[1]
        set editor_cmd $FORGE_EDITOR
    else if set -q EDITOR[1]
        set editor_cmd $EDITOR
    end

    set -l edit_dir .forge
    if set -q FORGE_EDIT_DIR[1]
        set edit_dir $FORGE_EDIT_DIR
    end
    mkdir -p $edit_dir
    set -l temp_file $edit_dir/FORGE_EDITMSG.md
    touch "$temp_file"

    if test -n "$initial_text"
        printf '%s' "$initial_text" > "$temp_file"
    else
        : > "$temp_file"
    end

    if set -q FORGE_EDITOR_STUB_CONTENT[1]
        printf '%s' "$FORGE_EDITOR_STUB_CONTENT" > "$temp_file"
    else if test -r /dev/tty
        eval "$editor_cmd '$temp_file'" </dev/tty >/dev/tty 2>/dev/tty
    else
        eval "$editor_cmd '$temp_file'"
    end

    set -l content (string trim -- (cat "$temp_file" | tr -d '\r'))
    if test -z "$content"
        set -g _FORGE_LAST_BUFFER_ACTION preserve
        __forge_set_buffer ''
        return 0
    end

    set -g _FORGE_LAST_BUFFER_ACTION preserve
    __forge_set_buffer ": $content"
end

function __forge_action_suggest -a description
    if test -z "$description"
        __forge_log error 'Please provide a command description'
        return 0
    end
    set -l generated (__forge_exec suggest "$description")
    if test -n "$generated"
        set -g _FORGE_LAST_BUFFER_ACTION preserve
        __forge_set_buffer "$generated"
    else
        __forge_log error 'Failed to generate command'
    end
end
