import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:gal/gal.dart';

import 'save_png.dart';

/// POC: capture signature with Syncfusion SignaturePad and export PNG + Base64.
class SyncfusionPocScreen extends StatefulWidget {
  const SyncfusionPocScreen({super.key});

  @override
  State<SyncfusionPocScreen> createState() => _SyncfusionPocScreenState();
}

class _SyncfusionPocScreenState extends State<SyncfusionPocScreen> {
  final GlobalKey<SfSignaturePadState> _padKey =
      GlobalKey<SfSignaturePadState>();

  Future<Uint8List?> _capturePngBytes() async {
    final state = _padKey.currentState;
    if (state == null) {
      return null;
    }
    final ui.Image image = await state.toImage(pixelRatio: 3.0);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return null;
      }
      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _downloadPng() async {
    try {
      final bytes = await _capturePngBytes();
      if (!mounted) return;
      if (bytes == null) {
        _toast('Pad not ready or export failed.');
        return;
      }
      await saveSignaturePng(bytes);
      if (!mounted) return;
      _toast('Saved to gallery');
    } on GalException catch (e) {
      if (mounted) {
        _toast(e.toString());
      }
    } catch (e) {
      if (mounted) {
        _toast('Save failed: $e');
      }
    }
  }


  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SfSignaturePad')),
      body: Padding(
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
                  onPressed: _downloadPng,
                  child: const Text('Save to png'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
