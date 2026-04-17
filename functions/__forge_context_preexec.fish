function __forge_context_preexec --on-event fish_preexec
    __forge_bool_true "$_FORGE_TERM"
    or return 0

    if test -z "$argv[1]"
        return 0
    end

    set -g _FORGE_TERM_PENDING_CMD "$argv[1]"
    set -g _FORGE_TERM_PENDING_TS (date +%s)
end
