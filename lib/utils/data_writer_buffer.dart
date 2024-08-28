import 'dart:typed_data';

/// Wrapper for Uint8List
/// Used to ensure buffer grow on use
class DataWriterBuffer {
  ///
  DataWriterBuffer();

  /// Buffer with data
  Uint8List buffer = Uint8List(0);

  /// Get value from buffer at index [i]
  int operator [](int i) {
    _ensurePosition(i);
    return buffer[i];
  }

  /// Set [value] to buffer at index [i]
  void operator []=(int i, int value) {
    _ensurePosition(i);
    buffer[i] = value;
  }

  /// Ensure buffer have minimum size for [pos] use
  void _ensurePosition(int pos) {
    if (pos + 1 > buffer.length) {
      buffer = Uint8List.fromList([
        ...buffer,
        ...List.generate(pos + 1 - buffer.length, (_) => 0),
      ]);
    }
  }
}
