part of ttf_parser;

abstract class StreamReader {
  
  // Reads a 16.16 fixed value. The first 16 bits represent the decimal
  // and the last 16 bits represent the fraction
  num read32Fixed() {
    num value = readSignedShort();
    value += (readUnsignedShort() / 65536);
    return value;
  }
  
  String readString(int length) {
    var buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.writeCharCode(read());
    }
    return buffer.toString();
  }

  String readStringUtf8(int length) {
    List<int> data = readBytes(length);
    return const Utf8Codec().decode(data);
  }
  
  String readStringUtf16BE(int length) {
    List<int> data = readBytes(length);
    // UTF-16 Big Endian: 每两个字节组成一个字符
    if (length % 2 != 0) {
      throw TtfParseException("UTF-16 string length must be even: $length");
    }
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i += 2) {
      int codeUnit = (data[i] << 8) | data[i + 1];
      buffer.writeCharCode(codeUnit);
    }
    return buffer.toString();
  }
  
  String readStringMacRoman(int length) {
    List<int> data = readBytes(length);
    // MacRoman 编码，大部分与 ASCII 兼容
    // 对于基本的 ASCII 字符直接转换
    StringBuffer buffer = StringBuffer();
    for (int byte in data) {
      if (byte == 0) break; // 遇到 null 终止符
      // 简单处理：0-127 直接映射，128-255 也尝试直接映射
      buffer.writeCharCode(byte);
    }
    return buffer.toString();
  }

  // Read a signed byte from the stream
  int readSignedByte() {
    int value = read();
    return value < 127 ? value : value - 256;
  }
  
  int readUnsignedInt() {
    int byte1 = read();
    int byte2 = read();
    int byte3 = read();
    int byte4 = read();
    if (byte4 < 0) {
      throw EOFException("End of stream reached");
    }
    
    return (byte1 << 24) + (byte2 << 16) + (byte3 << 8) + (byte4);
  }
  
  // Read a long value from the stream
  int readSignedInt() {
    int value = readUnsignedInt();
    if ((value & 0x80000000) > 0) {
      // This is a negative number.  Invert the bits and add 1
      value = (~value & 0xFFFFFFFF) + 1;
      
      // Add a negative sign
      value = -value;
    }
    return value;
  }
  
  // Read an unsigned short
  int readUnsignedShort() {
    int byte1 = read();
    int byte2 = read();
    if (byte2 < 0) {
      throw EOFException("End of stream reached");
    }
    
    return (byte1 << 8) + (byte2);
  }
  
  // Read a short from the stream
  int readSignedShort() {
    int value = readUnsignedShort();
    if ((value & 0x8000) > 0) {
      // This is a negative number.  Invert the bits and add 1 and negate it
      value = (~value & 0xFFFF) + 1;
      value = -value;
    }
    return value;
  }
  
  // Read the data
  int readDate() {
    int epoch = readUnsignedInt();
    epoch = (epoch << 32) + readUnsignedInt();
    return epoch;
  }

  
  // Read an unsigned byte
  int read();
  
  // Read an unsigned byte
  List<int> readBytes(int count);
  
  // Close the stream
  void close();

  // Seek to the specified position in the stream
  void seek(int position);
  
  // Get the current seek position of the stream
  int get currentPosition;
  
  List<int> readOffsetFromArray(int offset, int length);
  
}
