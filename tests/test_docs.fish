function fail -a message
    echo "FAIL: $message"
    exit 1
end

set -l parity (cat docs/PARITY_MATRIX.md)
for token in '| `:ask` | `:sage` |' '| `:plan` | `:muse` |' '| `:s` | `:suggest` |' '| `:sync` | `:workspace-sync` |' '| `:login`, `:provider` | `:provider-login` |'
    if not string match -q -- "*$token*" "$parity"
        fail "parity matrix missing alias coverage for $token"
    end
end

echo 'ok docs'
