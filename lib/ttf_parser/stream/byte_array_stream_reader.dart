part of ttf_parser;

class ByteArrayStreamReader extends StreamReader {

  List<int> data;
  int position = 0;
  
  ByteArrayStreamReader(this.data) {
    if (data.isEmpty) {
      throw TtfParseException("Cannot create reader from empty data");
    }
  }
  
  @override
  int read() {
    if (position >= data.length) {
      throw EOFException("Cannot read beyond end of data at position $position (length: ${data.length})");
    }
    return data[position++];
  }
  
  @override
  List<int> readBytes(int count) {
    if (count < 0) {
      throw TtfParseException("Cannot read negative number of bytes: $count");
    }
    if (position + count > data.length) {
      throw EOFException("Cannot read $count bytes at position $position (length: ${data.length})");
    }
    var result = <int>[];
    result.addAll(data.getRange(position, position + count));
    position += count;
    return result;
  }

  @override
  void close() {
  }

  @override
  void seek(int position) {
    if (position < 0) {
      throw TtfParseException("Cannot seek to negative position: $position");
    }
    if (position > data.length) {
      throw TtfParseException("Cannot seek beyond data length: $position > ${data.length}");
    }
    this.position = position;
  }
  
  @override
  int get currentPosition => position;
  
  @override
  List<int> readOffsetFromArray(int offset, int length) {
    if (offset < 0 || length < 0) {
      throw TtfParseException("Invalid offset or length: offset=$offset, length=$length");
    }
    if (offset + length > data.length) {
      throw EOFException("Cannot read range [$offset, ${offset + length}) from data of length ${data.length}");
    }
    return data.getRange(offset, offset + length).toList();
  }
  
}
