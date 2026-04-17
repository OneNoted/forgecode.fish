function __forge_prompt_render
    if not set -q _FORGE_PROMPT_ENABLED[1]
        return 0
    end

    set -l icon '󰚩'
    if set -q USE_NERD_FONT[1]
        if not __forge_bool_true "$USE_NERD_FONT"
            set icon ''
        end
    else if set -q NERD_FONT[1]
        if not __forge_bool_true "$NERD_FONT"
            set icon ''
        end
    end

    set -l agent (__forge_get_active_agent)
    set -l model ''
    if set -q _FORGE_SESSION_MODEL[1]; and test -n "$_FORGE_SESSION_MODEL"
        set model $_FORGE_SESSION_MODEL
    else if set -q _FORGE_PROMPT_MODEL[1]
        set model $_FORGE_PROMPT_MODEL
    end

    set -l parts
    if test -n "$icon"
        set -a parts $icon
    end
    set -a parts "$agent"

    if test -n "$model"
        set -a parts "$model"
    end

    if set -q _FORGE_PROMPT_TOKENS[1]; and test -n "$_FORGE_PROMPT_TOKENS"
        set -a parts "$_FORGE_PROMPT_TOKENS tok"
    end

    if set -q _FORGE_PROMPT_COST[1]; and test -n "$_FORGE_PROMPT_COST"
        set -a parts (__forge_format_cost "$_FORGE_PROMPT_COST")
    end

    if test (count $parts) -eq 1
        echo "($parts[1])"
    else
        echo (string join ' · ' -- $parts)
    end
end
