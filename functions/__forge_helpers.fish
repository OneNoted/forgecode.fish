function __forge_bool_true -a value
    contains -- (string lower -- "$value") 1 true yes on
end

function __forge_default_agent
    echo forge
end

function __forge_get_active_agent
    if set -q _FORGE_ACTIVE_AGENT[1]
        if test -n "$_FORGE_ACTIVE_AGENT"
            echo $_FORGE_ACTIVE_AGENT
            return 0
        end
    end
    __forge_default_agent
end

function __forge_trim
    string trim -- $argv
end

function __forge_commandline_available
    status is-interactive
    or return 1
    commandline --current-buffer >/dev/null 2>/dev/null
end

function __forge_get_buffer
    if __forge_commandline_available
        commandline --current-buffer
    else if set -q _FORGE_TEST_BUFFER[1]
        echo $_FORGE_TEST_BUFFER
    else
        echo ''
    end
end

function __forge_set_buffer -a text
    if __forge_commandline_available
        commandline --replace -- "$text"
        commandline --cursor (string length -- "$text")
        commandline -f repaint
    else
        set -g _FORGE_TEST_BUFFER "$text"
    end
end

function __forge_reset_buffer
    set -g _FORGE_LAST_BUFFER_ACTION reset
    __forge_set_buffer ''
end

function __forge_log -a level message
    printf '[forge:%s] %s\n' "$level" "$message"
end

function __forge_tsv_fields -a line
    set -l tab (printf '\t')
    string split $tab -- (string replace -a -r '\s{2,}' $tab -- "$line")
end

function __forge_field -a line index
    set -l fields (__forge_tsv_fields "$line")
    if test $index -le (count $fields)
        echo $fields[$index]
    end
end

function __forge_lines_from_output -a output
    string split '\n' -- (string trim -r -c '\n' -- "$output")
end

function __forge_data_lines -a output
    set -l lines (__forge_lines_from_output "$output")
    if test (count $lines) -le 1
        return 0
    end
    printf '%s\n' $lines[2..-1]
end

function __forge_find_index -a output value field field2 value2
    set -l lines (__forge_lines_from_output "$output")
    set -l start 2
    set -l idx 1
    for line in $lines[$start..-1]
        set -l primary_field 1
        if test -n "$field"
            set primary_field $field
        end
        set -l lhs (__forge_field "$line" $primary_field)
        if test "$lhs" = "$value"
            if test -n "$field2" -a -n "$value2"
                set -l rhs (__forge_field "$line" $field2)
                if test "$rhs" = "$value2"
                    echo $idx
                    return 0
                end
            else
                echo $idx
                return 0
            end
        end
        set idx (math $idx + 1)
    end
    echo 1
end

function __forge_mock_pick -a output header_lines query preferred
    set -l lines (__forge_lines_from_output "$output")
    set -l start 1
    if string match -qr '^[0-9]+$' -- "$header_lines"
        set start (math $header_lines + 1)
    end
    set -l candidates $lines[$start..-1]
    set -l needle ''
    if set -q FORGE_FZF_CHOICE[1]; and test -n "$FORGE_FZF_CHOICE"
        set needle (string join ' ' -- $FORGE_FZF_CHOICE)
    else if test -n "$query"
        set needle (string join ' ' -- $query)
    else if test -n "$preferred"
        set needle (string join ' ' -- $preferred)
    end
    if test -n "$needle"
        for line in $candidates
            if string match -iq -- "*$needle*" "$line"
                echo "$line"
                return 0
            end
        end
    end
    if test (count $candidates) -gt 0
        echo $candidates[1]
    end
end

function __forge_fzf
    set -l lines (cat)
    set -l header_lines 0
    set -l query ''
    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case '--header-lines=*'
                set header_lines (string replace -- '--header-lines=' '' "$arg")
            case '--query=*'
                set query (string replace -- '--query=' '' "$arg")
            case '--query'
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set query $argv[$i]
                end
        end
        set i (math $i + 1)
    end

    if set -q FORGE_FZF_MOCK[1]
        set -l candidates $lines[(math $header_lines + 1)..-1]
        set -l needle ''
        if set -q FORGE_FZF_CHOICE[1]
            set needle (string join " " -- $FORGE_FZF_CHOICE)
        else if test -n "$query"
            set needle (string join " " -- $query)
        end
        if test -n "$needle"
            for line in $candidates
                if string match -iq -- "*$needle*" "$line"
                    echo "$line"
                    return 0
                end
            end
        end
        if test (count $candidates) -gt 0
            echo $candidates[1]
        end
        return 0
    end

    if not command -sq fzf
        return 1
    end

    printf '%s\n' $lines | command fzf --reverse --exact --cycle --select-1 --height 80% --no-scrollbar --ansi --color='header:bold' $argv
end


function __forge_get_commands
    if not set -q _FORGE_COMMANDS_CACHE[1]; or test -z "$_FORGE_COMMANDS_CACHE"
        set -g _FORGE_COMMANDS_CACHE (env CLICOLOR_FORCE=0 $_FORGE_BIN list commands --porcelain 2>/dev/null | string split '\n')
    end
    printf '%s\n' $_FORGE_COMMANDS_CACHE
end

function __forge_get_agents
    $_FORGE_BIN list agents --porcelain 2>/dev/null | string split '\n'
end

function __forge_get_models
    if not set -q _FORGE_MODELS_CACHE[1]; or test -z "$_FORGE_MODELS_CACHE"
        set -g _FORGE_MODELS_CACHE ($_FORGE_BIN list models --porcelain 2>/dev/null | string split '\n')
    end
    printf '%s\n' $_FORGE_MODELS_CACHE
end

function __forge_get_providers
    $_FORGE_BIN list provider --porcelain 2>/dev/null | string split '\n'
end

function __forge_get_conversations
    $_FORGE_BIN conversation list --porcelain 2>/dev/null | string split '\n'
end

function __forge_get_files
    set -l file_output ($_FORGE_BIN list files --porcelain 2>/dev/null | string collect)
    if test -n "$file_output"
        if string match -rq '^PATH' -- (string split '\n' -- $file_output)[1]
            __forge_data_lines "$file_output"
        else
            echo "$file_output"
        end
        return 0
    end

    if command -sq fd
        fd --type f .
        return 0
    end

    if command -sq fdfind
        fdfind --type f .
        return 0
    end

    find . -type f 2>/dev/null | sed 's#^\./##'
end


function __forge_is_workspace_indexed
    $_FORGE_BIN workspace info . >/dev/null 2>/dev/null
end

function __forge_start_background_sync
    if set -q FORGE_DISABLE_BACKGROUND[1]
        __forge_bool_true "$FORGE_DISABLE_BACKGROUND"
        and return 0
    end

    set -l sync_enabled true
    if set -q FORGE_SYNC_ENABLED[1]
        set sync_enabled $FORGE_SYNC_ENABLED
    end
    __forge_bool_true "$sync_enabled"
    or return 0

    __forge_is_workspace_indexed
    or return 0

    if set -q FORGE_BACKGROUND_INLINE[1]
        __forge_bool_true "$FORGE_BACKGROUND_INLINE"
        and begin
            $_FORGE_BIN workspace sync . >/dev/null 2>&1
            return $status
        end
    end

    begin
        $_FORGE_BIN workspace sync . >/dev/null 2>&1 </dev/null &
        disown
    end
end

function __forge_start_background_update
    if set -q FORGE_DISABLE_BACKGROUND[1]
        __forge_bool_true "$FORGE_DISABLE_BACKGROUND"
        and return 0
    end

    if set -q FORGE_BACKGROUND_INLINE[1]
        __forge_bool_true "$FORGE_BACKGROUND_INLINE"
        and begin
            $_FORGE_BIN update --no-confirm >/dev/null 2>&1
            return $status
        end
    end

    begin
        $_FORGE_BIN update --no-confirm >/dev/null 2>&1 </dev/null &
        disown
    end
end

function __forge_version_at_least -a actual minimum
    set -l actual_parts (string split '.' -- "$actual")
    set -l minimum_parts (string split '.' -- "$minimum")
    for i in 1 2 3
        set -l actual_part 0
        set -l minimum_part 0
        if test $i -le (count $actual_parts)
            set actual_part $actual_parts[$i]
        end
        if test $i -le (count $minimum_parts)
            set minimum_part $minimum_parts[$i]
        end
        if test $actual_part -gt $minimum_part
            return 0
        else if test $actual_part -lt $minimum_part
            return 1
        end
    end
    return 0
end

function __forge_ensure_conversation_id
    if set -q _FORGE_CONVERSATION_ID[1]; and test -n "$_FORGE_CONVERSATION_ID"
        echo $_FORGE_CONVERSATION_ID
        return 0
    end

    set -l new_id ($_FORGE_BIN conversation new 2>/dev/null)
    if test -n "$new_id"
        set -g _FORGE_CONVERSATION_ID "$new_id"
        __forge_refresh_prompt_state
        echo "$new_id"
    end
end

function __forge_refresh_prompt_state
    set -g _FORGE_PROMPT_MODEL
    set -g _FORGE_PROMPT_TOKENS
    set -g _FORGE_PROMPT_COST

    if not set -q _FORGE_CONVERSATION_ID[1]; or test -z "$_FORGE_CONVERSATION_ID"
        return 0
    end

    set -l info_output ($_FORGE_BIN conversation info $_FORGE_CONVERSATION_ID --porcelain 2>/dev/null | string collect)
    if test -z "$info_output"
        return 0
    end

    for line in (__forge_data_lines "$info_output")
        set -l key (string lower -- (__forge_field "$line" 1))
        set -l value (__forge_field "$line" 2)
        switch $key
            case model
                set -g _FORGE_PROMPT_MODEL "$value"
            case tokens
                set -g _FORGE_PROMPT_TOKENS "$value"
            case cost
                set -g _FORGE_PROMPT_COST "$value"
        end
    end
end

function __forge_format_cost -a raw_cost
    if test -z "$raw_cost"
        return 0
    end

    set -l rate 1
    if set -q FORGE_CURRENCY_RATE[1]
        set rate $FORGE_CURRENCY_RATE
    else if set -q FORGE_CURRENCY_CONVERSION[1]
        set rate $FORGE_CURRENCY_CONVERSION
    end

    set -l symbol '$'
    if set -q FORGE_CURRENCY_SYMBOL[1]
        set symbol $FORGE_CURRENCY_SYMBOL
    end

    set -l converted (math --scale=2 "$raw_cost * $rate" 2>/dev/null)
    if test $status -ne 0
        set converted $raw_cost
    end
    echo "$symbol$converted"
end
