part of ttf_parser;

class TtfTableGlyf implements TtfTable {
  TtfFont font;
  TtfTableGlyf(this.font);
  
  // Glyph index to info mapping
  var glyphInfoMap = <int, GlyphInfo>{};
  
  @override
  void parseData(StreamReader reader) {
    var offsets = font.loca.glyphOffsets;
    var baseOffset = reader.currentPosition;
    
    int glyphIndex = 0;
    for (var i = 0; i < offsets.length - 1; i++) {
      int offset = offsets[i];
      int nextOffset = offsets[i + 1];
      
      // Skip empty glyphs
      if (offset == nextOffset) {
        glyphIndex++;
        continue;
      }
      
      reader.seek(baseOffset + offset);
      var glyphInfo = GlyphInfo();
      glyphInfo.index = glyphIndex;
      glyphInfo.numberOfContours = reader.readSignedShort();
      glyphInfo.xMin = reader.readSignedShort();
      glyphInfo.yMin = reader.readSignedShort();
      glyphInfo.xMax = reader.readSignedShort();
      glyphInfo.yMax = reader.readSignedShort();
      
      // Parse simple glyph contour data
      if (glyphInfo.numberOfContours > 0) {
        _parseSimpleGlyph(reader, glyphInfo);
      }
      // Composite glyphs (numberOfContours < 0) not fully supported yet
      
      glyphInfoMap[glyphIndex] = glyphInfo;
      glyphIndex++;
    }
  }
  
  void _parseSimpleGlyph(StreamReader reader, GlyphInfo glyphInfo) {
    int nContours = glyphInfo.numberOfContours;
    
    // Read endPtsOfContours array
    List<int> endPtsOfContours = [];
    for (int i = 0; i < nContours; i++) {
      endPtsOfContours.add(reader.readUnsignedShort());
    }
    glyphInfo.endPtsOfContours = endPtsOfContours;
    
    if (endPtsOfContours.isEmpty) return;
    
    int nPoints = endPtsOfContours.last + 1;
    
    // Read instruction length and skip instructions
    int instructionLength = reader.readUnsignedShort();
    for (int i = 0; i < instructionLength; i++) {
      reader.read();
    }
    
    // Read flags
    List<int> flags = [];
    while (flags.length < nPoints) {
      int flag = reader.read();
      flags.add(flag);
      
      // Check for repeat flag
      if ((flag & 0x08) != 0) {
        int repeatCount = reader.read();
        for (int i = 0; i < repeatCount; i++) {
          flags.add(flag);
        }
      }
    }
    
    // Read X coordinates
    List<int> xCoordinates = [];
    int xValue = 0;
    for (int flag in flags) {
      if ((flag & 0x02) != 0) {
        // X-Short Vector: coordinate is 1 byte
        int val = reader.read();
        if ((flag & 0x10) != 0) {
          // Positive
          xValue += val;
        } else {
          // Negative
          xValue -= val;
        }
      } else {
        // X coordinate is 2 bytes or same as previous
        if ((flag & 0x10) != 0) {
          // Same as previous
          // xValue stays the same
        } else {
          // Read signed short
          xValue += reader.readSignedShort();
        }
      }
      xCoordinates.add(xValue);
    }
    
    // Read Y coordinates
    List<int> yCoordinates = [];
    int yValue = 0;
    for (int flag in flags) {
      if ((flag & 0x04) != 0) {
        // Y-Short Vector: coordinate is 1 byte
        int val = reader.read();
        if ((flag & 0x20) != 0) {
          // Positive
          yValue += val;
        } else {
          // Negative
          yValue -= val;
        }
      } else {
        // Y coordinate is 2 bytes or same as previous
        if ((flag & 0x20) != 0) {
          // Same as previous
          // yValue stays the same
        } else {
          // Read signed short
          yValue += reader.readSignedShort();
        }
      }
      yCoordinates.add(yValue);
    }
    
    // Create contour points
    List<ContourPoint> points = [];
    for (int i = 0; i < nPoints; i++) {
      ContourPoint point = ContourPoint();
      point.x = xCoordinates[i];
      point.y = yCoordinates[i];
      point.onCurve = (flags[i] & 0x01) != 0;
      points.add(point);
    }
    
    glyphInfo.points = points;
  }
}


class GlyphInfo {
  late int index;
  late int numberOfContours;
  late int xMin;
  late int yMin;
  late int xMax;
  late int yMax;
  List<int>? endPtsOfContours;
  List<ContourPoint>? points;
}

class ContourPoint {
  late int x;
  late int y;
  late bool onCurve;
}