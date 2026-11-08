import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../brand/app_brand.dart';
import '../content/app_messages.dart';
import '../theme/app_theme.dart';
import '../ui/responsive/app_responsive.dart';

/// Estrutura de navegação compartilhada pelas telas principais.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, windowClass) => FocusTraversalGroup(
      child: Scaffold(
        bottomNavigationBar: windowClass.isCompact
            ? _CompactNavigation(selectedIndex: navigationShell.currentIndex, onSelected: _select)
            : null,
        body: Row(
          children: [
            if (windowClass.isMedium)
              _MediumNavigation(selectedIndex: navigationShell.currentIndex, onSelected: _select)
            else if (windowClass.isExpanded)
              _SideNavigation(selectedIndex: navigationShell.currentIndex, onSelected: _select),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    ),
  );
}

@immutable
class _AppDestination {
  const _AppDestination({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _AppDestination(label: AppMessages.navigationToday, icon: AppIcons.today, selectedIcon: AppIcons.todayActive),
  _AppDestination(label: AppMessages.navigationWeek, icon: AppIcons.calendar, selectedIcon: AppIcons.calendarActive),
  _AppDestination(
    label: AppMessages.navigationHorizons,
    icon: AppIcons.horizons,
    selectedIcon: AppIcons.horizonsActive,
  ),
  _AppDestination(label: AppMessages.navigationReviews, icon: AppIcons.reviews, selectedIcon: AppIcons.reviewsActive),
  _AppDestination(
    label: AppMessages.navigationErrors,
    icon: AppIcons.errorNotebook,
    selectedIcon: AppIcons.errorNotebookActive,
  ),
];

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.layout.sideNavigationWidth,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.tokens.spacing.xl,
          context.tokens.spacing.xxl,
          context.tokens.spacing.xl,
          context.tokens.spacing.xl,
        ),
        child: Column(
          children: [
            AppBrandLogo(width: context.tokens.sizes.navigationBrand),
            SizedBox(height: context.tokens.spacing.xxxl),
            for (var index = 0; index < _destinations.length; index++)
              _SideItem(
                destination: _destinations[index],
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
          ],
        ),
      ),
    ),
  );
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: context.tokens.spacing.xxs),
    child: Material(
      color: context.tokens.colors.transparent,
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: context.tokens.borders.md),
        leading: Icon(
          selected ? destination.selectedIcon : destination.icon,
          size: context.tokens.icons.md,
        ),
        title: Text(destination.label, style: Theme.of(context).textTheme.labelLarge),
        onTap: onTap,
      ),
    ),
  );
}

class _MediumNavigation extends StatelessWidget {
  const _MediumNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationRail(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    labelType: NavigationRailLabelType.all,
    destinations: [
      for (final destination in _destinations)
        NavigationRailDestination(
          icon: Icon(destination.icon),
          selectedIcon: Icon(destination.selectedIcon),
          label: Text(destination.label),
        ),
    ],
  );
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: [
      for (final destination in _destinations)
        NavigationDestination(
          icon: Icon(destination.icon),
          selectedIcon: Icon(destination.selectedIcon),
          label: destination.label,
        ),
    ],
  );
}

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({required this.width, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SvgPicture.asset(
      dark ? AppBrand.logoDark : AppBrand.logoLight,
      width: width,
      semanticsLabel: AppBrand.productName,
    );
  }
}

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.route});

  final String label;
  final String? route;
}

/// Navegação estrutural para telas internas do aplicativo.
///
/// O último item representa a tela atual; os anteriores permanecem clicáveis
/// para que a pessoa retorne rapidamente ao nível anterior.
class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({required this.items, super.key});

  final List<AppBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppMessages.navigationPath,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) ...[
              Icon(
                AppIcons.chevronRight,
                size: context.tokens.icons.md,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: context.tokens.spacing.xxs),
            ],
            if (items[index].route case final route?)
              TextButton(
                onPressed: () => context.go(route),
                style: TextButton.styleFrom(
                  minimumSize: Size(0, context.tokens.layout.controlHeight),
                  padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xs),
                ),
                child: Text(items[index].label),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xs),
                child: Text(
                  items[index].label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}
