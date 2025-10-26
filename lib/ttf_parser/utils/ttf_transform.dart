part of ttf_parser;

/// Utility class to perform transform operations on a Path object
class TtfTransform {
  /// Translate and scale a path to desired location and size
  static Path moveAndScale(Path path, double posX, double posY, double scaleX, double scaleY) {
    // Create transformation matrix
    final matrix = Float64List(16);
    matrix[0] = scaleX;      // scale X
    matrix[1] = 0.0;
    matrix[2] = 0.0;
    matrix[3] = 0.0;
    matrix[4] = 0.0;
    matrix[5] = -scaleY;     // scale Y (negated for coordinate system flip)
    matrix[6] = 0.0;
    matrix[7] = 0.0;
    matrix[8] = 0.0;
    matrix[9] = 0.0;
    matrix[10] = 1.0;
    matrix[11] = 0.0;
    matrix[12] = posX;       // translate X
    matrix[13] = posY;       // translate Y
    matrix[14] = 0.0;
    matrix[15] = 1.0;
    
    return path.transform(matrix);
  }
}

