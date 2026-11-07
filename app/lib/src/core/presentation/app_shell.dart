import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

enum AppSection { today, week, horizons, reviews, errors, settings }

typedef AppShellBuilder = Widget Function(BuildContext context, bool desktop);

/// Estrutura de navegação compartilhada pelas telas principais.
class AppShell extends StatelessWidget {
  const AppShell({required this.section, required this.builder, super.key});

  final AppSection section;
  final AppShellBuilder builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 980;
      return Scaffold(
        bottomNavigationBar: desktop
            ? null
            : _BottomNavigation(section: section),
        body: Row(
          children: [
            if (desktop) _SideNavigation(section: section),
            Expanded(child: builder(context, desktop)),
          ],
        ),
      );
    },
  );
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.section});

  final AppSection section;

  @override
  Widget build(BuildContext context) => Container(
    width: 232,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
        child: Column(
          children: [
            const AppBrandLogo(width: 184),
            const SizedBox(height: 32),
            _SideItem(
              label: 'Hoje',
              icon: AppIcons.today,
              activeIcon: AppIcons.todayActive,
              selected: section == AppSection.today,
              onTap: () => _open(context, AppSection.today),
            ),
            _SideItem(
              label: 'Esta semana',
              icon: AppIcons.calendar,
              activeIcon: AppIcons.calendarActive,
              selected: section == AppSection.week,
              onTap: () => _open(context, AppSection.week),
            ),
            _SideItem(
              label: 'Horizontes',
              icon: AppIcons.horizons,
              activeIcon: AppIcons.horizonsActive,
              selected: section == AppSection.horizons,
              onTap: () => _open(context, AppSection.horizons),
            ),
            _SideItem(
              label: 'Revisões',
              icon: AppIcons.reviews,
              activeIcon: AppIcons.reviewsActive,
              selected: section == AppSection.reviews,
              onTap: () => _open(context, AppSection.reviews),
            ),
            _SideItem(
              label: 'Caderno de Erros',
              icon: AppIcons.errorNotebook,
              activeIcon: AppIcons.errorNotebookActive,
              selected: section == AppSection.errors,
              onTap: () => _open(context, AppSection.errors),
            ),
            const Spacer(),
            _SideItem(
              label: 'Ajustes',
              icon: AppIcons.settings,
              selected: section == AppSection.settings,
              onTap: () => _open(context, AppSection.settings),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: Colors.transparent,
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(selected ? activeIcon ?? icon : icon, size: 22),
        title: Text(label, style: Theme.of(context).textTheme.labelLarge),
        onTap: onTap,
      ),
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.section});

  final AppSection section;

  int get _currentIndex => switch (section) {
    AppSection.today => 0,
    AppSection.week => 1,
    AppSection.horizons => 2,
    AppSection.reviews => 3,
    _ => 4,
  };

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) => _open(context, switch (index) {
      0 => AppSection.today,
      1 => AppSection.week,
      2 => AppSection.horizons,
      3 => AppSection.reviews,
      _ => AppSection.settings,
    }),
    items: [
      BottomNavigationBarItem(
        icon: Icon(
          section == AppSection.today ? AppIcons.todayActive : AppIcons.today,
        ),
        label: 'Hoje',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          section == AppSection.week
              ? AppIcons.calendarActive
              : AppIcons.calendar,
        ),
        label: 'Esta semana',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          section == AppSection.horizons
              ? AppIcons.horizonsActive
              : AppIcons.horizons,
        ),
        label: 'Horizontes',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          section == AppSection.reviews
              ? AppIcons.reviewsActive
              : AppIcons.reviews,
        ),
        label: 'Revisões',
      ),
      const BottomNavigationBarItem(
        icon: Icon(AppIcons.settings),
        label: 'Mais',
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
      dark
          ? 'assets/brand/alvorada-monochrome-paper.svg'
          : 'assets/brand/alvorada-horizontal.svg',
      width: width,
    );
  }
}

void _open(BuildContext context, AppSection destination) {
  final route = switch (destination) {
    AppSection.today => '/',
    AppSection.week => '/semana',
    AppSection.horizons => '/horizontes',
    AppSection.reviews => '/revisoes',
    AppSection.errors => '/caderno-de-erros',
    _ => null,
  };

  if (route != null) {
    context.go(route);
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Esta área entra nas próximas telas.')),
    );
}
