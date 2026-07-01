// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'KeeAuth';

  @override
  String get splashSubtitle => '安全认证器';

  @override
  String get splashStarting => '正在启动...';

  @override
  String get splashReady => '准备就绪';

  @override
  String get loadingSettings => '正在加载设置...';

  @override
  String get initializingSecurity => '正在初始化安全...';

  @override
  String get authenticator => '认证器';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get addAuthenticator => '添加认证器';

  @override
  String get editAuthenticator => '编辑认证器';

  @override
  String get deleteAuthenticator => '删除认证器';

  @override
  String get deleteConfirm => '确定要删除此认证器吗？';

  @override
  String get authenticatorAdded => '认证器添加成功';

  @override
  String get authenticatorUpdated => '认证器已更新';

  @override
  String get authenticatorDeleted => '认证器已删除';

  @override
  String get issuer => '服务商';

  @override
  String get issuerOptional => '服务商（可选）';

  @override
  String get accountName => '账户名';

  @override
  String get account => '账户';

  @override
  String get secretKey => '密钥';

  @override
  String get add => '添加';

  @override
  String get showAdvancedOptions => '显示高级选项';

  @override
  String get tryAgain => '重试';

  @override
  String get close => '关闭';

  @override
  String get ok => '确定';

  @override
  String get retry => '重试';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get showQrCode => '显示二维码';

  @override
  String get enterManually => '手动输入';

  @override
  String get category => '分类';

  @override
  String get categories => '分类';

  @override
  String get addCategory => '添加分类';

  @override
  String get editCategory => '编辑分类';

  @override
  String get deleteCategory => '删除分类';

  @override
  String get selectCategory => '选择分类';

  @override
  String get all => '全部';

  @override
  String get uncategorized => '未分类';

  @override
  String get categoryName => '分类名称';

  @override
  String get categoryColor => '颜色';

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get importAuthenticators => '导入认证器';

  @override
  String get exportBackup => '导出备份';

  @override
  String get importFromOtherApps => '从其他2FA应用导入';

  @override
  String get parsingBackupFile => '正在解析备份文件...';

  @override
  String get selectBackupFile => '选择备份文件';

  @override
  String importItems(Object count) {
    return '导入 $count 项';
  }

  @override
  String importedCount(Object count) {
    return '已导入 $count 个认证器';
  }

  @override
  String get backup => '备份';

  @override
  String get autoBackup => '自动备份';

  @override
  String get encryptedBackup => '加密备份';

  @override
  String get plainText => '纯文本 (URI列表)';

  @override
  String get passwordProtected => '受密码保护的 .keebaup 文件';

  @override
  String get unencryptedUris => '未加密的 otpauth URI';

  @override
  String get encryptedExportComingSoon => '加密导出功能即将推出';

  @override
  String get plainExportComingSoon => '纯文本导出功能即将推出';

  @override
  String get enableAutoBackup => '启用自动备份';

  @override
  String get backupFrequency => '备份频率';

  @override
  String get daily => '每天';

  @override
  String get security => '安全';

  @override
  String get data => '数据';

  @override
  String get display => '显示';

  @override
  String get biometricUnlock => '生物识别解锁';

  @override
  String get biometricDescription => '使用指纹或面部识别解锁';

  @override
  String get biometricRequiresPassword => '请先设置应用密码以启用生物识别解锁';

  @override
  String get verifyToEnableBiometric => '验证以启用生物识别解锁';

  @override
  String get autoLockTimeout => '自动锁定超时';

  @override
  String get immediately => '立即';

  @override
  String get allowScreenshots => '允许截图';

  @override
  String get screenshotsDescription => '禁用后，截图将被阻止';

  @override
  String get tapToReveal => '点击显示';

  @override
  String get tapToRevealDescription => '默认隐藏验证码，点击显示';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get sortMode => '排序方式';

  @override
  String get manual => '手动（拖拽排序）';

  @override
  String get byName => '按名称';

  @override
  String get mostUsed => '最常使用';

  @override
  String get dateAdded => '添加日期';

  @override
  String get search => '搜索';

  @override
  String get searchAuthenticators => '搜索认证器...';

  @override
  String get searchIcons => '搜索图标...';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get noAuthenticators => '还没有认证器';

  @override
  String get addFirstAuthenticator => '添加您的第一个认证器';

  @override
  String get codeCopied => '验证码已复制到剪贴板';

  @override
  String get secretCopied => '密钥已复制';

  @override
  String get uriCopied => 'URI 已复制到剪贴板';

  @override
  String get copyUri => '复制 URI';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get done => '完成';

  @override
  String get share => '分享';

  @override
  String get next => '下一步';

  @override
  String get skip => '跳过';

  @override
  String get getStarted => '开始使用';

  @override
  String get version => '版本';

  @override
  String get license => '基于 GNU GPL v3.0 许可';

  @override
  String get github => 'GitHub';

  @override
  String get reportIssue => '报告问题';

  @override
  String get helpUsImprove => '帮助我们改进';

  @override
  String get introWelcomeTitle => '欢迎使用 KeeAuth';

  @override
  String get introWelcomeDescription => '一个安全开源的双因素认证应用，保护您的在线账户安全。';

  @override
  String get introEasySetupTitle => '轻松设置';

  @override
  String get introEasySetupDescription => '扫描二维码或手动输入密钥，在几秒钟内添加您的认证器。';

  @override
  String get introImportTitle => '从其他应用导入';

  @override
  String get introImportDescription =>
      '轻松从 Google Authenticator、Aegis、Bitwarden 等应用迁移。';

  @override
  String get introBackupTitle => '安全备份';

  @override
  String get introBackupDescription => '创建加密备份，确保您的认证器安全，永远不会被锁定。';

  @override
  String get details => '详情';

  @override
  String get edit => '编辑';

  @override
  String get copy => '复制';

  @override
  String get currentCode => '当前验证码';

  @override
  String get technicalDetails => '技术详情';

  @override
  String get type => '类型';

  @override
  String get algorithm => '算法';

  @override
  String get digits => '位数';

  @override
  String get period => '周期';

  @override
  String get createdAt => '创建时间';

  @override
  String get qrCode => '二维码';

  @override
  String get scanHelpText => '将二维码对准框内即可扫描';

  @override
  String get flashOn => '闪光灯开';

  @override
  String get flashOff => '闪光灯关';

  @override
  String get invalidQrCode => '无效的二维码。请扫描认证器二维码。';

  @override
  String get invalidQrCodeShort => '无效的二维码';

  @override
  String get galleryPickerNotImplemented => '相册选择器尚未实现';

  @override
  String get passwordRequired => '需要密码';

  @override
  String get backupPassword => '备份密码';

  @override
  String get enterBackupPassword => '输入此备份的密码';

  @override
  String get addCustomImage => '添加自定义图片';

  @override
  String get failedToLoadIcons => '加载图标失败';

  @override
  String get failedToPickImage => '选择图片失败';

  @override
  String get configureAutomaticBackups => '配置自动备份';

  @override
  String get exportYourAuthenticators => '导出您的认证器';

  @override
  String get error => '错误';

  @override
  String get selectSource => '选择来源';

  @override
  String get supportedFormats => '支持的格式';

  @override
  String get importPreview => '导入预览';

  @override
  String get unlock => '解锁';

  @override
  String get menu => '菜单';

  @override
  String get more => '更多';

  @override
  String get backupAndRestore => '备份与恢复';

  @override
  String get issuerHint => '例如: Google, GitHub';

  @override
  String get accountHint => '例如: user@example.com';

  @override
  String get secretKeyHint => '输入密钥';

  @override
  String get pleaseEnterAccount => '请输入账户名';

  @override
  String get pleaseEnterSecret => '请输入密钥';

  @override
  String get invalidSecretFormat => '密钥格式无效';

  @override
  String get invalidUri => '无效的 URI';

  @override
  String get authenticatorAlreadyExists => '认证器已存在';

  @override
  String get advancedOptionsComingSoon => '高级选项（类型、算法、位数、周期）将在未来版本中提供。';

  @override
  String get tapToRevealHint => '点击显示';

  @override
  String get or => '或';

  @override
  String get restore => '恢复';

  @override
  String get restoreBackupComingSoon => '恢复备份功能即将推出';

  @override
  String get failedToPickFile => '选择文件失败';

  @override
  String get failedToProcessFile => '处理文件失败';

  @override
  String get couldNotDetectFormat => '无法检测备份格式。请手动选择格式。';

  @override
  String get failedToParseQrCode => '解析二维码失败';

  @override
  String get havingIssue => '遇到问题？在这里报告';

  @override
  String get author => '作者';

  @override
  String get forkOnGithub => '在 GitHub 上 Fork';

  @override
  String get sendEmail => '发送邮件';

  @override
  String get askQuestion => '有问题？';

  @override
  String get apacheLicense => 'GNU GPL v3.0 许可证';

  @override
  String get changeIcon => '更改图标';

  @override
  String get leastUsed => '最少使用';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get viewGuide => '查看指南';

  @override
  String get gettingStarted => '入门指南';

  @override
  String get gotIt => '知道了';

  @override
  String get guideStep1 => '1. 点击 + 按钮添加新的认证器';

  @override
  String get guideStep2 => '2. 扫描二维码或手动输入密钥';

  @override
  String get guideStep3 => '3. 验证码将自动生成';

  @override
  String get guideStep4 => '4. 点击验证码复制到剪贴板';

  @override
  String get guideStep5 => '5. 使用菜单管理分类和设置';

  @override
  String get tryDifferentSearch => '试试其他搜索词';

  @override
  String get manageCategories => '管理分类';

  @override
  String get view => '视图';

  @override
  String get viewStandard => '标准';

  @override
  String get viewCompact => '紧凑';

  @override
  String get viewTile => '磁贴';

  @override
  String get noCategories => '暂无分类';

  @override
  String get enterCategoryName => '输入分类名称';

  @override
  String deleteCategoryConfirm(Object name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get counter => '计数器';

  @override
  String get pin => 'PIN';

  @override
  String get changeSecretKey => '更改密钥';

  @override
  String maxCharacters(Object count) {
    return '最多 $count 个字符';
  }

  @override
  String get motpSecretAlphanumeric => 'mOTP 密钥必须为字母数字';

  @override
  String get invalidBase32Format => '无效的 Base32 格式';

  @override
  String get digitsRange => '6 ~ 10';

  @override
  String get mustBePositive => '必须大于 0';

  @override
  String get pinRequired => '需要 PIN';

  @override
  String get assignCategories => '指定分类';

  @override
  String get noCategoriesCreate => '暂无分类，请先创建一个。';

  @override
  String get createCategory => '创建分类';

  @override
  String get password => '密码';

  @override
  String get setPassword => '设置密码';

  @override
  String get changePassword => '修改密码';

  @override
  String get removePassword => '移除密码';

  @override
  String get changeOrRemovePassword => '修改或移除应用密码';

  @override
  String get protectWithPassword => '使用密码保护应用';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get confirmNewPassword => '确认新密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get passwordCannotBeEmpty => '密码不能为空';

  @override
  String get passwordMinLength => '密码至少需要4个字符';

  @override
  String get passwordsDoNotMatch => '密码不一致';

  @override
  String get passwordSetSuccess => '密码设置成功';

  @override
  String get passwordChangedSuccess => '密码修改成功';

  @override
  String get currentPasswordIncorrect => '当前密码不正确';

  @override
  String get newPasswordCannotBeEmpty => '新密码不能为空';

  @override
  String get confirmRemovePassword => '输入当前密码以确认移除。';

  @override
  String get passwordIncorrect => '密码不正确';

  @override
  String get passwordRemoved => '密码已移除';

  @override
  String get exportFailed => '导出失败';

  @override
  String get encryptedBackupFile => '加密备份 (.keebaup)';

  @override
  String get passwordProtectedFile => '受密码保护的加密文件';

  @override
  String get htmlFile => 'HTML 文件';

  @override
  String get humanReadableHtml => '人类可读的 HTML 表格';

  @override
  String get uriList => 'URI 列表';

  @override
  String get plainTextUris => '纯文本 otpauth:// URI';

  @override
  String get enterPasswordEncrypt => '输入密码以加密备份';

  @override
  String get codeGroupSize => '验证码分组大小';

  @override
  String digitsPerGroup(Object count) {
    return '每组 $count 位数字';
  }

  @override
  String secondsCount(Object count) {
    return '$count 秒';
  }

  @override
  String minutesCount(Object count) {
    return '$count 分钟';
  }

  @override
  String get remove => '移除';

  @override
  String get appLocked => '应用已锁定';

  @override
  String get authenticateToUnlock => '验证身份以解锁';

  @override
  String get useBiometrics => '使用生物识别';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get incorrectPassword => '密码错误';

  @override
  String get mainMenu => '主菜单';

  @override
  String get editDetails => '编辑详情';

  @override
  String get gettingStartedGuide => '入门指南';

  @override
  String get restoreBackup => '恢复备份';

  @override
  String get backUp => '备份';

  @override
  String get editCategories => '编辑分类';

  @override
  String get advancedWarningTitle => '警告';

  @override
  String get advancedWarningMessage =>
      '修改高级设置（类型、算法、位数、周期）可能导致验证码失效。请仅在确切了解后果的情况下进行修改。\n\n错误的更改可能导致您无法登录账户。';

  @override
  String get iUnderstand => '我已了解';

  @override
  String get goBack => '返回';

  @override
  String get creatingBackup => '正在创建备份...';

  @override
  String get restoringBackup => '正在恢复备份...';

  @override
  String get exportedTo => '已保存至';

  @override
  String get autoBackupEnabled => '自动备份已启用';

  @override
  String get autoBackupDisabled => '自动备份已关闭';

  @override
  String get everyHour => '每小时';

  @override
  String get every6Hours => '每6小时';

  @override
  String get every12Hours => '每12小时';

  @override
  String get every2Days => '每2天';

  @override
  String get weekly => '每周';

  @override
  String get setBackupPasswordDescription => '设置自动备份的密码';

  @override
  String get biometricNotAvailable => '此设备不支持生物识别';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicyContent =>
      'KeeAuth 重视您的隐私。\n\n• 所有数据仅存储在您的设备上\n• 不收集、不传输任何个人信息\n• 不包含广告或分析SDK\n• 摄像头仅用于扫描二维码';

  @override
  String get privacyPolicyViewFull => '查看完整隐私政策';

  @override
  String get privacyPolicyAgree => '同意并继续';

  @override
  String get privacyPolicyDisagree => '不同意';

  @override
  String get linkCopied => '链接已复制，请在浏览器中打开';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'KeeAuth';

  @override
  String get splashSubtitle => '安全認證器';

  @override
  String get splashStarting => '正在啟動...';

  @override
  String get splashReady => '準備就緒';

  @override
  String get loadingSettings => '正在載入設定...';

  @override
  String get initializingSecurity => '正在初始化安全...';

  @override
  String get authenticator => '認證器';

  @override
  String get settings => '設定';

  @override
  String get about => '關於';

  @override
  String get addAuthenticator => '新增認證器';

  @override
  String get editAuthenticator => '編輯認證器';

  @override
  String get deleteAuthenticator => '刪除認證器';

  @override
  String get deleteConfirm => '確定要刪除此認證器嗎？';

  @override
  String get authenticatorAdded => '認證器新增成功';

  @override
  String get authenticatorUpdated => '認證器已更新';

  @override
  String get authenticatorDeleted => '認證器已刪除';

  @override
  String get issuer => '服務商';

  @override
  String get issuerOptional => '服務商（選填）';

  @override
  String get accountName => '帳戶名稱';

  @override
  String get account => '帳戶';

  @override
  String get secretKey => '密鑰';

  @override
  String get add => '新增';

  @override
  String get showAdvancedOptions => '顯示進階選項';

  @override
  String get tryAgain => '重試';

  @override
  String get close => '關閉';

  @override
  String get ok => '確定';

  @override
  String get retry => '重試';

  @override
  String get scanQrCode => '掃描 QR 碼';

  @override
  String get showQrCode => '顯示 QR 碼';

  @override
  String get enterManually => '手動輸入';

  @override
  String get category => '分類';

  @override
  String get categories => '分類';

  @override
  String get addCategory => '新增分類';

  @override
  String get editCategory => '編輯分類';

  @override
  String get deleteCategory => '刪除分類';

  @override
  String get selectCategory => '選擇分類';

  @override
  String get all => '全部';

  @override
  String get uncategorized => '未分類';

  @override
  String get categoryName => '分類名稱';

  @override
  String get categoryColor => '顏色';

  @override
  String get import => '匯入';

  @override
  String get export => '匯出';

  @override
  String get importAuthenticators => '匯入認證器';

  @override
  String get exportBackup => '匯出備份';

  @override
  String get importFromOtherApps => '從其他 2FA 應用程式匯入';

  @override
  String get parsingBackupFile => '正在解析備份檔案...';

  @override
  String get selectBackupFile => '選擇備份檔案';

  @override
  String importItems(Object count) {
    return '匯入 $count 項';
  }

  @override
  String importedCount(Object count) {
    return '已匯入 $count 個認證器';
  }

  @override
  String get backup => '備份';

  @override
  String get autoBackup => '自動備份';

  @override
  String get encryptedBackup => '加密備份';

  @override
  String get plainText => '純文字 (URI 列表)';

  @override
  String get passwordProtected => '受密碼保護的 .keebaup 檔案';

  @override
  String get unencryptedUris => '未加密的 otpauth URI';

  @override
  String get encryptedExportComingSoon => '加密匯出功能即將推出';

  @override
  String get plainExportComingSoon => '純文字匯出功能即將推出';

  @override
  String get enableAutoBackup => '啟用自動備份';

  @override
  String get backupFrequency => '備份頻率';

  @override
  String get daily => '每天';

  @override
  String get security => '安全性';

  @override
  String get data => '資料';

  @override
  String get display => '顯示';

  @override
  String get biometricUnlock => '生物辨識解鎖';

  @override
  String get biometricDescription => '使用指紋或臉部辨識解鎖';

  @override
  String get biometricRequiresPassword => '請先設定應用程式密碼以啟用生物辨識解鎖';

  @override
  String get verifyToEnableBiometric => '驗證以啟用生物辨識解鎖';

  @override
  String get autoLockTimeout => '自動鎖定逾時';

  @override
  String get immediately => '立即';

  @override
  String get allowScreenshots => '允許截圖';

  @override
  String get screenshotsDescription => '停用後，將封鎖截圖功能';

  @override
  String get tapToReveal => '點選顯示';

  @override
  String get tapToRevealDescription => '預設隱藏驗證碼，點選後顯示';

  @override
  String get theme => '主題';

  @override
  String get light => '淺色';

  @override
  String get dark => '深色';

  @override
  String get systemDefault => '跟隨系統';

  @override
  String get sortMode => '排序方式';

  @override
  String get manual => '手動（拖曳排序）';

  @override
  String get byName => '依名稱';

  @override
  String get mostUsed => '最常使用';

  @override
  String get dateAdded => '新增日期';

  @override
  String get search => '搜尋';

  @override
  String get searchAuthenticators => '搜尋認證器...';

  @override
  String get searchIcons => '搜尋圖示...';

  @override
  String get noResultsFound => '找不到結果';

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get noAuthenticators => '尚無認證器';

  @override
  String get addFirstAuthenticator => '新增您的第一個認證器';

  @override
  String get codeCopied => '驗證碼已複製到剪貼簿';

  @override
  String get secretCopied => '密鑰已複製';

  @override
  String get uriCopied => 'URI 已複製到剪貼簿';

  @override
  String get copyUri => '複製 URI';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get done => '完成';

  @override
  String get share => '分享';

  @override
  String get next => '下一步';

  @override
  String get skip => '略過';

  @override
  String get getStarted => '開始使用';

  @override
  String get version => '版本';

  @override
  String get license => '採用 Apache License 2.0 授權';

  @override
  String get github => 'GitHub';

  @override
  String get reportIssue => '報告問題';

  @override
  String get helpUsImprove => '幫助我們改進';

  @override
  String get introWelcomeTitle => '歡迎使用 KeeAuth';

  @override
  String get introWelcomeDescription => '一個安全開源的雙因素認證應用程式，保護您的線上帳戶安全。';

  @override
  String get introEasySetupTitle => '輕鬆設定';

  @override
  String get introEasySetupDescription => '掃描 QR 碼或手動輸入密鑰，在幾秒鐘內新增您的認證器。';

  @override
  String get introImportTitle => '從其他應用程式匯入';

  @override
  String get introImportDescription =>
      '輕鬆從 Google Authenticator、Aegis、Bitwarden 等應用程式移轉。';

  @override
  String get introBackupTitle => '安全備份';

  @override
  String get introBackupDescription => '建立加密備份，確保您的認證器安全，永遠不會被鎖定。';

  @override
  String get details => '詳情';

  @override
  String get edit => '編輯';

  @override
  String get copy => '複製';

  @override
  String get currentCode => '目前驗證碼';

  @override
  String get technicalDetails => '技術詳情';

  @override
  String get type => '類型';

  @override
  String get algorithm => '演算法';

  @override
  String get digits => '位數';

  @override
  String get period => '週期';

  @override
  String get createdAt => '建立時間';

  @override
  String get qrCode => 'QR 碼';

  @override
  String get scanHelpText => '將 QR 碼對準框內即可掃描';

  @override
  String get flashOn => '閃光燈開';

  @override
  String get flashOff => '閃光燈關';

  @override
  String get invalidQrCode => '無效的 QR 碼。請掃描認證器 QR 碼。';

  @override
  String get invalidQrCodeShort => '無效的 QR 碼';

  @override
  String get galleryPickerNotImplemented => '相簿選擇器尚未實作';

  @override
  String get passwordRequired => '需要密碼';

  @override
  String get backupPassword => '備份密碼';

  @override
  String get enterBackupPassword => '輸入此備份的密碼';

  @override
  String get addCustomImage => '新增自訂圖片';

  @override
  String get failedToLoadIcons => '載入圖示失敗';

  @override
  String get failedToPickImage => '選擇圖片失敗';

  @override
  String get configureAutomaticBackups => '設定自動備份';

  @override
  String get exportYourAuthenticators => '匯出您的認證器';

  @override
  String get error => '錯誤';

  @override
  String get selectSource => '選擇來源';

  @override
  String get supportedFormats => '支援的格式';

  @override
  String get importPreview => '匯入預覽';

  @override
  String get unlock => '解鎖';

  @override
  String get menu => '選單';

  @override
  String get more => '更多';

  @override
  String get backupAndRestore => '備份與還原';

  @override
  String get issuerHint => '例如: Google, GitHub';

  @override
  String get accountHint => '例如: user@example.com';

  @override
  String get secretKeyHint => '輸入密鑰';

  @override
  String get pleaseEnterAccount => '請輸入帳戶名稱';

  @override
  String get pleaseEnterSecret => '請輸入密鑰';

  @override
  String get invalidSecretFormat => '密鑰格式無效';

  @override
  String get invalidUri => '無效的 URI';

  @override
  String get authenticatorAlreadyExists => '認證器已存在';

  @override
  String get advancedOptionsComingSoon => '進階選項（類型、演算法、位數、週期）將在未來版本中提供。';

  @override
  String get tapToRevealHint => '點選顯示';

  @override
  String get or => '或';

  @override
  String get restore => '還原';

  @override
  String get restoreBackupComingSoon => '還原備份功能即將推出';

  @override
  String get failedToPickFile => '選擇檔案失敗';

  @override
  String get failedToProcessFile => '處理檔案失敗';

  @override
  String get couldNotDetectFormat => '無法檢測備份格式。請手動選擇格式。';

  @override
  String get failedToParseQrCode => '解析 QR 碼失敗';

  @override
  String get havingIssue => '遇到問題？在這裡報告';

  @override
  String get author => '作者';

  @override
  String get forkOnGithub => '在 GitHub 上 Fork';

  @override
  String get sendEmail => '發送郵件';

  @override
  String get askQuestion => '有問題？';

  @override
  String get apacheLicense => 'Apache 授權';

  @override
  String get changeIcon => '更改圖示';

  @override
  String get leastUsed => '最少使用';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get viewGuide => '查看指南';

  @override
  String get gettingStarted => '入門指南';

  @override
  String get gotIt => '知道了';

  @override
  String get guideStep1 => '1. 點選 + 按鈕新增認證器';

  @override
  String get guideStep2 => '2. 掃描 QR 碼或手動輸入密鑰';

  @override
  String get guideStep3 => '3. 驗證碼將自動產生';

  @override
  String get guideStep4 => '4. 點選驗證碼複製到剪貼簿';

  @override
  String get guideStep5 => '5. 使用選單管理分類和設定';

  @override
  String get tryDifferentSearch => '試試其他搜尋詞';

  @override
  String get manageCategories => '管理分類';

  @override
  String get view => '檢視';

  @override
  String get viewStandard => '標準';

  @override
  String get viewCompact => '精簡';

  @override
  String get viewTile => '磚塊';

  @override
  String get noCategories => '尚無分類';

  @override
  String get enterCategoryName => '輸入分類名稱';

  @override
  String deleteCategoryConfirm(Object name) {
    return '確定要刪除「$name」嗎？';
  }

  @override
  String get counter => '計數器';

  @override
  String get pin => 'PIN';

  @override
  String get changeSecretKey => '更改密鑰';

  @override
  String maxCharacters(Object count) {
    return '最多 $count 個字元';
  }

  @override
  String get motpSecretAlphanumeric => 'mOTP 密鑰必須為英數字元';

  @override
  String get invalidBase32Format => '無效的 Base32 格式';

  @override
  String get digitsRange => '6 ~ 10';

  @override
  String get mustBePositive => '必須大於 0';

  @override
  String get pinRequired => '需要 PIN';

  @override
  String get assignCategories => '指定分類';

  @override
  String get noCategoriesCreate => '尚無分類，請先建立一個。';

  @override
  String get createCategory => '建立分類';

  @override
  String get password => '密碼';

  @override
  String get setPassword => '設定密碼';

  @override
  String get changePassword => '變更密碼';

  @override
  String get removePassword => '移除密碼';

  @override
  String get changeOrRemovePassword => '變更或移除應用程式密碼';

  @override
  String get protectWithPassword => '使用密碼保護應用程式';

  @override
  String get newPassword => '新密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get confirmNewPassword => '確認新密碼';

  @override
  String get currentPassword => '目前密碼';

  @override
  String get passwordCannotBeEmpty => '密碼不能為空';

  @override
  String get passwordMinLength => '密碼至少需要4個字元';

  @override
  String get passwordsDoNotMatch => '密碼不一致';

  @override
  String get passwordSetSuccess => '密碼設定成功';

  @override
  String get passwordChangedSuccess => '密碼變更成功';

  @override
  String get currentPasswordIncorrect => '目前密碼不正確';

  @override
  String get newPasswordCannotBeEmpty => '新密碼不能為空';

  @override
  String get confirmRemovePassword => '輸入目前密碼以確認移除。';

  @override
  String get passwordIncorrect => '密碼不正確';

  @override
  String get passwordRemoved => '密碼已移除';

  @override
  String get exportFailed => '匯出失敗';

  @override
  String get encryptedBackupFile => '加密備份 (.keebaup)';

  @override
  String get passwordProtectedFile => '受密碼保護的加密檔案';

  @override
  String get htmlFile => 'HTML 檔案';

  @override
  String get humanReadableHtml => '人類可讀的 HTML 表格';

  @override
  String get uriList => 'URI 列表';

  @override
  String get plainTextUris => '純文字 otpauth:// URI';

  @override
  String get enterPasswordEncrypt => '輸入密碼以加密備份';

  @override
  String get codeGroupSize => '驗證碼分組大小';

  @override
  String digitsPerGroup(Object count) {
    return '每組 $count 位數字';
  }

  @override
  String secondsCount(Object count) {
    return '$count 秒';
  }

  @override
  String minutesCount(Object count) {
    return '$count 分鐘';
  }

  @override
  String get remove => '移除';

  @override
  String get appLocked => '應用程式已鎖定';

  @override
  String get authenticateToUnlock => '驗證身份以解鎖';

  @override
  String get useBiometrics => '使用生物辨識';

  @override
  String get pleaseEnterPassword => '請輸入密碼';

  @override
  String get incorrectPassword => '密碼錯誤';

  @override
  String get mainMenu => '主選單';

  @override
  String get editDetails => '編輯詳情';

  @override
  String get gettingStartedGuide => '入門指南';

  @override
  String get restoreBackup => '還原備份';

  @override
  String get backUp => '備份';

  @override
  String get editCategories => '編輯分類';

  @override
  String get advancedWarningTitle => '警告';

  @override
  String get advancedWarningMessage =>
      '修改進階設定（類型、演算法、位數、週期）可能導致驗證碼失效。請僅在確切了解後果的情況下進行修改。\n\n錯誤的更改可能導致您無法登入帳戶。';

  @override
  String get iUnderstand => '我已了解';

  @override
  String get goBack => '返回';

  @override
  String get creatingBackup => '正在建立備份...';

  @override
  String get restoringBackup => '正在恢復備份...';

  @override
  String get exportedTo => '已儲存至';

  @override
  String get autoBackupEnabled => '自動備份已啟用';

  @override
  String get autoBackupDisabled => '自動備份已關閉';

  @override
  String get everyHour => '每小時';

  @override
  String get every6Hours => '每6小時';

  @override
  String get every12Hours => '每12小時';

  @override
  String get every2Days => '每2天';

  @override
  String get weekly => '每週';

  @override
  String get setBackupPasswordDescription => '設定自動備份的密碼';

  @override
  String get biometricNotAvailable => '此裝置不支援生物辨識';

  @override
  String get privacyPolicyTitle => '隱私政策';

  @override
  String get privacyPolicyContent =>
      'KeeAuth 重視您的隱私。\n\n• 所有資料僅儲存在您的裝置上\n• 不收集、不傳輸任何個人資訊\n• 不包含廣告或分析SDK\n• 相機僅用於掃描二維碼';

  @override
  String get privacyPolicyViewFull => '查看完整隱私政策';

  @override
  String get privacyPolicyAgree => '同意並繼續';

  @override
  String get privacyPolicyDisagree => '不同意';

  @override
  String get linkCopied => '連結已複製，請在瀏覽器中開啟';
}
