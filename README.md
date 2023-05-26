# Kumobox

## Building
```
nimble build
```

Because containers might not have the same libc, static linking is enabled by default. Use musl to reduce the executable size (if using zig cc, use `-d:zigcc`), or disable static linking with `-d:nostatic`. Non-statically linked executables may prevent running commands such as `kumobox export`.
