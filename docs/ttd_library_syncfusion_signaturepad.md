# Technical spike: `syncfusion_flutter_signaturepad` (Flutter TTD / e-signature)

**Related story:** [ICB-21](https://infokes.atlassian.net/browse/ICB-21) (General consent — signature capture).

This document focuses on the [`syncfusion_flutter_signaturepad`](https://pub.dev/packages/syncfusion_flutter_signaturepad) library. A companion document covers [`signature`](./ttd_library_signature.md).

---

## 1. Library overview

| Item | Detail |
|------|--------|
| **Package** | [`syncfusion_flutter_signaturepad`](https://pub.dev/packages/syncfusion_flutter_signaturepad) |
| **Publisher** | [syncfusion.com](https://pub.dev/publishers/syncfusion.com) (verified on pub.dev) |
| **License** | **Commercial / Community License** — not a permissive OSS license like MIT. You must comply with [Syncfusion licensing](https://github.com/syncfusion/flutter-examples/blob/master/LICENSE). |
| **Implementation** | Dart widget built on Flutter rendering; depends on `syncfusion_flutter_core` |
| **Platforms** | Intended for Flutter targets where the widget is supported; export APIs differ slightly for **web mobile browsers** vs desktop/native (see §3). |
| **Current version (POC)** | `33.1.46` |

`SfSignaturePad` captures signatures with a **velocity-sensitive stroke model** (minimum/maximum stroke width), which tends to look more like natural handwriting than a fixed-width pen.

---

## 2. Credibility signals

- **Vendor:** Syncfusion, Inc. — long-established component vendor (since 2001) with large customer base and formal support, documentation, and KB.
- **Documentation:** User guide and API reference linked from pub.dev; examples in the official `flutter-widgets` monorepo.
- **Adoption:** Strong download numbers on pub.dev; common choice in enterprises already licensed for Syncfusion.
- **Legal / compliance:** Using this package **without** an appropriate Syncfusion license is a compliance risk. Plan for license registration, renewal, and possibly legal review before production.
- **Risk note:** Tight coupling to Syncfusion release cadence and SDK constraints (`syncfusion_flutter_signaturepad` declares minimum Flutter SDK in its `pubspec.yaml`).

---

## 3. Outputs you can produce (backend / document compatibility)

| Output | API / mechanism | Typical use |
|--------|-----------------|-------------|
| **`dart:ui` image** | `GlobalKey<SfSignaturePadState>` → `await state.toImage(pixelRatio: …)` | Intermediate step for PNG/JPEG |
| **PNG bytes** | `image.toByteData(format: ImageByteFormat.png)` → `Uint8List` | Same as `signature` for APIs and PDF embedding |
| **Base64** | `base64Encode(pngBytes)` | JSON payloads |
| **JPEG (web / canvas)** | `renderToContext2D` + `canvas.toBlob('image/jpeg', …)` (mobile web path in Syncfusion docs) | When JPEG is required on specific web clients |
| **Stroke point export** | Not the primary documented workflow; typical integration is **raster export** | If you need vector/point replay, validate whether current API meets requirements or add a custom layer |

**Clear:** `signaturePadKey.currentState?.clear()`.

**Web caveat:** Syncfusion documents **different** export approaches for desktop web vs mobile web (`toImage` vs `renderToContext2D`). Your team should test both renderers (`html` vs `canvaskit`) if ePuS Connect ships a Flutter web build.

---

## 4. Comparison with `signature` (summary)

| Dimension | `syncfusion_flutter_signaturepad` | `signature` |
|-----------|-----------------------------------|-------------|
| **License** | Commercial / Community License | MIT |
| **Stroke look** | Variable width from gesture speed | Fixed pen width (configurable) |
| **Enterprise support** | Formal vendor support | Community / maintainer |
| **Dependencies** | `syncfusion_flutter_core`, `web` | `flutter_svg` (for SVG-related features) |
| **Export ergonomics** | GlobalKey + `State.toImage()` | Controller `toPngBytes()` directly |
| **Web mobile** | Documented special path | Standard Flutter canvas export path |

---

## 5. Recommendation

**Default for this spike:** Prefer **`signature`** (see companion doc) when the goal is minimal legal overhead, MIT-only dependencies, and straightforward PNG/Base64 for consent storage.

**Choose `syncfusion_flutter_signaturepad` when:**

- The organization **already** has a valid Syncfusion license covering the app.
- Product design explicitly wants **velocity-based** stroke rendering.
- You want **vendor-backed** support and long-form documentation for enterprise audits.

If Syncfusion is selected, add explicit tasks for: license registration, periodic compliance check, and **web QA** (including mobile browsers) for image export.

---

## 6. Sample usage (validated pattern)

Aligned with the official example and the POC in this repository (`lib/poc/syncfusion_poc_screen.dart`).

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SyncfusionSignatureDemo extends StatefulWidget {
  const SyncfusionSignatureDemo({super.key});

  @override
  State<SyncfusionSignatureDemo> createState() => _SyncfusionSignatureDemoState();
}

class _SyncfusionSignatureDemoState extends State<SyncfusionSignatureDemo> {
  final GlobalKey<SfSignaturePadState> _padKey = GlobalKey<SfSignaturePadState>();

  Future<void> _exportPngBase64() async {
    final state = _padKey.currentState;
    if (state == null) return;

    final ui.Image image = await state.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final Uint8List png = byteData.buffer.asUint8List();
    final String base64Png = base64Encode(png);
    debugPrint('Base64 length: ${base64Png.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: SfSignaturePad(
            key: _padKey,
            backgroundColor: Colors.grey.shade200,
            strokeColor: Colors.black,
            minimumStrokeWidth: 1,
            maximumStrokeWidth: 4,
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _padKey.currentState?.clear(),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: _exportPngBase64,
              child: const Text('Export PNG → Base64'),
            ),
          ],
        ),
      ],
    );
  }
}
```

For **Flutter web on mobile browsers**, follow Syncfusion’s `renderToContext2D` + blob workflow from the package README on pub.dev.

---

## 7. References

- Package: https://pub.dev/packages/syncfusion_flutter_signaturepad  
- API docs: https://pub.dev/documentation/syncfusion_flutter_signaturepad/latest/  
- Product / docs hub: https://help.syncfusion.com/flutter/introduction/overview  
- Source tree: https://github.com/syncfusion/flutter-widgets/tree/master/packages/syncfusion_flutter_signaturepad  

POC implementation: `lib/poc/syncfusion_poc_screen.dart` in this project.
