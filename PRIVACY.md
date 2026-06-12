# Privacy Policy

**Last updated: 2026-06-09**

KeeAuth ("we", "our", or "us") is committed to protecting your privacy.
This policy explains how KeeAuth handles your data.

## Data Collection

**KeeAuth does not collect, transmit, or store any personal data on external servers.**

All data is stored **exclusively on your device**:

- **2FA Secrets & Account Information** — Stored in an encrypted SQLCipher database (AES-256) in the app's private storage.
- **Backup Files** — Encrypted with AES-256-GCM and saved only where you choose (local storage or cloud).
- **App Password & Biometric Data** — Stored in Android Keystore / iOS Keychain, never accessible to the app directly.
- **Preferences** — Stored in encrypted shared preferences.

## Data Sharing

**KeeAuth does not share any data with third parties.**

- No analytics SDKs
- No advertising SDKs  
- No crash reporting services
- No network requests (except when you explicitly share a backup file)

## Permissions

| Permission | Purpose |
|-----------|---------|
| Camera | Scanning QR codes to add authenticators |
| Biometric | Fingerprint/face unlock |
| Storage | Saving/restoring backup files |

## Your Control

- You can delete all app data at any time via Android/iOS system settings
- Backup files are encrypted with a password you choose
- You control where backup files are saved

## Changes

We may update this policy. Changes will be reflected in the app's next update.

## Contact

- GitHub: [github.com/photowey/keeauth](https://github.com/photowey/keeauth)
- Email: photowey@gmail.com
