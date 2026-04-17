# Known Differences

## Bracketed paste auto-wrap
Modern fish does not expose the same configurable bracketed-paste interception path used by the zsh plugin. This port treats `@` + `Tab` as the primary tagged-file workflow and does not block release on automatic pasted-path wrapping.

## Inline syntax-highlighting parity
This port keeps fish-native highlighting and does not attempt to recreate zsh's custom inline regex highlighter for `:` commands and `@[...]` file refs.
