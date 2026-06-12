import 'package:flutter/material.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Intro/Onboarding screen for first-time users
class IntroScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  final SecureStorageService _storage = SecureStorageService();
  int _currentPage = 0;

  List<IntroPageData> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      IntroPageData(
        icon: Icons.security,
        title: l10n?.introWelcomeTitle ?? 'Welcome to KeeAuth',
        description:
            l10n?.introWelcomeDescription ??
            'A secure and open-source two-factor authentication app to protect your online accounts.',
        color: Colors.blue,
      ),
      IntroPageData(
        icon: Icons.qr_code_scanner,
        title: l10n?.introEasySetupTitle ?? 'Easy Setup',
        description:
            l10n?.introEasySetupDescription ??
            'Scan QR codes or manually enter secrets to add your authenticators in seconds.',
        color: Colors.green,
      ),
      IntroPageData(
        icon: Icons.download,
        title: l10n?.introImportTitle ?? 'Import from Other Apps',
        description:
            l10n?.introImportDescription ??
            'Easily migrate from Google Authenticator, Aegis, Bitwarden, and many more.',
        color: Colors.orange,
      ),
      IntroPageData(
        icon: Icons.backup,
        title: l10n?.introBackupTitle ?? 'Secure Backups',
        description:
            l10n?.introBackupDescription ??
            'Create encrypted backups to keep your authenticators safe and never get locked out.',
        color: Colors.purple,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro() async {
    await _storage.setHasSeenIntro(true);
    if (mounted) {
      widget.onComplete();
    }
  }

  void _nextPage() {
    final pages = _getPages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntro();
    }
  }

  void _skip() {
    _completeIntro();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _getPages(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(l10n?.skip ?? 'Skip'),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(pages[index]);
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1
                            ? (l10n?.getStarted ?? 'Get Started')
                            : (l10n?.next ?? 'Next'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPageData page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 80, color: page.color),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IntroPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const IntroPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
