import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/design_system/design_system.dart';
import 'app_brand.dart';
import 'app_theme_controller.dart';

/// Estrutura de navegação compartilhada pelas telas principais.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth <= 620;
      final condensed = !compact && constraints.maxWidth <= 900;
      return FocusTraversalGroup(
        child: Scaffold(
          bottomNavigationBar: compact
              ? _CompactNavigation(
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _select,
                )
              : null,
          body: Row(
            children: [
              if (!compact)
                _IconRail(
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _select,
                  condensed: condensed,
                ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    },
  );
}

@immutable
class _AppDestination {
  const _AppDestination({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _IconRail extends StatelessWidget {
  const _IconRail({
    required this.selectedIndex,
    required this.onSelected,
    required this.condensed,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool condensed;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);
    return Container(
      width: condensed ? 80 : context.tokens.layout.iconRailWidth,
      decoration: BoxDecoration(
        color: context.tokens.colors.surface,
        border: Border(right: BorderSide(color: context.tokens.colors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(condensed ? 0 : 20, 16, condensed ? 0 : 20, 8),
              child: _BrandMark(showLabel: !condensed),
            ),
            const AppDivider(margin: EdgeInsets.zero),
            SizedBox(height: context.tokens.spacing.md),
            for (var index = 0; index < destinations.length; index++)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.tokens.spacing.sm,
                  vertical: context.tokens.spacing.xxxs,
                ),
                child: _RailDestination(
                  key: ValueKey('shell-destination-$index'),
                  destination: destinations[index],
                  selected: selectedIndex == index,
                  condensed: condensed,
                  onPressed: () => onSelected(index),
                ),
              ),
            const Spacer(),
            const AppDivider(margin: EdgeInsets.zero),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.md),
              child: _AppearanceMenuButton(showLabel: !condensed),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.colors.surface,
        border: Border(top: BorderSide(color: context.tokens.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
            child: Row(
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _CompactDestination(
                      key: ValueKey('shell-destination-$index'),
                      destination: destinations[index],
                      selected: selectedIndex == index,
                      onPressed: () => onSelected(index),
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

class _CompactDestination extends StatelessWidget {
  const _CompactDestination({
    required this.destination,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final _AppDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: destination.label,
    excludeSemantics: true,
    child: Material(
      color: context.tokens.colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.tokens.borders.lg,
        child: AnimatedContainer(
          duration: context.motionDuration(context.tokens.motion.fast),
          decoration: BoxDecoration(
            color: selected ? context.tokens.colors.surfaceSubtle : context.tokens.colors.transparent,
            borderRadius: context.tokens.borders.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 20,
                color: selected ? context.tokens.colors.onSurface : context.tokens.colors.onSurfaceMuted,
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: selected
                    ? context.tokens.typography.navigationCompactLabel
                    : context.tokens.typography.navigationCompactLabelMuted,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.showLabel});

  final bool showLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      mainAxisAlignment: showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppBrand.appIcon,
          width: 32,
          height: 32,
          semanticsLabel: AppBrand.productName,
        ),
        if (showLabel) ...[
          const SizedBox(width: 11),
          Text(
            'Prumo',
            style: context.tokens.typography.navigationBrand,
          ),
        ],
      ],
    ),
  );
}

class _RailDestination extends StatefulWidget {
  const _RailDestination({
    required this.destination,
    required this.selected,
    required this.condensed,
    required this.onPressed,
    super.key,
  });

  final _AppDestination destination;
  final bool selected;
  final bool condensed;
  final VoidCallback onPressed;

  @override
  State<_RailDestination> createState() => _RailDestinationState();
}

class _RailDestinationState extends State<_RailDestination> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: widget.selected,
    button: true,
    label: widget.destination.label,
    onTap: widget.onPressed,
    excludeSemantics: true,
    child: Material(
      color: context.tokens.colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        borderRadius: context.tokens.borders.lg,
        overlayColor: WidgetStatePropertyAll(context.tokens.colors.transparent),
        child: AnimatedScale(
          scale: _pressed && !context.reduceMotion ? .98 : 1,
          duration: context.motionDuration(context.tokens.motion.fast),
          child: AnimatedContainer(
            duration: context.motionDuration(context.tokens.motion.fast),
            constraints: BoxConstraints(minHeight: context.tokens.layout.inputHeight),
            padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.md),
            decoration: BoxDecoration(
              color: widget.selected ? context.tokens.colors.surfaceSubtle : context.tokens.colors.transparent,
              borderRadius: context.tokens.borders.lg,
            ),
            child: Row(
              mainAxisAlignment: widget.condensed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.selected ? widget.destination.selectedIcon : widget.destination.icon,
                  size: context.tokens.icons.md,
                  color: widget.selected ? context.tokens.colors.onSurface : context.tokens.colors.onSurfaceMuted,
                ),
                if (!widget.condensed) ...[
                  SizedBox(width: context.tokens.spacing.md),
                  Expanded(
                    child: Text(
                      widget.destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.selected
                          ? context.tokens.typography.navigationLabel
                          : context.tokens.typography.navigationLabelMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

enum _AppearanceChoice { system, light, dark }

class _AppearanceMenuButton extends StatelessWidget {
  const _AppearanceMenuButton({this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);
    final items = [
      AppMenuItem(
        value: _AppearanceChoice.system,
        label: context.l10n.followSystemTheme,
        icon: controller.value == ThemeMode.system ? AppIcons.check : null,
      ),
      AppMenuItem(
        value: _AppearanceChoice.light,
        label: context.l10n.lightTheme,
        icon: controller.value == ThemeMode.light ? AppIcons.check : AppIcons.sun,
      ),
      AppMenuItem(
        value: _AppearanceChoice.dark,
        label: context.l10n.darkTheme,
        icon: controller.value == ThemeMode.dark ? AppIcons.check : AppIcons.moon,
      ),
    ];
    void select(_AppearanceChoice choice) {
      controller.mode = switch (choice) {
        _AppearanceChoice.system => ThemeMode.system,
        _AppearanceChoice.light => ThemeMode.light,
        _AppearanceChoice.dark => ThemeMode.dark,
      };
    }

    if (!showLabel) {
      return AppMenuButton<_AppearanceChoice>(
        key: const ValueKey('theme-toggle'),
        icon: AppIcons.settings,
        label: context.l10n.appearance,
        onSelected: select,
        items: items,
      );
    }

    return PopupMenuButton<_AppearanceChoice>(
      key: const ValueKey('theme-toggle'),
      tooltip: context.l10n.appearance,
      color: context.tokens.colors.popover,
      surfaceTintColor: context.tokens.colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.borders.sm,
        side: BorderSide(color: context.tokens.colors.border),
      ),
      constraints: const BoxConstraints(minWidth: 184),
      onSelected: select,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<_AppearanceChoice>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: context.tokens.icons.sm, color: context.tokens.colors.onSurfaceMuted),
                  SizedBox(width: context.tokens.spacing.sm),
                ],
                Text(item.label, style: context.tokens.typography.compactLabel),
              ],
            ),
          ),
      ],
      child: SizedBox(
        width: 200,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(AppIcons.settings, size: 20, color: context.tokens.colors.onSurfaceMuted),
              const SizedBox(width: 12),
              Text(
                context.l10n.appearance,
                style: context.tokens.typography.navigationLabelMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<_AppDestination> _destinations(BuildContext context) => [
  _AppDestination(
    label: context.l10n.navigationConcursos,
    icon: AppIcons.concursos,
    selectedIcon: AppIcons.concursosActive,
  ),
  _AppDestination(
    label: context.l10n.navigationDisciplines,
    icon: AppIcons.bookText,
    selectedIcon: AppIcons.bookText,
  ),
  _AppDestination(
    label: context.l10n.navigationWeek,
    icon: AppIcons.calendar,
    selectedIcon: AppIcons.calendar,
  ),
];
