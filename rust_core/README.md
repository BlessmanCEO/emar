Rust core for shared eMAR logic.

FRB codegen (run from repo root):

```bash
cargo install flutter_rust_bridge_codegen
flutter_rust_bridge_codegen generate \
  --rust-root rust_core \
  -r crate::api \
  -d mobile/lib \
  -c mobile/ios/Runner/bridge_generated.h
```

Build (from `rust_core`):

```bash
cargo build
```
