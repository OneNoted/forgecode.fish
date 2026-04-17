function __forge_context_postexec --on-event fish_postexec
    set -l last_status $status

    __forge_bool_true "$_FORGE_TERM"
    or return 0

    if not set -q _FORGE_TERM_PENDING_CMD[1]
        return 0
    end

    if test -z "$_FORGE_TERM_PENDING_CMD"
        return 0
    end

    set -ga _FORGE_TERM_COMMANDS "$_FORGE_TERM_PENDING_CMD"
    set -ga _FORGE_TERM_EXIT_CODES "$last_status"
    set -ga _FORGE_TERM_TIMESTAMPS "$_FORGE_TERM_PENDING_TS"

    set -l max_items $_FORGE_TERM_MAX_COMMANDS
    while test (count $_FORGE_TERM_COMMANDS) -gt $max_items
        set -e _FORGE_TERM_COMMANDS[1]
        set -e _FORGE_TERM_EXIT_CODES[1]
        set -e _FORGE_TERM_TIMESTAMPS[1]
    end

    set -g _FORGE_TERM_PENDING_CMD
    set -g _FORGE_TERM_PENDING_TS
end
