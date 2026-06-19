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

Last updated: 2026-06-09

KeeAuth ("we", "our", or "us") is committed to protecting your privacy. This policy explains how KeeAuth handles your data.

Data Collection

KeeAuth does not collect, transmit, or store any personal data on external servers.

All data is stored exclusively on your device:

• 2FA Secrets & Account Information — Stored in an encrypted SQLCipher database (AES-256) in the app's private storage.
• Backup Files — Encrypted with AES-256-GCM and saved only where you choose (local storage or cloud).
• App Password & Biometric Data — Stored in Android Keystore / iOS Keychain, never accessible to the app directly.
• Preferences — Stored in encrypted shared preferences.

Data Sharing

KeeAuth does not share any data with third parties.

• No analytics SDKs
• No advertising SDKs
• No crash reporting services
• No network requests (except when you explicitly share a backup file)

Permissions

• Camera — Scanning QR codes to add authenticators
• Biometric — Fingerprint/face unlock
• Storage — Saving/restoring backup files

Your Control

• You can delete all app data at any time via Android/iOS system settings
• Backup files are encrypted with a password you choose
• You control where backup files are saved

Changes

We may update this policy. Changes will be reflected in the app's next update.

Contact

• GitHub: github.com/photowey/keeauth
• Email: photowey@gmail.com''';

  static const zhCN = '''隐私政策

最后更新：2026-06-09

KeeAuth（"我们"）致力于保护您的隐私。本政策说明 KeeAuth 如何处理您的数据。

数据收集

KeeAuth 不会收集、传输或在外部服务器上存储任何个人数据。

所有数据仅存储在您的设备上：

• 2FA 密钥与账户信息 — 存储在应用私有存储中的加密 SQLCipher 数据库（AES-256）中。
• 备份文件 — 使用 AES-256-GCM 加密，仅保存在您选择的位置（本地存储或云端）。
• 应用密码与生物识别数据 — 存储在 Android Keystore / iOS Keychain 中，应用无法直接访问。
• 偏好设置 — 存储在加密的 SharedPreferences 中。

数据共享

KeeAuth 不会与任何第三方共享数据。

• 无分析 SDK
• 无广告 SDK
• 无崩溃报告服务
• 无网络请求（除非您主动分享备份文件）

权限说明

• 相机 — 扫描二维码以添加验证器
• 生物识别 — 指纹/面部解锁
• 存储 — 保存/恢复备份文件

您的控制权

• 您可以随时通过 Android/iOS 系统设置删除所有应用数据
• 备份文件使用您选择的密码加密
• 您可以控制备份文件的保存位置

变更

我们可能会更新本政策。变更将在应用下次更新时体现。

联系方式

• GitHub：github.com/photowey/keeauth
• 电子邮件：photowey@gmail.com''';

  static const zhHant = '''隱私政策

最後更新：2026-06-09

KeeAuth（「我們」）致力於保護您的隱私。本政策說明 KeeAuth 如何處理您的資料。

資料收集

KeeAuth 不會收集、傳輸或在外部伺服器上儲存任何個人資料。

所有資料僅儲存在您的裝置上：

• 2FA 密鑰與帳戶資訊 — 儲存在應用程式私有儲存中的加密 SQLCipher 資料庫（AES-256）中。
• 備份檔案 — 使用 AES-256-GCM 加密，僅儲存在您選擇的位置（本機儲存或雲端）。
• 應用程式密碼與生物辨識資料 — 儲存在 Android Keystore / iOS Keychain 中，應用程式無法直接存取。
• 偏好設定 — 儲存在加密的 SharedPreferences 中。

資料分享

KeeAuth 不會與任何第三方分享資料。

• 無分析 SDK
• 無廣告 SDK
• 無當機回報服務
• 無網路請求（除非您主動分享備份檔案）

權限說明

• 相機 — 掃描 QR Code 以新增驗證器
• 生物辨識 — 指紋/臉部解鎖
• 儲存空間 — 儲存/還原備份檔案

您的控制權

• 您可以隨時透過 Android/iOS 系統設定刪除所有應用程式資料
• 備份檔案使用您選擇的密碼加密
• 您可以控制備份檔案的儲存位置

變更

我們可能會更新本政策。變更將在應用程式下次更新時體現。

聯絡方式

• GitHub：github.com/photowey/keeauth
• 電子郵件：photowey@gmail.com''';
}
