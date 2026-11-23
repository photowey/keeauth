# Privacy Policy

**Last updated: 2026-11-23**

KeeAuth ("we", "our", or "us") is committed to protecting your privacy.
This policy explains the **purpose**, **method**, and **scope** of personal
information processing, in accordance with the Personal Information Protection
Law of the People's Republic of China and applicable app compliance
requirements.

---

## 1. Personal Information We Process

KeeAuth processes the following types of user-provided content, **all stored
exclusively on your device**:

- **2FA Secrets & Account Information** — TOTP/HOTP secret keys, account names,
  and issuer names that you manually enter, scan via QR code, or import from a
  backup file.
- **Backup Files** — Encrypted exports of your authenticator data.
- **App Password** — A locally hashed password you set to lock the app.
- **Biometric Data** — Fingerprint or face recognition, handled entirely by the
  operating system (Android Keystore / iOS Secure Enclave).
- **Preferences** — Theme, language, auto-lock settings.

---

## 2. Sensitive Personal Information

We process the following **sensitive personal information**. For each item we
set out its **purpose, method, and scope**:

- **Camera** — **Purpose:** scan QR codes to add authenticator accounts.
  **Method:** the camera preview is processed in real time on your device.
  **Scope:** frames are never uploaded, stored, or shared with any third party.
- **Biometric information (fingerprint / face)** — **Purpose:** unlock the app.
  **Method:** handled by the system authentication prompt. **Scope:** the app
  never receives or stores raw biometric data; it is managed by Android
  Keystore / iOS Secure Enclave.
- **2FA secrets** — **Purpose:** generate verification codes. **Method:** you
  enter them manually or scan a QR code; they are stored in the encrypted local
  database (SQLCipher, AES-256). **Scope:** never uploaded or shared.
- **Device storage (backup files)** — **Purpose:** save and restore encrypted
  backups. **Method:** you choose the location and the file is encrypted with
  your password. **Scope:** the app never uploads backups automatically.

Before the system camera permission prompt appears, the app explains the
**purpose** of the camera in its own dialog.

---

## 3. Purpose of Processing

| Purpose | Explanation |
|---------|-------------|
| Generate verification codes | Compute TOTP / HOTP / Steam / mOTP / Yandex codes from the secrets you provide |
| App lock & security | Verify your identity via password or biometric before accessing the app |
| Backup & restore | Let you export your data as an encrypted file and restore it on another device |
| User preferences | Remember your theme, language, and other settings |

**All processing happens locally on your device.** KeeAuth has no backend
servers and does not transmit your data anywhere.

---

## 4. Method of Collection / Processing

| Data | How it enters the app | Processing location |
|------|----------------------|---------------------|
| 2FA secrets / accounts | You manually type them in, scan a QR code, or import a backup file | Encrypted SQLCipher database (AES-256) in app private storage |
| App password | You set it in Settings | Hashed (SHA-256) and stored in Android EncryptedSharedPreferences / iOS Keychain |
| Biometric | System prompt triggered by the app | Handled entirely by Android Keystore / iOS Secure Enclave; the app never sees raw biometric data |
| Preferences | Automatic as you use the app | Encrypted shared preferences |

**No data is collected automatically.** The app only processes what you
explicitly provide.

---

## 5. Scope of Data Usage

- **Local only** — All data is processed and stored on your device.
- **No transmission** — KeeAuth has no backend servers and no advertising,
  analytics, or tracking SDKs. It does not upload your data.
- **Google ML Kit** — The on-device QR recognition component may be identified
  by some tools as a Google/Firebase component; it runs fully offline and never
  uploads data.
- **No third-party sharing** — Your data is never shared with any third party.
- **No network requests** — The app makes no network requests unless you
  explicitly choose to open a GitHub link from the About page.

---

## 6. Permissions

| Permission | Purpose |
|-----------|---------|
| Camera | Scanning QR codes to add authenticators. The app explains this purpose in its own dialog before the system permission prompt appears. |
| Biometric | Fingerprint / face unlock |
| Storage | Saving and restoring encrypted backup files |

You may revoke any permission in system settings; the related feature will then
be unavailable.

---

## 7. Collected Information List & Third-Party SDK List

You can review the **Collected Personal Information** list and the
**Third-Party SDK List** at any time under **Settings → Privacy & Compliance**
in the app. This privacy policy is also available there.

---

## 8. Your Control

- You can delete any authenticator entry at any time within the app.
- You can delete all app data via Android / iOS system settings.
- Backup files are encrypted with a password you choose.
- You control where backup files are saved.

---

## 9. Changes

We may update this policy. Changes will be reflected in the app's next update
and on this page.

---

## 10. Contact

- GitHub: [github.com/photowey/keeauth](https://github.com/photowey/keeauth)
- Email: photowey@gmail.com
