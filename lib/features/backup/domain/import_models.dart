import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';

/// Result of backup conversion
class ConversionResult {
  final bool success;
  final List<AuthenticatorStub> authenticators;
  final List<CategoryStub> categories;
  final String? error;
  final bool needsPassword;

  const ConversionResult({
    required this.success,
    this.authenticators = const [],
    this.categories = const [],
    this.error,
    this.needsPassword = false,
  });

  factory ConversionResult.error(String error) {
    return ConversionResult(success: false, error: error);
  }

  factory ConversionResult.success({
    List<AuthenticatorStub> authenticators = const [],
    List<CategoryStub> categories = const [],
  }) {
    return ConversionResult(
      success: true,
      authenticators: authenticators,
      categories: categories,
    );
  }
}

/// Stub model for authenticator during import
class AuthenticatorStub {
  final String secret;
  final String issuer;
  final String accountName;
  final String type;
  final String algorithm;
  final int digits;
  final int period;
  final int? counter;
  final String? icon;
  final String? pin;

  const AuthenticatorStub({
    required this.secret,
    required this.issuer,
    required this.accountName,
    this.type = 'totp',
    this.algorithm = 'sha1',
    this.digits = 6,
    this.period = 30,
    this.counter,
    this.icon,
    this.pin,
  });

  Authenticator toAuthenticator() {
    return Authenticator(
      secret: secret,
      issuer: issuer,
      accountName: accountName,
      type: _parseType(type),
      algorithm: _parseAlgorithm(algorithm),
      digits: digits,
      period: period,
      counter: counter ?? 0,
      icon: icon,
      pin: pin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static AuthenticatorType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'hotp':
        return AuthenticatorType.hotp;
      case 'steam':
        return AuthenticatorType.steam;
      case 'motp':
        return AuthenticatorType.motp;
      case 'yandex':
      case 'yaotp':
        return AuthenticatorType.yandex;
      default:
        return AuthenticatorType.totp;
    }
  }

  static OtpHashAlgorithm _parseAlgorithm(String algorithm) {
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        return OtpHashAlgorithm.sha256;
      case 'SHA512':
        return OtpHashAlgorithm.sha512;
      default:
        return OtpHashAlgorithm.sha1;
    }
  }
}

/// Stub model for category during import
class CategoryStub {
  final String id;
  final String name;
  final int ranking;

  const CategoryStub({
    required this.id,
    required this.name,
    this.ranking = 0,
  });

  Category toCategory() {
    return Category(
      id: id,
      name: name,
      ranking: ranking,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Import conflict types
enum ImportConflictType {
  duplicateSecret,
  duplicateName,
  none,
}

/// Import conflict information
class ImportConflict {
  final AuthenticatorStub authenticator;
  final ImportConflictType type;
  final Authenticator? existingAuthenticator;

  const ImportConflict({
    required this.authenticator,
    required this.type,
    this.existingAuthenticator,
  });
}

/// Import preview for UI
class ImportPreview {
  final List<AuthenticatorStub> newAuthenticators;
  final List<ImportConflict> conflicts;
  final List<CategoryStub> newCategories;

  const ImportPreview({
    required this.newAuthenticators,
    required this.conflicts,
    required this.newCategories,
  });

  int get totalCount => newAuthenticators.length + conflicts.length;
  int get conflictCount => conflicts.length;
}
