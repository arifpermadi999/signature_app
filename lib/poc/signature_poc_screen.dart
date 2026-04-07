import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import 'package:gal/gal.dart';

import 'save_png.dart';

/// POC: capture signature with the `signature` package and export PNG + Base64.
class SignaturePocScreen extends StatefulWidget {
  const SignaturePocScreen({super.key});

  @override
  State<SignaturePocScreen> createState() => _SignaturePocScreenState();
}

class _SignaturePocScreenState extends State<SignaturePocScreen> {
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

  Future<void> _downloadPng() async {
    if (_controller.isEmpty) {
      _toast('Canvas is empty — draw a signature first.');
      return;
    }
    final bytes = await _controller.toPngBytes();
    if (!mounted || bytes == null) {
      _toast('Export failed.');
      return;
    }
    try {
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
      appBar: AppBar(title: const Text('signature')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'package: signature',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey.shade100,
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.grey.shade200,
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
                  onPressed: _controller.clear,
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: _downloadPng,
                  child: const Text('Save to png'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
