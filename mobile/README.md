eMAR mobile (Flutter + Drift).

Setup:

```bash
flutter pub get
dart run build_runner build -d
flutter_rust_bridge_codegen generate \
  --rust-root rust_core \
  -r crate::api \
  -d mobile/lib \
  -c mobile/ios/Runner/bridge_generated.h
```

Run:

```bash
flutter run
```
