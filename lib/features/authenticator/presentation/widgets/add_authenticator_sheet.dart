import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/backup/presentation/restore_backup.dart';
import 'package:keeauth/features/backup/presentation/screens/import_screen.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/authenticator/presentation/screens/qr_scanner_screen.dart';
import 'icon_picker_sheet.dart';

// Re-export for convenience
export 'icon_picker_sheet.dart' show IconSelectionResult;

/// Bottom sheet for adding a new authenticator
class AddAuthenticatorSheet extends StatefulWidget {
  const AddAuthenticatorSheet({super.key});

  @override
  State<AddAuthenticatorSheet> createState() => _AddAuthenticatorSheetState();
}

class _AddAuthenticatorSheetState extends State<AddAuthenticatorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountController = TextEditingController();
  final _secretController = TextEditingController();

  final _pinController = TextEditingController();
  final _counterController = TextEditingController(text: '0');

  String? _error;
  bool _isLoading = false;
  bool _showAdvanced = false;
  IconSelectionResult? _selectedIcon;

  // Advanced options
  String _otpType = 'TOTP';
  String _algorithm = 'SHA1';
  int _digits = 6;
  int _period = 30;
  int _counter = 0;

  @override
  void dispose() {
    _issuerController.dispose();
    _accountController.dispose();
    _secretController.dispose();
    _pinController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  l10n?.addAuthenticator ?? 'Add Authenticator',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scan QR button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _openScanner,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(l10n?.scanQrCode ?? 'Scan QR Code'),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n?.or ?? 'OR',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Import options
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openImport,
                                icon: const Icon(Icons.download),
                                label: Text(
                                  l10n?.import ?? 'Import',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openRestore,
                                icon: const Icon(Icons.restore),
                                label: Text(
                                  l10n?.restore ?? 'Restore',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                l10n?.enterManually ?? 'OR ENTER MANUALLY',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Icon picker and Issuer row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon picker
                            InkWell(
                              onTap: _showIconPicker,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child:
                                    _selectedIcon != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              _selectedIcon!.isCustom &&
                                                      _selectedIcon!
                                                              .customPath !=
                                                          null
                                                  ? Image.file(
                                                    File(
                                                      _selectedIcon!
                                                          .customPath!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Image.asset(
                                                    _selectedIcon!.assetPath ??
                                                        'assets/icons/key.png',
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.add,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                          size: 28,
                                                        ),
                                                  ),
                                        )
                                        : Icon(
                                          Icons.add,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                          size: 28,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Issuer field
                            Expanded(
                              child: TextFormField(
                                controller: _issuerController,
                                decoration: InputDecoration(
                                  labelText:
                                      l10n?.issuerOptional ??
                                      'Issuer (optional)',
                                  hintText:
                                      l10n?.issuerHint ??
                                      'e.g., Google, GitHub',
                                  prefixIcon: const Icon(Icons.business),
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (_) => _updateIconFromIssuer(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Account field
                        TextFormField(
                          controller: _accountController,
                          decoration: InputDecoration(
                            labelText: l10n?.account ?? 'Account',
                            hintText:
                                l10n?.accountHint ?? 'e.g., user@example.com',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n?.pleaseEnterAccount ??
                                  'Please enter an account name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Secret field
                        TextFormField(
                          controller: _secretController,
                          decoration: InputDecoration(
                            labelText: l10n?.secretKey ?? 'Secret Key',
                            hintText:
                                l10n?.secretKeyHint ?? 'Enter the secret key',
                            prefixIcon: const Icon(Icons.key),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n?.pleaseEnterSecret ??
                                  'Please enter the secret key';
                            }
                            // Basic validation for base32
                            final clean = value.toUpperCase().replaceAll(
                              ' ',
                              '',
                            );
                            if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(clean)) {
                              return l10n?.invalidSecretFormat ??
                                  'Invalid secret key format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Advanced options toggle
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _showAdvanced = !_showAdvanced);
                          },
                          icon: Icon(
                            _showAdvanced
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          label: Text(
                            l10n?.showAdvancedOptions ??
                                'Show advanced options',
                          ),
                        ),

                        // Advanced options
                        if (_showAdvanced) ...[
                          const SizedBox(height: 16),
                          // Type dropdown
                          DropdownButtonFormField<String>(
                            value: _otpType,
                            decoration: InputDecoration(
                              labelText: l10n?.type ?? 'Type',
                              border: const OutlineInputBorder(),
                            ),
                            items:
                                ['TOTP', 'HOTP', 'Steam', 'mOTP', 'Yandex'].map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _otpType = value ?? 'TOTP';
                                _applyTypeDefaults();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // PIN field (mOTP / Yandex only)
                          if (_otpType == 'mOTP' || _otpType == 'Yandex') ...[
                            TextFormField(
                              controller: _pinController,
                              decoration: InputDecoration(
                                labelText: 'PIN',
                                hintText: _otpType == 'mOTP' ? '4-digit PIN' : 'PIN for Yandex',
                                prefixIcon: const Icon(Icons.pin),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if ((_otpType == 'mOTP' || _otpType == 'Yandex') &&
                                    (value == null || value.isEmpty)) {
                                  return 'PIN is required for $_otpType';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Algorithm dropdown (locked for Steam/Yandex)
                          DropdownButtonFormField<String>(
                            value: _algorithm,
                            decoration: InputDecoration(
                              labelText: l10n?.algorithm ?? 'Algorithm',
                              border: const OutlineInputBorder(),
                              enabled: !_isAlgorithmLocked,
                            ),
                            items:
                                ['SHA1', 'SHA256', 'SHA512'].map((alg) {
                                  return DropdownMenuItem(
                                    value: alg,
                                    child: Text(alg),
                                  );
                                }).toList(),
                            onChanged: _isAlgorithmLocked ? null : (value) {
                              setState(() => _algorithm = value ?? 'SHA1');
                            },
                          ),
                          const SizedBox(height: 12),
                          // Digits field (locked for Steam/mOTP/Yandex)
                          TextFormField(
                            initialValue: _digits.toString(),
                            enabled: !_isDigitsLocked,
                            decoration: InputDecoration(
                              labelText: l10n?.digits ?? 'Digits',
                              border: const OutlineInputBorder(),
                              helperText: _isDigitsLocked ? 'Fixed for $_otpType' : null,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(
                                () => _digits = int.tryParse(value) ?? 6,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Period field (TOTP/Steam/mOTP/Yandex)
                          if (_otpType != 'HOTP')
                            TextFormField(
                              initialValue: _period.toString(),
                              enabled: !_isPeriodLocked,
                              decoration: InputDecoration(
                                labelText: l10n?.period ?? 'Period (seconds)',
                                border: const OutlineInputBorder(),
                                helperText: _isPeriodLocked ? 'Fixed for $_otpType' : null,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(
                                  () => _period = int.tryParse(value) ?? 30,
                                );
                              },
                            ),
                          // Counter field (HOTP only)
                          if (_otpType == 'HOTP')
                            TextFormField(
                              controller: _counterController,
                              decoration: InputDecoration(
                                labelText: 'Counter',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _counter = int.tryParse(value) ?? 0;
                              },
                            ),
                        ],

                        const SizedBox(height: 16),

                        // Error message
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n?.cancel ?? 'Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _isLoading ? null : _addManual,
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(l10n?.add ?? 'Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showIconPicker() async {
    final result = await showIconPicker(
      context,
      initialName: _issuerController.text,
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result;
        if (_issuerController.text.isEmpty) {
          _issuerController.text = result.name;
        }
      });
    }
  }

  void _updateIconFromIssuer() {
    // Icon matching is handled automatically
  }

  bool get _isAlgorithmLocked =>
      _otpType == 'Steam' || _otpType == 'Yandex';

  bool get _isDigitsLocked =>
      _otpType == 'Steam' || _otpType == 'mOTP' || _otpType == 'Yandex';

  bool get _isPeriodLocked => _otpType == 'Steam';

  void _applyTypeDefaults() {
    switch (_otpType) {
      case 'Steam':
        _digits = 5;
        _algorithm = 'SHA1';
        _period = 30;
      case 'mOTP':
        _digits = 6;
        _period = 10;
      case 'Yandex':
        _digits = 8;
        _algorithm = 'SHA256';
        _period = 30;
      case 'HOTP':
        _digits = 6;
      default:
        _digits = 6;
        _period = 30;
    }
  }

  Future<void> _openScanner() async {
    Navigator.pop(context);
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openImport() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
  }

  Future<void> _openRestore() async {
    await restoreBackupFromFile(context);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addManual() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = _buildUri();
      context.read<AuthenticatorBloc>().add(AddAuthenticator(uri));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _buildUri() {
    final issuer = _issuerController.text.trim();
    final account = _accountController.text.trim();
    final secret = _secretController.text.trim().toUpperCase().replaceAll(
      ' ',
      '',
    );

    // mOTP uses a different URI scheme
    if (_otpType == 'mOTP') {
      final pin = _pinController.text.trim();
      return 'motp://${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(account)}'
          '?secret=${_secretController.text.trim()}&pin=$pin&digits=$_digits&period=$_period';
    }

    final buffer = StringBuffer();
    final typeStr = _otpType == 'Steam' ? 'totp' :
                    _otpType == 'Yandex' ? 'totp' :
                    _otpType.toLowerCase();
    buffer.write('otpauth://$typeStr/');

    if (issuer.isNotEmpty) {
      buffer.write(Uri.encodeComponent('$issuer:'));
    }
    buffer.write(Uri.encodeComponent(account));

    buffer.write('?secret=$secret');

    if (issuer.isNotEmpty) {
      buffer.write('&issuer=${Uri.encodeComponent(issuer)}');
    }

    buffer.write('&algorithm=$_algorithm');
    buffer.write('&digits=$_digits');

    if (_otpType == 'HOTP') {
      buffer.write('&counter=$_counter');
    } else {
      buffer.write('&period=$_period');
    }

    if (_otpType == 'Steam') {
      buffer.write('&steam');
    }
    if (_otpType == 'Yandex') {
      final pin = _pinController.text.trim();
      buffer.write('&pin=$pin');
    }

    return buffer.toString();
  }
}
