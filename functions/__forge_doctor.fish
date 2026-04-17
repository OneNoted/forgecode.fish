function __forge_doctor
    set -l fish_version (fish --version | string replace 'fish, version ' '')
    set -l support_floor unsupported
    if __forge_version_at_least "$fish_version" '3.6.0'
        set support_floor ok
    end

    set -l fd_cmd missing
    if command -sq fd
        set fd_cmd fd
    else if command -sq fdfind
        set fd_cmd fdfind
    end

    set -l prompt_state disabled
    if test "$_FORGE_PROMPT_ENABLED" = 1
        set prompt_state enabled
    end

    set -l editor_cmd nano
    if set -q FORGE_EDITOR[1]
        set editor_cmd $FORGE_EDITOR
    else if set -q EDITOR[1]
        set editor_cmd $EDITOR
    end

    echo 'Forge fish doctor'
    printf 'fish_version	%s
' "$fish_version"
    printf 'support_floor	%s
' "$support_floor"
    printf 'forge	%s
' (command -sq $_FORGE_BIN; and echo present; or echo missing)
    printf 'fzf	%s
' (command -sq fzf; and echo present; or echo missing)
    printf 'fd	%s
' "$fd_cmd"
    printf 'bat	%s
' (command -sq bat; and echo present; or echo missing)
    printf 'plugin_loaded	%s
' (set -q _FORGE_PLUGIN_INITIALIZED[1]; and echo yes; or echo no)
    printf 'prompt	%s
' "$prompt_state"
    printf 'editor	%s
' "$editor_cmd"
end
