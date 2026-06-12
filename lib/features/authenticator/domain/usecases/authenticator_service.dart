import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/features/authenticator/data/repositories/authenticator_repository.dart';
import 'package:keeauth/features/authenticator/data/repositories/category_repository.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';
import 'package:keeauth/core/crypto/hash_algorithm.dart';

/// Service for managing authenticators
class AuthenticatorService {
  final AuthenticatorRepository _authenticatorRepository;
  final CategoryRepository _categoryRepository;
  final OtpGenerator _otpGenerator;

  AuthenticatorService(
    this._authenticatorRepository,
    this._categoryRepository,
    this._otpGenerator,
  );

  /// Get all authenticators
  Future<List<Authenticator>> getAll() async {
    return await _authenticatorRepository.getAll();
  }

  /// Get authenticator by secret
  Future<Authenticator?> getBySecret(String secret) async {
    return await _authenticatorRepository.getBySecret(secret);
  }

  /// Add authenticator from URI
  Future<Authenticator> addFromUri(String uri, {List<String>? categoryIds}) async {
    final result = OtpUriParser.parse(uri);
    if (!result.success || result.params == null) {
      throw Exception(result.error ?? 'Invalid URI');
    }

    final params = result.params!;
    final now = DateTime.now();

    // Check for duplicates
    if (await _authenticatorRepository.exists(params.secret)) {
      throw Exception('Authenticator already exists');
    }

    final authenticator = Authenticator(
      secret: params.secret,
      issuer: result.issuer ?? '',
      accountName: result.accountName ?? '',
      type: params.type,
      algorithm: params.algorithm,
      digits: params.digits,
      period: params.period,
      counter: params.counter,
      pin: params.pin,
      categoryIds: categoryIds ?? [],
      createdAt: now,
      updatedAt: now,
    );

    await _authenticatorRepository.insert(authenticator);
    return authenticator;
  }

  /// Add authenticator manually
  Future<Authenticator> add({
    required String secret,
    required String accountName,
    String? issuer,
    AuthenticatorType type = AuthenticatorType.totp,
    OtpHashAlgorithm algorithm = OtpHashAlgorithm.sha1,
    int digits = 6,
    int period = 30,
    int counter = 0,
    String? pin,
    List<String>? categoryIds,
  }) async {
    final now = DateTime.now();

    final authenticator = Authenticator(
      secret: secret.toUpperCase().replaceAll(' ', ''),
      issuer: issuer ?? '',
      accountName: accountName,
      type: type,
      algorithm: algorithm,
      digits: digits,
      period: period,
      counter: counter,
      pin: pin,
      categoryIds: categoryIds ?? [],
      createdAt: now,
      updatedAt: now,
    );

    await _authenticatorRepository.insert(authenticator);
    return authenticator;
  }

  /// Update authenticator
  Future<void> update(Authenticator authenticator) async {
    final updated = authenticator.copyWith(updatedAt: DateTime.now());
    await _authenticatorRepository.update(updated);
  }

  /// Delete authenticator
  Future<void> delete(String secret) async {
    await _authenticatorRepository.delete(secret);
  }

  /// Generate current code for authenticator
  String generateCode(Authenticator authenticator) {
    final params = OtpGeneratorParams(
      secret: authenticator.secret,
      type: authenticator.type,
      algorithm: authenticator.algorithm,
      digits: authenticator.digits,
      period: authenticator.period,
      counter: authenticator.counter,
      pin: authenticator.pin,
    );

    return _otpGenerator.generate(params);
  }

  /// Get remaining seconds until next code
  int getRemainingSeconds(int period) {
    return _otpGenerator.getRemainingSeconds(period);
  }

  /// Copy code and increment counter
  Future<void> copyCode(String secret) async {
    await _authenticatorRepository.incrementCopyCount(secret);
  }

  /// Get authenticators by category
  Future<List<Authenticator>> getByCategory(String categoryId) async {
    return await _authenticatorRepository.getByCategory(categoryId);
  }

  /// Get uncategorized authenticators
  Future<List<Authenticator>> getUncategorized() async {
    return await _authenticatorRepository.getUncategorized();
  }

  /// Update authenticator categories
  Future<void> updateCategories(String secret, List<String> categoryIds) async {
    final authenticator = await _authenticatorRepository.getBySecret(secret);
    if (authenticator == null) return;

    final updated = authenticator.copyWith(
      categoryIds: categoryIds,
      updatedAt: DateTime.now(),
    );
    await _authenticatorRepository.update(updated);
  }

  /// Update ranking (for drag and drop)
  Future<void> updateRanking(String secret, int ranking) async {
    await _authenticatorRepository.updateRanking(secret, ranking);
  }

  /// Generate category ID from name
  String generateCategoryId(String name) {
    final bytes = utf8.encode(name);
    final digest = sha1.convert(bytes);
    return digest.toString().substring(0, 16).toUpperCase();
  }

  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    return await _categoryRepository.getAll();
  }

  static const List<int> _categoryColorPalette = [
    0xFF4CAF50, 0xFF2196F3, 0xFFFF9800, 0xFF9C27B0,
    0xFF00BCD4, 0xFF795548, 0xFF607D8B, 0xFFE91E63,
  ];

  /// Create category, with optional explicit color. Falls back to palette-based default.
  Future<Category> createCategory(String name, {int? color}) async {
    if (await _categoryRepository.nameExists(name)) {
      throw Exception('Category already exists');
    }

    final now = DateTime.now();
    final id = generateCategoryId(name);
    final randomColor = _categoryColorPalette[
        (id.hashCode.abs()) % _categoryColorPalette.length];
    final resolvedColor = color ?? randomColor;
    final category = Category(
      id: id,
      name: name,
      ranking: await _categoryRepository.count(),
      createdAt: now,
      updatedAt: now,
      color: resolvedColor,
    );

    await _categoryRepository.insert(category);
    return category;
  }

  /// Update category
  Future<void> updateCategory(Category category) async {
    final updated = category.copyWith(updatedAt: DateTime.now());
    await _categoryRepository.update(updated);
  }

  /// Delete category
  Future<void> deleteCategory(String id) async {
    await _categoryRepository.delete(id);
  }

  /// Check if authenticator exists
  Future<bool> exists(String secret) async {
    return await _authenticatorRepository.exists(secret);
  }

  /// Get authenticator count
  Future<int> count() async {
    return await _authenticatorRepository.count();
  }
}
