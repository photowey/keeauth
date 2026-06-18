// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KeeAuth';

  @override
  String get splashSubtitle => 'Secure Authenticator';

  @override
  String get splashStarting => 'Starting...';

  @override
  String get splashReady => 'Ready';

  @override
  String get loadingSettings => 'Loading settings...';

  @override
  String get initializingSecurity => 'Initializing security...';

  @override
  String get authenticator => 'Authenticator';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get addAuthenticator => 'Add Authenticator';

  @override
  String get editAuthenticator => 'Edit Authenticator';

  @override
  String get deleteAuthenticator => 'Delete Authenticator';

  @override
  String get deleteConfirm =>
      'Are you sure you want to delete this authenticator?';

  @override
  String get authenticatorAdded => 'Authenticator added successfully';

  @override
  String get authenticatorUpdated => 'Authenticator updated';

  @override
  String get authenticatorDeleted => 'Authenticator deleted';

  @override
  String get issuer => 'Issuer';

  @override
  String get issuerOptional => 'Issuer (optional)';

  @override
  String get accountName => 'Account Name';

  @override
  String get account => 'Account';

  @override
  String get secretKey => 'Secret Key';

  @override
  String get add => 'Add';

  @override
  String get showAdvancedOptions => 'Show advanced options';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get showQrCode => 'Show QR Code';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get all => 'All';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryColor => 'Color';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get importAuthenticators => 'Import Authenticators';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importFromOtherApps => 'Import from other 2FA apps';

  @override
  String get parsingBackupFile => 'Parsing backup file...';

  @override
  String get selectBackupFile => 'Select Backup File';

  @override
  String importItems(Object count) {
    return 'Import $count Items';
  }

  @override
  String importedCount(Object count) {
    return 'Imported $count authenticators';
  }

  @override
  String get backup => 'Backup';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get encryptedBackup => 'Encrypted Backup';

  @override
  String get plainText => 'Plain Text (URI List)';

  @override
  String get passwordProtected => 'Password-protected .keebaup file';

  @override
  String get unencryptedUris => 'Unencrypted otpauth URIs';

  @override
  String get encryptedExportComingSoon => 'Encrypted export coming soon';

  @override
  String get plainExportComingSoon => 'Plain export coming soon';

  @override
  String get enableAutoBackup => 'Enable Auto Backup';

  @override
  String get backupFrequency => 'Backup Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get security => 'Security';

  @override
  String get data => 'Data';

  @override
  String get display => 'Display';

  @override
  String get biometricUnlock => 'Biometric Unlock';

  @override
  String get biometricDescription => 'Use fingerprint or face to unlock';

  @override
  String get biometricRequiresPassword =>
      'Set app password first to enable biometric unlock';

  @override
  String get verifyToEnableBiometric => 'Verify to enable biometric unlock';

  @override
  String get autoLockTimeout => 'Auto-lock Timeout';

  @override
  String get immediately => 'Immediately';

  @override
  String get allowScreenshots => 'Allow Screenshots';

  @override
  String get screenshotsDescription => '截图默认关闭，开启后可正常截图';

  @override
  String get tapToReveal => 'Tap to Reveal';

  @override
  String get tapToRevealDescription => 'Hide codes by default, tap to show';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get sortMode => 'Sort Mode';

  @override
  String get manual => 'Manual (drag to reorder)';

  @override
  String get byName => 'By name';

  @override
  String get mostUsed => 'Most used';

  @override
  String get dateAdded => 'Date added';

  @override
  String get search => 'Search';

  @override
  String get searchAuthenticators => 'Search authenticators...';

  @override
  String get searchIcons => 'Search icons...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get noAuthenticators => 'No authenticators yet';

  @override
  String get addFirstAuthenticator => 'Add your first authenticator';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get secretCopied => 'Secret copied';

  @override
  String get uriCopied => 'URI copied to clipboard';

  @override
  String get copyUri => 'Copy URI';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get share => 'Share';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get version => 'Version';

  @override
  String get license => 'Licensed under the GNU GPL v3.0';

  @override
  String get github => 'GitHub';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get helpUsImprove => 'Help us improve';

  @override
  String get introWelcomeTitle => 'Welcome to KeeAuth';

  @override
  String get introWelcomeDescription =>
      'A secure and open-source two-factor authentication app to protect your online accounts.';

  @override
  String get introEasySetupTitle => 'Easy Setup';

  @override
  String get introEasySetupDescription =>
      'Scan QR codes or manually enter secrets to add your authenticators in seconds.';

  @override
  String get introImportTitle => 'Import from Other Apps';

  @override
  String get introImportDescription =>
      'Easily migrate from Google Authenticator, Aegis, Bitwarden, and many more.';

  @override
  String get introBackupTitle => 'Secure Backups';

  @override
  String get introBackupDescription =>
      'Create encrypted backups to keep your authenticators safe and never get locked out.';

  @override
  String get details => 'Details';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get currentCode => 'Current Code';

  @override
  String get technicalDetails => 'Technical Details';

  @override
  String get type => 'Type';

  @override
  String get algorithm => 'Algorithm';

  @override
  String get digits => 'Digits';

  @override
  String get period => 'Period';

  @override
  String get createdAt => 'Created';

  @override
  String get qrCode => 'QR Code';

  @override
  String get scanHelpText => 'Align QR code within the frame to scan';

  @override
  String get flashOn => 'Flash On';

  @override
  String get flashOff => 'Flash Off';

  @override
  String get invalidQrCode =>
      'Invalid QR code. Please scan an authenticator QR code.';

  @override
  String get invalidQrCodeShort => 'Invalid QR Code';

  @override
  String get galleryPickerNotImplemented =>
      'Gallery picker not implemented yet';

  @override
  String get passwordRequired => 'Password Required';

  @override
  String get backupPassword => 'Backup Password';

  @override
  String get enterBackupPassword => 'Enter the password for this backup';

  @override
  String get addCustomImage => 'Add Custom Image';

  @override
  String get failedToLoadIcons => 'Failed to load icons';

  @override
  String get failedToPickImage => 'Failed to pick image';

  @override
  String get configureAutomaticBackups => 'Configure automatic backups';

  @override
  String get exportYourAuthenticators => 'Export your authenticators';

  @override
  String get error => 'Error';

  @override
  String get selectSource => 'Select Source';

  @override
  String get supportedFormats => 'Supported Formats';

  @override
  String get importPreview => 'Import Preview';

  @override
  String get unlock => 'Unlock';

  @override
  String get menu => 'Menu';

  @override
  String get more => 'More';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get issuerHint => 'e.g., Google, GitHub';

  @override
  String get accountHint => 'e.g., user@example.com';

  @override
  String get secretKeyHint => 'Enter the secret key';

  @override
  String get pleaseEnterAccount => 'Please enter an account name';

  @override
  String get pleaseEnterSecret => 'Please enter the secret key';

  @override
  String get invalidSecretFormat => 'Invalid secret key format';

  @override
  String get invalidUri => 'Invalid URI';

  @override
  String get authenticatorAlreadyExists => 'Authenticator already exists';

  @override
  String get advancedOptionsComingSoon =>
      'Advanced options (Type, Algorithm, Digits, Period) will be available in a future update.';

  @override
  String get tapToRevealHint => 'Tap to reveal';

  @override
  String get or => 'OR';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackupComingSoon => 'Restore backup feature coming soon';

  @override
  String get failedToPickFile => 'Failed to pick file';

  @override
  String get failedToProcessFile => 'Failed to process file';

  @override
  String get couldNotDetectFormat =>
      'Could not detect backup format. Please select a format manually.';

  @override
  String get failedToParseQrCode => 'Failed to parse QR code';

  @override
  String get havingIssue => 'Having an issue? Report it here';

  @override
  String get author => 'Author';

  @override
  String get forkOnGithub => 'Fork on GitHub';

  @override
  String get sendEmail => 'Send an Email';

  @override
  String get askQuestion => 'Ask Question?';

  @override
  String get apacheLicense => 'GNU GPL v3.0';

  @override
  String get changeIcon => 'Change Icon';

  @override
  String get leastUsed => 'Least Used';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get viewGuide => 'View Guide';

  @override
  String get gettingStarted => 'Getting Started';

  @override
  String get gotIt => 'Got it';

  @override
  String get guideStep1 => '1. Tap the + button to add a new authenticator';

  @override
  String get guideStep2 => '2. Scan a QR code or enter the secret manually';

  @override
  String get guideStep3 => '3. Your codes will be generated automatically';

  @override
  String get guideStep4 => '4. Tap a code to copy it to clipboard';

  @override
  String get guideStep5 => '5. Use the menu to manage categories and settings';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get view => 'View';

  @override
  String get viewStandard => 'Standard';

  @override
  String get viewCompact => 'Compact';

  @override
  String get viewTile => 'Tile';

  @override
  String get noCategories => 'No categories';

  @override
  String get enterCategoryName => 'Enter category name';

  @override
  String deleteCategoryConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get counter => 'Counter';

  @override
  String get pin => 'PIN';

  @override
  String get changeSecretKey => 'Change Secret Key';

  @override
  String maxCharacters(Object count) {
    return 'Max $count characters';
  }

  @override
  String get motpSecretAlphanumeric => 'mOTP secret must be alphanumeric';

  @override
  String get invalidBase32Format => 'Invalid Base32 format';

  @override
  String get digitsRange => '6 ~ 10';

  @override
  String get mustBePositive => 'Must be > 0';

  @override
  String get pinRequired => 'PIN is required';

  @override
  String get assignCategories => 'Specify categories';

  @override
  String get noCategoriesCreate => 'No categories. Create one first.';

  @override
  String get createCategory => 'Create category';

  @override
  String get password => 'Password';

  @override
  String get setPassword => 'Set Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get removePassword => 'Remove Password';

  @override
  String get changeOrRemovePassword => 'Change or remove your app password';

  @override
  String get protectWithPassword => 'Protect your app with a password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get passwordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get passwordMinLength => 'Password must be at least 4 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordSetSuccess => 'Password set successfully';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get newPasswordCannotBeEmpty => 'New password cannot be empty';

  @override
  String get confirmRemovePassword =>
      'Enter your current password to confirm removal.';

  @override
  String get passwordIncorrect => 'Password is incorrect';

  @override
  String get passwordRemoved => 'Password removed';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get encryptedBackupFile => 'Encrypted Backup (.keebaup)';

  @override
  String get passwordProtectedFile => 'Password-protected encrypted file';

  @override
  String get htmlFile => 'HTML File';

  @override
  String get humanReadableHtml => 'Human-readable HTML table';

  @override
  String get uriList => 'URI List';

  @override
  String get plainTextUris => 'Plain text otpauth:// URIs';

  @override
  String get enterPasswordEncrypt => 'Enter a password to encrypt the backup';

  @override
  String get codeGroupSize => 'Code Group Size';

  @override
  String digitsPerGroup(Object count) {
    return '$count digits per group';
  }

  @override
  String secondsCount(Object count) {
    return '$count seconds';
  }

  @override
  String minutesCount(Object count) {
    return '$count minute(s)';
  }

  @override
  String get remove => 'Remove';

  @override
  String get appLocked => 'App Locked';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get mainMenu => 'Main menu';

  @override
  String get editDetails => 'Edit details';

  @override
  String get gettingStartedGuide => 'Getting started guide';

  @override
  String get restoreBackup => 'Restore a backup';

  @override
  String get backUp => 'Back up';

  @override
  String get editCategories => 'Edit categories';

  @override
  String get advancedWarningTitle => 'Warning';

  @override
  String get advancedWarningMessage =>
      'Changing advanced settings (type, algorithm, digits, period) may cause your verification codes to become invalid. Only modify these if you know exactly what you are doing.\n\nIncorrect changes could lock you out of your accounts.';

  @override
  String get iUnderstand => 'I Understand';

  @override
  String get goBack => 'Go Back';

  @override
  String get creatingBackup => 'Creating backup...';

  @override
  String get restoringBackup => 'Restoring backup...';

  @override
  String get exportedTo => 'Saved to';

  @override
  String get autoBackupEnabled => 'Automatic backups are active';

  @override
  String get autoBackupDisabled => 'Automatic backups are off';

  @override
  String get everyHour => 'Every hour';

  @override
  String get every6Hours => 'Every 6 hours';

  @override
  String get every12Hours => 'Every 12 hours';

  @override
  String get every2Days => 'Every 2 days';

  @override
  String get weekly => 'Weekly';

  @override
  String get setBackupPasswordDescription =>
      'Set a password for automatic backups';

  @override
  String get biometricNotAvailable => 'Biometric not supported on this device';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'KeeAuth values your privacy.\n\n• All data is stored exclusively on your device\n• No personal information is collected or transmitted\n• No advertising or analytics SDKs\n• Camera is used only for QR code scanning';

  @override
  String get privacyPolicyViewFull => 'View Full Privacy Policy';

  @override
  String get privacyPolicyAgree => 'Agree and Continue';

  @override
  String get privacyPolicyDisagree => 'Disagree';
}
