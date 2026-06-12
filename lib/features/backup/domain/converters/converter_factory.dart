import 'backup_converter.dart';
import 'aegis_converter.dart';
import 'bitwarden_converter.dart';
import 'google_auth_converter.dart';
import 'freeotp_converter.dart';
import 'twofas_converter.dart';
import 'uri_list_converter.dart';
import 'keepass_converter.dart';
import 'lastpass_converter.dart';
import 'shensuo_converter.dart';

/// Factory for detecting and creating backup converters
class ConverterFactory {
  static final List<BackupConverter> _converters = [
    AegisConverter(),
    BitwardenConverter(),
    GoogleAuthConverter(),
    FreeOtpConverter(),
    TwoFasConverter(),
    UriListConverter(),
    KeePassConverter(),
    LastPassConverter(),
    ShenSuoConverter(),
  ];

  /// Get all available converters
  static List<BackupConverter> get allConverters => List.unmodifiable(_converters);

  /// Detect converter for given data
  static BackupConverter? detectConverter(String data) {
    for (final converter in _converters) {
      try {
        if (converter.canConvert(data)) {
          return converter;
        }
      } catch (e) {
        // Ignore errors during detection
        continue;
      }
    }
    return null;
  }

  /// Get converter by name
  static BackupConverter? getConverter(String name) {
    final lowerName = name.toLowerCase();
    for (final converter in _converters) {
      if (converter.name.toLowerCase() == lowerName) {
        return converter;
      }
    }
    return null;
  }

  /// Get list of converter names
  static List<String> get converterNames {
    return _converters.map((c) => c.name).toList();
  }
}
