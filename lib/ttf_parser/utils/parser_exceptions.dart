part of ttf_parser;

class ParseException {
  String message;
  ParseException(this.message);
  
  @override
  String toString() {
    return message;
  }
}

class TtfParseException extends ParseException {
  TtfParseException(super.message);
}


class EOFException extends ParseException {
  EOFException(super.message);
}

