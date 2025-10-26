part of ttf_parser;

class TtfTableName implements TtfTable {
  late int format;
  late int count;
  late int stringOffset;
  
  String? copyright;
  String? fontFamily;
  String? subFamily;
  String? subFamilyID;
  String? fontName;
  String? nameTableVersion;
  String? fontNamePostScript;
  String? trademarkNotice;
  String? manufacturer;
  
  @override
  void parseData(StreamReader reader) {
    int basePosition = reader.currentPosition;
    format = reader.readUnsignedShort();
    count = reader.readUnsignedShort();
    stringOffset = reader.readUnsignedShort();
    
    if (count > 1000) {
      throw ParseException("Invalid name table: too many entries ($count)");
    }
    
    // 存储所有的 name 记录，优先使用 Windows 平台的
    Map<int, List<_NameRecord>> nameRecords = {};
    
    for (var i = 0; i < count; i++) {
      // Read the row entry
      int platformID = reader.readUnsignedShort();
      int platformSpecificID = reader.readUnsignedShort();
      int languageID = reader.readUnsignedShort();
      int nameID = reader.readUnsignedShort();
      int length = reader.readUnsignedShort();
      int offset = reader.readUnsignedShort();
      
      // 记录所有支持的平台的字符串
      // Platform ID: 1 = Macintosh, 3 = Windows
      if (platformID == 1 || platformID == 3) {
        if (!nameRecords.containsKey(nameID)) {
          nameRecords[nameID] = [];
        }
        nameRecords[nameID]!.add(_NameRecord(
          platformID: platformID,
          platformSpecificID: platformSpecificID,
          languageID: languageID,
          nameID: nameID,
          length: length,
          offset: offset,
        ));
      }
    }
    
    // 解析字符串，优先使用 Windows 平台 (platformID == 3)
    for (var nameID in nameRecords.keys) {
      var records = nameRecords[nameID]!;
      
      // 优先选择 Windows 平台的记录
      records.sort((a, b) {
        if (a.platformID == 3 && b.platformID != 3) return -1;
        if (a.platformID != 3 && b.platformID == 3) return 1;
        return 0;
      });
      
      // 尝试解析字符串
      for (var record in records) {
        try {
          int currentPosition = reader.currentPosition;
          reader.seek(basePosition + stringOffset + record.offset);
          
          String value;
          if (record.platformID == 3) {
            // Windows 平台，使用 UTF-16 Big Endian
            value = reader.readStringUtf16BE(record.length);
          } else if (record.platformID == 1) {
            // Macintosh 平台，使用 MacRoman 编码
            value = reader.readStringMacRoman(record.length);
          } else {
            continue;
          }
          
          reader.seek(currentPosition);
          _registerString(record.nameID, value);
          break; // 成功解析后跳出
        } catch (e) {
          // 解码失败，尝试下一个记录
          continue;
        }
      }
    }
  }
  
  void _registerString(int nameID, String value) {
    if (value.isEmpty) return;
    
    // 清理字符串，移除不可见字符
    value = value.trim();
    if (value.isEmpty) return;
    
    switch(nameID) {
      case 0: copyright = value; break;
      case 1: fontFamily = value; break;
      case 2: subFamily = value; break;
      case 3:  subFamilyID = value; break;
      case 4:  fontName = value; break;
      case 5:  nameTableVersion = value; break;
      case 6:  fontNamePostScript = value; break;
      case 7:  trademarkNotice = value; break;
      case 8:  manufacturer = value; break;
    }
  }
}

class _NameRecord {
  final int platformID;
  final int platformSpecificID;
  final int languageID;
  final int nameID;
  final int length;
  final int offset;
  
  _NameRecord({
    required this.platformID,
    required this.platformSpecificID,
    required this.languageID,
    required this.nameID,
    required this.length,
    required this.offset,
  });
}
