/// Structured content for the "Collected Personal Information" list.
///
/// Required by the app compliance review: users must be able to see, from a
/// secondary menu (e.g. Settings), what personal information is processed,
/// why, how, where it is used, how long it is kept, and how to delete it.
///
/// All entries describe data processed locally on the device — KeeAuth has no
/// backend servers and never uploads this data.
class CollectedInfoItem {
  /// Information type, e.g. "2FA secrets & account information".
  final String title;

  /// Purpose of processing.
  final String purpose;

  /// Collection / processing method.
  final String method;

  /// Scope of use.
  final String scope;

  /// Retention period.
  final String retention;

  /// How the user can delete it.
  final String deletion;

  const CollectedInfoItem({
    required this.title,
    required this.purpose,
    required this.method,
    required this.scope,
    required this.retention,
    required this.deletion,
  });
}

class CollectedInfoContent {
  static List<CollectedInfoItem> forLocale(
    String languageCode,
    String? scriptCode,
  ) {
    if (languageCode == 'zh') {
      return scriptCode == 'Hant' ? zhHant : zhCN;
    }
    return en;
  }

  static const en = <CollectedInfoItem>[
    CollectedInfoItem(
      title: '2FA secrets & account information',
      purpose:
          'Generate TOTP / HOTP / Steam / mOTP / Yandex verification codes.',
      method:
          'Manually entered by you, scanned from a QR code, or imported from a backup file.',
      scope:
          'Stored only in the encrypted local database (SQLCipher, AES-256) on your device. Never uploaded or shared.',
      retention: 'Until you delete the entry in the app.',
      deletion:
          'Delete the entry from the authenticator list, or clear the app data in system settings.',
    ),
    CollectedInfoItem(
      title: 'App password',
      purpose: 'Lock the app and verify your identity before unlocking.',
      method:
          'Set by you in Settings. The password is hashed (SHA-256) before being stored in secure storage.',
      scope: 'Stored only in local secure storage. Never uploaded or shared.',
      retention: 'Until you change or remove the password.',
      deletion: 'Settings → Password → Remove password.',
    ),
    CollectedInfoItem(
      title: 'Biometric data (fingerprint / face)',
      purpose: 'Unlock the app quickly with biometrics.',
      method:
          'Captured by the system authentication prompt. The app never receives raw biometric data.',
      scope:
          'Handled entirely by Android Keystore / iOS Secure Enclave. Never uploaded or shared.',
      retention: 'Managed by the operating system; the app stores nothing.',
      deletion:
          'Disable biometric unlock in the app, or remove the enrolled fingerprint / face in system settings.',
    ),
    CollectedInfoItem(
      title: 'Backup files',
      purpose: 'Export and migrate your authenticator data.',
      method:
          'Exported by you on demand and encrypted with a password you choose.',
      scope:
          'Saved to the location you select. The app never uploads backups automatically.',
      retention: 'Managed by you.',
      deletion: 'Delete the backup file from your device storage.',
    ),
    CollectedInfoItem(
      title: 'Preferences',
      purpose: 'Remember your theme, language, auto-lock and other settings.',
      method: 'Recorded locally as you use the app.',
      scope:
          'Stored only in encrypted local storage. Never uploaded or shared.',
      retention: 'Until the app data is cleared.',
      deletion: 'Clear the app data in system settings.',
    ),
  ];

  static const zhCN = <CollectedInfoItem>[
    CollectedInfoItem(
      title: '2FA 密钥与账户信息',
      purpose: '生成 TOTP / HOTP / Steam / mOTP / Yandex 动态验证码。',
      method: '由您手动输入、扫描二维码，或从备份文件导入。',
      scope: '仅存储在您设备上的加密本地数据库（SQLCipher，AES-256），不上传、不共享。',
      retention: '直至您在 App 内删除该条目。',
      deletion: '在验证器列表中删除该条目，或在系统设置中清除 App 数据。',
    ),
    CollectedInfoItem(
      title: '应用密码',
      purpose: '锁定 App，在解锁前验证您的身份。',
      method: '您在设置中主动设置，经 SHA-256 哈希后存入安全存储。',
      scope: '仅存储在本地安全存储中，不上传、不共享。',
      retention: '直至您修改或移除密码。',
      deletion: '设置 → 密码 → 移除密码。',
    ),
    CollectedInfoItem(
      title: '生物识别信息（指纹 / 面容）',
      purpose: '通过生物识别快速解锁 App。',
      method: '由系统认证弹窗采集，App 从不接触原始生物特征数据。',
      scope: '完全由 Android Keystore / iOS 安全隔区处理，不上传、不共享。',
      retention: '由操作系统管理，App 不做存储。',
      deletion: '在 App 内关闭生物识别解锁，或在系统设置中删除已录入的指纹 / 面容。',
    ),
    CollectedInfoItem(
      title: '备份文件',
      purpose: '导出并迁移您的验证器数据。',
      method: '由您主动导出，并使用您设置的密码加密。',
      scope: '保存在您选择的位置，App 不会自动上传备份。',
      retention: '由您自行管理。',
      deletion: '删除设备存储中对应的备份文件。',
    ),
    CollectedInfoItem(
      title: '偏好设置',
      purpose: '记住您的主题、语言、自动锁定等设置。',
      method: '您使用 App 时在本地记录。',
      scope: '仅存储在加密的本地存储中，不上传、不共享。',
      retention: '直至清除 App 数据。',
      deletion: '在系统设置中清除 App 数据。',
    ),
  ];

  static const zhHant = <CollectedInfoItem>[
    CollectedInfoItem(
      title: '2FA 密鑰與帳戶資訊',
      purpose: '產生 TOTP / HOTP / Steam / mOTP / Yandex 動態驗證碼。',
      method: '由您手動輸入、掃描二維碼，或從備份檔案匯入。',
      scope: '僅儲存在您裝置上的加密本機資料庫（SQLCipher，AES-256），不上傳、不共享。',
      retention: '直至您在 App 內刪除該項目。',
      deletion: '在驗證器清單中刪除該項目，或在系統設定中清除 App 資料。',
    ),
    CollectedInfoItem(
      title: '應用程式密碼',
      purpose: '鎖定 App，在解鎖前驗證您的身份。',
      method: '您在設定中主動設定，經 SHA-256 雜湊後存入安全儲存。',
      scope: '僅儲存在本機安全儲存中，不上傳、不共享。',
      retention: '直至您修改或移除密碼。',
      deletion: '設定 → 密碼 → 移除密碼。',
    ),
    CollectedInfoItem(
      title: '生物辨識資訊（指紋 / 臉部）',
      purpose: '透過生物辨識快速解鎖 App。',
      method: '由系統認證彈窗擷取，App 從不接觸原始生物特徵資料。',
      scope: '完全由 Android Keystore / iOS 安全隔離區處理，不上傳、不共享。',
      retention: '由作業系統管理，App 不做儲存。',
      deletion: '在 App 內關閉生物辨識解鎖，或在系統設定中刪除已錄入的指紋 / 臉部。',
    ),
    CollectedInfoItem(
      title: '備份檔案',
      purpose: '匯出並移轉您的驗證器資料。',
      method: '由您主動匯出，並使用您設定的密碼加密。',
      scope: '儲存在您選擇的位置，App 不會自動上傳備份。',
      retention: '由您自行管理。',
      deletion: '刪除裝置儲存空間中對應的備份檔案。',
    ),
    CollectedInfoItem(
      title: '偏好設定',
      purpose: '記住您的主題、語言、自動鎖定等設定。',
      method: '您使用 App 時在本機記錄。',
      scope: '僅儲存在加密的本機儲存中，不上傳、不共享。',
      retention: '直至清除 App 資料。',
      deletion: '在系統設定中清除 App 資料。',
    ),
  ];
}
