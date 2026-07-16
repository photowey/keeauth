# Privacy Policy

**Last updated: 2026-06-19**

KeeAuth ("we", "our", or "us") is committed to protecting your privacy.
This policy explains how KeeAuth handles your data, covering the **purpose**,
**method**, and **scope** of any personal information processing.

---

## 1. Personal Information We Process

KeeAuth processes the following types of user-provided content, **all stored
exclusively on your device**:

- **2FA Secrets & Account Information** — TOTP/HOTP secret keys, account names,
  and issuer names that you manually enter or scan via QR code.
- **Backup Files** — Encrypted exports of your authenticator data.
- **App Password** — A locally hashed password you set to lock the app.
- **Biometric Data** — Fingerprint or face recognition, handled entirely by the
  operating system (Android Keystore / iOS Keychain).
- **Preferences** — Theme, language, auto-lock settings.

---

## 2. Purpose of Processing

| Purpose | Explanation |
|---------|-------------|
| Generate verification codes | Compute TOTP / HOTP / Steam / mOTP / Yandex codes from the secrets you provide |
| App lock & security | Verify your identity via password or biometric before accessing the app |
| Backup & restore | Let you export your data as an encrypted file and restore it on another device |
| User preferences | Remember your theme, language, and other settings |

**All processing happens locally on your device.** KeeAuth has no backend
servers and does not transmit your data anywhere.

---

## 3. Method of Collection / Processing

| Data | How it enters the app | Processing location |
|------|----------------------|---------------------|
| 2FA secrets / accounts | You manually type them in, scan a QR code, or import a backup file | Encrypted SQLCipher database (AES-256) in app private storage |
| App password | You set it in Settings | Hashed (SHA-256) and stored in Android EncryptedSharedPreferences / iOS Keychain |
| Biometric | System prompt triggered by the app | Handled entirely by Android Keystore / iOS Secure Enclave; the app never sees raw biometric data |
| Preferences | Automatic as you use the app | Encrypted shared preferences |

**No data is collected automatically.** The app only processes what you
explicitly provide.

---

## 4. Scope of Data Usage

- **Local only** — All data is processed and stored on your device.
- **No transmission** — KeeAuth does not have any backend servers, analytics
  SDKs, advertising SDKs, or crash reporting services.
- **No third-party sharing** — Your data is never shared with any third party.
- **No network requests** — The app makes no network requests unless you
  explicitly choose to open a GitHub link from the About page.

---

## 5. Permissions

| Permission | Purpose |
|-----------|---------|
| Camera | Scanning QR codes to add authenticators |
| Biometric | Fingerprint / face unlock |
| Storage | Saving and restoring encrypted backup files |

---

## 6. Your Control

- You can delete any authenticator entry at any time within the app.
- You can delete all app data via Android / iOS system settings.
- Backup files are encrypted with a password you choose.
- You control where backup files are saved.

---

## 7. Changes

We may update this policy. Changes will be reflected in the app's next update.

---

## 8. Contact

- GitHub: [github.com/photowey/keeauth](https://github.com/photowey/keeauth)
- Email: photowey@gmail.com
