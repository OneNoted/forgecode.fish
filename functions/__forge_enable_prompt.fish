function __forge_enable_prompt
    if test "$_FORGE_PROMPT_ENABLED" = 1
        return 0
    end

    set -g _FORGE_PROMPT_ENABLED 1

    if functions -q fish_right_prompt; and not functions -q __forge_user_fish_right_prompt
        functions -c fish_right_prompt __forge_user_fish_right_prompt
    end

    function fish_right_prompt
        set -l forge_segment (__forge_prompt_render)
        set -l user_segment ''
        if functions -q __forge_user_fish_right_prompt
            set user_segment (__forge_user_fish_right_prompt)
        end

        if test -n "$forge_segment" -a -n "$user_segment"
            echo "$forge_segment $user_segment"
        else if test -n "$forge_segment"
            echo "$forge_segment"
        else
            echo "$user_segment"
        end
    end
end
