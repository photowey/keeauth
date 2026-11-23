/// Structured content for the "Third-Party SDK List".
///
/// Required by the app compliance review: users must be able to see, from a
/// secondary menu (e.g. Settings), which third-party SDKs are embedded, what
/// they are used for, what personal information they involve, whether data is
/// shared, and where their privacy policies are published.
///
/// Entries are derived from the components actually shipped in the release APK
/// (merged manifest + dex). None of them perform advertising, analytics, or
/// tracking; the only Google/Firebase-labelled classes come from Google ML Kit,
/// which runs fully on-device for QR code recognition.
class SdkInfoItem {
  final String name;
  final String provider;
  final String purpose;
  final String infoCollected;

  /// Sharing status, e.g. "Not shared".
  final String sharing;

  /// Public privacy policy URL, or an empty string when not applicable.
  final String privacyUrl;

  const SdkInfoItem({
    required this.name,
    required this.provider,
    required this.purpose,
    required this.infoCollected,
    required this.sharing,
    required this.privacyUrl,
  });
}

class SdkListContent {
  static List<SdkInfoItem> forLocale(String languageCode, String? scriptCode) {
    if (languageCode == 'zh') {
      return scriptCode == 'Hant' ? zhHant : zhCN;
    }
    return en;
  }

  static const en = <SdkInfoItem>[
    SdkInfoItem(
      name: 'Google ML Kit (Barcode Scanning)',
      provider: 'Google LLC',
      purpose: 'On-device QR code recognition for adding authenticators.',
      infoCollected:
          'Camera frames, processed locally only. No image is uploaded or stored.',
      sharing: 'Not shared',
      privacyUrl: 'https://developers.google.com/ml-kit/terms',
    ),
    SdkInfoItem(
      name: 'SQLCipher for Android',
      provider: 'Zetetic LLC',
      purpose: 'AES-256 encryption of the local authenticator database.',
      infoCollected:
          'Authenticator secrets and account information (encrypted, on-device).',
      sharing: 'Not shared',
      privacyUrl: 'https://www.zetetic.net/sqlcipher/',
    ),
    SdkInfoItem(
      name: 'AndroidX / Android Support Library',
      provider: 'Google LLC',
      purpose: 'Base Android runtime and UI framework.',
      infoCollected: 'None.',
      sharing: 'Not shared',
      privacyUrl: 'https://developer.android.com/',
    ),
    SdkInfoItem(
      name: 'Kotlinx',
      provider: 'JetBrains s.r.o.',
      purpose: 'Base Kotlin runtime and coroutines framework.',
      infoCollected: 'None.',
      sharing: 'Not shared',
      privacyUrl: 'https://kotlinlang.org/',
    ),
    SdkInfoItem(
      name: 'WorkManager (androidx.work)',
      provider: 'Google LLC',
      purpose: 'Scheduling local automatic backups.',
      infoCollected: 'Backup task configuration, stored locally.',
      sharing: 'Not shared',
      privacyUrl:
          'https://developer.android.com/topic/libraries/architecture/workmanager',
    ),
    SdkInfoItem(
      name: 'local_auth / BiometricPrompt',
      provider: 'Google LLC / Flutter Community',
      purpose: 'Biometric unlock of the app.',
      infoCollected:
          'Biometric verification result returned by the system. The app never receives raw biometric data.',
      sharing: 'Not shared',
      privacyUrl:
          'https://developer.android.com/identity/sign-in/biometric-auth',
    ),
    SdkInfoItem(
      name: 'file_picker / share_plus',
      provider: 'Flutter Community',
      purpose: 'Choosing where to save backups and sharing backup files.',
      infoCollected: 'The file selected by the user.',
      sharing: 'Not shared',
      privacyUrl: 'https://pub.dev/packages/file_picker',
    ),
    SdkInfoItem(
      name: 'url_launcher',
      provider: 'Flutter Team',
      purpose: 'Opening GitHub and feedback links in the browser.',
      infoCollected: 'None.',
      sharing: 'Not shared',
      privacyUrl: 'https://pub.dev/packages/url_launcher',
    ),
  ];

  static const zhCN = <SdkInfoItem>[
    SdkInfoItem(
      name: 'Google ML Kit（条码扫描）',
      provider: 'Google LLC',
      purpose: '本地二维码识别，用于添加验证器。',
      infoCollected: '相机画面，仅在设备本地处理，不上传、不保存任何图像。',
      sharing: '不共享',
      privacyUrl: 'https://developers.google.com/ml-kit/terms',
    ),
    SdkInfoItem(
      name: 'SQLCipher for Android',
      provider: 'Zetetic LLC',
      purpose: '对本地验证器数据库进行 AES-256 加密。',
      infoCollected: '验证器密钥与账户信息（加密后存储在本地）。',
      sharing: '不共享',
      privacyUrl: 'https://www.zetetic.net/sqlcipher/',
    ),
    SdkInfoItem(
      name: 'AndroidX / Android Support Library',
      provider: 'Google LLC',
      purpose: 'Android 基础运行库与 UI 框架。',
      infoCollected: '无。',
      sharing: '不共享',
      privacyUrl: 'https://developer.android.com/',
    ),
    SdkInfoItem(
      name: 'Kotlinx',
      provider: 'JetBrains s.r.o.',
      purpose: 'Kotlin 基础运行库与协程框架。',
      infoCollected: '无。',
      sharing: '不共享',
      privacyUrl: 'https://kotlinlang.org/',
    ),
    SdkInfoItem(
      name: 'WorkManager（androidx.work）',
      provider: 'Google LLC',
      purpose: '调度本地自动备份任务。',
      infoCollected: '备份任务配置，存储在本地。',
      sharing: '不共享',
      privacyUrl:
          'https://developer.android.com/topic/libraries/architecture/workmanager',
    ),
    SdkInfoItem(
      name: 'local_auth / BiometricPrompt',
      provider: 'Google LLC / Flutter Community',
      purpose: '通过生物识别解锁 App。',
      infoCollected: '系统返回的生物识别验证结果，App 从不接触原始生物特征数据。',
      sharing: '不共享',
      privacyUrl:
          'https://developer.android.com/identity/sign-in/biometric-auth',
    ),
    SdkInfoItem(
      name: 'file_picker / share_plus',
      provider: 'Flutter Community',
      purpose: '选择备份保存位置、分享备份文件。',
      infoCollected: '用户主动选择的文件。',
      sharing: '不共享',
      privacyUrl: 'https://pub.dev/packages/file_picker',
    ),
    SdkInfoItem(
      name: 'url_launcher',
      provider: 'Flutter Team',
      purpose: '在浏览器中打开 GitHub 与反馈链接。',
      infoCollected: '无。',
      sharing: '不共享',
      privacyUrl: 'https://pub.dev/packages/url_launcher',
    ),
  ];

  static const zhHant = <SdkInfoItem>[
    SdkInfoItem(
      name: 'Google ML Kit（條碼掃描）',
      provider: 'Google LLC',
      purpose: '本機二維碼識別，用於新增驗證器。',
      infoCollected: '相機畫面，僅在裝置本機處理，不上傳、不儲存任何影像。',
      sharing: '不共享',
      privacyUrl: 'https://developers.google.com/ml-kit/terms',
    ),
    SdkInfoItem(
      name: 'SQLCipher for Android',
      provider: 'Zetetic LLC',
      purpose: '對本機驗證器資料庫進行 AES-256 加密。',
      infoCollected: '驗證器密鑰與帳戶資訊（加密後儲存在本機）。',
      sharing: '不共享',
      privacyUrl: 'https://www.zetetic.net/sqlcipher/',
    ),
    SdkInfoItem(
      name: 'AndroidX / Android Support Library',
      provider: 'Google LLC',
      purpose: 'Android 基礎執行庫與 UI 框架。',
      infoCollected: '無。',
      sharing: '不共享',
      privacyUrl: 'https://developer.android.com/',
    ),
    SdkInfoItem(
      name: 'Kotlinx',
      provider: 'JetBrains s.r.o.',
      purpose: 'Kotlin 基礎執行庫與協程框架。',
      infoCollected: '無。',
      sharing: '不共享',
      privacyUrl: 'https://kotlinlang.org/',
    ),
    SdkInfoItem(
      name: 'WorkManager（androidx.work）',
      provider: 'Google LLC',
      purpose: '排程本機自動備份任務。',
      infoCollected: '備份任務設定，儲存在本機。',
      sharing: '不共享',
      privacyUrl:
          'https://developer.android.com/topic/libraries/architecture/workmanager',
    ),
    SdkInfoItem(
      name: 'local_auth / BiometricPrompt',
      provider: 'Google LLC / Flutter Community',
      purpose: '透過生物辨識解鎖 App。',
      infoCollected: '系統傳回的生物辨識驗證結果，App 從不接觸原始生物特徵資料。',
      sharing: '不共享',
      privacyUrl:
          'https://developer.android.com/identity/sign-in/biometric-auth',
    ),
    SdkInfoItem(
      name: 'file_picker / share_plus',
      provider: 'Flutter Community',
      purpose: '選擇備份儲存位置、分享備份檔案。',
      infoCollected: '使用者主動選擇的檔案。',
      sharing: '不共享',
      privacyUrl: 'https://pub.dev/packages/file_picker',
    ),
    SdkInfoItem(
      name: 'url_launcher',
      provider: 'Flutter Team',
      purpose: '在瀏覽器中開啟 GitHub 與回饋連結。',
      infoCollected: '無。',
      sharing: '不共享',
      privacyUrl: 'https://pub.dev/packages/url_launcher',
    ),
  ];
}
