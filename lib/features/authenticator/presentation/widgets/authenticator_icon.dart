import 'dart:io';
import 'package:flutter/material.dart';
import 'package:keeauth/core/icons/icon_service.dart';

/// Widget for displaying authenticator icon with async loading.
/// Priority: customIconPath (user-selected) > issuer-based lookup > initials fallback
class AuthenticatorIcon extends StatefulWidget {
  final String issuer;
  final String? customIconPath;
  final double size;
  final BorderRadius? borderRadius;

  const AuthenticatorIcon({
    super.key,
    required this.issuer,
    this.customIconPath,
    this.size = 48,
    this.borderRadius,
  });

  @override
  State<AuthenticatorIcon> createState() => _AuthenticatorIconState();
}

class _AuthenticatorIconState extends State<AuthenticatorIcon> {
  final IconService _iconService = IconService();
  String? _issuerIconPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIssuerIcon();
  }

  @override
  void didUpdateWidget(covariant AuthenticatorIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issuer != widget.issuer ||
        oldWidget.customIconPath != widget.customIconPath) {
      _loadIssuerIcon();
    }
  }

  Future<void> _loadIssuerIcon() async {
    // If we have a custom icon, no need to load issuer icon
    if (_hasCustomIcon) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final path = await _iconService.getIconPathForIssuer(widget.issuer);
    if (mounted) {
      setState(() {
        _issuerIconPath = path;
        _loading = false;
      });
    }
  }

  bool get _hasCustomIcon =>
      widget.customIconPath != null && widget.customIconPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildPlaceholder();
    }

    final br = widget.borderRadius ?? BorderRadius.circular(widget.size / 4);

    // 1st priority: user-selected custom icon
    if (_hasCustomIcon) {
      final path = widget.customIconPath!;

      // Asset path (starts with "assets/")
      if (path.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: br,
          child: Image.asset(
            path,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildInitialsIcon(),
          ),
        );
      }

      // File path (custom image picked by user)
      final file = File(path);
      return ClipRRect(
        borderRadius: br,
        child: Image.file(
          file,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsIcon(),
        ),
      );
    }

    // 2nd priority: issuer-based icon from IconService
    if (_issuerIconPath != null &&
        _issuerIconPath != IconService.defaultIconPath) {
      return ClipRRect(
        borderRadius: br,
        child: Image.asset(
          _issuerIconPath!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildInitialsIcon(),
        ),
      );
    }

    // 3rd: initials fallback
    return _buildInitialsIcon();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _getIssuerColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(widget.size / 4),
      ),
      child: Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getIssuerColor()),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsIcon() {
    final initial =
        widget.issuer.isNotEmpty ? widget.issuer[0].toUpperCase() : '?';

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _getIssuerColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(widget.size / 4),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
            color: _getIssuerColor(),
          ),
        ),
      ),
    );
  }

  Color _getIssuerColor() {
    if (widget.issuer.isEmpty) return Colors.blue;

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    final hash = widget.issuer.hashCode.abs();
    return colors[hash % colors.length];
  }
}
