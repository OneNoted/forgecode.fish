function __forge_state_get -a name
    if test -z "$name"
        return 1
    end
    if set -q $name[1]
        printf '%s\n' $$name
    end
end
