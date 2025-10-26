part of ttf_parser;

class TtfFont {
  late FontDirectory directory;
  late TtfTableHead head;
  late TtfTableMaxp maxp;
  late TtfTableCmap cmap;
  late TtfTableHhea hhea;
  late TtfTableHmtx hmtx;
  late TtfTableLoca loca;
  late TtfTableGlyf glyf;
  late TtfTableKern kern;
  late TtfTableName name;

  TtfFont() {
    directory = FontDirectory();
    head = TtfTableHead();
    maxp = TtfTableMaxp();
    cmap = TtfTableCmap();
    hhea = TtfTableHhea();
    name = TtfTableName();
    hmtx = TtfTableHmtx(this);
    loca = TtfTableLoca(this);
    glyf = TtfTableGlyf(this);
    kern = TtfTableKern(this);
  }

  int get unitsPerEm => head.unitsPerEm;

  int get numGlyphs => maxp.numGlyphs;
  
  /// Get font ascender (baseline to top)
  int get ascender => hhea.ascent;
  
  /// Get font descender (baseline to bottom, typically negative)
  int get descender => hhea.descent;
  
  /// Get font line gap
  int get lineGap => hhea.lineGap;

  GlyphInfo? getGlyphInfo(String ch) {
    int charCode = ch.codeUnits[0];
    return getGlyphInfoFromCode(charCode);
  }

  GlyphInfo? getGlyphInfoFromCode(int charCode) {
    int? glyphIndex = cmap.charToGlyphIndexMap[charCode];
    if (glyphIndex == null) return null;
    var glyphInfo = glyf.glyphInfoMap[glyphIndex];
    return glyphInfo;
  }

  final int pixelsPerEm = 16;

  int getPixels(int unitsInEm, num sizeInEm) {
    var normalizedPixels = (unitsInEm * pixelsPerEm) / unitsPerEm;
    return (normalizedPixels * sizeInEm).round().toInt();
  }

  GlyphBoundingBox getGlyphBoundingBox(GlyphInfo glyphInfo, num sizeInEm) {
    var bbox = GlyphBoundingBox();
    bbox.xMin = getPixels(glyphInfo.xMin, sizeInEm);
    bbox.yMin = getPixels(glyphInfo.yMin, sizeInEm);
    bbox.xMax = getPixels(glyphInfo.xMax, sizeInEm);
    bbox.yMax = getPixels(glyphInfo.yMax, sizeInEm);
    return bbox;
  }
  
  /// Get glyph ID for a character code
  int getGlyphIdForCharacter(int charCode) {
    return cmap.charToGlyphIndexMap[charCode] ?? -1;
  }
  
  /// Get advance width for a glyph ID
  int? getAdvanceWidthForGlyphId(int glyphId) {
    if (glyphId < 0 || glyphId >= hmtx.metrics.length) {
      // If beyond the metrics array, use the last advance width
      if (hmtx.metrics.isNotEmpty) {
        return hmtx.metrics.last.advanceWidth;
      }
      return null;
    }
    return hmtx.metrics[glyphId].advanceWidth;
  }
  
  /// Generate Flutter Path for a character
  Path generatePathForCharacter(int charCode) {
    // Get glyph info
    GlyphInfo? glyphInfo = getGlyphInfoFromCode(charCode);
    if (glyphInfo == null || glyphInfo.points == null || glyphInfo.endPtsOfContours == null) {
      return Path();
    }
    
    List<ContourPoint> points = glyphInfo.points!;
    List<int> endPts = glyphInfo.endPtsOfContours!;
    
    if (points.isEmpty || endPts.isEmpty) {
      return Path();
    }
    
    // Group points into contours
    List<List<ContourPoint>> contours = [];
    int startIdx = 0;
    for (int endIdx in endPts) {
      if (endIdx >= points.length) break;
      contours.add(points.sublist(startIdx, endIdx + 1));
      startIdx = endIdx + 1;
    }
    
    Path path = Path();
    
    for (List<ContourPoint> contour in contours) {
      if (contour.isEmpty) continue;
      
      // Interpolate off-curve points
      List<ContourPoint> interpolated = [];
      for (int i = 0; i < contour.length - 1; i++) {
        interpolated.add(contour[i]);
        if (!contour[i].onCurve && !contour[i + 1].onCurve) {
          // Two consecutive off-curve points: add interpolated on-curve point
          ContourPoint mid = ContourPoint();
          mid.x = ((contour[i].x + contour[i + 1].x) / 2).round();
          mid.y = ((contour[i].y + contour[i + 1].y) / 2).round();
          mid.onCurve = true;
          interpolated.add(mid);
        }
      }
      interpolated.add(contour.last);
      
      // Handle wrap-around between last and first point
      if (!contour.last.onCurve && !contour.first.onCurve) {
        ContourPoint mid = ContourPoint();
        mid.x = ((contour.last.x + contour.first.x) / 2).round();
        mid.y = ((contour.last.y + contour.first.y) / 2).round();
        mid.onCurve = true;
        interpolated.add(mid);
      }
      
      // Generate path commands
      if (interpolated.isEmpty) continue;
      
      // Move to first point
      path.moveTo(interpolated[0].x.toDouble(), interpolated[0].y.toDouble());
      
      int i = 1;
      while (i < interpolated.length) {
        if (interpolated[i].onCurve) {
          // Line to on-curve point
          path.lineTo(interpolated[i].x.toDouble(), interpolated[i].y.toDouble());
          i++;
        } else {
          // Quadratic curve: off-curve control point + next on-curve point
          if (i + 1 < interpolated.length) {
            path.quadraticBezierTo(
              interpolated[i].x.toDouble(),
              interpolated[i].y.toDouble(),
              interpolated[i + 1].x.toDouble(),
              interpolated[i + 1].y.toDouble(),
            );
            i += 2;
          } else {
            i++;
          }
        }
      }
      
      path.close();
    }
    
    return path;
  }
}
