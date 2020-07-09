// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';

import '../constants.dart';
import '../l10n/localizations.dart';
import '../widgets/adaptive.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/profile_list_item.dart';
import '../models/profile.dart';
import '../models/app.dart';
import '../models/options.dart';

import 'settings.dart';
import 'splash.dart';

const _horizontalPadding = 32.0;
const _carouselItemMargin = 8.0;
const _horizontalDesktopPadding = 81.0;
const _carouselHeightMin = 200.0 + 2 * _carouselItemMargin;
const _desktopCardsPerPage = 4;

class ToggleSplashNotification extends Notification {}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var carouselHeight = _carouselHeight(.7, context);
    final isDesktop = isDisplayDesktop(context);
    final localizations = AsLocalizations.of(context);
    final apps = actived_apps(localizations);
    final carouselCards = apps.map((app) => _CarouselCard(app: app)).toList();

    if (isDesktop) {
      final desktopProfileItems = <_DesktopProfileItem>[
        _DesktopProfileItem(
          category: PrifleCategory.apps,
          asset: const AssetImage(
            'assets/icons/material/material.png',
            package: 'flutter_gallery_assets',
          ),
          items: profileApps(localizations),
        ),
        _DesktopProfileItem(
          category: PrifleCategory.network,
          asset: const AssetImage(
            'assets/icons/cupertino/cupertino.png',
            package: 'flutter_gallery_assets',
          ),
          items: profileNetwork(localizations),
        ),
        _DesktopProfileItem(
          category: PrifleCategory.accounts,
          asset: const AssetImage(
            'assets/icons/reference/reference.png',
            package: 'flutter_gallery_assets',
          ),
          items: profileAccounts(localizations),
        ),
      ];

      return Scaffold(
        body: ListView(
          // Makes integration tests possible.
          key: const ValueKey('HomeListView'),
          padding: EdgeInsetsDirectional.only(
            top: isDesktop ? firstHeaderDesktopTopPadding : 21,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalDesktopPadding,
              ),
              child: _AppHeader(),
            ),
            Container(
              height: carouselHeight,
              child: _DesktopCarousel(children: carouselCards),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalDesktopPadding,
              ),
              child: _ProfileHeader(),
            ),
            Container(
              height: 585,
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalDesktopPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: spaceBetween(28, desktopProfileItems),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: _horizontalDesktopPadding,
                bottom: 81,
                end: _horizontalDesktopPadding,
                top: 109,
              ),
              child: Row(
                children: [
                  FadeInImagePlaceholder(
                    image: Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? const AssetImage(
                            'assets/logo/flutter_logo.png',
                            package: 'flutter_gallery_assets',
                          )
                        : const AssetImage(
                            'assets/logo/flutter_logo_color.png',
                            package: 'flutter_gallery_assets',
                          ),
                    placeholder: const SizedBox.shrink(),
                    excludeFromSemantics: true,
                  ),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.end,
                      children: [
                        SettingsAbout(),
                        SettingsFeedback(),
                        SettingsAttribution(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: _AnimatedHomePage(
          isSplashPageAnimationFinished:
              SplashPageAnimation.of(context).isFinished,
          carouselCards: carouselCards,
        ),
      );
    }
  }

  List<Widget> spaceBetween(double paddingBetween, List<Widget> children) {
    return [
      for (int index = 0; index < children.length; index++) ...[
        Flexible(
          child: children[index],
        ),
        if (index < children.length - 1) SizedBox(width: paddingBetween),
      ],
    ];
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Header(
      color: Theme.of(context).colorScheme.primaryVariant,
      text: AsLocalizations.of(context).homeHeaderApps,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Header(
      color: Theme.of(context).colorScheme.primary,
      text: AsLocalizations.of(context).homeHeaderProfiles,
    );
  }
}

class Header extends StatelessWidget {
  const Header({this.color, this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isDisplayDesktop(context) ? 63 : 15,
        bottom: isDisplayDesktop(context) ? 21 : 11,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline4.apply(
              color: color,
              fontSizeDelta:
                  isDisplayDesktop(context) ? desktopDisplay1FontDelta : 0,
            ),
      ),
    );
  }
}

class _AnimatedHomePage extends StatefulWidget {
  const _AnimatedHomePage({
    Key key,
    @required this.carouselCards,
    @required this.isSplashPageAnimationFinished,
  }) : super(key: key);

  final List<Widget> carouselCards;
  final bool isSplashPageAnimationFinished;

  @override
  _AnimatedHomePageState createState() => _AnimatedHomePageState();
}

class _AnimatedHomePageState extends State<_AnimatedHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Timer _launchTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isSplashPageAnimationFinished) {
      // To avoid the animation from running when changing the window size from
      // desktop to mobile, we do not animate our widget if the
      // splash page animation is finished on initState.
      _animationController.value = 1.0;
    } else {
      // Start our animation halfway through the splash page animation.
      _launchTimer = Timer(
        const Duration(
          milliseconds: splashPageAnimationDurationInMilliseconds ~/ 2,
        ),
        () {
          _animationController.forward();
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _launchTimer?.cancel();
    _launchTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AsLocalizations.of(context);
    final isTestMode = AsOptions.of(context).isTestMode;
    return Stack(
      children: [
        ListView(
          // Makes integration tests possible.
          key: const ValueKey('HomeListView'),
          children: [
            const SizedBox(height: 8),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: _AppHeader(),
            ),
            _Carousel(
              children: widget.carouselCards,
              animationController: _animationController,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: _ProfileHeader(),
            ),
            _AnimatedProfileItem(
              startDelayFraction: 0.00,
              controller: _animationController,
              child: CategoryListItem(
                key: const PageStorageKey<PrifleCategory>(
                  PrifleCategory.apps,
                ),
                category: PrifleCategory.apps,
                imageString: 'assets/icons/material/material.png',
                items: profileApps(localizations),
                initiallyExpanded: isTestMode,
              ),
            ),
            _AnimatedProfileItem(
              startDelayFraction: 0.05,
              controller: _animationController,
              child: CategoryListItem(
                key: const PageStorageKey<PrifleCategory>(
                  PrifleCategory.network,
                ),
                category: PrifleCategory.network,
                imageString: 'assets/icons/cupertino/cupertino.png',
                items: profileNetwork(localizations),
                initiallyExpanded: isTestMode,
              ),
            ),
            _AnimatedProfileItem(
              startDelayFraction: 0.10,
              controller: _animationController,
              child: CategoryListItem(
                key: const PageStorageKey<PrifleCategory>(
                  PrifleCategory.accounts,
                ),
                category: PrifleCategory.accounts,
                imageString: 'assets/icons/reference/reference.png',
                items: profileAccounts(localizations),
                initiallyExpanded: isTestMode,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 200) {
                ToggleSplashNotification()..dispatch(context);
              }
            },
            child: SafeArea(
              child: Container(
                height: 40,
                // If we don't set the color, gestures are not detected.
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopProfileItem extends StatelessWidget {
  const _DesktopProfileItem({
    this.category,
    this.asset,
    this.items,
  });

  final PrifleCategory category;
  final ImageProvider asset;
  final List<ProfileModel> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surface,
      child: Semantics(
        container: true,
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Column(
            children: [
              _DesktopCategoryHeader(
                category: category,
                asset: asset,
              ),
              Divider(
                height: 2,
                thickness: 2,
                color: colorScheme.background,
              ),
              Flexible(
                child: ListView.builder(
                  // Makes integration tests possible.
                  key: ValueKey('${category.name}DemoList'),
                  itemBuilder: (context, index) =>
                      CategoryDemoItem(item: items[index]),
                  itemCount: items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopCategoryHeader extends StatelessWidget {
  const _DesktopCategoryHeader({
    this.category,
    this.asset,
  });
  final PrifleCategory category;
  final ImageProvider asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      // Makes integration tests possible.
      key: ValueKey('${category.name}CategoryHeader'),
      color: colorScheme.onBackground,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: FadeInImagePlaceholder(
              image: asset,
              placeholder: const SizedBox(
                height: 64,
                width: 64,
              ),
              width: 64,
              height: 64,
              excludeFromSemantics: true,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Semantics(
                header: true,
                child: Text(
                  category.displayTitle(AsLocalizations.of(context)),
                  style: Theme.of(context).textTheme.headline5.apply(
                        color: colorScheme.onSurface,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animates the category item to stagger in. The [_AnimatedProfileItem.startDelayFraction]
/// gives a delay in the unit of a fraction of the whole animation duration,
/// which is defined in [_AnimatedHomePageState].
class _AnimatedProfileItem extends StatelessWidget {
  _AnimatedProfileItem({
    Key key,
    double startDelayFraction,
    @required this.controller,
    @required this.child,
  })  : topPaddingAnimation = Tween(
          begin: 60.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000 + startDelayFraction,
              0.400 + startDelayFraction,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Widget child;
  final AnimationController controller;
  final Animation<double> topPaddingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(top: topPaddingAnimation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Animates the carousel to come in from the right.
class _AnimatedCarousel extends StatelessWidget {
  _AnimatedCarousel({
    Key key,
    @required this.child,
    @required this.controller,
  })  : startPositionAnimation = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.200,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Widget child;
  final AnimationController controller;
  final Animation<double> startPositionAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SizedBox(height: _carouselHeight(.4, context)),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return PositionedDirectional(
                start: constraints.maxWidth * startPositionAnimation.value,
                child: child,
              );
            },
            child: Container(
              height: _carouselHeight(.4, context),
              width: constraints.maxWidth,
              child: child,
            ),
          ),
        ],
      );
    });
  }
}

/// Animates a carousel card to come in from the right.
class _AnimatedCarouselCard extends StatelessWidget {
  _AnimatedCarouselCard({
    Key key,
    @required this.child,
    @required this.controller,
  })  : startPaddingAnimation = Tween(
          begin: _horizontalPadding,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.900,
              1.000,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Widget child;
  final AnimationController controller;
  final Animation<double> startPaddingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: startPaddingAnimation.value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({
    Key key,
    this.children,
    this.animationController,
  }) : super(key: key);

  final List<Widget> children;
  final AnimationController animationController;

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel>
    with SingleTickerProviderStateMixin {
  PageController _controller;
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      // The viewPortFraction is calculated as the width of the device minus the
      // padding.
      final width = MediaQuery.of(context).size.width;
      final padding = (_horizontalPadding * 2) - (_carouselItemMargin * 2);
      _controller = PageController(
        initialPage: _currentPage,
        viewportFraction: (width - padding) / width,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget builder(int index) {
    final carouselCard = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double value;
        if (_controller.position.haveDimensions) {
          value = _controller.page - index;
        } else {
          // If haveDimensions is false, use _currentPage to calculate value.
          value = (_currentPage - index).toDouble();
        }
        // We want the peeking cards to be 160 in height and 0.38 helps
        // achieve that.
        value = (1 - (value.abs() * .38)).clamp(0, 1).toDouble();
        value = Curves.easeOut.transform(value);

        return Center(
          child: Transform(
            transform: Matrix4.diagonal3Values(1.0, value, 1.0),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.children[index],
    );

    // We only want the second card to be animated.
    if (index == 1) {
      return _AnimatedCarouselCard(
        child: carouselCard,
        controller: widget.animationController,
      );
    } else {
      return carouselCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedCarousel(
      child: PageView.builder(
        // Makes integration tests possible.
        key: const ValueKey('studyDemoList'),
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        controller: _controller,
        itemCount: widget.children.length,
        itemBuilder: (context, index) => builder(index),
        allowImplicitScrolling: true,
      ),
      controller: widget.animationController,
    );
  }
}

/// This creates a horizontally scrolling [ListView] of items.
///
/// This class uses a [ListView] with a custom [ScrollPhysics] to enable
/// snapping behavior. A [PageView] was considered but does not allow for
/// multiple pages visible without centering the first page.
class _DesktopCarousel extends StatefulWidget {
  const _DesktopCarousel({Key key, this.children}) : super(key: key);

  final List<Widget> children;

  @override
  _DesktopCarouselState createState() => _DesktopCarouselState();
}

class _DesktopCarouselState extends State<_DesktopCarousel> {
  static const cardPadding = 15.0;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _builder(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: cardPadding,
      ),
      child: widget.children[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    var showPreviousButton = false;
    var showNextButton = true;
    // Only check this after the _controller has been attached to the ListView.
    if (_controller.hasClients) {
      showPreviousButton = _controller.offset > 0;
      showNextButton =
          _controller.offset < _controller.position.maxScrollExtent;
    }
    final totalWidth = MediaQuery.of(context).size.width -
        (_horizontalDesktopPadding - cardPadding) * 2;
    final itemWidth = totalWidth / _desktopCardsPerPage;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalDesktopPadding - cardPadding,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const _SnappingScrollPhysics(),
            controller: _controller,
            itemExtent: itemWidth,
            itemCount: widget.children.length,
            itemBuilder: (context, index) => _builder(index),
          ),
        ),
        if (showPreviousButton)
          _DesktopPageButton(
            onTap: () {
              _controller.animateTo(
                _controller.offset - itemWidth,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
        if (showNextButton)
          _DesktopPageButton(
            isEnd: true,
            onTap: () {
              _controller.animateTo(
                _controller.offset + itemWidth,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
      ],
    );
  }
}

/// Scrolling physics that snaps to the new item in the [_DesktopCarousel].
class _SnappingScrollPhysics extends ScrollPhysics {
  const _SnappingScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  _SnappingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _SnappingScrollPhysics(parent: buildParent(ancestor));
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final itemWidth = position.viewportDimension / _desktopCardsPerPage;
    var item = position.pixels / itemWidth;
    if (velocity < -tolerance.velocity) {
      item -= 0.5;
    } else if (velocity > tolerance.velocity) {
      item += 0.5;
    }
    return math.min(
      item.roundToDouble() * itemWidth,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = this.tolerance;
    final target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => true;
}

class _DesktopPageButton extends StatelessWidget {
  const _DesktopPageButton({
    Key key,
    this.isEnd = false,
    this.onTap,
  }) : super(key: key);

  final bool isEnd;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final buttonSize = 58.0;
    final padding = _horizontalDesktopPadding - buttonSize / 2;
    return ExcludeSemantics(
      child: Align(
        alignment: isEnd
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          margin: EdgeInsetsDirectional.only(
            start: isEnd ? 0 : padding,
            end: isEnd ? padding : 0,
          ),
          child: Tooltip(
            message: isEnd
                ? MaterialLocalizations.of(context).nextPageTooltip
                : MaterialLocalizations.of(context).previousPageTooltip,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Icon(
                  isEnd ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    Key key,
    this.app,
  }) : super(key: key);

  final AppModel app;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final asset = isDark ? app.assetDark : app.asset;
    final assetColor = isDark ? app.assetDarkColor : app.assetColor;
    final textColor = isDark ? Colors.white.withOpacity(0.87) : app.textColor;

    return Container(
      // Makes integration tests possible.
      key: ValueKey(app.describe),
      margin:
          EdgeInsets.all(isDisplayDesktop(context) ? 0 : _carouselItemMargin),
      child: Material(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(app.route);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (asset != null)
                FadeInImagePlaceholder(
                  image: asset,
                  child: Ink.image(
                    image: asset,
                    fit: BoxFit.cover,
                  ),
                  placeholder: Container(
                    color: assetColor,
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      app.title,
                      style: textTheme.caption.apply(color: textColor),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      app.subtitle,
                      style: textTheme.overline.apply(color: textColor),
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _carouselHeight(double scaleFactor, BuildContext context) => math.max(
    _carouselHeightMin *
        AsOptions.of(context).textScaleFactor(context) *
        scaleFactor,
    _carouselHeightMin);

/// Wrap the apps with this to display a back button and allow the user to
/// exit them at any time.
class AppWrapper extends StatefulWidget {
  const AppWrapper({
    Key key,
    this.study,
  }) : super(key: key);

  final Widget study;

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ApplyTextOptions(
      child: Stack(
        children: [
          Semantics(
            sortKey: const OrdinalSortKey(1),
            child: widget.study,
          ),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                sortKey: const OrdinalSortKey(0),
                label: AsLocalizations.of(context).backToAssassin,
                button: true,
                excludeSemantics: true,
                child: FloatingActionButton.extended(
                  key: const ValueKey('Back'),
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.settings.name == '/');
                  },
                  icon: IconTheme(
                    data: IconThemeData(color: colorScheme.onPrimary),
                    child: const BackButtonIcon(),
                  ),
                  label: Text(
                    MaterialLocalizations.of(context).backButtonTooltip,
                    style: textTheme.button.apply(color: colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
