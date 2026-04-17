function fail -a message
    echo "FAIL: $message"
    exit 1
end

set -l repo_root (path dirname (path dirname (status filename)))
set -l tmpdir (mktemp -d)
set -l fish_root "$tmpdir/fish"
mkdir -p "$fish_root/vendor_conf.d" "$fish_root/vendor_functions.d" "$fish_root/vendor_completions.d"
cp "$repo_root/conf.d/forgecode.fish" "$fish_root/vendor_conf.d/forgecode.fish"
cp $repo_root/functions/*.fish "$fish_root/vendor_functions.d/"
cp "$repo_root/completions/forge.fish" "$fish_root/vendor_completions.d/forge.fish"

set -l out (fish -c "source '$fish_root/vendor_conf.d/forgecode.fish'; functions -q __forge_init; and echo VENDOR_OK" 2>&1)
if not string match -q '*VENDOR_OK*' -- "$out"
    fail "vendor layout source failed: $out"
end
if string match -q '*No such file or directory*' -- "$out"
    fail "vendor layout produced missing-file errors: $out"
end

echo 'ok vendor-layout'
