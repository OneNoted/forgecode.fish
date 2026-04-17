function __forge_init
    if set -q _FORGE_PLUGIN_INITIALIZED[1]
        return 0
    end

    set -g _FORGE_PLUGIN_INITIALIZED 1

    if not set -q _FORGE_BIN[1]
        if set -q FORGE_BIN[1]
            set -g _FORGE_BIN $FORGE_BIN
        else
            set -g _FORGE_BIN forge
        end
    end

    if not set -q _FORGE_MAX_COMMIT_DIFF[1]
        if set -q FORGE_MAX_COMMIT_DIFF[1]
            set -g _FORGE_MAX_COMMIT_DIFF $FORGE_MAX_COMMIT_DIFF
        else
            set -g _FORGE_MAX_COMMIT_DIFF 100000
        end
    end

    if not set -q _FORGE_TERM[1]
        if set -q FORGE_TERM[1]
            set -g _FORGE_TERM $FORGE_TERM
        else
            set -g _FORGE_TERM true
        end
    end

    if not set -q _FORGE_TERM_MAX_COMMANDS[1]
        if set -q FORGE_TERM_MAX_COMMANDS[1]
            set -g _FORGE_TERM_MAX_COMMANDS $FORGE_TERM_MAX_COMMANDS
        else
            set -g _FORGE_TERM_MAX_COMMANDS 5
        end
    end

    if not set -q _FORGE_ACTIVE_AGENT[1]
        set -g _FORGE_ACTIVE_AGENT forge
    end

    if not set -q _FORGE_CONVERSATION_ID
        set -g _FORGE_CONVERSATION_ID
    end

    if not set -q _FORGE_PREVIOUS_CONVERSATION_ID
        set -g _FORGE_PREVIOUS_CONVERSATION_ID
    end

    if not set -q _FORGE_SESSION_MODEL
        set -g _FORGE_SESSION_MODEL
    end

    if not set -q _FORGE_SESSION_PROVIDER
        set -g _FORGE_SESSION_PROVIDER
    end

    if not set -q _FORGE_SESSION_REASONING_EFFORT
        set -g _FORGE_SESSION_REASONING_EFFORT
    end

    if not set -q _FORGE_TERM_COMMANDS
        set -g _FORGE_TERM_COMMANDS
    end

    if not set -q _FORGE_TERM_EXIT_CODES
        set -g _FORGE_TERM_EXIT_CODES
    end

    if not set -q _FORGE_TERM_TIMESTAMPS
        set -g _FORGE_TERM_TIMESTAMPS
    end

    if not set -q _FORGE_COMMANDS_CACHE
        set -g _FORGE_COMMANDS_CACHE
    end

    if not set -q _FORGE_MODELS_CACHE
        set -g _FORGE_MODELS_CACHE
    end

    if not set -q _FORGE_LAST_BUFFER_ACTION[1]
        set -g _FORGE_LAST_BUFFER_ACTION reset
    end

    if not set -q _FORGE_PROMPT_ENABLED[1]
        set -g _FORGE_PROMPT_ENABLED 0
    end

    if status is-interactive
        for __forge_mode in default insert visual
            bind -M $__forge_mode \r __forge_accept_line 2>/dev/null
            bind -M $__forge_mode \n __forge_accept_line 2>/dev/null
            bind -M $__forge_mode \t __forge_tab_handler 2>/dev/null
        end
    end
end
