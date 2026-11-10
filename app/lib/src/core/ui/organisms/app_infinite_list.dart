import 'dart:async';

import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../accessibility/app_accessibility.dart';
import '../atoms/app_button.dart';
import '../atoms/app_skeleton.dart';
import 'app_state_view.dart';

@immutable
class AppInfinitePage<T> {
  const AppInfinitePage({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;
}

class AppInfiniteListController {
  VoidCallback? _reload;

  void reload() => _reload?.call();
}

typedef AppPageLoader<T> = Future<AppInfinitePage<T>> Function(String? cursor);

class AppInfiniteListView<T> extends StatefulWidget {
  const AppInfiniteListView({
    required this.loadPage,
    required this.itemBuilder,
    this.controller,
    this.emptyTitle,
    this.emptyMessage,
    this.padding,
    super.key,
  });

  final AppPageLoader<T> loadPage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final AppInfiniteListController? controller;
  final String? emptyTitle;
  final String? emptyMessage;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppInfiniteListView<T>> createState() => _AppInfiniteListViewState<T>();
}

class _AppInfiniteListViewState<T> extends State<AppInfiniteListView<T>> {
  final _scrollController = ScrollController();
  final _items = <T>[];
  String? _cursor;
  Object? _error;
  bool _loading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    widget.controller?._reload = _reload;
    unawaited(_loadNextPage());
  }

  @override
  void didUpdateWidget(covariant AppInfiniteListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._reload = null;
      widget.controller?._reload = _reload;
    }
  }

  @override
  void dispose() {
    widget.controller?._reload = null;
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _loading || !_hasMore) return;
    final remaining = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    if (remaining <= context.tokens.layout.infiniteScrollExtent) unawaited(_loadNextPage());
  }

  void _reload() {
    setState(() {
      _items.clear();
      _cursor = null;
      _error = null;
      _hasMore = true;
      _loading = true;
    });
    unawaited(_loadNextPage());
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore && _items.isNotEmpty) return;
    if (!_loading) setState(() => _loading = true);
    try {
      final page = await widget.loadPage(_cursor);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        _loading = false;
        _error = null;
      });
      AppAccessibility.announce(context, AppMessages.loadedItems(page.items.length));
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _items.isEmpty) {
      return ListView.separated(
        padding: widget.padding,
        itemCount: 3,
        separatorBuilder: (_, _) => SizedBox(height: context.tokens.spacing.md),
        itemBuilder: (_, _) => AppSkeleton(
          height: context.tokens.sizes.rowDividerHeight,
          semanticLabel: AppMessages.loading,
        ),
      );
    }
    if (_error != null && _items.isEmpty) {
      return AppStateView(
        variant: AppStateVariant.error,
        actionLabel: AppMessages.tryAgain,
        onAction: _reload,
      );
    }
    if (_items.isEmpty) {
      return AppStateView(
        variant: AppStateVariant.empty,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }
    final footer = _loading || _error != null || !_hasMore;
    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: _items.length + (footer ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: context.tokens.spacing.md),
      itemBuilder: (context, index) {
        if (index < _items.length) return widget.itemBuilder(context, _items[index], index);
        if (_loading) {
          return AppSkeleton(
            height: context.tokens.sizes.rowDividerHeight,
            semanticLabel: AppMessages.loadingMore,
          );
        }
        if (_error != null) {
          return Center(
            child: AppButton(label: AppMessages.tryAgain, variant: AppButtonVariant.outline, onPressed: _loadNextPage),
          );
        }
        return Padding(
          padding: EdgeInsets.all(context.tokens.spacing.lg),
          child: Text(
            AppMessages.noMoreResults,
            textAlign: TextAlign.center,
            style: context.tokens.typography.bodySmall,
          ),
        );
      },
    );
  }
}
