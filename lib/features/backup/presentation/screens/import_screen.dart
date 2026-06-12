import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:keeauth/l10n/app_localizations.dart';

import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/backup/domain/converters/converter_factory.dart';
import 'package:keeauth/features/backup/domain/converters/backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen for importing authenticators from various formats
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _isLoading = false;
  String? _error;
  BackupConverter? _selectedConverter;
  ImportPreview? _preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.importAuthenticators ?? 'Import Authenticators'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n?.parsingBackupFile ?? 'Parsing backup file...'),
          ],
        ),
      );
    }

    if (_preview != null) {
      return _buildPreview();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildFormatSelection(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  l10n?.importFromOtherApps ?? 'Supported Formats',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.importFromOtherApps ??
                  l10n?.importFromOtherApps ??
                  'Import authenticators from other 2FA apps including Aegis, Bitwarden, 2FAS, FreeOTP+, and Google Authenticator.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    final converters = ConverterFactory.allConverters;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.selectSource ?? 'Select Source',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...converters.map((converter) => _buildConverterTile(converter)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedConverter != null ? _pickFile : null,
            icon: const Icon(Icons.file_open),
            label: Text(l10n?.selectBackupFile ?? 'Select Backup File'),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterTile(BackupConverter converter) {
    final l10n = AppLocalizations.of(context);
    final isSelected = _selectedConverter?.name == converter.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
                : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(
          _getIconForConverter(converter.name),
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(converter.name),
        subtitle: Text(
          '${l10n?.supportedFormats ?? 'Extensions'}: ${converter.supportedExtensions.join(", ")}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
                : null,
        onTap: () {
          setState(() {
            _selectedConverter = converter;
            _error = null;
          });
        },
      ),
    );
  }

  IconData _getIconForConverter(String name) {
    switch (name.toLowerCase()) {
      case 'aegis':
        return Icons.shield;
      case 'bitwarden':
        return Icons.password;
      case '2fas':
        return Icons.two_wheeler;
      case 'freeotp+':
        return Icons.vpn_key;
      case 'google authenticator':
        return Icons.g_mobiledata;
      default:
        return Icons.import_export;
    }
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error!, style: TextStyle(color: Colors.red[700])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final preview = _preview!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPreviewHeader(preview),
              const SizedBox(height: 16),
              ...preview.newAuthenticators.map(
                (stub) => _buildAuthenticatorTile(stub, isConflict: false),
              ),
              ...preview.conflicts.map(
                (conflict) => _buildAuthenticatorTile(
                  conflict.authenticator,
                  isConflict: true,
                  conflictType: conflict.type,
                ),
              ),
            ],
          ),
        ),
        _buildPreviewActions(preview),
      ],
    );
  }

  Widget _buildPreviewHeader(ImportPreview preview) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.importPreview ?? 'Import Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('${preview.newAuthenticators.length} new authenticators'),
            if (preview.conflictCount > 0)
              Text(
                '${preview.conflictCount} conflicts detected',
                style: TextStyle(color: Colors.orange[700]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatorTile(
    AuthenticatorStub stub, {
    required bool isConflict,
    ImportConflictType? conflictType,
  }) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading:
          isConflict
              ? Icon(Icons.warning_amber, color: Colors.orange[700])
              : const Icon(Icons.check_circle, color: Colors.green),
      title: Text(stub.issuer.isNotEmpty ? stub.issuer : stub.accountName),
      subtitle: Text(stub.accountName),
      trailing:
          isConflict
              ? TextButton(onPressed: () {}, child: Text(l10n?.skip ?? 'Skip'))
              : null,
    );
  }

  Widget _buildPreviewActions(ImportPreview preview) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _preview = null;
                  });
                },
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    preview.newAuthenticators.isNotEmpty
                        ? () => _importAuthenticators(preview)
                        : null,
                child: Text(
                  l10n?.importItems(preview.newAuthenticators.length) ??
                      'Import ${preview.newAuthenticators.length} Items',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            _selectedConverter!.supportedExtensions
                .map((e) => e.replaceAll('.', ''))
                .toList(),
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await _processFile(file.path!);
        }
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      setState(() {
        _error = '${loc?.failedToPickFile ?? 'Failed to pick file'}: $e';
      });
    }
  }

  Future<void> _processFile(String path) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final file = File(path);
      final content = await file.readAsString();

      // Auto-detect if no converter selected
      BackupConverter? converter = _selectedConverter;
      if (converter == null) {
        converter = ConverterFactory.detectConverter(content);
        if (converter == null) {
          final loc = AppLocalizations.of(context);
          setState(() {
            _isLoading = false;
            _error =
                loc?.couldNotDetectFormat ??
                'Could not detect backup format. Please select a format manually.';
          });
          return;
        }
      }

      // Check for password requirement
      if (converter.supportsEncryption && _needsPassword(content)) {
        final password = await _showPasswordDialog();
        if (password == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final result = await converter.convert(content, password: password);
        _handleConversionResult(result);
      } else {
        final result = await converter.convert(content);
        _handleConversionResult(result);
      }
    } catch (e) {
      final loc = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _error = '${loc?.failedToProcessFile ?? 'Failed to process file'}: $e';
      });
    }
  }

  bool _needsPassword(String content) {
    // Simple check for encryption markers
    return content.contains('"encrypted"') ||
        content.contains('servicesEncrypted') ||
        content.contains('db');
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(l10n?.passwordRequired ?? 'Password Required'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n?.backupPassword ?? 'Backup Password',
                hintText:
                    l10n?.enterBackupPassword ??
                    l10n?.enterBackupPassword ??
                    'Enter the password for this backup',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(l10n?.unlock ?? 'Unlock'),
              ),
            ],
          ),
    );
  }

  void _handleConversionResult(ConversionResult result) {
    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      if (result.needsPassword) {
        _showPasswordDialog().then((password) {
          if (password != null) {
            // Retry with password
            _processFileWithPassword(password);
          }
        });
        return;
      }

      final loc = AppLocalizations.of(context);
      setState(() {
        _error = result.error ?? loc?.error ?? 'Unknown error';
      });
      return;
    }

    // Build preview
    final conflicts = <ImportConflict>[];
    final newAuths = <AuthenticatorStub>[];

    for (final stub in result.authenticators) {
      // Check for conflicts (simplified)
      // In production, check against existing authenticators
      newAuths.add(stub);
    }

    setState(() {
      _preview = ImportPreview(
        newAuthenticators: newAuths,
        conflicts: conflicts,
        newCategories: result.categories,
      );
    });
  }

  Future<void> _processFileWithPassword(String password) async {
    // Implementation for retry with password
  }

  void _importAuthenticators(ImportPreview preview) {
    final l10n = AppLocalizations.of(context);

    // Build URI for each authenticator and add
    for (final stub in preview.newAuthenticators) {
      final uri = _buildOtpAuthUri(stub);
      context.read<AuthenticatorBloc>().add(AddAuthenticator(uri));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.importedCount(preview.newAuthenticators.length) ??
              'Imported ${preview.newAuthenticators.length} authenticators',
        ),
      ),
    );

    Navigator.pop(context);
  }

  String _buildOtpAuthUri(AuthenticatorStub stub) {
    final buffer = StringBuffer('otpauth://${stub.type}/');

    final label =
        stub.issuer.isNotEmpty
            ? '${Uri.encodeComponent(stub.issuer)}:${Uri.encodeComponent(stub.accountName)}'
            : Uri.encodeComponent(stub.accountName);
    buffer.write(label);

    buffer.write('?secret=${Uri.encodeComponent(stub.secret)}');

    if (stub.issuer.isNotEmpty) {
      buffer.write('&issuer=${Uri.encodeComponent(stub.issuer)}');
    }

    if (stub.algorithm.toLowerCase() != 'sha1') {
      buffer.write('&algorithm=${stub.algorithm.toUpperCase()}');
    }

    if (stub.digits != 6) {
      buffer.write('&digits=${stub.digits}');
    }

    if (stub.type == 'totp' && stub.period != 30) {
      buffer.write('&period=${stub.period}');
    }

    if (stub.type == 'hotp' && stub.counter != null) {
      buffer.write('&counter=${stub.counter}');
    }

    return buffer.toString();
  }
}
