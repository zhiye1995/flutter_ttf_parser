# flutter_ttf_parser

A comprehensive TrueType Font (TTF) parser for Flutter written in pure Dart. This package allows you to parse and extract detailed information from TTF font files without relying on platform-specific code.

## Features

### Complete TTF Table Support

This parser implements parsing for all essential TrueType font tables:

#### 📁 **Font Directory**
- Parses the font table directory structure
- Validates font file integrity
- Provides access to all available tables

#### 🔤 **Name Table (`name`)**
- **Font Metadata**: Extracts comprehensive font information
  - Font name and family
  - Subfamily (Regular, Bold, Italic, etc.)
  - PostScript name
  - Version information
  - Copyright notices
  - Manufacturer information
  - Trademark notices
- **Multi-Platform Support**: Handles both Windows (UTF-16 BE) and Macintosh (MacRoman) encoding
- **Language Support**: Properly decodes international characters

#### 📏 **Head Table (`head`)**
- **Font Header Information**:
  - Font version and revision
  - Units per EM (font design metrics)
  - Creation and modification dates
  - Global bounding box (xMin, yMin, xMax, yMax)
  - Font direction hints
  - Index-to-location format
  - Font flags and style information
- **Validation**: Verifies magic number (0x5F0F3CF5) and units per EM range

#### 📊 **Maximum Profile Table (`maxp`)**
- **Glyph Statistics**:
  - Total number of glyphs
  - Maximum points per glyph
  - Maximum contours per simple glyph
  - Maximum composite glyph nesting depth
  - Maximum zones, twilight points, storage areas
  - Maximum instruction definitions and stack elements

#### 🗺️ **Character Map Table (`cmap`)**
- **Character to Glyph Mapping**: Bidirectional mapping between Unicode characters and glyph indices
- **Multiple Format Support**:
  - **Format 0**: Basic byte encoding (ASCII)
  - **Format 4**: Segmented coverage (most common for Unicode BMP)
  - **Format 6**: Trimmed table mapping
- **Platform Support**: Windows (Platform ID 3) prioritized
- **Efficient Lookup**: Fast character to glyph index conversion

#### ↕️ **Horizontal Header Table (`hhea`)**
- **Typography Metrics**:
  - Ascent (height above baseline)
  - Descent (depth below baseline)
  - Line gap (spacing between lines)
  - Maximum advance width
  - Minimum left and right side bearings
  - Caret positioning information
  - Number of horizontal metrics

#### 📐 **Horizontal Metrics Table (`hmtx`)**
- **Per-Glyph Metrics**:
  - Advance width for each glyph
  - Left side bearing values
- Used for proper text layout and spacing

#### 📍 **Index to Location Table (`loca`)**
- **Glyph Offset Mapping**: Maps glyph indices to their locations in the `glyf` table
- **Format Support**: Both short (16-bit) and long (32-bit) offset formats
- **Memory Efficient**: Optimized storage for font files

#### 🎨 **Glyph Data Table (`glyf`)**
- **Glyph Information**:
  - Number of contours (outline complexity)
  - Bounding box for each glyph (xMin, yMin, xMax, yMax)
  - Glyph index mapping
- **Quick Access**: Fast retrieval of glyph dimensions and properties

#### 🔄 **Kerning Table (`kern`) - Optional**
- **Advanced Typography**:
  - Pair kerning adjustments (spacing between specific character pairs)
  - Multiple subtable support
  - Format 0 kerning pairs
  - Character code to kerning value mapping
- **Graceful Handling**: Optional table that doesn't break parsing if absent

### 🛠️ Utility Features

#### Glyph Operations
- **Character to Glyph Lookup**: Get glyph information from any character
- **Bounding Box Calculation**: Calculate pixel-perfect bounding boxes at any size
- **Unit Conversion**: Convert between font units and pixels
- **Size Scaling**: Scale glyphs to specific EM sizes

#### Error Handling
- **Robust Parsing**: Comprehensive error messages for debugging
- **Validation**: Checks for malformed font files
- **Exception Types**: 
  - `TtfParseException`: Font parsing errors
  - `ParseException`: Table-specific parsing errors
  - `EOFException`: Premature end-of-file errors

#### Stream Reading
- **Efficient Binary Parsing**: Custom stream reader for binary font data
- **Data Type Support**:
  - Unsigned/signed 8-bit, 16-bit, 32-bit integers
  - Fixed-point numbers (16.16 format)
  - Date/time values
  - String reading with multiple encodings (ASCII, UTF-16 BE, MacRoman)
- **Seeking**: Random access to any position in the font file

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ttf_parser: ^0.1.0
```

## Usage

### Basic Example

```dart
import 'package:flutter/services.dart';
import 'package:flutter_ttf_parser/flutter_ttf_parser.dart';

// Load a font file from assets
final ByteData data = await rootBundle.load('assets/fonts/my_font.ttf');
final Uint8List bytes = data.buffer.asUint8List();

// Parse the font
final parser = TtfParser();
final TtfFont font = parser.parse(bytes);

// Access font information
print('Font Name: ${font.name.fontName}');
print('Font Family: ${font.name.fontFamily}');
print('Number of Glyphs: ${font.numGlyphs}');
print('Units per EM: ${font.unitsPerEm}');
```

### Accessing Font Metadata

```dart
// Basic information
String? fontName = font.name.fontName;
String? fontFamily = font.name.fontFamily;
String? subFamily = font.name.subFamily;
String? postScriptName = font.name.fontNamePostScript;
String? version = font.name.nameTableVersion;
String? copyright = font.name.copyright;
String? manufacturer = font.name.manufacturer;
```

### Typography Metrics

```dart
// Vertical metrics
int ascent = font.hhea.ascent;           // Height above baseline
int descent = font.hhea.descent;         // Depth below baseline
int lineGap = font.hhea.lineGap;         // Line spacing
int lineHeight = ascent - descent + lineGap;

// Horizontal metrics
int maxAdvanceWidth = font.hhea.advanceWidthMax;
```

### Glyph Information

```dart
// Get glyph info for a character
GlyphInfo? glyphInfo = font.getGlyphInfo('A');
if (glyphInfo != null) {
  print('Glyph Index: ${glyphInfo.index}');
  print('Contours: ${glyphInfo.numberOfContours}');
  print('Bounding Box: ${glyphInfo.xMin}, ${glyphInfo.yMin}, ${glyphInfo.xMax}, ${glyphInfo.yMax}');
}

// Get glyph info from character code
GlyphInfo? glyphInfo2 = font.getGlyphInfoFromCode(65); // 'A'
```

### Bounding Box Calculation

```dart
// Calculate bounding box at specific size
GlyphInfo? glyphInfo = font.getGlyphInfo('中');
if (glyphInfo != null) {
  // Get bounding box at 2.0 EM size
  GlyphBoundingBox bbox = font.getGlyphBoundingBox(glyphInfo, 2.0);
  print('Pixel Bounding Box: ${bbox.xMin}, ${bbox.yMin}, ${bbox.xMax}, ${bbox.yMax}');
}
```

### Character Mapping

```dart
// Check available characters
Map<int, int> charMap = font.cmap.charToGlyphIndexMap;
int numCharacters = charMap.length;
print('Font supports $numCharacters characters');

// Check if a character is supported
int charCode = '中'.codeUnitAt(0);
bool isSupported = charMap.containsKey(charCode);
```

### Kerning Information

```dart
// Access kerning pairs (if available)
Map<int, Map<int, int>> kernings = font.kern.kernings;

// Get kerning between two characters
int leftCharCode = 'A'.codeUnitAt(0);
int rightCharCode = 'V'.codeUnitAt(0);
int? kerningValue = kernings[leftCharCode]?[rightCharCode];
if (kerningValue != null) {
  print('Kerning between A and V: $kerningValue');
}
```

### Error Handling

```dart
try {
  final parser = TtfParser();
  final font = parser.parse(fontBytes);
  // Use font...
} on TtfParseException catch (e) {
  print('Font parsing error: $e');
} on ParseException catch (e) {
  print('Table parsing error: $e');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Supported Font Files

- ✅ TrueType fonts (.ttf)
- ✅ Fonts with standard TrueType tables
- ✅ Unicode fonts (BMP - Basic Multilingual Plane)
- ✅ CJK (Chinese, Japanese, Korean) fonts
- ✅ Latin, Cyrillic, Greek scripts
- ❌ OpenType fonts with CFF outlines (.otf) - not yet supported
- ❌ TrueType Collections (.ttc) - not yet supported
- ❌ Variable fonts - not yet supported

## Example Application

The package includes a comprehensive example application that demonstrates:
- Loading fonts from assets
- Displaying font metadata
- Showing technical parameters
- Visualizing glyph information
- Testing with multiple font types (Song, Hei, Kai, Microsoft YaHei, Times New Roman, etc.)

To run the example:

```bash
cd example
flutter run
```

## Technical Details

### Architecture

```
flutter_ttf_parser/
├── lib/
│   └── ttf_parser/
│       ├── ttf_parser.dart          # Main library entry
│       ├── ttf_font.dart            # Font model class
│       ├── parsers/
│       │   ├── ttf_parser.dart      # Main parser logic
│       │   └── tables/              # Table-specific parsers
│       │       ├── font_directory.dart
│       │       ├── ttf_table_head.dart
│       │       ├── ttf_table_name.dart
│       │       ├── ttf_table_maxp.dart
│       │       ├── ttf_table_cmap.dart
│       │       ├── ttf_table_hhea.dart
│       │       ├── ttf_table_hmtx.dart
│       │       ├── ttf_table_loca.dart
│       │       ├── ttf_table_glyf.dart
│       │       └── ttf_table_kern.dart
│       ├── stream/
│       │   ├── stream_reader.dart           # Abstract stream reader
│       │   └── byte_array_stream_reader.dart # Binary data reader
│       └── utils/
│           ├── parser_exceptions.dart       # Exception classes
│           └── glyph_bounding_box.dart     # Bounding box utilities
```

### Performance

- **Pure Dart Implementation**: No platform channels, works on all Flutter platforms
- **Efficient Parsing**: Streams through binary data without loading entire font into memory multiple times
- **Fast Lookup**: Hash maps for character-to-glyph mapping
- **Minimal Dependencies**: Only depends on Flutter SDK

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

Since this is a pure Dart implementation, it works on all Flutter platforms.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Areas for contribution:
- OpenType CFF outline support
- TrueType Collection (.ttc) support
- Variable font support
- GPOS/GSUB advanced typography tables
- Additional cmap format support (8, 10, 12, 13, 14)
- Vertical metrics (vhea, vmtx)
- Bitmap strike tables (EBDT, EBLC)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- TrueType specification from [Apple](https://developer.apple.com/fonts/TrueType-Reference-Manual/)
- OpenType specification from [Microsoft](https://docs.microsoft.com/en-us/typography/opentype/spec/)

## Author

Created for the Flutter community with ❤️
