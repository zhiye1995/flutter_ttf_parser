part of ttf_parser;

class TtfTableHead implements TtfTable {
  late num version;
  late num fontRevision;
  late int checkSumAdjustment;
  late int magicNumber;
  late int flags;
  late int unitsPerEm;
  late int created;
  late int modified;
  late int xMin;
  late int yMin;
  late int xMax;
  late int yMax;
  late int macStyle;
  late int lowestRecPPEM;
  late int fontDirectionHint;
  late int indexToLocFormat;
  late int glyphDataFormat;
  
  @override
  void parseData(StreamReader reader) {
    version = reader.read32Fixed();
    fontRevision = reader.read32Fixed();
    checkSumAdjustment = reader.readUnsignedInt();
    magicNumber = reader.readUnsignedInt();
    flags = reader.readUnsignedShort();
    unitsPerEm = reader.readUnsignedShort();
    created = reader.readDate();
    modified = reader.readDate();
    xMin = reader.readSignedShort();
    yMin = reader.readSignedShort();
    xMax = reader.readSignedShort();
    yMax = reader.readSignedShort();
    macStyle = reader.readUnsignedShort();
    lowestRecPPEM = reader.readUnsignedShort();
    fontDirectionHint = reader.readSignedShort();
    indexToLocFormat = reader.readSignedShort();
    glyphDataFormat = reader.readSignedShort();
    
    // Make sure the magic number is correct
    if (magicNumber != 0x5F0F3CF5) {
      throw ParseException("Invalid magic number in 'head' table: expected 0x5F0F3CF5, got 0x${magicNumber.toRadixString(16)}. This is not a valid TrueType font.");
    }
    
    // Validate unitsPerEm
    if (unitsPerEm < 16 || unitsPerEm > 16384) {
      throw ParseException("Invalid unitsPerEm: $unitsPerEm (must be between 16 and 16384)");
    }
  }
}
