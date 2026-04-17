function __forge_accept_line
    set -l buffer (__forge_get_buffer)
    if not string match -qr '^:' -- "$buffer"
        commandline -f execute
        return 0
    end

    history append -- "$buffer"
    __forge_dispatch "$buffer"
end
