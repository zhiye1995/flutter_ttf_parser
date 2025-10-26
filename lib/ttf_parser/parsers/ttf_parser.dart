part of ttf_parser;

class TtfParser {
  TtfFont parse(List<int> data) {
    try {
      if (data.isEmpty) {
        throw TtfParseException("Cannot parse empty font data");
      }

      if (data.length < 12) {
        throw TtfParseException("Font data too small (${data.length} bytes), minimum 12 bytes required");
      }

      var reader = ByteArrayStreamReader(data);
      var font = TtfFont();
      
      // Parse font directory
      try {
        font.directory.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse font directory: $e");
      }

      // Parse the head table (required)
      try {
        var headEntry = font.directory.getTableEntry("head");
        reader.seek(headEntry.offset);
        font.head.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'head' table: $e");
      }

      // Parse the name table (required)
      try {
        var nameEntry = font.directory.getTableEntry("name");
        reader.seek(nameEntry.offset);
        font.name.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'name' table: $e");
      }
      
      // Parse the maxp table (required)
      try {
        var maxpEntry = font.directory.getTableEntry("maxp");
        reader.seek(maxpEntry.offset);
        font.maxp.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'maxp' table: $e");
      }

      // Parse char map table (required)
      try {
        var cmapEntry = font.directory.getTableEntry("cmap");
        reader.seek(cmapEntry.offset);
        font.cmap.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'cmap' table: $e");
      }
      
      // Parse the horizontal header table (required)
      try {
        var hheaEntry = font.directory.getTableEntry("hhea");
        reader.seek(hheaEntry.offset);
        font.hhea.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'hhea' table: $e");
      }
      
      // Parse the horizontal metrics table (required)
      try {
        var hmtxEntry = font.directory.getTableEntry("hmtx");
        reader.seek(hmtxEntry.offset);
        font.hmtx.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'hmtx' table: $e");
      }
      
      // Parse the glyph locations table (required)
      try {
        var locaEntry = font.directory.getTableEntry("loca");
        reader.seek(locaEntry.offset);
        font.loca.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'loca' table: $e");
      }
      
      // Parse the glyph data table (required)
      try {
        var glyfEntry = font.directory.getTableEntry("glyf");
        reader.seek(glyfEntry.offset);
        font.glyf.parseData(reader);
      } catch (e) {
        throw TtfParseException("Failed to parse 'glyf' table: $e");
      }

      // Parse the kerning table (optional)
      if (font.directory.containsTable("kern")) {
        try {
          var kernEntry = font.directory.getTableEntry("kern");
          reader.seek(kernEntry.offset);
          font.kern.parseData(reader);
        } catch (e) {
          // Kerning is optional, so we can continue if it fails
          // print("Warning: Failed to parse 'kern' table: $e");
        }
      }

      return font;
    } catch (e) {
      if (e is TtfParseException || e is EOFException) {
        rethrow;
      }
      throw TtfParseException("Unexpected error parsing TTF font: $e");
    }
  }
}
