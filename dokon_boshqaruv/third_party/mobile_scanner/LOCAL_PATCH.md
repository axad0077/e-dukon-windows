# Local diagnostics patch

Upstream: mobile_scanner 7.4.2, https://pub.dev/packages/mobile_scanner/versions/7.4.2
License: BSD-3-Clause (LICENSE retained).

Local Android changes:
- Preserve original start exceptions with stage/cause/stack in MethodChannel errors.
- Catch synchronous camera selection and asynchronous setup failures.
- Release native camera resources after setup failures and retain cleanup errors.
- Add a metadata-only diagnostics method and atomic analysis counters.
- Never retain barcode values, images or full-device logcat.

The remaining upstream package code is unchanged. Upstream example/test/screenshots
are omitted from this app dependency copy; runtime sources and license are included.
No claim of device verification or Android build verification is made.

Packaging: omitted example screenshot metadata and use the application flutter_lints configuration for local analysis; no runtime effect.
