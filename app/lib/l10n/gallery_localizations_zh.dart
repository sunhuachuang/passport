// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'gallery_localizations.dart';

// ignore_for_file: unnecessary_brace_in_string_interps

/// The translations for Chinese (`zh`).
class GalleryLocalizationsZh extends GalleryLocalizations {
  GalleryLocalizationsZh([String locale = 'zh']) : super(locale);

  // Common

  // ---- Home page --------
  @override
  String get homeHeaderApps => '应用';
  @override
  String get homeHeaderProfiles => '配置';

  @override
  String get homeProfileApp => '应用列表';
  @override
  String get homeProfileNetwork => '网络管理';
  @override
  String get homeProfileAccount => '个人账户';
  // ---- End Home page ----

  // ---- Settings menu page --------
  @override
  String get settingsTitle => '设置';
  @override
  String get settingsButtonLabel => '设置';
  @override
  String get settingsButtonCloseLabel => '关闭设置';
  @override
  String get settingsSystemDefault => '系统';
  @override
  String get settingsTextScaling => '文字缩放';
  @override
  String get settingsTextScalingSmall => '小';
  @override
  String get settingsTextScalingNormal => '正常';
  @override
  String get settingsTextScalingLarge => '大';
  @override
  String get settingsTextScalingHuge => '超大';
  @override
  String get settingsTextDirection => '文本方向';
  @override
  String get settingsTextDirectionLocaleBased => '根据语言区域';
  @override
  String get settingsTextDirectionLTR => '从左到右';
  @override
  String get settingsTextDirectionRTL => '从右到左';
  @override
  String get settingsLocale => '语言区域';
  @override
  String get settingsPlatformMechanics => '平台力学';
  @override
  String get settingsTheme => '主题背景';
  @override
  String get settingsDarkTheme => '深色';
  @override
  String get settingsLightTheme => '浅色';
  @override
  String get settingsSlowMotion => '慢镜头';
  @override
  String get settingsAbout => '关于 Assassin';
  @override
  String get settingsFeedback => '发送反馈';
  @override
  String get settingsAttribution => '由 CypherLink 团队设计实现';
  // ---- End Settings menu page ------

  @override
  String aboutDialogDescription(Object repoLink) {
    return '要查看此应用的源代码，请访问 ${repoLink}。';
  }

  @override
  String get signIn => '登录';

  @override
  String get dismiss => '关闭';

  @override
  String get backToGallery => '返回 Flutter Gallery';

  @override
  String get demoInvalidURL => '无法显示网址。';
  @override
  String get demoOptionsTooltip => '选项';
  @override
  String get demoInfoTooltip => '信息';
  @override
  String get demoCodeTooltip => '演示代码';
  @override
  String get demoDocumentationTooltip => 'API 文档';
  @override
  String get demoFullscreenTooltip => '全屏';
  @override
  String get demoCodeViewerCopyAll => '全部复制';
  @override
  String get demoCodeViewerCopiedToClipboardMessage => '已复制到剪贴板。';
  @override
  String demoCodeViewerFailedToCopyToClipboardMessage(Object error) {
    return '未能复制到剪贴板：${error}';
  }
  @override
  String get demoOptionsFeatureTitle => '查看选项';
  @override
  String get demoOptionsFeatureDescription => '点按此处即可查看此演示可用的选项。';

  @override
  String get demoBannerTitle => '横幅';
  @override
  String get demoBannerSubtitle => '在列表内显示横幅';
  @override
  String get demoBannerDescription =>
  '横幅显示简明的重要信息，并提供相应操作供用户执行（或关闭横幅）。横幅需要用户手动关闭。';

  @override
  String get bannerDemoText => 'banner';
  @override
  String get bannerDemoResetText => 'Reset';
  @override
  String get bannerDemoMultipleText => 'Multiple';
  @override
  String get bannerDemoLeadingText => 'Leading';

  @override
  String get starterAppTitle => '入门应用';

  @override
  String get starterAppDescription => '自适应入门布局';

  @override
  String get starterAppGenericButton => '按钮';

  @override
  String get starterAppTooltipAdd => '添加';

  @override
  String get starterAppTooltipFavorite => '收藏';

  @override
  String get starterAppTooltipShare => '分享';

  @override
  String get starterAppTooltipSearch => '搜索';

  @override
  String get starterAppGenericTitle => '标题';

  @override
  String get starterAppGenericSubtitle => '副标题';

  @override
  String get starterAppGenericHeadline => '标题';

  @override
  String get starterAppGenericBody => '正文';

  @override
  String starterAppDrawerItem(Object value) {
    return '项 ${value}';
  }
}
