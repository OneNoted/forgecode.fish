set -l __forge_conf_dir (path dirname (status filename))
set -l __forge_root (path dirname $__forge_conf_dir)

if not contains -- "$__forge_root/functions" $fish_function_path
    set -p fish_function_path "$__forge_root/functions"
end

if not contains -- "$__forge_root/completions" $fish_complete_path
    set -p fish_complete_path "$__forge_root/completions"
end

set -g _FORGE_PLUGIN_ROOT "$__forge_root"

set -l __forge_sources \
    __forge_helpers.fish \
    __forge_state_get.fish \
    __forge_state_set.fish \
    __forge_exec.fish \
    __forge_exec_interactive.fish \
    __forge_init.fish \
    __forge_context_preexec.fish \
    __forge_context_postexec.fish \
    __forge_alias_normalize.fish \
    __forge_prompt_render.fish \
    __forge_enable_prompt.fish \
    __forge_doctor.fish \
    __forge_help.fish \
    __forge_action_core.fish \
    __forge_action_conversation.fish \
    __forge_action_config.fish \
    __forge_action_provider.fish \
    __forge_action_editor.fish \
    __forge_action_git.fish \
    __forge_dispatch.fish \
    __forge_accept_line.fish \
    __forge_complete_command.fish \
    __forge_complete_file_ref.fish \
    __forge_tab_handler.fish

for __forge_file in $__forge_sources
    source "$__forge_root/functions/$__forge_file"
end

__forge_init

if set -q FORGE_FISH_PROMPT
    if contains -- "$FORGE_FISH_PROMPT" 1 true yes on
        __forge_enable_prompt
    end
end
