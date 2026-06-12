import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/core/icons/icon_service.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Boot animation sequence — transitions from small logo to large logo
class BootSequence extends StatefulWidget {
  final VoidCallback onComplete;

  const BootSequence({super.key, required this.onComplete});

  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence>
    with TickerProviderStateMixin {
  // Phase 1: Small logo pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Phase 2: Transition to large logo
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // Phase 3: Show welcome content
  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  int _currentPhase = 0; // 0: small, 1: transition, 2: large/welcome
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startBootSequence();
  }

  void _initAnimations() {
    // Phase 1: Small logo pulse animation (2s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Phase 2: Scale-up transition (800ms)
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5, // Scale small logo to 2.5x
    ).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15), // Move upward
    ).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );

    // Phase 3: Content reveal animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _startBootSequence() async {
    // Phase 1: Show small logo, start pulse
    setState(() {
      _currentPhase = 0;
      _statusText = 'Starting...';
    });
    _pulseController.repeat();

    // Initialize services in background
    unawaited(_initializeServices());

    // Wait 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    // Phase 2: Quick transition to large logo
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPhase = 1;
      _statusText = '';
    });

    _pulseController.stop();
    await _expandController.forward();

    // Phase 3: Show welcome content
    if (!mounted) {
      return;
    }
    setState(() {
      _currentPhase = 2;
    });

    await _contentController.forward();

    // Auto-finish after 500ms, total ~4.5s
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      widget.onComplete();
    } else {
    }
  }

  Future<void> _initializeServices() async {
    // Background init, non-blocking
    unawaited(IconService().initialize());

    final storage = SecureStorageService();
    unawaited(storage.isTapToRevealEnabled());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          _buildBackground(colorScheme),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo area (small logo + transition)
                if (_currentPhase < 2) _buildSmallLogo(colorScheme),

                // Spacing
                if (_currentPhase < 2) const SizedBox(height: 48),

                // Status text
                if (_statusText.isNotEmpty && _currentPhase < 2)
                  _buildStatusText(colorScheme),

                // Progress indicator
                if (_currentPhase == 0) _buildProgressIndicator(colorScheme),
              ],
            ),
          ),

          // Large logo and welcome (Phase 2+)
          if (_currentPhase >= 2) _buildWelcomeContent(colorScheme, l10n),
        ],
      ),
    );
  }

  Widget _buildBackground(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            _currentPhase >= 2
                ? colorScheme.primaryContainer.withOpacity(0.1)
                : colorScheme.surface,
            colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildSmallLogo(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _expandController]),
      builder: (context, child) {
        double scale = _pulseAnimation.value;
        double opacity = 1.0;

        if (_currentPhase == 1) {
          scale = _scaleAnimation.value;
          opacity = _opacityAnimation.value;
        }

        final glowAlpha = _glowAnimation.value * 0.5;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset:
                _currentPhase == 1
                    ? _slideAnimation.value *
                        MediaQuery.of(context).size.height *
                        0.5
                    : Offset.zero,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(glowAlpha),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText(ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: _currentPhase == 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(
            _statusText,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KeeAuth',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      width: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent(ColorScheme colorScheme, AppLocalizations? l10n) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentOpacity.value,
          child: Transform.translate(
            offset:
                _contentSlide.value * MediaQuery.of(context).size.height * 0.3,
            child: child,
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large logo
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Welcome title
            Text(
              l10n?.introWelcomeTitle ?? 'Welcome to KeeAuth',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                l10n?.introWelcomeDescription ??
                    'A secure and open-source two-factor authentication app.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // Ready text
            Text(
              l10n?.splashReady ?? 'Ready',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData get theme => Theme.of(context);
}
