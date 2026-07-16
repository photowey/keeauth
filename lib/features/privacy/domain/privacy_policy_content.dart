/// Embedded privacy policy content for offline display.
/// Kept in sync with PRIVACY.md / PRIVACY.zh-CN.md / PRIVACY.zh-Hant.md.
class PrivacyPolicyContent {
  static String forLocale(String languageCode, String? scriptCode) {
    if (languageCode == 'zh') {
      return scriptCode == 'Hant' ? zhHant : zhCN;
    }
    return en;
  }

  static const en = '''Privacy Policy

Last updated: 2026-06-19

KeeAuth ("we", "our", or "us") is committed to protecting your privacy. This policy explains how KeeAuth handles your data, covering the purpose, method, and scope of any personal information processing.

1. Personal Information We Process

KeeAuth processes the following types of user-provided content, all stored exclusively on your device:

• 2FA Secrets & Account Information — TOTP/HOTP secret keys, account names, and issuer names that you manually enter or scan via QR code.
• Backup Files — Encrypted exports of your authenticator data.
• App Password — A locally hashed password you set to lock the app.
• Biometric Data — Fingerprint or face recognition, handled entirely by the operating system (Android Keystore / iOS Keychain).
• Preferences — Theme, language, auto-lock settings.

2. Purpose of Processing

• Generate verification codes — Compute TOTP / HOTP / Steam / mOTP / Yandex codes from the secrets you provide.
• App lock & security — Verify your identity via password or biometric before accessing the app.
• Backup & restore — Let you export your data as an encrypted file and restore it on another device.
• User preferences — Remember your theme, language, and other settings.

All processing happens locally on your device. KeeAuth has no backend servers and does not transmit your data anywhere.

3. Method of Collection / Processing

• 2FA secrets / accounts — You manually type them in, scan a QR code, or import a backup file. Stored in encrypted SQLCipher database (AES-256) in app private storage.
• App password — You set it in Settings. Hashed (SHA-256) and stored in Android EncryptedSharedPreferences / iOS Keychain.
• Biometric — System prompt triggered by the app. Handled entirely by Android Keystore / iOS Secure Enclave; the app never sees raw biometric data.
• Preferences — Automatic as you use the app. Stored in encrypted shared preferences.

No data is collected automatically. The app only processes what you explicitly provide.

4. Scope of Data Usage

• Local only — All data is processed and stored on your device.
• No transmission — KeeAuth does not have any backend servers, analytics SDKs, advertising SDKs, or crash reporting services.
• No third-party sharing — Your data is never shared with any third party.
• No network requests — The app makes no network requests unless you explicitly choose to open a GitHub link from the About page.

5. Permissions

• Camera — Scanning QR codes to add authenticators
• Biometric — Fingerprint / face unlock
• Storage — Saving and restoring encrypted backup files

6. Your Control

• You can delete any authenticator entry at any time within the app.
• You can delete all app data via Android / iOS system settings.
• Backup files are encrypted with a password you choose.
• You control where backup files are saved.

7. Changes

We may update this policy. Changes will be reflected in the app's next update.

8. Contact

• GitHub: github.com/photowey/keeauth
• Email: photowey@gmail.com''';

  static const zhCN = '''隐私政策

最后更新：2026-06-19

KeeAuth（"我们"）致力于保护您的隐私。本政策从目的、方式、范围三个维度说明 KeeAuth 如何处理您的数据。

一、处理的个人信息类型

KeeAuth 处理以下由您主动提供的用户内容，全部仅存储在您的设备上：

• 2FA 密钥与账户信息 — 您手动输入或通过二维码扫描添加的 TOTP/HOTP 密钥、账户名称和发行方信息。
• 备份文件 — 您的验证器数据的加密导出文件。
• 应用密码 — 您设置的用于锁定 App 的密码，经本地哈希处理。
• 生物识别数据 — 指纹或面部识别，完全由操作系统（Android Keystore / iOS Keychain）处理。
• 偏好设置 — 主题、语言、自动锁定等设置。

二、处理目的

• 生成验证码 — 基于您提供的密钥计算 TOTP / HOTP / Steam / mOTP / Yandex 验证码。
• 应用锁定与安全 — 通过密码或生物识别验证您的身份后解锁 App。
• 备份与恢复 — 将您的数据导出为加密文件，或从备份文件恢复至另一设备。
• 用户偏好 — 记住您的主题、语言等设置。

所有处理均在您的设备本地完成。KeeAuth 无后端服务器，不会将您的数据传输至任何地方。

三、收集/处理方式

• 2FA 密钥/账户 — 您手动输入、扫描二维码或导入备份文件。存储在 App 私有存储中的加密 SQLCipher 数据库（AES-256）。
• 应用密码 — 您在设置中设置。哈希（SHA-256）后存储在 Android EncryptedSharedPreferences / iOS Keychain。
• 生物识别 — App 触发系统认证提示。完全由 Android Keystore / iOS 安全隔区处理；App 从不接触原始生物特征数据。
• 偏好设置 — 您使用 App 时自动记录。存储在加密 SharedPreferences 中。

不会自动收集任何数据。App 仅处理您主动提供的内容。

四、数据使用范围

• 仅限本地 — 所有数据在您的设备上处理和存储。
• 无传输 — KeeAuth 无任何后端服务器、统计分析 SDK、广告 SDK 或崩溃报告服务。
• 无第三方共享 — 您的数据不会与任何第三方共享。
• 无网络请求 — 除您主动从关于页面点击 GitHub 链接外，App 不发起任何网络请求。

五、权限说明

• 相机 — 扫描二维码以添加验证器
• 生物识别 — 指纹/面部解锁
• 存储 — 保存和恢复加密备份文件

六、您的控制权

• 您可以随时在 App 内删除任意验证器条目。
• 您可以通过 Android / iOS 系统设置删除所有 App 数据。
• 备份文件使用您选择的密码加密。
• 您可以控制备份文件的保存位置。

七、变更

我们可能会更新本政策。变更将在 App 下次更新时体现。

八、联系方式

• GitHub：github.com/photowey/keeauth
• 电子邮件：photowey@gmail.com''';

  static const zhHant = '''隱私政策

最後更新：2026-06-19

KeeAuth（「我們」）致力於保護您的隱私。本政策從目的、方式、範圍三個維度說明 KeeAuth 如何處理您的資料。

一、處理的個人資訊類型

KeeAuth 處理以下由您主動提供的使用者內容，全部僅儲存在您的裝置上：

• 2FA 密鑰與帳戶資訊 — 您手動輸入或透過 QR Code 掃描新增的 TOTP/HOTP 密鑰、帳戶名稱和發行方資訊。
• 備份檔案 — 您的驗證器資料的加密匯出檔案。
• 應用程式密碼 — 您設定的用於鎖定 App 的密碼，經本機雜湊處理。
• 生物辨識資料 — 指紋或臉部辨識，完全由作業系統（Android Keystore / iOS Keychain）處理。
• 偏好設定 — 主題、語言、自動鎖定等設定。

二、處理目的

• 產生驗證碼 — 基於您提供的密鑰計算 TOTP / HOTP / Steam / mOTP / Yandex 驗證碼。
• 應用程式鎖定與安全 — 透過密碼或生物辨識驗證您的身份後解鎖 App。
• 備份與還原 — 將您的資料匯出為加密檔案，或從備份檔案還原至另一裝置。
• 使用者偏好 — 記住您的主題、語言等設定。

所有處理均在您的裝置本機完成。KeeAuth 無後端伺服器，不會將您的資料傳輸至任何地方。

三、收集/處理方式

• 2FA 密鑰/帳戶 — 您手動輸入、掃描 QR Code 或匯入備份檔案。儲存在 App 私有儲存中的加密 SQLCipher 資料庫（AES-256）。
• 應用程式密碼 — 您在設定中設定。雜湊（SHA-256）後儲存在 Android EncryptedSharedPreferences / iOS Keychain。
• 生物辨識 — App 觸發系統認證提示。完全由 Android Keystore / iOS 安全隔離區處理；App 從不接觸原始生物特徵資料。
• 偏好設定 — 您使用 App 時自動記錄。儲存在加密 SharedPreferences 中。

不會自動收集任何資料。App 僅處理您主動提供的內容。

四、資料使用範圍

• 僅限本機 — 所有資料在您的裝置上處理和儲存。
• 無傳輸 — KeeAuth 無任何後端伺服器、統計分析 SDK、廣告 SDK 或當機回報服務。
• 無第三方分享 — 您的資料不會與任何第三方分享。
• 無網路請求 — 除您主動從關於頁面點擊 GitHub 連結外，App 不發起任何網路請求。

五、權限說明

• 相機 — 掃描 QR Code 以新增驗證器
• 生物辨識 — 指紋/臉部解鎖
• 儲存空間 — 儲存和還原加密備份檔案

六、您的控制權

• 您可以隨時在 App 內刪除任意驗證器項目。
• 您可以透過 Android / iOS 系統設定刪除所有 App 資料。
• 備份檔案使用您選擇的密碼加密。
• 您可以控制備份檔案的儲存位置。

七、變更

我們可能會更新本政策。變更將在 App 下次更新時體現。

八、聯絡方式

• GitHub：github.com/photowey/keeauth
• 電子郵件：photowey@gmail.com''';
}
