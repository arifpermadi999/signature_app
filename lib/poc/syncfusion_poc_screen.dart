import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

/// POC: capture signature with Syncfusion SignaturePad and export PNG + Base64.
class SyncfusionPocScreen extends StatefulWidget {
  const SyncfusionPocScreen({super.key});

  @override
  State<SyncfusionPocScreen> createState() => _SyncfusionPocScreenState();
}

class _SyncfusionPocScreenState extends State<SyncfusionPocScreen> {
  final GlobalKey<SfSignaturePadState> _padKey = GlobalKey<SfSignaturePadState>();

  Future<void> _export() async {
    final state = _padKey.currentState;
    if (state == null) {
      _toast('Pad not ready.');
      return;
    }
    try {
      final ui.Image image = await state.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted || byteData == null) {
        _toast('Export failed.');
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      final b64 = base64Encode(bytes);
      _toast('PNG: ${bytes.length} bytes | Base64 length: ${b64.length}');
    } catch (e) {
      if (mounted) {
        _toast('Export error: $e');
      }
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'package: syncfusion_flutter_signaturepad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey.shade100,
              ),
              child: SfSignaturePad(
                key: _padKey,
                backgroundColor: Colors.white,
                strokeColor: Colors.black,
                minimumStrokeWidth: 1,
                maximumStrokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () => _padKey.currentState?.clear(),
                child: const Text('Clear'),
              ),
              FilledButton(
                onPressed: _export,
                child: const Text('Export PNG + Base64 info'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
