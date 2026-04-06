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
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('TTD / Signature POC'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'signature'),
                Tab(text: 'SfSignaturePad'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SignaturePocScreen(),
              SyncfusionPocScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
