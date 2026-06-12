import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';

/// Backup format version constants
class BackupFormatVersion {
  static const int v1UriList = 1;
  static const int v2Complete = 2;
  static const int current = v2Complete;
}

/// Backup header containing metadata
class BackupHeader {
  final int version;
  final String appName;
  final DateTime createdAt;
  final String? deviceId;

  const BackupHeader({
    required this.version,
    required this.appName,
    required this.createdAt,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'appName': appName,
      'createdAt': createdAt.toIso8601String(),
      if (deviceId != null) 'deviceId': deviceId,
    };
  }

  factory BackupHeader.fromJson(Map<String, dynamic> json) {
    return BackupHeader(
      version: json['version'] as int,
      appName: json['appName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deviceId: json['deviceId'] as String?,
    );
  }
}

/// Authenticator-Category relationship for backup
class BackupAuthenticatorCategory {
  final String authenticatorSecret;
  final String categoryId;

  const BackupAuthenticatorCategory({
    required this.authenticatorSecret,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'authenticatorSecret': authenticatorSecret,
      'categoryId': categoryId,
    };
  }

  factory BackupAuthenticatorCategory.fromJson(Map<String, dynamic> json) {
    return BackupAuthenticatorCategory(
      authenticatorSecret: json['authenticatorSecret'] as String,
      categoryId: json['categoryId'] as String,
    );
  }
}

/// Custom icon data for backup
class BackupCustomIcon {
  final String id;
  final String name;
  final String data; // Base64 encoded

  const BackupCustomIcon({
    required this.id,
    required this.name,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  factory BackupCustomIcon.fromJson(Map<String, dynamic> json) {
    return BackupCustomIcon(
      id: json['id'] as String,
      name: json['name'] as String,
      data: json['data'] as String,
    );
  }
}

/// Complete backup data structure
class BackupData {
  final List<Authenticator> authenticators;
  final List<Category> categories;
  final List<BackupAuthenticatorCategory> authenticatorCategories;
  final List<BackupCustomIcon> customIcons;

  const BackupData({
    required this.authenticators,
    required this.categories,
    required this.authenticatorCategories,
    required this.customIcons,
  });

  Map<String, dynamic> toJson() {
    return {
      'authenticators': authenticators.map((a) => _authenticatorToJson(a)).toList(),
      'categories': categories.map((c) => _categoryToJson(c)).toList(),
      'authenticatorCategories': authenticatorCategories.map((ac) => ac.toJson()).toList(),
      'customIcons': customIcons.map((i) => i.toJson()).toList(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      authenticators: (json['authenticators'] as List)
          .map((a) => _authenticatorFromJson(a as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List)
          .map((c) => _categoryFromJson(c as Map<String, dynamic>))
          .toList(),
      authenticatorCategories: (json['authenticatorCategories'] as List)
          .map((ac) => BackupAuthenticatorCategory.fromJson(ac as Map<String, dynamic>))
          .toList(),
      customIcons: (json['customIcons'] as List)
          .map((i) => BackupCustomIcon.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  // Helper methods for Authenticator JSON serialization
  static Map<String, dynamic> _authenticatorToJson(Authenticator a) {
    return {
      'secret': a.secret,
      'issuer': a.issuer,
      'accountName': a.accountName,
      'type': a.type.name,
      'algorithm': a.algorithm.name,
      'digits': a.digits,
      'period': a.period,
      'counter': a.counter,
      'icon': a.icon,
      'pin': a.pin,
      'copyCount': a.copyCount,
      'ranking': a.ranking,
      'createdAt': a.createdAt.toIso8601String(),
      'updatedAt': a.updatedAt.toIso8601String(),
    };
  }

  static Authenticator _authenticatorFromJson(Map<String, dynamic> json) {
    return Authenticator(
      secret: json['secret'] as String,
      issuer: json['issuer'] as String? ?? '',
      accountName: json['accountName'] as String,
      type: AuthenticatorType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AuthenticatorType.totp,
      ),
      algorithm: OtpHashAlgorithm.values.firstWhere(
        (a) => a.name == json['algorithm'],
        orElse: () => OtpHashAlgorithm.sha1,
      ),
      digits: json['digits'] as int? ?? 6,
      period: json['period'] as int? ?? 30,
      counter: json['counter'] as int? ?? 0,
      icon: json['icon'] as String?,
      pin: json['pin'] as String?,
      copyCount: json['copyCount'] as int? ?? 0,
      ranking: json['ranking'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Helper methods for Category JSON serialization
  static Map<String, dynamic> _categoryToJson(Category c) {
    return {
      'id': c.id,
      'name': c.name,
      'ranking': c.ranking,
      'color': c.color,
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
    };
  }

  static Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      ranking: json['ranking'] as int? ?? 0,
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Complete backup structure with header and data
class CompleteBackup {
  final BackupHeader header;
  final BackupData data;

  const CompleteBackup({
    required this.header,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'header': header.toJson(),
      'data': data.toJson(),
    };
  }

  factory CompleteBackup.fromJson(Map<String, dynamic> json) {
    return CompleteBackup(
      header: BackupHeader.fromJson(json['header'] as Map<String, dynamic>),
      data: BackupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
