/// Utility class for OTP code formatting
class CodeUtil {
  CodeUtil._();

  /// Pads code to [digits] length and groups by [groupSize].
  ///
  /// Example: padCode("123456", 6, 3) => "123 456"
  /// Example: padCode("12345678", 8, 4) => "1234 5678"
  static String padCode(String code, int digits, int groupSize) {
    final padded = code.padLeft(digits, '0');
    final buffer = StringBuffer();
    for (var i = 0; i < padded.length; i++) {
      if (i > 0 && i % groupSize == 0) buffer.write(' ');
      buffer.write(padded[i]);
    }
    return buffer.toString();
  }
}
