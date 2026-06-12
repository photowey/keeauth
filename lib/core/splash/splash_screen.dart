import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/core/android/screenshot_service.dart';
import 'package:keeauth/core/icons/icon_service.dart';
import 'package:keeauth/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1: Logo-only animation (seamless from native splash)
  late AnimationController _logoAnimController;
  late Animation<double> _logoPulse;
  late Animation<double> _logoGlow;

  // Logo entrance (scale from 0.8 → 1.0 + fade in)
  late AnimationController _entranceController;
  late Animation<double> _entranceScale;
  late Animation<double> _entranceOpacity;

  // Phase 2: Content reveal
  late AnimationController _revealController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _progressOpacity;

  // Continuous shimmer
  late AnimationController _shimmerController;

  bool _phase2Started = false;
  double _progress = 0.0;
  /// Status key for i18n: 'loading_settings' | 'initializing_security' | ''
  String _statusKey = '';

  @override
  void initState() {
    super.initState();

    // Entrance: logo dramatically pops in from invisible
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _entranceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.elasticOut,
      ),
    );

    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Phase 1: Logo continuous breathing pulse
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Visible pulse: 1.0 → 1.12 → 1.0
    _logoPulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeInOut,
    ));

    // Glow intensity: 0 → 1 → 0.2
    _logoGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeInOut,
    ));

    // Phase 2: Text + progress reveal
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );

    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Start entrance after a tiny delay (let native splash disappear first)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _entranceController.forward().then((_) {
          if (mounted) _logoAnimController.repeat();
        });
      }
    });

    // Phase 2 reveals after entrance animation finishes
    _startPhase2After(const Duration(milliseconds: 1200));
    _initialize();
  }

  void _startPhase2After(Duration delay) {
    Future.delayed(delay, () {
      if (mounted) {
        setState(() => _phase2Started = true);
        _revealController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _logoAnimController.dispose();
    _revealController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final stopwatch = Stopwatch()..start();

    // Icons load lazily in background — NOT blocking splash
    IconService().initialize();

    const taskKeys = ['loading_settings', 'initializing_security'];
    final taskFns = [_loadSettings, _initSecurity];

    for (var i = 0; i < taskFns.length; i++) {
      if (!mounted) return;
      setState(() {
        _statusKey = taskKeys[i];
        _progress = (i + 1) / taskFns.length;
      });
      try {
        await taskFns[i]();
      } catch (e) {
        debugPrint('Init task failed: ${taskKeys[i]}, error: $e');
      }
    }

    // Ensure splash is visible long enough to show animation
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 2000) {
      await Future.delayed(Duration(milliseconds: 2000 - elapsed));
    }

    if (mounted) {
      widget.onComplete();
    }
  }

  Future<void> _loadSettings() async {
    final storage = SecureStorageService();
    await storage.isTapToRevealEnabled();
  }

  Future<void> _initSecurity() async {
    final secureStorage = SecureStorageService();
    final screenshotEnabled = await secureStorage.isScreenshotEnabled();
    await ScreenshotService.setSecure(!screenshotEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _logoAnimController,
          _revealController,
          _shimmerController,
        ]),
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Phase 1: Animated logo ──
                Opacity(
                  opacity: _entranceOpacity.value,
                  child: Transform.scale(
                    scale: _entranceScale.value * _logoPulse.value,
                    child: _buildLogo(colorScheme),
                  ),
                ),

                // ── Phase 2: Text + progress ──
                if (_phase2Started) ...[
                  const SizedBox(height: 32),

                  SlideTransition(
                    position: _titleSlide,
                    child: Opacity(
                      opacity: _titleOpacity.value,
                      child: Text(
                        l10n?.appTitle ?? 'KeeAuth',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      l10n?.splashSubtitle ?? 'Secure Authenticator',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Opacity(
                    opacity: _progressOpacity.value,
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _progress),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, _) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: value,
                                  minHeight: 4,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    colorScheme.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _statusKey == 'loading_settings'
                                  ? (l10n?.loadingSettings ?? 'Loading settings...')
                                  : _statusKey == 'initializing_security'
                                      ? (l10n?.initializingSecurity ?? 'Initializing security...')
                                      : '',
                              key: ValueKey(_statusKey),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    final glowAlpha = _logoGlow.value * 0.4;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: glowAlpha),
            blurRadius: 30 + _logoGlow.value * 16,
            spreadRadius: _logoGlow.value * 6,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Real app logo
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallbackLogo(colorScheme),
            ),
          ),
          // Shimmer sweep overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: CustomPaint(
              size: const Size(120, 120),
              painter: _ShimmerPainter(
                progress: _shimmerController.value,
                color:
                    colorScheme.onPrimaryContainer.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(
        Icons.security,
        size: 64,
        color: colorScheme.primary,
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sweepWidth = size.width * 0.4;
    final totalTravel = size.width + sweepWidth * 2;
    final currentX = -sweepWidth + totalTravel * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          color,
          color,
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(currentX, 0, sweepWidth, size.height));

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi * 0.12);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(
      Rect.fromLTWH(currentX, -size.height, sweepWidth, size.height * 3),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
