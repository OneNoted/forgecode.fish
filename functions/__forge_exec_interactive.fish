function __forge_exec_interactive
    set -l agent (__forge_get_active_agent)
    set -l env_pairs

    if __forge_bool_true "$_FORGE_TERM"; and test (count $_FORGE_TERM_COMMANDS) -gt 0
        set -a env_pairs _FORGE_TERM_COMMANDS=(string join \x1f -- $_FORGE_TERM_COMMANDS)
        set -a env_pairs _FORGE_TERM_EXIT_CODES=(string join \x1f -- $_FORGE_TERM_EXIT_CODES)
        set -a env_pairs _FORGE_TERM_TIMESTAMPS=(string join \x1f -- $_FORGE_TERM_TIMESTAMPS)
    end
    if test -n "$_FORGE_SESSION_MODEL"
        set -a env_pairs FORGE_SESSION__MODEL_ID=$_FORGE_SESSION_MODEL
    end
    if test -n "$_FORGE_SESSION_PROVIDER"
        set -a env_pairs FORGE_SESSION__PROVIDER_ID=$_FORGE_SESSION_PROVIDER
    end
    if test -n "$_FORGE_SESSION_REASONING_EFFORT"
        set -a env_pairs FORGE_REASONING__EFFORT=$_FORGE_SESSION_REASONING_EFFORT
    end

    if status is-interactive; and tty >/dev/null 2>&1; and test -r /dev/tty
        if test (count $env_pairs) -gt 0
            env $env_pairs $_FORGE_BIN --agent "$agent" $argv </dev/tty >/dev/tty 2>/dev/tty
        else
            $_FORGE_BIN --agent "$agent" $argv </dev/tty >/dev/tty 2>/dev/tty
        end
    else
        if test (count $env_pairs) -gt 0
            env $env_pairs $_FORGE_BIN --agent "$agent" $argv
        else
            $_FORGE_BIN --agent "$agent" $argv
        end
    end
end
