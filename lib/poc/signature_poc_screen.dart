import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

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

  Future<void> _export() async {
    if (_controller.isEmpty) {
      _toast('Canvas is empty — draw a signature first.');
      return;
    }
    final bytes = await _controller.toPngBytes();
    if (!mounted || bytes == null) {
      _toast('Export failed.');
      return;
    }
    final b64 = base64Encode(bytes);
    _toast(
      'PNG: ${bytes.length} bytes | Base64 length: ${b64.length} | '
      'points: ${_controller.points.length}',
    );
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
