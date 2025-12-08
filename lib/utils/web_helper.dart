// Stub file for non-web platforms
import 'dart:typed_data';

void downloadFileWeb(Uint8List bytes, String fileName) {
  // No-op on non-web platforms
  throw UnsupportedError('Web download not supported on this platform');
}
