# Contributing

Run the stable toolchain validation loop before opening a change:

```bash
moon version --all
moon fmt --check
moon check --deny-warn
moon build --target all
moon test --target wasm-gc --deny-warn
moon test --target native --deny-warn
moon run cmd/main
moon info
```

Keep public types in the root package, add black-box tests for new behavior, and update the README or roadmap when the supported scope changes.
