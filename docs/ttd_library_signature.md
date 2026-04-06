# Technical spike: `signature` package (Flutter TTD / e-signature)

**Related story:** [ICB-21](https://infokes.atlassian.net/browse/ICB-21) (General consent — signature capture).

This document focuses on the [`signature`](https://pub.dev/packages/signature) library. A companion document covers [`syncfusion_flutter_signaturepad`](./ttd_library_syncfusion_signaturepad.md).

---

## 1. Library overview

| Item | Detail |
|------|--------|
| **Package** | [`signature`](https://pub.dev/packages/signature) |
| **Publisher** | [4q.eu](https://pub.dev/publishers/4q.eu) (verified on pub.dev) |
| **License** | [MIT](https://pub.dev/packages/signature/license) |
| **Implementation** | Pure Flutter / Dart (no native platform channel required for drawing) |
| **Platforms (declared)** | Android, iOS, Linux, macOS, Web, Windows (per pub.dev listing) |
| **Current version (POC)** | `6.3.0` |

The package provides a `Signature` canvas widget driven by a `SignatureController`. It is positioned as a performance-oriented, cross-platform signature capture solution with configurable pen style, bounds, and **restoration from saved stroke data**.

---

## 2. Credibility signals

- **Adoption:** High download count and strong pub.dev engagement (likes / points) relative to many alternatives.
- **Open source:** Source and issue tracker on GitHub (`4Q-s-r-o/signature`).
- **Licensing:** MIT — straightforward for redistribution in proprietary apps; no vendor registration or community-license flow.
- **Maintenance:** Regular releases; changelog and migration notes published on pub.dev.
- **Risk note:** Like any third-party package, you should pin versions in `pubspec.yaml` and run your own regression tests on target devices (especially low-end Android and web).

---

## 3. Outputs you can produce (backend / document compatibility)

| Output | API / mechanism | Typical use |
|--------|-----------------|-------------|
| **PNG bytes** | `SignatureController.toPngBytes({width, height})` → `Future<Uint8List?>` | Upload as file, embed in PDF, store in object storage |
| **`dart:ui` image** | `toImage({width, height})` → `Future<ui.Image?>` | Custom encoding or further processing |
| **Base64 string** | `base64Encode(bytes)` from `dart:convert` after PNG export | JSON APIs that accept inline image data |
| **Raw SVG string** | `toRawSVG({width, height, minDistanceBetweenPoints})` → `String?` | Vector workflows, smaller archival format (with caveats on fidelity) |
| **Stroke points** | `SignatureController.points` (serializable `Point` list) | Replay on canvas, tamper-evident payloads, very compact transport (not a standard image) |

**Empty canvas:** `toPngBytes` / `toImage` return `null` when there are no strokes; use `controller.isEmpty` / `isNotEmpty` before export.

**Cropping:** PNG export can be limited to the drawn bounding region (see package behavior and optional explicit width/height). This keeps payloads smaller than always exporting a full fixed canvas.

---

## 4. Comparison with `syncfusion_flutter_signaturepad` (summary)

| Dimension | `signature` | `syncfusion_flutter_signaturepad` |
|-----------|-------------|-----------------------------------|
| **License** | MIT | Commercial; **requires** Syncfusion commercial or [Community License](https://www.syncfusion.com/products/communitylicense) |
| **Vendor lock-in** | Low | Higher (ecosystem tied to Syncfusion releases) |
| **Stroke rendering** | Standard vector strokes | Speed-based variable width for a more “pen on paper” feel |
| **Stroke data export** | Yes (`points`, SVG) | Primarily image-oriented in typical usage |
| **Web edge cases** | Same Flutter canvas model across targets | Mobile web may need `renderToContext2D` path (per Syncfusion docs) |
| **Support** | Community / GitHub issues | Commercial support channels |

---

## 5. Recommendation (project default)

**For the general-consent TTD spike, the recommended default is `signature`.**

**Reasons:**

1. **License clarity:** MIT avoids Syncfusion license registration, compliance review, and renewal overhead unless the organization already standardizes on Syncfusion.
2. **Outputs match typical API contracts:** PNG → Base64 is trivial and widely accepted by backends and document pipelines.
3. **Extra export options:** Point lists and raw SVG give flexibility if product or legal later requires vector storage or stroke-level audit data.
4. **Cross-platform consistency:** Single mental model for export on mobile and desktop web without maintaining a separate mobile-web image path.

**When to prefer Syncfusion instead:** The team already holds a Syncfusion license, uses other Syncfusion Flutter widgets, or explicitly prioritizes Syncfusion’s variable-width stroke rendering and vendor support over MIT-only dependencies. See the companion document for details.

---

## 6. Sample usage (validated pattern)

The following pattern matches the package example and the POC in this repository (`lib/poc/signature_poc_screen.dart`).

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureDemo extends StatefulWidget {
  const SignatureDemo({super.key});

  @override
  State<SignatureDemo> createState() => _SignatureDemoState();
}

class _SignatureDemoState extends State<SignatureDemo> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportPngBase64() async {
    if (_controller.isEmpty) {
      // Handle validation for consent flows
      return;
    }
    final Uint8List? png = await _controller.toPngBytes();
    if (png == null) return;

    final String base64Png = base64Encode(png);
    // Send base64Png to API, or write png to file
    debugPrint('Base64 length: ${base64Png.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        Row(
          children: [
            TextButton(onPressed: _controller.clear, child: const Text('Clear')),
            TextButton(onPressed: _exportPngBase64, child: const Text('Export PNG → Base64')),
          ],
        ),
      ],
    );
  }
}
```

**Persistence / restore (optional):**

```dart
// After capture
final saved = _controller.points;

// Later: new controller with same strokes
final restored = SignatureController(points: saved);
```

---

## 7. References

- Package: https://pub.dev/packages/signature  
- API docs: https://pub.dev/documentation/signature/latest/  
- Repository: https://github.com/4Q-s-r-o/signature  

POC implementation: `lib/poc/signature_poc_screen.dart` in this project.
