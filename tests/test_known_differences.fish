function fail -a message
    echo "FAIL: $message"
    exit 1
end

set -l known (cat docs/KNOWN_DIFFERENCES.md)
for needle in 'Bracketed paste auto-wrap' 'primary tagged-file workflow' 'Inline syntax-highlighting parity'
    if not string match -q -- "*$needle*" "$known"
        fail "known differences doc missing $needle"
    end
end

echo 'ok known-differences'
