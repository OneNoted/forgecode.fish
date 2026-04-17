source (path dirname (status filename))/test_support.fish
setup_forge_test_env

set -gx FORGE_FZF_CHOICE sage
__forge_complete_command ':sa'
assert_eq ':sage ' $_FORGE_TEST_BUFFER 'command completion replaces buffer'
set -e FORGE_FZF_CHOICE

set -gx FORGE_FZF_CHOICE src/main.fish
__forge_complete_file_ref '@src' ': review @src'
assert_eq ': review @[src/main.fish]' $_FORGE_TEST_BUFFER 'file completion inserts tagged path'
set -e FORGE_FZF_CHOICE

set -gx FORGE_STUB_FAIL_LIST_FILES 1
set -gx FORGE_FZF_CHOICE README.md
__forge_complete_file_ref '@REA' ': review @REA'
assert_eq ': review @[README.md]' $_FORGE_TEST_BUFFER 'fd/find fallback still inserts path'
set -e FORGE_STUB_FAIL_LIST_FILES
set -e FORGE_FZF_CHOICE

echo 'ok completion'
