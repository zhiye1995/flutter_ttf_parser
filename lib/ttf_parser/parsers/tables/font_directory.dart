part of ttf_parser;

class TableDirectoryEntry {
  late String name;
  late int checksum;
  late int offset;
  late int length;
}

class FontDirectory implements TtfTable {
  late int scalarType;
  late int numTables;
  late int searchRange;
  late int entrySelector;
  late int rangeShift;
  var tableEntries = <String, TableDirectoryEntry>{};

  @override
  void parseData(StreamReader reader) {
    scalarType = reader.readUnsignedInt();
    numTables = reader.readUnsignedShort();
    
    if (numTables == 0) {
      throw ParseException("Font directory contains no tables");
    }
    
    if (numTables > 100) {
      throw ParseException("Invalid number of tables: $numTables (maximum 100 expected)");
    }
    
    searchRange = reader.readUnsignedShort();
    entrySelector = reader.readUnsignedShort();
    rangeShift = reader.readUnsignedShort();
    
    // Extract the offset of each table
    for (var i = 0; i < numTables; i++) {
      var entry = TableDirectoryEntry();
      entry.name = reader.readString(4);
      
      if (entry.name.trim().isEmpty) {
        throw ParseException("Invalid table name at index $i");
      }
      
      entry.checksum = reader.readUnsignedInt();
      entry.offset = reader.readUnsignedInt();
      entry.length = reader.readUnsignedInt();
      
      if (entry.offset < 0 || entry.length < 0) {
        throw ParseException("Invalid table entry '${entry.name}': offset=${entry.offset}, length=${entry.length}");
      }
      
      tableEntries[entry.name] = entry;
    }
  }
  
  bool containsTable(String tableName) => tableEntries.containsKey(tableName);
  
  TableDirectoryEntry getTableEntry(String tableName) {
    if (!tableEntries.containsKey(tableName)) {
      throw ParseException("Cannot find table entry: $tableName");
    }
    return tableEntries[tableName]!;
  }
}
