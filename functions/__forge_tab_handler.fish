function __forge_tab_handler
    if not __forge_commandline_available
        set -g _FORGE_TEST_TAB_FALLBACK 1
        return 0
    end

    set -l buffer (commandline --current-buffer)
    set -l token (commandline --current-token)

    if string match -qr '^@' -- "$token"
        __forge_complete_file_ref "$token"
        return 0
    end

    if string match -qr '^:' -- "$buffer"
        set -l before_cursor (commandline --cut-at-cursor)
        if string match -qr '^:[A-Za-z0-9_-]*$' -- "$before_cursor"
            __forge_complete_command "$before_cursor"
            return 0
        end
    end

    commandline -f complete
end
