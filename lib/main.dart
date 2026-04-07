import 'package:flutter/material.dart';

import 'poc/signature_poc_screen.dart';
import 'poc/syncfusion_poc_screen.dart';

void main() {
  runApp(const SignaturePocApp());
}

/// Side-by-side POC for ICB-21 TTD / general consent spike.
class SignaturePocApp extends StatelessWidget {
  const SignaturePocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTD Signature POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _PocHome(),
    );
  }
}

class _PocHome extends StatelessWidget {
  const _PocHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TTD / Signature POC')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SignaturePocScreen(),
                      ),
                    );
                  },
                  child: const Text('signature'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SyncfusionPocScreen(),
                      ),
                    );
                  },
                  child: const Text('syncfusion_flutter_signaturepad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
