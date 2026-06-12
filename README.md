# `KeeAuth`

A secure, open-source 2FA authenticator built with Flutter.  
Generate TOTP/HOTP codes, scan QR codes, create encrypted backups, and import from other authenticator apps.

[![License](https://img.shields.io/badge/license-GPL%203.0-blue)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)

## Features

### OTP Engine
- **TOTP** (RFC 6238) & **HOTP** (RFC 4226)
- **Steam Guard** — 5-character alphanumeric codes
- **mOTP** — Mobile OTP with PIN
- **Yandex OTP** — 8-character lowercase codes
- SHA1 / SHA256 / SHA512 with configurable 5–10 digits

### Backup & Restore
- **Encrypted Backup** — AES-256-GCM `.keebaup` files
- **HTML & URI List** — Plain-text export formats
- **Restore** — Decrypt and import KeeAuth backups
- **Import 8+ formats** — Aegis, Bitwarden, 2FAS, FreeOTP+, Google Authenticator, KeePass, LastPass, URI lists
- **Auto-Backup** — Scheduled encrypted backups

### Security
- **Encrypted Database** — SQLCipher AES-256
- **Biometric Unlock** — Fingerprint / face unlock
- **App Password** — Configurable auto-lock timeout
- **Screenshot Protection** — FLAG_SECURE on Android
- **Tap-to-Reveal** — Hide codes, tap to show

### Organization
- **Categories** — Custom colors, drag-to-reorder
- **Custom Icons** — Built-in icon pack + image picker
- **View Modes** — Standard / Compact / Tile
- **Sort Modes** — Manual / A–Z / Most used / Date
- **Search** — By issuer, account, or category

### Platform
- **Material 3** — Light & dark themes
- **i18n** — English, 简体中文, 繁體中文
- **Android & iOS**

## Getting Started

```shell
git clone https://github.com/photowey/keeauth.git
cd keeauth
flutter pub get
flutter run
```

## Architecture

```
lib/
├── main.dart              # Entry point, lock screen, theme
├── di/                    # get_it dependency injection
├── core/
│   ├── auth/              # AppLock, Biometric
│   ├── crypto/            # OTP generator, AES-256-GCM, URI parser
│   ├── storage/           # SQLCipher DB, secure storage
│   ├── theme/             # ThemeBloc
│   ├── enums/             # ViewMode, Screen
│   ├── splash/            # Boot sequence animation
│   ├── icons/             # Icon resolution
│   └── utils/             # CodeUtil, navigator key
├── features/
│   ├── authenticator/     # Main feature
│   │   ├── presentation/  # Screens, widgets, BLoC
│   │   ├── domain/        # Entities, service
│   │   └── data/          # Repositories
│   ├── backup/            # Backup/restore, converters, auto-backup
│   ├── settings/          # Settings screen
│   └── intro/             # First-launch intro
├── pages/about/           # About page
└── l10n/                  # .arb files (en, zh, zh_Hant)
```

**State Management**: flutter_bloc  
**DI**: get_it  
**Database**: sqflite_sqlcipher  
**Architecture**: Clean Architecture (Presentation → Domain → Data)

## Acknowledgments

KeeAuth is a Flutter port of **[Stratum Auth](https://github.com/stratumauth/app)**,
an excellent open-source 2FA authenticator for Android.  

Static assets (icons, images) are directly sourced from the Stratum Auth project.  
UI design closely follows the original Material 3 layout.

Huge thanks to the Stratum Auth authors for their work.

## Privacy

KeeAuth does not collect any data. All information stays on your device.  
See [Privacy Policy](PRIVACY.md) for details.

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE)  

KeeAuth is a derivative work of [Stratum Auth](https://github.com/stratumauth/app)
(also GPL 3.0), in compliance with its license terms.
