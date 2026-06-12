import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'authenticator_icon.dart';

/// Bottom sheet for previewing scanned authenticator before adding
class AddAuthenticatorPreviewSheet extends StatefulWidget {
  final String uri;

  const AddAuthenticatorPreviewSheet({super.key, required this.uri});

  @override
  State<AddAuthenticatorPreviewSheet> createState() =>
      _AddAuthenticatorPreviewSheetState();
}

class _AddAuthenticatorPreviewSheetState
    extends State<AddAuthenticatorPreviewSheet> {
  OtpUriParseResult? _parsedResult;
  String? _error;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _parseUri();
  }

  void _parseUri() {
    final result = OtpUriParser.parse(widget.uri);
    if (result.success) {
      setState(() => _parsedResult = result);
    } else {
      setState(() => _error = result.error ?? 'Failed to parse QR code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              if (_error != null)
                _buildErrorView()
              else if (_parsedResult == null)
                const Center(child: CircularProgressIndicator())
              else
                _buildPreviewView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          l10n?.invalidQrCodeShort ?? 'Invalid QR Code',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _error != null && _error!.contains('Failed to parse')
              ? (l10n?.failedToParseQrCode ?? _error!)
              : _error!,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.tryAgain ?? 'Try Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    final result = _parsedResult!;
    final issuer = result.issuer ?? '';
    final accountName = result.accountName ?? '';
    final type = result.params?.type.name ?? 'totp';
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          l10n?.addAuthenticator ?? 'Add Authenticator?',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Preview card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getIssuerColor(issuer).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AuthenticatorIcon(issuer: issuer, size: 36),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issuer.isNotEmpty ? issuer : accountName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (issuer.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        accountName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _isAdding ? null : () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addAuthenticator,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isAdding
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(l10n?.add ?? 'Add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getIssuerColor(String issuer) {
    // Use a default color based on issuer name hash
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    if (issuer.isEmpty) return Colors.grey;
    final hash = issuer.hashCode.abs();
    return colors[hash % colors.length];
  }

  void _addAuthenticator() {
    final l10n = AppLocalizations.of(context);
    setState(() => _isAdding = true);

    context.read<AuthenticatorBloc>().add(AddAuthenticator(widget.uri));

    // Show success and close
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.authenticatorAdded ?? 'Authenticator added successfully',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, true);
  }
}
