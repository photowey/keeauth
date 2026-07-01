import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The app title
  ///
  /// In en, this message translates to:
  /// **'KeeAuth'**
  String get appTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Authenticator'**
  String get splashSubtitle;

  /// No description provided for @splashStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get splashStarting;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get splashReady;

  /// No description provided for @loadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get loadingSettings;

  /// No description provided for @initializingSecurity.
  ///
  /// In en, this message translates to:
  /// **'Initializing security...'**
  String get initializingSecurity;

  /// No description provided for @authenticator.
  ///
  /// In en, this message translates to:
  /// **'Authenticator'**
  String get authenticator;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @addAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Add Authenticator'**
  String get addAuthenticator;

  /// No description provided for @editAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Edit Authenticator'**
  String get editAuthenticator;

  /// No description provided for @deleteAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Delete Authenticator'**
  String get deleteAuthenticator;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this authenticator?'**
  String get deleteConfirm;

  /// No description provided for @authenticatorAdded.
  ///
  /// In en, this message translates to:
  /// **'Authenticator added successfully'**
  String get authenticatorAdded;

  /// No description provided for @authenticatorUpdated.
  ///
  /// In en, this message translates to:
  /// **'Authenticator updated'**
  String get authenticatorUpdated;

  /// No description provided for @authenticatorDeleted.
  ///
  /// In en, this message translates to:
  /// **'Authenticator deleted'**
  String get authenticatorDeleted;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// No description provided for @issuerOptional.
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get issuerOptional;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get secretKey;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @showAdvancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Show advanced options'**
  String get showAdvancedOptions;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQrCode;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @importAuthenticators.
  ///
  /// In en, this message translates to:
  /// **'Import Authenticators'**
  String get importAuthenticators;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @importFromOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Import from other 2FA apps'**
  String get importFromOtherApps;

  /// No description provided for @parsingBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Parsing backup file...'**
  String get parsingBackupFile;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectBackupFile;

  /// No description provided for @importItems.
  ///
  /// In en, this message translates to:
  /// **'Import {count} Items'**
  String importItems(Object count);

  /// No description provided for @importedCount.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} authenticators'**
  String importedCount(Object count);

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @encryptedBackup.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backup'**
  String get encryptedBackup;

  /// No description provided for @plainText.
  ///
  /// In en, this message translates to:
  /// **'Plain Text (URI List)'**
  String get plainText;

  /// No description provided for @passwordProtected.
  ///
  /// In en, this message translates to:
  /// **'Password-protected .keebaup file'**
  String get passwordProtected;

  /// No description provided for @unencryptedUris.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted otpauth URIs'**
  String get unencryptedUris;

  /// No description provided for @encryptedExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Encrypted export coming soon'**
  String get encryptedExportComingSoon;

  /// No description provided for @plainExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Plain export coming soon'**
  String get plainExportComingSoon;

  /// No description provided for @enableAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Enable Auto Backup'**
  String get enableAutoBackup;

  /// No description provided for @backupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFrequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricDescription.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face to unlock'**
  String get biometricDescription;

  /// No description provided for @biometricRequiresPassword.
  ///
  /// In en, this message translates to:
  /// **'Set app password first to enable biometric unlock'**
  String get biometricRequiresPassword;

  /// No description provided for @verifyToEnableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Verify to enable biometric unlock'**
  String get verifyToEnableBiometric;

  /// No description provided for @autoLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock Timeout'**
  String get autoLockTimeout;

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @allowScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Allow Screenshots'**
  String get allowScreenshots;

  /// No description provided for @screenshotsDescription.
  ///
  /// In en, this message translates to:
  /// **'截图默认关闭，开启后可正常截图'**
  String get screenshotsDescription;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to Reveal'**
  String get tapToReveal;

  /// No description provided for @tapToRevealDescription.
  ///
  /// In en, this message translates to:
  /// **'Hide codes by default, tap to show'**
  String get tapToRevealDescription;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @sortMode.
  ///
  /// In en, this message translates to:
  /// **'Sort Mode'**
  String get sortMode;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual (drag to reorder)'**
  String get manual;

  /// No description provided for @byName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get byName;

  /// No description provided for @mostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get mostUsed;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get dateAdded;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchAuthenticators.
  ///
  /// In en, this message translates to:
  /// **'Search authenticators...'**
  String get searchAuthenticators;

  /// No description provided for @searchIcons.
  ///
  /// In en, this message translates to:
  /// **'Search icons...'**
  String get searchIcons;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @noAuthenticators.
  ///
  /// In en, this message translates to:
  /// **'No authenticators yet'**
  String get noAuthenticators;

  /// No description provided for @addFirstAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Add your first authenticator'**
  String get addFirstAuthenticator;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @secretCopied.
  ///
  /// In en, this message translates to:
  /// **'Secret copied'**
  String get secretCopied;

  /// No description provided for @uriCopied.
  ///
  /// In en, this message translates to:
  /// **'URI copied to clipboard'**
  String get uriCopied;

  /// No description provided for @copyUri.
  ///
  /// In en, this message translates to:
  /// **'Copy URI'**
  String get copyUri;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'Licensed under the GNU GPL v3.0'**
  String get license;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve'**
  String get helpUsImprove;

  /// No description provided for @introWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KeeAuth'**
  String get introWelcomeTitle;

  /// No description provided for @introWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'A secure and open-source two-factor authentication app to protect your online accounts.'**
  String get introWelcomeDescription;

  /// No description provided for @introEasySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Setup'**
  String get introEasySetupTitle;

  /// No description provided for @introEasySetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan QR codes or manually enter secrets to add your authenticators in seconds.'**
  String get introEasySetupDescription;

  /// No description provided for @introImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Other Apps'**
  String get introImportTitle;

  /// No description provided for @introImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily migrate from Google Authenticator, Aegis, Bitwarden, and many more.'**
  String get introImportDescription;

  /// No description provided for @introBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Backups'**
  String get introBackupTitle;

  /// No description provided for @introBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create encrypted backups to keep your authenticators safe and never get locked out.'**
  String get introBackupDescription;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @currentCode.
  ///
  /// In en, this message translates to:
  /// **'Current Code'**
  String get currentCode;

  /// No description provided for @technicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get technicalDetails;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @algorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithm;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @scanHelpText.
  ///
  /// In en, this message translates to:
  /// **'Align QR code within the frame to scan'**
  String get scanHelpText;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash On'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash Off'**
  String get flashOff;

  /// No description provided for @invalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Please scan an authenticator QR code.'**
  String get invalidQrCode;

  /// No description provided for @invalidQrCodeShort.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQrCodeShort;

  /// No description provided for @galleryPickerNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Gallery picker not implemented yet'**
  String get galleryPickerNotImplemented;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password Required'**
  String get passwordRequired;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup Password'**
  String get backupPassword;

  /// No description provided for @enterBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the password for this backup'**
  String get enterBackupPassword;

  /// No description provided for @addCustomImage.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Image'**
  String get addCustomImage;

  /// No description provided for @failedToLoadIcons.
  ///
  /// In en, this message translates to:
  /// **'Failed to load icons'**
  String get failedToLoadIcons;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// No description provided for @configureAutomaticBackups.
  ///
  /// In en, this message translates to:
  /// **'Configure automatic backups'**
  String get configureAutomaticBackups;

  /// No description provided for @exportYourAuthenticators.
  ///
  /// In en, this message translates to:
  /// **'Export your authenticators'**
  String get exportYourAuthenticators;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @selectSource.
  ///
  /// In en, this message translates to:
  /// **'Select Source'**
  String get selectSource;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported Formats'**
  String get supportedFormats;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get importPreview;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @issuerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Google, GitHub'**
  String get issuerHint;

  /// No description provided for @accountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., user@example.com'**
  String get accountHint;

  /// No description provided for @secretKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the secret key'**
  String get secretKeyHint;

  /// No description provided for @pleaseEnterAccount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get pleaseEnterAccount;

  /// No description provided for @pleaseEnterSecret.
  ///
  /// In en, this message translates to:
  /// **'Please enter the secret key'**
  String get pleaseEnterSecret;

  /// No description provided for @invalidSecretFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid secret key format'**
  String get invalidSecretFormat;

  /// No description provided for @invalidUri.
  ///
  /// In en, this message translates to:
  /// **'Invalid URI'**
  String get invalidUri;

  /// No description provided for @authenticatorAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Authenticator already exists'**
  String get authenticatorAlreadyExists;

  /// No description provided for @advancedOptionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Advanced options (Type, Algorithm, Digits, Period) will be available in a future update.'**
  String get advancedOptionsComingSoon;

  /// No description provided for @tapToRevealHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToRevealHint;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreBackupComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Restore backup feature coming soon'**
  String get restoreBackupComingSoon;

  /// No description provided for @failedToPickFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file'**
  String get failedToPickFile;

  /// No description provided for @failedToProcessFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to process file'**
  String get failedToProcessFile;

  /// No description provided for @couldNotDetectFormat.
  ///
  /// In en, this message translates to:
  /// **'Could not detect backup format. Please select a format manually.'**
  String get couldNotDetectFormat;

  /// No description provided for @failedToParseQrCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse QR code'**
  String get failedToParseQrCode;

  /// No description provided for @havingIssue.
  ///
  /// In en, this message translates to:
  /// **'Having an issue? Report it here'**
  String get havingIssue;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @forkOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Fork on GitHub'**
  String get forkOnGithub;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send an Email'**
  String get sendEmail;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask Question?'**
  String get askQuestion;

  /// No description provided for @apacheLicense.
  ///
  /// In en, this message translates to:
  /// **'GNU GPL v3.0'**
  String get apacheLicense;

  /// No description provided for @changeIcon.
  ///
  /// In en, this message translates to:
  /// **'Change Icon'**
  String get changeIcon;

  /// No description provided for @leastUsed.
  ///
  /// In en, this message translates to:
  /// **'Least Used'**
  String get leastUsed;

  /// No description provided for @sortAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAZ;

  /// No description provided for @sortZA.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortZA;

  /// No description provided for @viewGuide.
  ///
  /// In en, this message translates to:
  /// **'View Guide'**
  String get viewGuide;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @guideStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Tap the + button to add a new authenticator'**
  String get guideStep1;

  /// No description provided for @guideStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Scan a QR code or enter the secret manually'**
  String get guideStep2;

  /// No description provided for @guideStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Your codes will be generated automatically'**
  String get guideStep3;

  /// No description provided for @guideStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Tap a code to copy it to clipboard'**
  String get guideStep4;

  /// No description provided for @guideStep5.
  ///
  /// In en, this message translates to:
  /// **'5. Use the menu to manage categories and settings'**
  String get guideStep5;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @viewStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get viewStandard;

  /// No description provided for @viewCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get viewCompact;

  /// No description provided for @viewTile.
  ///
  /// In en, this message translates to:
  /// **'Tile'**
  String get viewTile;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteCategoryConfirm(Object name);

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @changeSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Change Secret Key'**
  String get changeSecretKey;

  /// No description provided for @maxCharacters.
  ///
  /// In en, this message translates to:
  /// **'Max {count} characters'**
  String maxCharacters(Object count);

  /// No description provided for @motpSecretAlphanumeric.
  ///
  /// In en, this message translates to:
  /// **'mOTP secret must be alphanumeric'**
  String get motpSecretAlphanumeric;

  /// No description provided for @invalidBase32Format.
  ///
  /// In en, this message translates to:
  /// **'Invalid Base32 format'**
  String get invalidBase32Format;

  /// No description provided for @digitsRange.
  ///
  /// In en, this message translates to:
  /// **'6 ~ 10'**
  String get digitsRange;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get mustBePositive;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequired;

  /// No description provided for @assignCategories.
  ///
  /// In en, this message translates to:
  /// **'Specify categories'**
  String get assignCategories;

  /// No description provided for @noCategoriesCreate.
  ///
  /// In en, this message translates to:
  /// **'No categories. Create one first.'**
  String get noCategoriesCreate;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @removePassword.
  ///
  /// In en, this message translates to:
  /// **'Remove Password'**
  String get removePassword;

  /// No description provided for @changeOrRemovePassword.
  ///
  /// In en, this message translates to:
  /// **'Change or remove your app password'**
  String get changeOrRemovePassword;

  /// No description provided for @protectWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Protect your app with a password'**
  String get protectWithPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password set successfully'**
  String get passwordSetSuccess;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @newPasswordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'New password cannot be empty'**
  String get newPasswordCannotBeEmpty;

  /// No description provided for @confirmRemovePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to confirm removal.'**
  String get confirmRemovePassword;

  /// No description provided for @passwordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Password is incorrect'**
  String get passwordIncorrect;

  /// No description provided for @passwordRemoved.
  ///
  /// In en, this message translates to:
  /// **'Password removed'**
  String get passwordRemoved;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @encryptedBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Backup (.keebaup)'**
  String get encryptedBackupFile;

  /// No description provided for @passwordProtectedFile.
  ///
  /// In en, this message translates to:
  /// **'Password-protected encrypted file'**
  String get passwordProtectedFile;

  /// No description provided for @htmlFile.
  ///
  /// In en, this message translates to:
  /// **'HTML File'**
  String get htmlFile;

  /// No description provided for @humanReadableHtml.
  ///
  /// In en, this message translates to:
  /// **'Human-readable HTML table'**
  String get humanReadableHtml;

  /// No description provided for @uriList.
  ///
  /// In en, this message translates to:
  /// **'URI List'**
  String get uriList;

  /// No description provided for @plainTextUris.
  ///
  /// In en, this message translates to:
  /// **'Plain text otpauth:// URIs'**
  String get plainTextUris;

  /// No description provided for @enterPasswordEncrypt.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to encrypt the backup'**
  String get enterPasswordEncrypt;

  /// No description provided for @codeGroupSize.
  ///
  /// In en, this message translates to:
  /// **'Code Group Size'**
  String get codeGroupSize;

  /// No description provided for @digitsPerGroup.
  ///
  /// In en, this message translates to:
  /// **'{count} digits per group'**
  String digitsPerGroup(Object count);

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String secondsCount(Object count);

  /// No description provided for @minutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} minute(s)'**
  String minutesCount(Object count);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get appLocked;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock'**
  String get authenticateToUnlock;

  /// No description provided for @useBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get useBiometrics;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get mainMenu;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetails;

  /// No description provided for @gettingStartedGuide.
  ///
  /// In en, this message translates to:
  /// **'Getting started guide'**
  String get gettingStartedGuide;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup'**
  String get restoreBackup;

  /// No description provided for @backUp.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backUp;

  /// No description provided for @editCategories.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get editCategories;

  /// No description provided for @advancedWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get advancedWarningTitle;

  /// No description provided for @advancedWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Changing advanced settings (type, algorithm, digits, period) may cause your verification codes to become invalid. Only modify these if you know exactly what you are doing.\n\nIncorrect changes could lock you out of your accounts.'**
  String get advancedWarningMessage;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get iUnderstand;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating backup...'**
  String get creatingBackup;

  /// No description provided for @restoringBackup.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup...'**
  String get restoringBackup;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to'**
  String get exportedTo;

  /// No description provided for @autoBackupEnabled.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are active'**
  String get autoBackupEnabled;

  /// No description provided for @autoBackupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are off'**
  String get autoBackupDisabled;

  /// No description provided for @everyHour.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get everyHour;

  /// No description provided for @every6Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 6 hours'**
  String get every6Hours;

  /// No description provided for @every12Hours.
  ///
  /// In en, this message translates to:
  /// **'Every 12 hours'**
  String get every12Hours;

  /// No description provided for @every2Days.
  ///
  /// In en, this message translates to:
  /// **'Every 2 days'**
  String get every2Days;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @setBackupPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a password for automatic backups'**
  String get setBackupPasswordDescription;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric not supported on this device'**
  String get biometricNotAvailable;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'KeeAuth values your privacy.\n\n• All data is stored exclusively on your device\n• No personal information is collected or transmitted\n• No advertising or analytics SDKs\n• Camera is used only for QR code scanning'**
  String get privacyPolicyContent;

  /// No description provided for @privacyPolicyViewFull.
  ///
  /// In en, this message translates to:
  /// **'View Full Privacy Policy'**
  String get privacyPolicyViewFull;

  /// No description provided for @privacyPolicyAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get privacyPolicyAgree;

  /// No description provided for @privacyPolicyDisagree.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get privacyPolicyDisagree;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied — please open in browser'**
  String get linkCopied;

  /// No description provided for @externalLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'External Link'**
  String get externalLinkTitle;

  /// No description provided for @externalLinkContent.
  ///
  /// In en, this message translates to:
  /// **'You are about to open an external link in your browser.\n\n{url}'**
  String externalLinkContent(String url);

  /// No description provided for @externalLinkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get externalLinkConfirm;

  /// No description provided for @externalLinkCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get externalLinkCancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
