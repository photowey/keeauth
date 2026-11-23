/// Embedded privacy policy content for offline display.
/// Kept in sync with PRIVACY.md / PRIVACY.zh-CN.md / PRIVACY.zh-Hant.md.
///
/// Text wrapped in `**double asterisks**` is rendered with emphasis
/// (bold + accent colour + slightly larger size) by [PrivacyDetailScreen].
/// This is how sensitive personal information and its purpose / method / scope
/// are highlighted, as required by the app compliance review.
class PrivacyPolicySection {
  final String title;
  final List<String> paragraphs;

  const PrivacyPolicySection({required this.title, required this.paragraphs});
}

class PrivacyPolicyDocument {
  final String title;
  final String lastUpdated;
  final String intro;
  final List<PrivacyPolicySection> sections;

  const PrivacyPolicyDocument({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });
}

class PrivacyPolicyContent {
  static PrivacyPolicyDocument forLocale(
    String languageCode,
    String? scriptCode,
  ) {
    if (languageCode == 'zh') {
      return scriptCode == 'Hant' ? zhHant : zhCN;
    }
    return en;
  }

  static const en = PrivacyPolicyDocument(
    title: 'Privacy Policy',
    lastUpdated: 'Last updated: 2026-11-23',
    intro:
        'KeeAuth ("we", "our", or "us") is committed to protecting your privacy. '
        'This policy explains the **purpose, method, and scope** of personal '
        'information processing, in accordance with the Personal Information '
        'Protection Law of the People\'s Republic of China and applicable app '
        'compliance requirements.',
    sections: [
      PrivacyPolicySection(
        title: '1. Personal Information We Process',
        paragraphs: [
          'The **personal information** we process is the user-provided content '
              'listed below. All of it is stored exclusively on your device:',
          '• **2FA secrets & account information** — TOTP/HOTP secret keys, '
              'account names, and issuer names that you manually enter, scan via '
              'QR code, or import from a backup file.',
          '• **Backup files** — encrypted exports of your authenticator data.',
          '• **App password** — a locally hashed password you set to lock the app.',
          '• **Biometric data** — fingerprint or face recognition, handled entirely '
              'by the operating system (Android Keystore / iOS Secure Enclave).',
          '• **Preferences** — theme, language, auto-lock, and similar settings.',
        ],
      ),
      PrivacyPolicySection(
        title: '2. Sensitive Personal Information',
        paragraphs: [
          'We process the following **sensitive personal information**. For each '
              'item we set out its **purpose, method, and scope**:',
          '• **Camera** — **Purpose:** scan QR codes to add authenticator accounts. '
              '**Method:** the camera preview is processed in real time on your '
              'device. **Scope:** frames are never uploaded, stored, or shared with '
              'any third party.',
          '• **Biometric information (fingerprint / face)** — **Purpose:** unlock '
              'the app. **Method:** handled by the system authentication prompt. '
              '**Scope:** the app never receives or stores raw biometric data; it is '
              'managed by Android Keystore / iOS Secure Enclave.',
          '• **2FA secrets** — **Purpose:** generate verification codes. '
              '**Method:** you enter them manually or scan a QR code; they are '
              'stored in the encrypted local database (SQLCipher, AES-256). '
              '**Scope:** never uploaded or shared.',
          '• **Device storage (backup files)** — **Purpose:** save and restore '
              'encrypted backups. **Method:** you choose the location and the file '
              'is encrypted with your password. **Scope:** the app never uploads '
              'backups automatically.',
          'Before the system camera permission prompt appears, the app explains '
              'the **purpose** of the camera in its own dialog.',
        ],
      ),
      PrivacyPolicySection(
        title: '3. Purpose of Processing',
        paragraphs: [
          '• Generate verification codes — compute TOTP / HOTP / Steam / mOTP / '
              'Yandex codes from the secrets you provide.',
          '• App lock & security — verify your identity via password or biometrics '
              'before unlocking the app.',
          '• Backup & restore — export your data as an encrypted file and restore '
              'it on another device.',
          '• Preferences — remember your theme, language, and other settings.',
          'All processing happens **locally on your device**. KeeAuth has no backend '
              'servers and does not transmit your data anywhere.',
        ],
      ),
      PrivacyPolicySection(
        title: '4. Method of Collection / Processing',
        paragraphs: [
          '• **2FA secrets / accounts** — entered by you, scanned from a QR code, '
              'or imported from a backup file; stored in the app-private encrypted '
              'SQLCipher database (AES-256).',
          '• **App password** — set by you in Settings; hashed (SHA-256) and kept in '
              'Android EncryptedSharedPreferences / iOS Keychain.',
          '• **Biometrics** — the app triggers the system prompt; handled entirely by '
              'Android Keystore / iOS Secure Enclave.',
          '• **Preferences** — recorded automatically as you use the app, in '
              'encrypted shared preferences.',
          'No data is collected automatically. The app only processes what you '
              'explicitly provide.',
        ],
      ),
      PrivacyPolicySection(
        title: '5. Scope of Data Usage',
        paragraphs: [
          '• **Local only** — all data is processed and stored on your device.',
          '• **No transmission** — KeeAuth has no backend servers and no '
              'advertising, analytics, or tracking SDKs. It does not upload your '
              'data.',
          '• **Google ML Kit** — the on-device QR recognition component may be '
              'identified by some tools as a Google/Firebase component; it runs '
              'fully offline and never uploads data.',
          '• **No third-party sharing** — your data is never shared with any third '
              'party.',
          '• **No network requests** — the app makes no network requests unless you '
              'explicitly open a GitHub link from the About page.',
        ],
      ),
      PrivacyPolicySection(
        title: '6. Permissions',
        paragraphs: [
          '• **Camera** — scanning QR codes to add authenticators. The app explains '
              'this purpose in its own dialog before the system permission prompt '
              'appears.',
          '• **Biometrics** — fingerprint / face unlock.',
          '• **Storage** — saving and restoring encrypted backup files.',
          'You may revoke any permission in system settings; the related feature '
              'will then be unavailable.',
        ],
      ),
      PrivacyPolicySection(
        title: '7. Collected Information List & Third-Party SDK List',
        paragraphs: [
          'You can review the **Collected Personal Information** list and the '
              '**Third-Party SDK List** at any time under '
              '**Settings → Privacy & Compliance**. This privacy policy is also '
              'available there.',
        ],
      ),
      PrivacyPolicySection(
        title: '8. Your Control',
        paragraphs: [
          '• You can delete any authenticator entry at any time within the app.',
          '• You can delete all app data via Android / iOS system settings.',
          '• Backup files are encrypted with a password you choose.',
          '• You control where backup files are saved.',
        ],
      ),
      PrivacyPolicySection(
        title: '9. Changes',
        paragraphs: [
          'We may update this policy. Changes will be reflected in the app\'s next '
              'update and on this page.',
        ],
      ),
      PrivacyPolicySection(
        title: '10. Contact',
        paragraphs: [
          '• GitHub: github.com/photowey/keeauth',
          '• Email: photowey@gmail.com',
        ],
      ),
    ],
  );

  static const zhCN = PrivacyPolicyDocument(
    title: '隐私政策',
    lastUpdated: '最后更新：2026-11-23',
    intro:
        'KeeAuth（“我们”）致力于保护您的隐私。本政策依据《中华人民共和国个人信息保护法》'
        '及相关 App 合规要求，从**目的**、**方式**、**范围**三个维度说明 KeeAuth 如何'
        '处理您的个人信息。',
    sections: [
      PrivacyPolicySection(
        title: '一、处理的个人信息类型',
        paragraphs: [
          'KeeAuth 处理的**个人信息**为下列由您主动提供的内容，**全部仅存储在您的设备上**：',
          '• **2FA 密钥与账户信息** — 您手动输入、通过二维码扫描或从备份文件导入的 '
              'TOTP/HOTP 密钥、账户名称和发行方信息。',
          '• **备份文件** — 您的验证器数据的加密导出文件。',
          '• **应用密码** — 您设置的用于锁定 App 的密码，经本地哈希处理。',
          '• **生物识别数据** — 指纹或面部识别，完全由操作系统（Android Keystore / '
              'iOS 安全隔区）处理。',
          '• **偏好设置** — 主题、语言、自动锁定等设置。',
        ],
      ),
      PrivacyPolicySection(
        title: '二、个人敏感信息',
        paragraphs: [
          '我们处理以下**个人敏感信息**，并逐项说明其**目的、方式与范围**：',
          '• **相机** — **目的：** 扫描二维码以添加验证器账户。**方式：** 相机画面'
              '仅在您的设备本地实时处理。**范围：** 画面不会上传、保存或与任何第三方共享。',
          '• **生物识别信息（指纹 / 面容）** — **目的：** 解锁 App。**方式：** 由系统'
              '认证弹窗处理。**范围：** App 从不接收或存储原始生物特征数据，相关数据由 '
              'Android Keystore / iOS 安全隔区管理。',
          '• **2FA 密钥** — **目的：** 生成动态验证码。**方式：** 由您手动输入或扫描'
              '二维码添加，存储在本地加密数据库（SQLCipher，AES-256）中。**范围：** '
              '不上传、不共享。',
          '• **设备存储（备份文件）** — **目的：** 保存与恢复加密备份。**方式：** 由您'
              '选择保存位置，文件使用您设置的密码加密。**范围：** App 不会自动上传备份。',
          '在系统相机授权框弹出之前，App 会先通过自己的弹窗向您说明相机的**使用目的**。',
        ],
      ),
      PrivacyPolicySection(
        title: '三、处理目的',
        paragraphs: [
          '• 生成验证码 — 基于您提供的密钥计算 TOTP / HOTP / Steam / mOTP / Yandex '
              '验证码。',
          '• 应用锁定与安全 — 通过密码或生物识别验证您的身份后解锁 App。',
          '• 备份与恢复 — 将您的数据导出为加密文件，或从备份文件恢复至另一设备。',
          '• 用户偏好 — 记住您的主题、语言等设置。',
          '**所有处理均在您的设备本地完成。** KeeAuth 无后端服务器，不会将您的数据传输'
              '至任何地方。',
        ],
      ),
      PrivacyPolicySection(
        title: '四、收集 / 处理方式',
        paragraphs: [
          '• **2FA 密钥 / 账户** — 由您手动输入、扫描二维码或导入备份文件；存储在 App '
              '私有存储中的加密 SQLCipher 数据库（AES-256）。',
          '• **应用密码** — 您在设置中设置；哈希（SHA-256）后存储在 Android '
              'EncryptedSharedPreferences / iOS Keychain。',
          '• **生物识别** — App 触发系统认证提示；完全由 Android Keystore / iOS 安全'
              '隔区处理。',
          '• **偏好设置** — 您使用 App 时自动记录，存储在加密的本地存储中。',
          '**不会自动收集任何数据。** App 仅处理您主动提供的内容。',
        ],
      ),
      PrivacyPolicySection(
        title: '五、数据使用范围',
        paragraphs: [
          '• **仅限本地** — 所有数据在您的设备上处理和存储。',
          '• **无传输** — KeeAuth 无任何后端服务器，也不含广告、统计分析或用户追踪 SDK，'
              '不会上传您的数据。',
          '• **Google ML Kit** — 本地二维码识别组件可能被部分检测工具识别为 '
              'Google/Firebase 组件；该组件完全离线运行，不会上传任何数据。',
          '• **无第三方共享** — 您的数据不会与任何第三方共享。',
          '• **无网络请求** — 除您主动从关于页面点击 GitHub 链接外，App 不发起任何网络'
              '请求。',
        ],
      ),
      PrivacyPolicySection(
        title: '六、权限说明',
        paragraphs: [
          '• **相机** — 扫描二维码以添加验证器。App 会在系统授权框弹出前，先通过自己的'
              '弹窗说明该用途。',
          '• **生物识别** — 指纹 / 面部解锁。',
          '• **存储** — 保存和恢复加密备份文件。',
          '您可以在系统设置中随时撤回任何权限；撤回后相关功能将不可用。',
        ],
      ),
      PrivacyPolicySection(
        title: '七、已收集个人信息清单与第三方 SDK 共享清单',
        paragraphs: [
          '您可以随时在 App 内的 **设置 → 隐私与合规** 中查看**已收集个人信息清单**与'
              '**第三方 SDK 共享清单**。本隐私政策同样可以在该入口查看。',
        ],
      ),
      PrivacyPolicySection(
        title: '八、您的控制权',
        paragraphs: [
          '• 您可以随时在 App 内删除任意验证器条目。',
          '• 您可以通过 Android / iOS 系统设置删除所有 App 数据。',
          '• 备份文件使用您选择的密码加密。',
          '• 您可以控制备份文件的保存位置。',
        ],
      ),
      PrivacyPolicySection(
        title: '九、变更',
        paragraphs: ['我们可能会更新本政策。变更将在 App 下次更新时体现，并同步更新本页面。'],
      ),
      PrivacyPolicySection(
        title: '十、联系方式',
        paragraphs: [
          '• GitHub：github.com/photowey/keeauth',
          '• 电子邮件：photowey@gmail.com',
        ],
      ),
    ],
  );

  static const zhHant = PrivacyPolicyDocument(
    title: '隱私政策',
    lastUpdated: '最後更新：2026-11-23',
    intro:
        'KeeAuth（「我們」）致力於保護您的隱私。本政策依據相關個人資訊保護法規與 App '
        '合規要求，從**目的**、**方式**、**範圍**三個維度說明 KeeAuth 如何處理您的'
        '個人資訊。',
    sections: [
      PrivacyPolicySection(
        title: '一、處理的個人資訊類型',
        paragraphs: [
          'KeeAuth 處理的**個人資訊**為下列由您主動提供的內容，**全部僅儲存在您的裝置上**：',
          '• **2FA 密鑰與帳戶資訊** — 您手動輸入、透過二維碼掃描或從備份檔案匯入的 '
              'TOTP/HOTP 密鑰、帳戶名稱和發行方資訊。',
          '• **備份檔案** — 您的驗證器資料的加密匯出檔案。',
          '• **應用程式密碼** — 您設定的用於鎖定 App 的密碼，經本機雜湊處理。',
          '• **生物辨識資料** — 指紋或臉部辨識，完全由作業系統（Android Keystore / '
              'iOS 安全隔離區）處理。',
          '• **偏好設定** — 主題、語言、自動鎖定等設定。',
        ],
      ),
      PrivacyPolicySection(
        title: '二、個人敏感資訊',
        paragraphs: [
          '我們處理以下**個人敏感資訊**，並逐項說明其**目的、方式與範圍**：',
          '• **相機** — **目的：** 掃描二維碼以新增驗證器帳戶。**方式：** 相機畫面僅在'
              '您的裝置本機即時處理。**範圍：** 畫面不會上傳、儲存或與任何第三方共享。',
          '• **生物辨識資訊（指紋 / 臉部）** — **目的：** 解鎖 App。**方式：** 由系統'
              '認證彈窗處理。**範圍：** App 從不接收或儲存原始生物特徵資料，相關資料由 '
              'Android Keystore / iOS 安全隔離區管理。',
          '• **2FA 密鑰** — **目的：** 產生動態驗證碼。**方式：** 由您手動輸入或掃描'
              '二維碼新增，儲存在本機加密資料庫（SQLCipher，AES-256）中。**範圍：** '
              '不上傳、不共享。',
          '• **裝置儲存空間（備份檔案）** — **目的：** 儲存與還原加密備份。**方式：** '
              '由您選擇儲存位置，檔案使用您設定的密碼加密。**範圍：** App 不會自動上傳備份。',
          '在系統相機授權框彈出之前，App 會先透過自己的彈窗向您說明相機的**使用目的**。',
        ],
      ),
      PrivacyPolicySection(
        title: '三、處理目的',
        paragraphs: [
          '• 產生驗證碼 — 基於您提供的密鑰計算 TOTP / HOTP / Steam / mOTP / Yandex '
              '驗證碼。',
          '• 應用程式鎖定與安全 — 透過密碼或生物辨識驗證您的身份後解鎖 App。',
          '• 備份與還原 — 將您的資料匯出為加密檔案，或從備份檔案還原至另一裝置。',
          '• 使用者偏好 — 記住您的主題、語言等設定。',
          '**所有處理均在您的裝置本機完成。** KeeAuth 無後端伺服器，不會將您的資料'
              '傳輸至任何地方。',
        ],
      ),
      PrivacyPolicySection(
        title: '四、收集 / 處理方式',
        paragraphs: [
          '• **2FA 密鑰 / 帳戶** — 由您手動輸入、掃描二維碼或匯入備份檔案；儲存在 App '
              '私有儲存中的加密 SQLCipher 資料庫（AES-256）。',
          '• **應用程式密碼** — 您在設定中設定；雜湊（SHA-256）後儲存在 Android '
              'EncryptedSharedPreferences / iOS Keychain。',
          '• **生物辨識** — App 觸發系統認證提示；完全由 Android Keystore / iOS 安全'
              '隔離區處理。',
          '• **偏好設定** — 您使用 App 時自動記錄，儲存在加密的本機儲存中。',
          '**不會自動收集任何資料。** App 僅處理您主動提供的內容。',
        ],
      ),
      PrivacyPolicySection(
        title: '五、資料使用範圍',
        paragraphs: [
          '• **僅限本機** — 所有資料在您的裝置上處理和儲存。',
          '• **無傳輸** — KeeAuth 無任何後端伺服器，也不含廣告、統計分析或使用者追蹤 '
              'SDK，不會上傳您的資料。',
          '• **Google ML Kit** — 本機二維碼識別元件可能被部分檢測工具識別為 '
              'Google/Firebase 元件；該元件完全離線執行，不會上傳任何資料。',
          '• **無第三方分享** — 您的資料不會與任何第三方分享。',
          '• **無網路請求** — 除您主動從關於頁面點擊 GitHub 連結外，App 不發起任何網路'
              '請求。',
        ],
      ),
      PrivacyPolicySection(
        title: '六、權限說明',
        paragraphs: [
          '• **相機** — 掃描二維碼以新增驗證器。App 會在系統授權框彈出前，先透過自己的'
              '彈窗說明該用途。',
          '• **生物辨識** — 指紋 / 臉部解鎖。',
          '• **儲存空間** — 儲存和還原加密備份檔案。',
          '您可以在系統設定中隨時撤回任何權限；撤回後相關功能將無法使用。',
        ],
      ),
      PrivacyPolicySection(
        title: '七、已收集個人資訊清單與第三方 SDK 共享清單',
        paragraphs: [
          '您可以隨時在 App 內的 **設定 → 隱私與合規** 中查看**已收集個人資訊清單**與'
              '**第三方 SDK 共享清單**。本隱私政策同樣可以在該入口查看。',
        ],
      ),
      PrivacyPolicySection(
        title: '八、您的控制權',
        paragraphs: [
          '• 您可以隨時在 App 內刪除任意驗證器項目。',
          '• 您可以透過 Android / iOS 系統設定刪除所有 App 資料。',
          '• 備份檔案使用您選擇的密碼加密。',
          '• 您可以控制備份檔案的儲存位置。',
        ],
      ),
      PrivacyPolicySection(
        title: '九、變更',
        paragraphs: ['我們可能會更新本政策。變更將在 App 下次更新時體現，並同步更新本頁面。'],
      ),
      PrivacyPolicySection(
        title: '十、聯絡方式',
        paragraphs: [
          '• GitHub：github.com/photowey/keeauth',
          '• 電子郵件：photowey@gmail.com',
        ],
      ),
    ],
  );
}
