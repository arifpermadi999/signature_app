import 'dart:typed_data';

import 'package:gal/gal.dart';

/// Saves PNG [bytes] to the device photo gallery.
Future<void> saveSignaturePng(Uint8List bytes, {String? name}) async {
  final granted = await Gal.requestAccess();
  if (!granted) {
    throw Exception('Permission to save to Photos was denied.');
  }
  final base = name ?? 'signature_${DateTime.now().millisecondsSinceEpoch}';
  await Gal.putImageBytes(bytes, name: base);
}
