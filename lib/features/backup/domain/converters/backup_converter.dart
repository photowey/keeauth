import 'package:keeauth/features/backup/domain/import_models.dart';

/// Abstract base class for backup converters
abstract class BackupConverter {
  /// Converter name
  String get name;

  /// File extension(s) supported (e.g., ['.json', '.txt'])
  List<String> get supportedExtensions;

  /// MIME type(s) supported
  List<String> get supportedMimeTypes;

  /// Whether this converter supports encrypted backups
  bool get supportsEncryption;

  /// Check if this converter can handle the given data
  /// This should be a quick check, not full validation
  bool canConvert(String data);

  /// Convert backup data to authenticator stubs
  /// [password] is required for encrypted backups
  Future<ConversionResult> convert(String data, {String? password});
}

/// Exception for import errors
class ImportException implements Exception {
  final String message;
  final String? code;

  const ImportException(this.message, {this.code});

  @override
  String toString() => 'ImportException: $message';
}

/// Exception for password-related errors
class PasswordRequiredException extends ImportException {
  const PasswordRequiredException() : super('Password required for encrypted backup');
}

/// Exception for invalid password
class InvalidPasswordException extends ImportException {
  const InvalidPasswordException() : super('Invalid password');
}

/// Exception for corrupted/invalid data
class InvalidDataException extends ImportException {
  const InvalidDataException(String message) : super(message, code: 'INVALID_DATA');
}
