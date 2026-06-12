import 'package:equatable/equatable.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/core/crypto/hash_algorithm.dart';

/// Authenticator entity representing a 2FA account
class Authenticator extends Equatable {
  final String secret;
  final String issuer;
  final String accountName;
  final AuthenticatorType type;
  final OtpHashAlgorithm algorithm;
  final int digits;
  final int period;
  final int counter;
  final String? icon;
  final String? pin;
  final int copyCount;
  final int ranking;
  final List<String> categoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Authenticator({
    required this.secret,
    required this.issuer,
    required this.accountName,
    this.type = AuthenticatorType.totp,
    this.algorithm = OtpHashAlgorithm.sha1,
    this.digits = 6,
    this.period = 30,
    this.counter = 0,
    this.icon,
    this.pin,
    this.copyCount = 0,
    this.ranking = 0,
    this.categoryIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Display name (issuer + account)
  String get displayName {
    if (issuer.isNotEmpty) {
      return '$issuer ($accountName)';
    }
    return accountName;
  }

  /// Copy with new values
  Authenticator copyWith({
    String? secret,
    String? issuer,
    String? accountName,
    AuthenticatorType? type,
    OtpHashAlgorithm? algorithm,
    int? digits,
    int? period,
    int? counter,
    String? icon,
    String? pin,
    int? copyCount,
    int? ranking,
    List<String>? categoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Authenticator(
      secret: secret ?? this.secret,
      issuer: issuer ?? this.issuer,
      accountName: accountName ?? this.accountName,
      type: type ?? this.type,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      counter: counter ?? this.counter,
      icon: icon ?? this.icon,
      pin: pin ?? this.pin,
      copyCount: copyCount ?? this.copyCount,
      ranking: ranking ?? this.ranking,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'secret': secret,
      'issuer': issuer,
      'accountName': accountName,
      'type': type.name,
      'algorithm': algorithm.name,
      'digits': digits,
      'period': period,
      'counter': counter,
      'icon': icon,
      'pin': pin,
      'copyCount': copyCount,
      'ranking': ranking,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create from database map
  factory Authenticator.fromMap(Map<String, dynamic> map, {List<String>? categoryIds}) {
    return Authenticator(
      secret: map['secret'] as String,
      issuer: map['issuer'] as String? ?? '',
      accountName: map['accountName'] as String,
      type: AuthenticatorType.fromString(map['type'] as String?),
      algorithm: OtpHashAlgorithm.fromString(map['algorithm'] as String?),
      digits: map['digits'] as int? ?? 6,
      period: map['period'] as int? ?? 30,
      counter: map['counter'] as int? ?? 0,
      icon: map['icon'] as String?,
      pin: map['pin'] as String?,
      copyCount: map['copyCount'] as int? ?? 0,
      ranking: map['ranking'] as int? ?? 0,
      categoryIds: categoryIds ?? const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  @override
  List<Object?> get props => [
        secret,
        issuer,
        accountName,
        type,
        algorithm,
        digits,
        period,
        counter,
        icon,
        pin,
        copyCount,
        ranking,
        categoryIds,
        createdAt,
        updatedAt,
      ];
}
