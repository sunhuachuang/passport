import 'dart:async';

// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'gallery_localizations_en.dart' deferred as gallery_localizations_en;
import 'gallery_localizations_zh.dart' deferred as gallery_localizations_zh;


/// Callers can lookup localized strings with an instance of GalleryLocalizations returned
/// by `GalleryLocalizations.of(context)`.
///
/// Applications need to include `GalleryLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/gallery_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GalleryLocalizations.localizationsDelegates,
///   supportedLocales: GalleryLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the GalleryLocalizations.supportedLocales
/// property.
abstract class GalleryLocalizations {
  GalleryLocalizations(String locale)
      : assert(locale != null),
        localeName = intl.Intl.canonicalizedLocale(locale.toString());

  // ignore: unused_field
  final String localeName;

  static GalleryLocalizations of(BuildContext context) {
    return Localizations.of<GalleryLocalizations>(
        context, GalleryLocalizations);
  }

  static const LocalizationsDelegate<GalleryLocalizations> delegate =
      _GalleryLocalizationsDelegate();

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
  String get settingsFeedback;
  String get settingsAttribution;
  // ---- End Settings menu page ------

  // A description about how to view the source code for this app.
  String aboutDialogDescription(Object repoLink);

  String get signIn;
  String get backToGallery;
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

  String get starterAppTitle;
  String get starterAppDescription;
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

class _GalleryLocalizationsDelegate
    extends LocalizationsDelegate<GalleryLocalizations> {
  const _GalleryLocalizationsDelegate();

  @override
  Future<GalleryLocalizations> load(Locale locale) {
    return _lookupGalleryLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'zh',
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_GalleryLocalizationsDelegate old) => false;
}

Future<GalleryLocalizations> _lookupGalleryLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
    {
      return gallery_localizations_en.loadLibrary().then((dynamic _) =>
        gallery_localizations_en.GalleryLocalizationsEn());
      }
    case 'zh':
    {
      return gallery_localizations_zh.loadLibrary().then((dynamic _) =>
        gallery_localizations_zh.GalleryLocalizationsZh());
      }
  }

  assert(false,
      'GalleryLocalizations.delegate failed to load unsupported locale "$locale"');
  return null;
}
