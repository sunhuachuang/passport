// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'gallery_localizations.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for English (`en`).
class GalleryLocalizationsEn extends GalleryLocalizations {
  GalleryLocalizationsEn([String locale = 'en']) : super(locale);

  // Common

  // ---- Home page --------
  @override
  String get homeHeaderApps => 'Apps';
  @override
  String get homeHeaderProfiles => 'Profiles';

  @override
  String get homeProfileApp => 'Applications';
  @override
  String get homeProfileNetwork => 'Network';
  @override
  String get homeProfileAccount => 'Accounts';
  // ---- End Home page ----

  // ---- Settings menu page --------
  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsButtonLabel => 'Settings';
  @override
  String get settingsButtonCloseLabel => 'Close settings';
  @override
  String get settingsSystemDefault => 'System';
  @override
  String get settingsTextScaling => 'Text scaling';
  @override
  String get settingsTextScalingSmall => 'Small';
  @override
  String get settingsTextScalingNormal => 'Normal';
  @override
  String get settingsTextScalingLarge => 'Large';
  @override
  String get settingsTextScalingHuge => 'Huge';
  @override
  String get settingsTextDirection => 'Text direction';
  @override
  String get settingsTextDirectionLocaleBased => 'Based on locale';
  @override
  String get settingsTextDirectionLTR => 'LTR';
  @override
  String get settingsTextDirectionRTL => 'RTL';
  @override
  String get settingsLocale => 'Locale';
  @override
  String get settingsPlatformMechanics => 'Platform mechanics';
  @override
  String get settingsTheme => 'Theme';
  @override
  String get settingsDarkTheme => 'Dark';
  @override
  String get settingsLightTheme => 'Light';
  @override
  String get settingsSlowMotion => 'Slow motion';
  @override
  String get settingsAbout => 'About Assassin';
  @override
  String get settingsFeedback => 'Send feedback';
  @override
  String get settingsAttribution => 'Designed & implemented by CypherLink';
  // ---- End Settings menu page --------

  @override
  String aboutDialogDescription(Object repoLink) {
    return 'To see the source code for this app, please visit the ${repoLink}.';
  }

  @override
  String get signIn => 'SIGN IN';
  @override
  String get dismiss => 'DISMISS';
  @override
  String get backToGallery => 'Back to Assassin';

  @override
  String get demoInvalidURL => 'Couldn\'t display URL:';
  @override
  String get demoOptionsTooltip => 'Options';
  @override
  String get demoInfoTooltip => 'Info';
  @override
  String get demoCodeTooltip => 'Demo Code';
  @override
  String get demoDocumentationTooltip => 'API Documentation';
  @override
  String get demoFullscreenTooltip => 'Full Screen';
  @override
  String get demoCodeViewerCopyAll => 'COPY ALL';
  @override
  String get demoCodeViewerCopiedToClipboardMessage => 'Copied to clipboard.';
  @override
  String demoCodeViewerFailedToCopyToClipboardMessage(Object error) {
    return 'Failed to copy to clipboard: ${error}';
  }
  @override
  String get demoOptionsFeatureTitle => 'View options';
  @override
  String get demoOptionsFeatureDescription =>
  'Tap here to view available options for this demo.';

  @override
  String get demoBannerTitle => 'Banner';
  @override
  String get demoBannerSubtitle => 'Displaying a banner within a list';
  @override
  String get demoBannerDescription =>
  'A banner displays an important, succinct message, and provides actions for users to address (or dismiss the banner). A user action is required for it to be dismissed.';

  @override
  String get bannerDemoText => 'banner';
  @override
  String get bannerDemoResetText => 'Reset';
  @override
  String get bannerDemoMultipleText => 'Multiple';
  @override
  String get bannerDemoLeadingText => 'Leading';

  @override
  String get starterAppTitle => 'Starter app';
  @override
  String get starterAppDescription => 'A responsive starter layout';
  @override
  String get starterAppGenericButton => 'BUTTON';
  @override
  String get starterAppTooltipAdd => 'Add';
  @override
  String get starterAppTooltipFavorite => 'Favorite';
  @override
  String get starterAppTooltipShare => 'Share';
  @override
  String get starterAppTooltipSearch => 'Search';
  @override
  String get starterAppGenericTitle => 'Title';
  @override
  String get starterAppGenericSubtitle => 'Subtitle';
  @override
  String get starterAppGenericHeadline => 'Headline';
  @override
  String get starterAppGenericBody => 'Body';
  @override
  String starterAppDrawerItem(Object value) {
    return 'Item ${value}';
  }
}
