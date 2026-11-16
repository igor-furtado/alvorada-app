import 'package:material_ui/material_ui.dart';

import '../app_icons.dart';
import '../app_tokens.dart';
import '../controls/app_button.dart';
import 'app_card.dart';
import 'app_resizable.dart';
import 'app_responsive.dart';
import 'app_scroll_area.dart';

/// Reorganiza uma relação mestre-detalhe conforme o espaço disponível.
class AppMasterDetail extends StatelessWidget {
  const AppMasterDetail({
    required this.master,
    required this.detail,
    this.compactDetailVisible = false,
    this.onCompactBack,
    this.compactBackLabel,
    this.initialMasterRatio = .25,
    super.key,
  });

  final Widget master;
  final Widget detail;
  final bool compactDetailVisible;
  final VoidCallback? onCompactBack;
  final String? compactBackLabel;
  final double initialMasterRatio;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < context.tokens.layout.contentSplit) {
          final compactChild = compactDetailVisible
              ? Column(
                  key: const ValueKey('compact-detail'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.tokens.spacing.sm,
                        context.tokens.spacing.sm,
                        context.tokens.spacing.sm,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          key: const ValueKey('compact-master-detail-back'),
                          label: compactBackLabel ?? '',
                          icon: AppIcons.chevronLeft,
                          variant: AppButtonVariant.text,
                          onPressed: onCompactBack,
                        ),
                      ),
                    ),
                    Expanded(child: AppScrollArea(child: detail)),
                  ],
                )
              : AppScrollArea(
                  key: const ValueKey('compact-master'),
                  child: master,
                );
          return AnimatedSwitcher(
            duration: context.motionDuration(context.tokens.motion.medium),
            switchInCurve: context.tokens.motion.enter,
            switchOutCurve: context.tokens.motion.exit,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              fit: StackFit.expand,
              children: [
                ...previousChildren,
                ?currentChild,
              ],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: compactChild,
          );
        }
        return AppResizable(
          initialRatio: initialMasterRatio,
          first: AppScrollArea(child: master),
          second: AppScrollArea(child: detail),
        );
      },
    ),
  );
}
