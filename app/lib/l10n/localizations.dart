import 'dart:async';

// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_en.dart' deferred as localizations_en;
import 'localizations_zh.dart' deferred as localizations_zh;


/// Callers can lookup localized strings with an instance of AsLocalizations returned
/// by `AsLocalizations.of(context)`.
///
/// Applications need to include `AsLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AsLocalizations.localizationsDelegates,
///   supportedLocales: AsLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: 0.16.1
///
///   # rest of dependencies
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
/// be consistent with the languages listed in the AsLocalizations.supportedLocales
/// property.
abstract class AsLocalizations {
  AsLocalizations(String locale)
      : assert(locale != null),
        localeName = intl.Intl.canonicalizedLocale(locale.toString());

  // ignore: unused_field
  final String localeName;

  static AsLocalizations of(BuildContext context) {
    return Localizations.of<AsLocalizations>(
        context, AsLocalizations);
  }

  static const LocalizationsDelegate<AsLocalizations> delegate =
      _AsLocalizationsDelegate();

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
  ];

  // Common
  String get cancel;
  String get start;
  String get stop;

  // ---- Home page --------
  String get homeHeaderApps;
  String get homeHeaderProfiles;

  String get homeProfileApp;
  String get homeProfileNetwork;
  String get homeProfileAccount;
  // ---- End Home page ----

  // ---- Settings menu page --------
  String get settingsTitle;
  String get settingsButtonLabel;
  String get settingsButtonCloseLabel;
  String get settingsSystemDefault;
  String get settingsTextScaling;
  String get settingsTextScalingSmall;
  String get settingsTextScalingNormal;
  String get settingsTextScalingLarge;
  String get settingsTextScalingHuge;
  String get settingsTextDirection;
  String get settingsTextDirectionLocaleBased;
  String get settingsTextDirectionLTR;
  String get settingsTextDirectionRTL;
  String get settingsLocale;
  String get settingsPlatformMechanics;
  String get settingsTheme;
  String get settingsDarkTheme;
  String get settingsLightTheme;
  String get settingsSlowMotion;
  String get settingsAbout;
  String get settingsAttribution;
  String aboutDialogDescription(Object repoLink);
  // ---- End Settings menu page ------

  // ---- bulit-in apps -----
  String get yuTitle;
  String get yuDescription;
  String get docsTitle;
  String get docsDescription;
  String get healthTitle;
  String get healthDescription;
  String get remindersTitle;
  String get remindersDescription;
  String get starterAppTitle;
  String get starterAppDescription;
  // ---- end bulit-in apps--

  // ---- profile -----
  String get devicesInfo;
  String get p2pNetwork;
  String get addBoostrap;
  String get changeNode;
  String get addAccount;
  String get chooseAccount;
  String get chooseAccountRun;
  String get noAccountRun;
  // ---- end profile--

  // ---- Yu -----
  String get yuAppWelcome;
  String get yuAppFriendInfo;
  String get yuAppScanAddFriend;

  // ---- End Yu--

  // ---- Docs -----

  // ---- End Docs--

  String get signIn;
  String get backToAssassin;
  String get dismiss;

  String get demoInvalidURL;
  String get demoOptionsTooltip;
  String get demoInfoTooltip;
  String get demoCodeTooltip;
  String get demoDocumentationTooltip;
  String get demoFullscreenTooltip;
  String get demoCodeViewerCopyAll;
  String get demoCodeViewerCopiedToClipboardMessage;
  String demoCodeViewerFailedToCopyToClipboardMessage(Object error);
  String get demoOptionsFeatureTitle;
  String get demoOptionsFeatureDescription;

  String get demoBannerTitle;
  String get demoBannerSubtitle;
  String get demoBannerDescription;

  String get bannerDemoText;
  String get bannerDemoResetText;
  String get bannerDemoMultipleText;
  String get bannerDemoLeadingText;

  String get starterAppGenericButton;
  String get starterAppTooltipAdd;
  String get starterAppTooltipFavorite;
  String get starterAppTooltipShare;
  String get starterAppTooltipSearch;
  String get starterAppGenericTitle;
  String get starterAppGenericSubtitle;
  String get starterAppGenericHeadline;
  String get starterAppGenericBody;
  String starterAppDrawerItem(Object value);
}

class _AsLocalizationsDelegate
    extends LocalizationsDelegate<AsLocalizations> {
  const _AsLocalizationsDelegate();

  @override
  Future<AsLocalizations> load(Locale locale) {
    return _lookupAsLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'zh',
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AsLocalizationsDelegate old) => false;
}

Future<AsLocalizations> _lookupAsLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
    {
      return localizations_en.loadLibrary().then((dynamic _) =>
        localizations_en.AsLocalizationsEn());
      }
    case 'zh':
    {
      return localizations_zh.loadLibrary().then((dynamic _) =>
        localizations_zh.AsLocalizationsZh());
      }
  }

  assert(false,
      'AsLocalizations.delegate failed to load unsupported locale "$locale"');
  return null;
}
