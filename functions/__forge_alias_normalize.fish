function __forge_alias_normalize -a action
    switch $action
        case ask
            echo sage
        case plan
            echo muse
        case n
            echo new
        case c
            echo conversation
        case r
            echo retry
        case i
            echo info
        case a
            echo agent
        case d
            echo dump
        case m
            echo model
        case cm
            echo config-model
        case cr mr
            echo config-reload
        case re
            echo reasoning-effort
        case cre
            echo config-reasoning-effort
        case ccm
            echo config-commit-model
        case csm
            echo config-suggest-model
        case t
            echo tools
        case e env
            echo config
        case ce
            echo config-edit
        case ed
            echo edit
        case s
            echo suggest
        case rn
            echo rename
        case login provider
            echo provider-login
        case sync
            echo workspace-sync
        case sync-init
            echo workspace-init
        case sync-status
            echo workspace-status
        case sync-info
            echo workspace-info
        case '*'
            echo $action
    end
end
