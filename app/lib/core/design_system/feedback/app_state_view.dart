import 'package:material_ui/material_ui.dart';

import '../app_icons.dart';
import '../app_tokens.dart';
import '../controls/app_button.dart';
import '../design_system_localizations.dart';

enum AppStateVariant { empty, error }

class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.variant,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final AppStateVariant variant;
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final defaults = switch (variant) {
      AppStateVariant.empty => (AppIcons.folderDashed, context.l10n.emptyTitle, ''),
      AppStateVariant.error => (
        AppIcons.attention,
        context.l10n.genericErrorTitle,
        context.l10n.genericErrorMessage,
      ),
    };
    final resolvedTitle = title ?? defaults.$2;
    final resolvedMessage = message ?? defaults.$3;
    final resolvedIcon = icon ?? defaults.$1;

    return Semantics(
      container: true,
      liveRegion: variant != AppStateVariant.empty,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tokens = context.tokens;
          final padding = constraints.maxWidth < tokens.layout.compact ? tokens.spacing.xxl : tokens.spacing.huge;
          final minimumHeight = constraints.hasBoundedHeight ? constraints.maxHeight : tokens.spacing.none;
          final body = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: minimumHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: LayoutBuilder(
                builder: (context, contentConstraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: contentConstraints.hasBoundedHeight
                          ? contentConstraints.maxHeight
                          : tokens.spacing.none,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AppStateHeader(
                            title: resolvedTitle,
                            message: resolvedMessage,
                            icon: resolvedIcon,
                          ),
                          if (actionLabel != null) ...[
                            SizedBox(height: tokens.spacing.xxl),
                            AppButton(label: actionLabel!, onPressed: onAction),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          return ClipRRect(
            borderRadius: tokens.borders.lg,
            child: body,
          );
        },
      ),
    );
  }
}

class _AppStateHeader extends StatelessWidget {
  const _AppStateHeader({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.layout.dialogMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AppStateMedia(icon: icon),
          SizedBox(height: tokens.spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tokens.typography.stateTitle,
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tokens.typography.supportingText,
            ),
          ],
        ],
      ),
    );
  }
}

class _AppStateMedia extends StatelessWidget {
  const _AppStateMedia({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IconTheme.merge(
      data: IconThemeData(
        size: tokens.icons.lg,
        color: tokens.colors.onSurface,
      ),
      child: Container(
        width: tokens.feedbackIconSize,
        height: tokens.feedbackIconSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.colors.surfaceSubtle,
          borderRadius: tokens.borders.lg,
        ),
        child: ExcludeSemantics(child: Icon(icon)),
      ),
    );
  }
}
