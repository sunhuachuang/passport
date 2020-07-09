// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../l10n/localizations.dart';
import '../widgets/adaptive.dart';

class CategoryListItem extends StatefulWidget {
  const CategoryListItem({
    Key key,
    this.category,
    this.imageString,
    this.items = const [],
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  final PrifleCategory category;
  final String imageString;
  final List<ProfileModel> items;
  final bool initiallyExpanded;

  @override
  _CategoryListItemState createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static const _expandDuration = Duration(milliseconds: 200);
  AnimationController _controller;
  Animation<double> _childrenHeightFactor;
  Animation<double> _headerChevronOpacity;
  Animation<double> _headerHeight;
  Animation<EdgeInsetsGeometry> _headerMargin;
  Animation<EdgeInsetsGeometry> _headerImagePadding;
  Animation<EdgeInsetsGeometry> _childrenPadding;
  Animation<BorderRadius> _headerBorderRadius;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _expandDuration, vsync: this);
    _childrenHeightFactor = _controller.drive(_easeInTween);
    _headerChevronOpacity = _controller.drive(_easeInTween);
    _headerHeight = Tween<double>(
      begin: 80,
      end: 96,
    ).animate(_controller);
    _headerMargin = EdgeInsetsGeometryTween(
      begin: const EdgeInsets.fromLTRB(32, 8, 32, 8),
      end: EdgeInsets.zero,
    ).animate(_controller);
    _headerImagePadding = EdgeInsetsGeometryTween(
      begin: const EdgeInsets.all(8),
      end: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
    ).animate(_controller);
    _childrenPadding = EdgeInsetsGeometryTween(
      begin: const EdgeInsets.symmetric(horizontal: 32),
      end: EdgeInsets.zero,
    ).animate(_controller);
    _headerBorderRadius = BorderRadiusTween(
      begin: BorderRadius.circular(10),
      end: BorderRadius.zero,
    ).animate(_controller);

    _isExpanded = PageStorage.of(context)?.readState(context) as bool ??
        widget.initiallyExpanded;
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((value) {
          if (!mounted) {
            return;
          }
          setState(() {
            // Rebuild without widget.demos.
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildHeaderWithChildren(BuildContext context, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CategoryHeader(
          margin: _headerMargin.value,
          imagePadding: _headerImagePadding.value,
          borderRadius: _headerBorderRadius.value,
          height: _headerHeight.value,
          chevronOpacity: _headerChevronOpacity.value,
          imageString: widget.imageString,
          category: widget.category,
          onTap: _handleTap,
        ),
        Padding(
          padding: _childrenPadding.value,
          child: ClipRect(
            child: Align(
              heightFactor: _childrenHeightFactor.value,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildHeaderWithChildren,
      child: closed
          ? null
          : _ExpandedCategoryDemos(
              category: widget.category,
              items: widget.items,
            ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    Key key,
    this.margin,
    this.imagePadding,
    this.borderRadius,
    this.height,
    this.chevronOpacity,
    this.imageString,
    this.category,
    this.onTap,
  }) : super(key: key);

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry imagePadding;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final String imageString;
  final PrifleCategory category;
  final double chevronOpacity;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: colorScheme.onBackground,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: InkWell(
            // Makes integration tests possible.
            key: ValueKey('${category.name}CategoryHeader'),
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: imagePadding,
                        child: ExcludeSemantics(
                          child: Image.asset(
                            imageString,
                            width: 64,
                            height: 64,
                            package: 'flutter_gallery_assets',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: Text(
                          category.displayTitle(
                            AsLocalizations.of(context),
                          ),
                          style: Theme.of(context).textTheme.headline5.apply(
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: chevronOpacity,
                  child: chevronOpacity != 0
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8,
                            end: 32,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: colorScheme.onSurface,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedCategoryDemos extends StatelessWidget {
  const _ExpandedCategoryDemos({
    Key key,
    this.category,
    this.items,
  }) : super(key: key);

  final PrifleCategory category;
  final List<ProfileModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Makes integration tests possible.
      key: ValueKey('${category.name}DemoList'),
      children: [
        for (final item in items)
          CategoryDemoItem(
            item: item,
          ),
        const SizedBox(height: 12), // Extra space below.
      ],
    );
  }
}

class CategoryDemoItem extends StatelessWidget {
  const CategoryDemoItem({Key key, this.item}) : super(key: key);

  final ProfileModel item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      // Makes integration tests possible.
      key: ValueKey(item.describe),
      color: Theme.of(context).colorScheme.surface,
      child: MergeSemantics(
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(item.route);
          },
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: 32,
              top: 20,
              end: isDisplayDesktop(context) ? 16 : 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 40),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: textTheme.subtitle1
                            .apply(color: colorScheme.onSurface),
                      ),
                      if (item.subtitle != null)
                      Text(
                        item.subtitle,
                        style: textTheme.overline.apply(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        thickness: 1,
                        height: 1,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
