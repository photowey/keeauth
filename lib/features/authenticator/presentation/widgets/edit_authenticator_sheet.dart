import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_qr_sheet.dart';

class EditAuthenticatorSheet extends StatefulWidget {
  final Authenticator authenticator;

  const EditAuthenticatorSheet({super.key, required this.authenticator});

  @override
  State<EditAuthenticatorSheet> createState() => _EditAuthenticatorSheetState();
}

class _EditAuthenticatorSheetState extends State<EditAuthenticatorSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _issuerController;
  late TextEditingController _accountController;
  late TextEditingController _secretController;
  late TextEditingController _digitsController;
  late TextEditingController _periodController;
  late TextEditingController _counterController;
  late TextEditingController _pinController;

  late AuthenticatorType _type;
  late OtpHashAlgorithm _algorithm;

  bool _isLoading = false;
  bool _showAdvanced = false;
  bool _advancedWarningAccepted = false;
  bool _showChangeSecret = false;

  @override
  void initState() {
    super.initState();
    final a = widget.authenticator;
    _issuerController = TextEditingController(text: a.issuer);
    _accountController = TextEditingController(text: a.accountName);
    _secretController = TextEditingController(text: a.secret);
    _digitsController = TextEditingController(text: a.digits.toString());
    _periodController = TextEditingController(text: a.period.toString());
    _counterController = TextEditingController(text: a.counter.toString());
    _pinController = TextEditingController(text: a.pin ?? '');
    _type = a.type;
    _algorithm = a.algorithm;
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _accountController.dispose();
    _secretController.dispose();
    _digitsController.dispose();
    _periodController.dispose();
    _counterController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  bool get _isDigitsLocked =>
      _type == AuthenticatorType.steam ||
      _type == AuthenticatorType.motp ||
      _type == AuthenticatorType.yandex;

  bool get _isAlgorithmLocked =>
      _type == AuthenticatorType.steam ||
      _type == AuthenticatorType.yandex;

  bool get _isPeriodLocked => _type == AuthenticatorType.steam;

  bool get _showPeriod =>
      _type == AuthenticatorType.totp ||
      _type == AuthenticatorType.steam ||
      _type == AuthenticatorType.yandex ||
      _type == AuthenticatorType.motp;

  bool get _showCounter => _type == AuthenticatorType.hotp;

  bool get _showPin =>
      _type == AuthenticatorType.motp || _type == AuthenticatorType.yandex;

  void _onTypeChanged(AuthenticatorType? newType) {
    if (newType == null) return;
    setState(() {
      _type = newType;
      switch (newType) {
        case AuthenticatorType.steam:
          _digitsController.text = '5';
          _algorithm = OtpHashAlgorithm.sha1;
          _periodController.text = '30';
        case AuthenticatorType.motp:
          _digitsController.text = '6';
        case AuthenticatorType.yandex:
          _digitsController.text = '8';
          _algorithm = OtpHashAlgorithm.sha256;
        case AuthenticatorType.totp:
        case AuthenticatorType.hotp:
          break;
      }
    });
  }

  String? _validateIssuer(String? value) {
    if (value != null && value.length > 32) {
      final l10n = AppLocalizations.of(context);
      return l10n?.maxCharacters(32) ?? 'Max 32 characters';
    }
    return null;
  }

  String? _validateAccount(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseEnterAccount ?? 'Please enter an account name';
    }
    if (value.length > 40) {
      return l10n?.maxCharacters(40) ?? 'Max 40 characters';
    }
    return null;
  }

  String? _validateSecret(String? value) {
    if (!_showChangeSecret) return null;
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n?.pleaseEnterSecret ?? 'Please enter the secret key';
    }
    final clean = value.trim();
    if (_type == AuthenticatorType.motp) {
      if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(clean)) {
        return l10n?.motpSecretAlphanumeric ?? 'mOTP secret must be alphanumeric';
      }
    } else {
      final upper = clean.toUpperCase().replaceAll(' ', '');
      if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(upper)) {
        return l10n?.invalidBase32Format ?? 'Invalid Base32 format';
      }
    }
    return null;
  }

  String? _validateDigits(String? value) {
    if (_isDigitsLocked) return null;
    final v = int.tryParse(value ?? '');
    if (v == null || v < 6 || v > 10) {
      final l10n = AppLocalizations.of(context);
      return l10n?.digitsRange ?? '6 ~ 10';
    }
    return null;
  }

  String? _validatePeriod(String? value) {
    if (_isPeriodLocked) return null;
    final v = int.tryParse(value ?? '');
    if (v == null || v <= 0) {
      final l10n = AppLocalizations.of(context);
      return l10n?.mustBePositive ?? 'Must be > 0';
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (!_showPin) return null;
    if (value == null || value.trim().isEmpty) {
      final l10n = AppLocalizations.of(context);
      return l10n?.pinRequired ?? 'PIN is required';
    }
    return null;
  }

  Future<void> _toggleAdvancedOptions(AppLocalizations? l10n) async {
    if (_showAdvanced) {
      setState(() => _showAdvanced = false);
      return;
    }

    // First time expanding: show warning dialog
    if (!_advancedWarningAccepted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          title: Text(l10n?.advancedWarningTitle ?? 'Warning'),
          content: Text(
            l10n?.advancedWarningMessage ??
                'Changing advanced settings (type, algorithm, digits, period) may cause your verification codes to become invalid. Only modify these if you know exactly what you are doing.\n\nIncorrect changes could lock you out of your accounts.',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.goBack ?? 'Go Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n?.iUnderstand ?? 'I Understand'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      _advancedWarningAccepted = true;
    }

    setState(() => _showAdvanced = true);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      final updated = widget.authenticator.copyWith(
        issuer: _issuerController.text.trim(),
        accountName: _accountController.text.trim(),
        secret:
            _showChangeSecret
                ? _secretController.text.trim()
                : widget.authenticator.secret,
        type: _type,
        algorithm: _algorithm,
        digits: int.tryParse(_digitsController.text) ?? widget.authenticator.digits,
        period: int.tryParse(_periodController.text) ?? widget.authenticator.period,
        counter:
            int.tryParse(_counterController.text) ?? widget.authenticator.counter,
        pin: _showPin ? _pinController.text.trim() : widget.authenticator.pin,
        updatedAt: DateTime.now(),
      );

      if (!mounted) return;
      context.read<AuthenticatorBloc>().add(UpdateAuthenticator(updated));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.authenticatorUpdated ?? 'Authenticator updated'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.error ?? 'Error'}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final l10n = AppLocalizations.of(context);
    final a = widget.authenticator;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteAuthenticator ?? 'Delete Authenticator'),
        content: Text(
          l10n?.deleteConfirm ??
              'Are you sure you want to delete "${a.issuer.isNotEmpty ? a.issuer : a.accountName}"?\n\n'
                  'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthenticatorBloc>().add(DeleteAuthenticator(a.secret));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.authenticatorDeleted ?? 'Authenticator deleted'),
        ),
      );
    }
  }

  void _showQrCode() {
    final a = widget.authenticator;
    showAuthenticatorQrSheet(
      context,
      issuer: a.issuer,
      accountName: a.accountName,
      secret: a.secret,
      type: a.type.name,
      algorithm: a.algorithm.displayName,
      digits: a.digits,
      period: a.period,
      counter: a.counter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.editAuthenticator ?? 'Edit Authenticator',
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable form content
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Basic fields ---
                        TextFormField(
                          controller: _issuerController,
                          maxLength: 32,
                          decoration: InputDecoration(
                            labelText: l10n?.issuer ?? 'Issuer',
                            hintText: l10n?.issuerHint ?? 'e.g., Google, GitHub',
                            prefixIcon: const Icon(Icons.business),
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateIssuer,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _accountController,
                          maxLength: 40,
                          decoration: InputDecoration(
                            labelText: l10n?.accountName ?? 'Account Name',
                            hintText: l10n?.accountHint ?? 'e.g., user@example.com',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateAccount,
                        ),
                        const SizedBox(height: 16),

                        // --- Advanced options (with warning gate) ---
                        InkWell(
                          onTap: () => _toggleAdvancedOptions(l10n),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tune,
                                  color: _showAdvanced
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n?.showAdvancedOptions ?? 'Advanced Options',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: _showAdvanced
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showAdvanced
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showAdvanced) ...[
                          // Warning banner
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n?.advancedWarningMessage ??
                                        'Changing advanced settings may cause your codes to become invalid.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Type
                          DropdownButtonFormField<AuthenticatorType>(
                            value: _type,
                            decoration: InputDecoration(
                              labelText: l10n?.type ?? 'Type',
                              border: const OutlineInputBorder(),
                            ),
                            items: AuthenticatorType.values.map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Text(t.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: _onTypeChanged,
                          ),
                          const SizedBox(height: 12),

                          // Algorithm
                          DropdownButtonFormField<OtpHashAlgorithm>(
                            value: _algorithm,
                            decoration: InputDecoration(
                              labelText: l10n?.algorithm ?? 'Algorithm',
                              border: const OutlineInputBorder(),
                            ),
                            items: OtpHashAlgorithm.values.map((a) {
                              return DropdownMenuItem(
                                value: a,
                                child: Text(a.displayName),
                              );
                            }).toList(),
                            onChanged: _isAlgorithmLocked
                                ? null
                                : (v) {
                                    if (v != null) setState(() => _algorithm = v);
                                  },
                          ),
                          const SizedBox(height: 12),

                          // Digits
                          TextFormField(
                            controller: _digitsController,
                            readOnly: _isDigitsLocked,
                            decoration: InputDecoration(
                              labelText: l10n?.digits ?? 'Digits',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateDigits,
                          ),
                          const SizedBox(height: 12),

                          // Period (TOTP / Steam / mOTP / Yandex)
                          if (_showPeriod) ...[
                            TextFormField(
                              controller: _periodController,
                              readOnly: _isPeriodLocked,
                              decoration: InputDecoration(
                                labelText: l10n?.period ?? 'Period (seconds)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _validatePeriod,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Counter (HOTP only)
                          if (_showCounter) ...[
                            TextFormField(
                              controller: _counterController,
                              decoration: InputDecoration(
                                labelText: l10n?.counter ?? 'Counter',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // PIN (mOTP / Yandex)
                          if (_showPin) ...[
                            TextFormField(
                              controller: _pinController,
                              decoration: InputDecoration(
                                labelText: l10n?.pin ?? 'PIN',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.pin),
                              ),
                              validator: _validatePin,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Change secret toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n?.changeSecretKey ?? 'Change Secret Key',
                              style: theme.textTheme.bodyMedium,
                            ),
                            secondary: const Icon(Icons.key),
                            value: _showChangeSecret,
                            onChanged: (v) =>
                                setState(() => _showChangeSecret = v),
                          ),

                          if (_showChangeSecret) ...[
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _secretController,
                              decoration: InputDecoration(
                                labelText: l10n?.secretKey ?? 'Secret Key',
                                hintText:
                                    l10n?.secretKeyHint ?? 'Enter the secret key',
                                prefixIcon: const Icon(Icons.vpn_key),
                                border: const OutlineInputBorder(),
                              ),
                              validator: _validateSecret,
                            ),
                            const SizedBox(height: 12),
                          ],

                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 16),

                        // --- Action buttons ---
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isLoading ? null : _showDeleteConfirmation,
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: Text(
                                  l10n?.delete ?? 'Delete',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _saveChanges,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(l10n?.save ?? 'Save'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Show QR button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _showQrCode,
                            icon: const Icon(Icons.qr_code),
                            label: Text(l10n?.showQrCode ?? 'Show QR Code'),
                          ),
                        ),
                        const SizedBox(height: 8),
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
}

/// Show edit authenticator bottom sheet
Future<void> showEditAuthenticator(
  BuildContext context, {
  required Authenticator authenticator,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: EditAuthenticatorSheet(authenticator: authenticator),
    ),
  );
}
