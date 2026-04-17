function __forge_action_commit -a additional_context
    if test -n "$additional_context"
        __forge_exec commit --max-diff "$_FORGE_MAX_COMMIT_DIFF" "$additional_context"
    else
        __forge_exec commit --max-diff "$_FORGE_MAX_COMMIT_DIFF"
    end
end

function __forge_action_commit_preview -a additional_context
    set -l commit_message
    if test -n "$additional_context"
        set commit_message (__forge_exec commit --preview --max-diff "$_FORGE_MAX_COMMIT_DIFF" "$additional_context")
    else
        set commit_message (__forge_exec commit --preview --max-diff "$_FORGE_MAX_COMMIT_DIFF")
    end

    if test -z "$commit_message"
        __forge_reset_buffer
        return 0
    end

    set -l quoted (string escape --style=script -- $commit_message)
    if git diff --staged --quiet >/dev/null 2>&1
        set -g _FORGE_LAST_BUFFER_ACTION preserve
        __forge_set_buffer "git commit -am $quoted"
    else
        set -g _FORGE_LAST_BUFFER_ACTION preserve
        __forge_set_buffer "git commit -m $quoted"
    end
end
