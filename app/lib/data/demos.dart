// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show describeEnum;
import 'package:flutter/material.dart';

import '../codeviewer/code_displayer.dart';
import '../codeviewer/code_segments.dart';

import '../profiles/banner_demo.dart';

import '../l10n/gallery_localizations.dart';
import '../l10n/gallery_localizations_en.dart' show GalleryLocalizationsEn;
import '../themes/material_demo_theme_data.dart';

import 'gallery_options.dart';
import 'icons.dart';

const _docsBaseUrl = 'https://api.flutter.dev/flutter';

enum GalleryDemoCategory {
  study,
  material,
  cupertino,
  other,
}

extension GalleryDemoExtension on GalleryDemoCategory {
  String get name => describeEnum(this);

  String displayTitle(GalleryLocalizations localizations) {
    switch (this) {
      case GalleryDemoCategory.material:
        return localizations.homeProfileApp;
      case GalleryDemoCategory.cupertino:
        return localizations.homeProfileNetwork;
      case GalleryDemoCategory.other:
        return localizations.homeProfileAccount;
      case GalleryDemoCategory.study:
    }
    return null;
  }
}

class GalleryDemo {
  const GalleryDemo({
    @required this.title,
    @required this.category,
    @required this.subtitle,
    // This parameter is required for studies.
    this.studyId,
    // Parameters below are required for non-study demos.
    this.slug,
    this.icon,
    this.configurations,
  })  : assert(title != null),
        assert(category != null),
        assert(subtitle != null),
        assert(category == GalleryDemoCategory.study ||
            (slug != null && icon != null && configurations != null)),
        assert(slug != null || studyId != null);

  final String title;
  final GalleryDemoCategory category;
  final String subtitle;
  final String studyId;
  final String slug;
  final IconData icon;
  final List<GalleryDemoConfiguration> configurations;

  String get describe => '${slug ?? studyId}@${category.name}';
}

class GalleryDemoConfiguration {
  const GalleryDemoConfiguration({
    this.title,
    this.description,
    this.documentationUrl,
    this.buildRoute,
    this.code,
  });

  final String title;
  final String description;
  final String documentationUrl;
  final WidgetBuilder buildRoute;
  final CodeDisplayer code;
}

List<GalleryDemo> allGalleryDemos(GalleryLocalizations localizations) =>
    studies(localizations).values.toList() +
    materialDemos(localizations) +
    cupertinoDemos(localizations) +
    otherDemos(localizations);

List<String> allGalleryDemoDescriptions() =>
    allGalleryDemos(GalleryLocalizationsEn())
        .map((demo) => demo.describe)
        .toList();

Map<String, GalleryDemo> studies(GalleryLocalizations localizations) {
  return <String, GalleryDemo>{
    'shrine': GalleryDemo(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      category: GalleryDemoCategory.study,
      studyId: 'shrine',
    ),
    'rally': GalleryDemo(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      category: GalleryDemoCategory.study,
      studyId: 'rally',
    ),
    'crane': GalleryDemo(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      category: GalleryDemoCategory.study,
      studyId: 'crane',
    ),
    'fortnightly': GalleryDemo(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      category: GalleryDemoCategory.study,
      studyId: 'fortnightly',
    ),
    'starterApp': GalleryDemo(
      title: localizations.starterAppTitle,
      subtitle: localizations.starterAppDescription,
      category: GalleryDemoCategory.study,
      studyId: 'starter',
    ),
  };
}

List<GalleryDemo> materialDemos(GalleryLocalizations localizations) {
  return [
    GalleryDemo(
      title: localizations.demoBannerTitle,
      icon: GalleryIcons.listsLeaveBehind,
      slug: 'banner',
      subtitle: localizations.demoBannerSubtitle,
      configurations: [
        GalleryDemoConfiguration(
          title: localizations.demoBannerTitle,
          description: localizations.demoBannerDescription,
          documentationUrl: '$_docsBaseUrl/material/MaterialBanner-class.html',
          buildRoute: (_) => const BannerDemo(),
          code: CodeSegments.bannerDemo,
        ),
      ],
      category: GalleryDemoCategory.material,
    ),
  ];
}

List<GalleryDemo> cupertinoDemos(GalleryLocalizations localizations) {
  return [
    GalleryDemo(
      title: localizations.demoBannerTitle,
      icon: GalleryIcons.listsLeaveBehind,
      slug: 'banner',
      subtitle: localizations.demoBannerSubtitle,
      configurations: [
        GalleryDemoConfiguration(
          title: localizations.demoBannerTitle,
          description: localizations.demoBannerDescription,
          documentationUrl: '$_docsBaseUrl/material/MaterialBanner-class.html',
          buildRoute: (_) => const BannerDemo(),
          code: CodeSegments.bannerDemo,
        ),
      ],
      category: GalleryDemoCategory.material,
    ),
  ];
}

List<GalleryDemo> otherDemos(GalleryLocalizations localizations) {
  return [
    GalleryDemo(
      title: localizations.demoBannerTitle,
      icon: GalleryIcons.listsLeaveBehind,
      slug: 'banner',
      subtitle: localizations.demoBannerSubtitle,
      configurations: [
        GalleryDemoConfiguration(
          title: localizations.demoBannerTitle,
          description: localizations.demoBannerDescription,
          documentationUrl: '$_docsBaseUrl/material/MaterialBanner-class.html',
          buildRoute: (_) => const BannerDemo(),
          code: CodeSegments.bannerDemo,
        ),
      ],
      category: GalleryDemoCategory.material,
    ),
  ];
}

Map<String, GalleryDemo> slugToDemo(BuildContext context) {
  final localizations = GalleryLocalizations.of(context);
  return LinkedHashMap<String, GalleryDemo>.fromIterable(
    allGalleryDemos(localizations),
    key: (dynamic demo) => demo.slug as String,
  );
}

class DemoWrapper extends StatelessWidget {
  const DemoWrapper({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MaterialDemoThemeData.themeData.copyWith(
        platform: GalleryOptions.of(context).platform,
      ),
      child: ApplyTextOptions(
        child: CupertinoTheme(
          data:
              const CupertinoThemeData().copyWith(brightness: Brightness.light),
          child: child,
        ),
      ),
    );
  }
}
