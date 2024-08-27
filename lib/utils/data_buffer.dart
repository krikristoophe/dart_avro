import 'dart:convert';
import 'dart:typed_data';

/// Wrapper for ByteBuffer
/// Used to keep count of offset while reading buffer
class DataBuffer {
  ///
  DataBuffer(this.buffer);

  /// Buffer with data
  final ByteBuffer buffer;

  /// Current buffer offset
  int offset = 0;

  /// Get next [length] bytes from buffer
  Uint8List next(int length) {
    offset += length;
    return buffer.asUint8List(offset - length, length);
  }

  /// Read bool from buffer
  bool readBool() {
    final data = next(1);

    return data[0] == 1;
  }

  /// Read long/int from buffer
  int readLong() {
    // Converted to dart from js avsc library
    int n = 0;
    int k = 0;
    int b;
    int h;
    int f;
    int fk;

    do {
      b = next(1)[0];
      h = b & 0x80;
      n |= (b & 0x7f) << k;
      k += 7;
    } while (h != 0 && k < 28);

    if (h != 0) {
      // Switch to float arithmetic, otherwise we might overflow.
      f = n;
      fk = 268435456; // 2 ** 28.
      do {
        b = next(1)[0];
        f += (b & 0x7f) * fk;
        fk *= 128;
      } while ((b & 0x80) != 0);
      return ((f % 2) != 0 ? -(f + 1) : f) ~/ 2;
    }

    return (n >> 1) ^ -(n & 1);
  }

  /// Read double from buffer
  double readDouble() {
    return ByteData.sublistView(next(8)).getFloat64(0, Endian.little);
  }

  /// Read float from buffer
  double readFloat() {
    return ByteData.sublistView(next(4)).getFloat32(0, Endian.little);
  }

  /// Read String from buffer
  String readString() {
    return utf8.decode(next(readLong()));
  }
}
