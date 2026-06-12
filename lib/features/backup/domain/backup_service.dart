import 'dart:convert';
import 'dart:typed_data';
import 'package:keeauth/core/crypto/encryption_service.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';

import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'backup_models.dart';

/// Backup format options
enum BackupFormat {
  keeauth, // Custom encrypted format (v2)
  html, // Human-readable HTML
  uriList, // Plain text URI list
}

/// Service for backup and restore operations
class BackupService {
  final EncryptionService _encryptionService;

  BackupService(this._encryptionService);

  /// Create backup in specified format
  Future<Uint8List> createBackup({
    required List<Authenticator> authenticators,
    required BackupFormat format,
    String? password,
    List<Category>? categories,
    Map<String, List<String>>? authenticatorCategories,
    List<BackupCustomIcon>? customIcons,
  }) async {
    switch (format) {
      case BackupFormat.keeauth:
        return _createCompleteBackup(
          authenticators: authenticators,
          password: password ?? '',
          categories: categories,
          authenticatorCategories: authenticatorCategories,
          customIcons: customIcons,
        );
      case BackupFormat.html:
        return _createHtmlBackup(authenticators);
      case BackupFormat.uriList:
        return _createUriListBackup(authenticators);
    }
  }

  /// Restore authenticators from backup
  Future<BackupRestoreResult> restoreBackup({
    required Uint8List data,
    required BackupFormat format,
    String? password,
  }) async {
    switch (format) {
      case BackupFormat.keeauth:
        return _restoreCompleteBackup(data, password ?? '');
      case BackupFormat.html:
        final auths = await _restoreHtmlBackup(data);
        return BackupRestoreResult(authenticators: auths);
      case BackupFormat.uriList:
        final auths = await _restoreUriListBackup(data);
        return BackupRestoreResult(authenticators: auths);
    }
  }

  /// Detect backup format from data
  BackupFormat? detectFormat(Uint8List data) {
    if (data.length < 16) return null;

    // Check for encrypted KeeAuth backup — 16-byte magic header.
    final header = utf8.decode(data.sublist(0, 16));
    if (header == 'KEEAUTH_0_BACKUP') {
      return BackupFormat.keeauth;
    }

    // For text-based formats, peek at the first bytes before decoding the
    // whole file (which may be binary and un-decodable as UTF-8).
    final peek = utf8.decode(data.sublist(0, data.length < 200 ? data.length : 200));
    if (peek.contains('<!DOCTYPE html>') || peek.contains('<html')) {
      return BackupFormat.html;
    }
    if (peek.startsWith('otpauth://')) {
      return BackupFormat.uriList;
    }

    return null;
  }

  /// Detect backup version from encrypted backup
  int detectBackupVersion(Uint8List data) {
    if (data.length < 20) return BackupFormatVersion.v1UriList;

    final header = utf8.decode(data.sublist(0, 16));
    if (header != 'KEEAUTH_0_BACKUP') {
      return BackupFormatVersion.v1UriList;
    }

    // Read version from bytes 16-20
    final versionBytes = data.sublist(16, 20);
    final version = ByteData.sublistView(
      Uint8List.fromList(versionBytes),
    ).getInt32(0, Endian.big);
    return version;
  }

  // Complete backup (v2)
  Future<Uint8List> _createCompleteBackup({
    required List<Authenticator> authenticators,
    required String password,
    List<Category>? categories,
    Map<String, List<String>>? authenticatorCategories,
    List<BackupCustomIcon>? customIcons,
  }) async {
    // Build authenticator-category relationships
    final relationships = <BackupAuthenticatorCategory>[];
    if (authenticatorCategories != null) {
      for (final entry in authenticatorCategories.entries) {
        final secret = entry.key;
        for (final categoryId in entry.value) {
          relationships.add(
            BackupAuthenticatorCategory(
              authenticatorSecret: secret,
              categoryId: categoryId,
            ),
          );
        }
      }
    }

    // Build complete backup structure
    final backup = CompleteBackup(
      header: BackupHeader(
        version: BackupFormatVersion.v2Complete,
        appName: 'keeauth',
        createdAt: DateTime.now(),
      ),
      data: BackupData(
        authenticators: authenticators,
        categories: categories ?? [],
        authenticatorCategories: relationships,
        customIcons: customIcons ?? [],
      ),
    );

    // Serialize to JSON
    final jsonString = jsonEncode(backup.toJson());
    final plaintext = Uint8List.fromList(utf8.encode(jsonString));

    // Encrypt in a separate isolate — PBKDF2 + AES-256-GCM is CPU-heavy
    // and would block the UI thread, causing ANR.
    final salt = _encryptionService.generateSalt();
    final encrypted = await EncryptionService.encryptInIsolate(
      plaintext: plaintext,
      password: password,
      salt: salt,
    );

    // Build header: 16-byte magic + version (4 bytes) + salt + iv + ciphertext
    final header = utf8.encode('KEEAUTH_0_BACKUP');
    final versionBytes = ByteData(4)
      ..setInt32(0, BackupFormatVersion.v2Complete, Endian.big);

    final result = Uint8List(
      header.length +
          4 + // version
          salt.length +
          encrypted.iv.length +
          encrypted.ciphertext.length,
    );

    var offset = 0;
    result.setRange(offset, offset + header.length, header);
    offset += header.length;
    result.setRange(offset, offset + 4, versionBytes.buffer.asUint8List());
    offset += 4;
    result.setRange(offset, offset + salt.length, salt);
    offset += salt.length;
    result.setRange(offset, offset + encrypted.iv.length, encrypted.iv);
    offset += encrypted.iv.length;
    result.setRange(offset, result.length, encrypted.ciphertext);

    return result;
  }

  Future<BackupRestoreResult> _restoreCompleteBackup(
    Uint8List data,
    String password,
  ) async {
    final version = detectBackupVersion(data);

    if (version == BackupFormatVersion.v1UriList) {
      // Legacy format - only URI list
      final auths = _restoreV1Backup(data, password);
      return BackupRestoreResult(authenticators: auths);
    }

    // V2 format
    return _restoreV2Backup(data, password);
  }

  List<Authenticator> _restoreV1Backup(Uint8List data, String password) {
    // Skip header (16 bytes)
    final headerLength = 16;
    final encryptedData = data.sublist(headerLength);

    final decrypted = _encryptionService.decrypt(encryptedData, password);
    final uriList = utf8.decode(decrypted);

    return _parseUriList(uriList);
  }

  Future<BackupRestoreResult> _restoreV2Backup(
    Uint8List data,
    String password,
  ) async {
    // Parse structure: header(16) + version(4) + salt(16) + iv(12) + ciphertext(includes GCM tag)
    const headerLength = 16;
    const versionLength = 4;
    const saltLength = 16;
    const ivLength = 12;

    final salt = data.sublist(
      headerLength + versionLength,
      headerLength + versionLength + saltLength,
    );
    final iv = data.sublist(
      headerLength + versionLength + saltLength,
      headerLength + versionLength + saltLength + ivLength,
    );
    final ciphertext = data.sublist(
      headerLength + versionLength + saltLength + ivLength,
    );

    final key = await deriveKeyInIsolate(password, salt);
    final encrypted = EncryptedData(ciphertext: ciphertext, iv: iv, salt: salt);
    final decrypted = _encryptionService.decryptWithKey(encrypted, key);
    final jsonString = utf8.decode(decrypted);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final backup = CompleteBackup.fromJson(json);

    return BackupRestoreResult(
      authenticators: backup.data.authenticators,
      categories: backup.data.categories,
      authenticatorCategories: backup.data.authenticatorCategories,
      customIcons: backup.data.customIcons,
    );
  }

  // HTML backup
  Uint8List _createHtmlBackup(List<Authenticator> authenticators) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <title>Authenticator Backup</title>');
    buffer.writeln('  <style>');
    buffer.writeln(
      '    body { font-family: Arial, sans-serif; margin: 20px; }',
    );
    buffer.writeln('    table { border-collapse: collapse; width: 100%; }');
    buffer.writeln(
      '    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }',
    );
    buffer.writeln('    th { background-color: #f2f2f2; }');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <h1>Authenticator Backup</h1>');
    buffer.writeln('  <p>Generated: ${DateTime.now().toIso8601String()}</p>');
    buffer.writeln('  <table>');
    buffer.writeln(
      '    <tr><th>Issuer</th><th>Account</th><th>Secret</th><th>Type</th></tr>',
    );

    for (final auth in authenticators) {
      buffer.writeln('    <tr>');
      buffer.writeln('      <td>${_escapeHtml(auth.issuer)}</td>');
      buffer.writeln('      <td>${_escapeHtml(auth.accountName)}</td>');
      buffer.writeln('      <td>${_escapeHtml(auth.secret)}</td>');
      buffer.writeln('      <td>${auth.type.name.toUpperCase()}</td>');
      buffer.writeln('    </tr>');
    }

    buffer.writeln('  </table>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  Future<List<Authenticator>> _restoreHtmlBackup(Uint8List data) async {
    final content = utf8.decode(data);
    // Simple HTML parsing - extract otpauth URIs
    final uriRegex = RegExp(r'otpauth://[^\s<>"{}|\\^`\[\]]+');
    final matches = uriRegex.allMatches(content);

    final uris = matches.map((m) => m.group(0)!).toList();
    return _parseUriList(uris.join('\n'));
  }

  // URI list backup
  Uint8List _createUriListBackup(List<Authenticator> authenticators) {
    final uris = authenticators
        .map(
          (a) => OtpUriParser.generate(
            secret: a.secret,
            type: a.type,
            issuer: a.issuer,
            accountName: a.accountName,
            algorithm: a.algorithm,
            digits: a.digits,
            period: a.period,
            counter: a.counter,
          ),
        )
        .join('\n');

    return Uint8List.fromList(utf8.encode(uris));
  }

  Future<List<Authenticator>> _restoreUriListBackup(Uint8List data) async {
    final content = utf8.decode(data);
    return _parseUriList(content);
  }

  List<Authenticator> _parseUriList(String uriList) {
    final authenticators = <Authenticator>[];
    final uris = uriList
        .split('\n')
        .where((u) => u.trim().startsWith('otpauth://'));

    for (final uri in uris) {
      final result = OtpUriParser.parse(uri.trim());
      if (result.success && result.params != null) {
        final params = result.params!;
        authenticators.add(
          Authenticator(
            secret: params.secret,
            issuer: result.issuer ?? '',
            accountName: result.accountName ?? '',
            type: params.type,
            algorithm: params.algorithm,
            digits: params.digits,
            period: params.period,
            counter: params.counter,
            pin: params.pin,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }

    return authenticators;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

/// Result of backup restore operation
class BackupRestoreResult {
  final List<Authenticator> authenticators;
  final List<Category>? categories;
  final List<BackupAuthenticatorCategory>? authenticatorCategories;
  final List<BackupCustomIcon>? customIcons;

  const BackupRestoreResult({
    required this.authenticators,
    this.categories,
    this.authenticatorCategories,
    this.customIcons,
  });
}
