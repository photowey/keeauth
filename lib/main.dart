import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/core/android/screenshot_service.dart';
import 'package:keeauth/core/utils/navigator_key.dart';
import 'core/auth/app_lock_service.dart';
import 'core/auth/biometric_service.dart';
import 'core/splash/boot_sequence.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/theme_bloc.dart';
import 'di/injection.dart';
import 'features/authenticator/domain/usecases/authenticator_service.dart';
import 'features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'features/authenticator/presentation/screens/authenticator_list_screen.dart';
import 'features/intro/presentation/screens/intro_screen.dart';
import 'features/privacy/presentation/screens/privacy_consent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Warm up secure storage (HarmonyOS may return stale values on first read)
  await getIt<SecureStorageService>().hasPassword();

  runApp(const KeeAuthApp());
}

class KeeAuthApp extends StatefulWidget {
  const KeeAuthApp({super.key});

  @override
  State<KeeAuthApp> createState() => _KeeAuthAppState();
}

class _KeeAuthAppState extends State<KeeAuthApp> with WidgetsBindingObserver {
  final SecureStorageService _secureStorage = SecureStorageService();
  final BiometricService _biometricService = BiometricService();
  late AppLockService _appLockService;
  bool _isLocked = true;
  bool _initialized = false;
  bool _isFirstLaunch = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLockService = AppLockService(_secureStorage, _biometricService);
    _appLockService.initialize(_onLock);
  }

  void _onLock() {
    setState(() => _isLocked = true);
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  void _onIntroComplete() {
    setState(() => _isFirstLaunch = false);
  }

  void _onPrivacyAccepted() async {
    await _secureStorage.setPrivacyAccepted(true);
    setState(() => _privacyAccepted = true);
  }

  Future<void> _checkInitialLock() async {
    final hasPassword = await _appLockService.hasPassword();
    // If user has set app password, always show lock screen on cold start
    if (hasPassword) {
      setState(() => _isLocked = true);
      return;
    }
    final timeout = await _secureStorage.getAutoLockTimeout();
    // No password: if timeout is 0, no lock; otherwise lock when resuming from background (already handled)
    if (timeout == 0) {
      setState(() => _isLocked = false);
      _appLockService.unlock();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLockService.onAppLifecycleStateChanged(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLockService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final bloc = AuthenticatorBloc(getIt<AuthenticatorService>());
            if (_initialized) {
              bloc.add(LoadAuthenticators());
            }
            return bloc;
          },
        ),
        BlocProvider(create: (context) => ThemeBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'KeeAuth',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: themeState.mode,
            home: _buildHome(blocCtx: context),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('zh'), // Simplified Chinese (default for zh)
              Locale.fromSubtags(
                languageCode: 'zh',
                scriptCode: 'Hant',
              ), // Traditional
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // If no locale match, return first supported locale (en)
              if (locale == null) return const Locale('en');

              // Try exact match first
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.scriptCode == locale.scriptCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }

              // For Chinese, check country code to determine variant
              if (locale.languageCode == 'zh') {
                // Traditional Chinese regions: TW, HK, MO
                final traditionalRegions = ['TW', 'HK', 'MO'];
                if (traditionalRegions.contains(locale.countryCode)) {
                  return const Locale.fromSubtags(
                    languageCode: 'zh',
                    scriptCode: 'Hant',
                  );
                }
                // Default to Simplified for other regions (CN, SG, etc.)
                return const Locale('zh');
              }

              // Try language-only match for other languages
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.scriptCode == null) {
                  return supportedLocale;
                }
              }

              // Default to English
              return const Locale('en');
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brightness == Brightness.light ? const Color(0xFF515B92) : const Color(0xFFBBC3FF),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Card theme matching Material3 Elevated Card
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        color: colorScheme.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
      ),
      // AppBar theme matching Material3
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      // BottomAppBar theme
      bottomAppBarTheme: BottomAppBarTheme(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Colors.transparent,
        linearMinHeight: 2,
      ),
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      // Icon theme
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildHome({required BuildContext blocCtx}) {
    if (!_initialized) {
      return BootSequence(
        onComplete: () async {
          await _checkInitialLock();

          final privacyOk = await _secureStorage.hasAcceptedPrivacy();
          final hasSeenIntro = await _secureStorage.hasSeenIntro();

          setState(() {
            _privacyAccepted = privacyOk;
            _isFirstLaunch = !hasSeenIntro;
            _initialized = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            blocCtx.read<AuthenticatorBloc>().add(LoadAuthenticators());
          });

          Future.delayed(const Duration(milliseconds: 500), () async {
            final allowScreenshots = await _secureStorage.isScreenshotEnabled();
            await ScreenshotService.setSecure(!allowScreenshots);
          });
        },
      );
    }

    // Privacy consent must come first
    if (!_privacyAccepted) {
      return PrivacyConsentScreen(onAccepted: _onPrivacyAccepted);
    }

    // Show intro on first launch
    if (_isFirstLaunch) {
      return IntroScreen(onComplete: _onIntroComplete);
    }

    // Show lock screen or main screen
    if (_isLocked) {
      return _LockScreen(
        appLockService: _appLockService,
        onUnlocked: _onUnlocked,
      );
    }

    return const AuthenticatorListScreen();
  }
}

/// Lock screen widget with password input and biometric support
class _LockScreen extends StatefulWidget {
  final AppLockService appLockService;
  final VoidCallback onUnlocked;

  const _LockScreen({required this.appLockService, required this.onUnlocked});

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _hasPassword = false;
  bool _hasBiometric = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthMethods();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthMethods() async {
    final hasPass = await widget.appLockService.hasPassword();
    final hasBio = await widget.appLockService.isBiometricUnlockAvailable();
    if (!mounted) return;

    setState(() {
      _hasPassword = hasPass;
      _hasBiometric = hasBio;
      _isLoading = false;
    });

    if (hasBio) {
      _authenticateWithBiometric();
    } else if (!hasPass) {
      widget.appLockService.unlock();
      widget.onUnlocked();
    }
  }

  Future<void> _verifyPassword() async {
    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(
        () =>
            _errorMessage =
                l10n?.pleaseEnterPassword ?? 'Please enter your password',
      );
      return;
    }

    setState(() => _errorMessage = null);
    final success = await widget.appLockService.authenticateToUnlock(
      password: password,
    );
    if (success) {
      widget.appLockService.unlock();
      widget.onUnlocked();
    } else {
      setState(() {
        _errorMessage = l10n?.incorrectPassword ?? 'Incorrect password';
        _passwordController.clear();
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final l10n = AppLocalizations.of(context);
    final success = await widget.appLockService.authenticateToUnlock(
      reason: l10n?.authenticateToUnlock ?? 'Authenticate to unlock',
    );
    if (success) {
      widget.appLockService.unlock();
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n?.appLocked ?? 'App Locked',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.authenticateToUnlock ?? 'Authenticate to unlock',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                if (_hasPassword) _buildPasswordInput(colorScheme),
                if (_hasPassword && _hasBiometric) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n?.or ?? 'OR',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (_hasBiometric) _buildBiometricButton(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: l10n?.password ?? 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            errorText: _errorMessage,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onSubmitted: (_) => _verifyPassword(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _verifyPassword,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(l10n?.unlock ?? 'Unlock'),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricButton(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _authenticateWithBiometric,
        icon: const Icon(Icons.fingerprint),
        label: Text(l10n?.useBiometrics ?? 'Use Biometrics'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
