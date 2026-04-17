function setup_forge_test_env
    set -l root (path dirname (path dirname (status filename)))
    set -gx FORGE_BIN "$root/tests/stub-forge.py"
    set -gx FORGE_FZF_MOCK 1
    set -gx FORGE_DISABLE_BACKGROUND 1
    set -gx FORGE_TEST_TMPDIR (mktemp -d)
    set -gx FORGE_STUB_STATE "$FORGE_TEST_TMPDIR/state.json"
    set -gx FORGE_STUB_LOG "$FORGE_TEST_TMPDIR/log.jsonl"
    set -gx FORGE_STUB_CONFIG_PATH "$FORGE_TEST_TMPDIR/forge.toml"
    set -gx FORGE_CLIPBOARD_FILE "$FORGE_TEST_TMPDIR/clipboard.txt"
    set -gx XDG_DATA_HOME "$FORGE_TEST_TMPDIR/xdg"
    set -gx FORGE_EDIT_DIR "$FORGE_TEST_TMPDIR/edit"
    mkdir -p "$XDG_DATA_HOME" "$FORGE_EDIT_DIR"
    rm -f "$FORGE_STUB_STATE" "$FORGE_STUB_LOG" "$FORGE_CLIPBOARD_FILE" "$FORGE_STUB_CONFIG_PATH"
    set -e _FORGE_TEST_BUFFER
    source "$root/conf.d/forgecode.fish"
end

function fail -a message
    echo "FAIL: $message"
    exit 1
end

function assert_eq -a expected actual label
    if test "$expected" != "$actual"
        fail "$label (expected '$expected', got '$actual')"
    end
end

function assert_contains -a haystack needle label
    if not string match -q -- "*$needle*" "$haystack"
        fail "$label (missing '$needle' in '$haystack')"
    end
end

function assert_file_contains -a file needle label
    if not test -f "$file"
        fail "$label (missing file $file)"
    end
    if not grep -Fq -- "$needle" "$file"
        fail "$label (missing '$needle' in $file)"
    end
end

function stub_log_count
    if not test -f "$FORGE_STUB_LOG"
        echo 0
        return 0
    end
    wc -l < "$FORGE_STUB_LOG" | string trim
end

function stub_log_last_field -a field
    if not test -f "$FORGE_STUB_LOG"
        return 1
    end
    python3 -c 'import json, sys
path, field = sys.argv[1:]
with open(path) as fh:
    row = json.loads(fh.readlines()[-1])
value = row
for part in field.split("."):
    if part.isdigit():
        value = value[int(part)]
    else:
        value = value.get(part, "")
if isinstance(value, list):
    print(" ".join(str(v) for v in value))
else:
    print(value)' "$FORGE_STUB_LOG" "$field"
end
function stub_log_field_from_end -a offset field
    if not test -f "$FORGE_STUB_LOG"
        return 1
    end
    python3 -c 'import json, sys
path, offset, field = sys.argv[1:]
offset = int(offset)
with open(path) as fh:
    rows = [json.loads(line) for line in fh if line.strip()]
row = rows[-offset]
value = row
for part in field.split("."):
    if part.isdigit():
        value = value[int(part)]
    else:
        value = value.get(part, "")
if isinstance(value, list):
    print(" ".join(str(v) for v in value))
else:
    print(value)' "$FORGE_STUB_LOG" "$offset" "$field"
end

function stub_log_last_json
    if not test -f "$FORGE_STUB_LOG"
        return 1
    end
    tail -n 1 "$FORGE_STUB_LOG"
end
