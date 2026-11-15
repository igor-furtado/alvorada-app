import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';
import 'app_card.dart';
import 'app_divider.dart';
import 'app_resizable.dart';
import 'app_scroll_area.dart';

/// Reorganiza uma relação mestre-detalhe conforme o espaço disponível.
class AppMasterDetail extends StatelessWidget {
  const AppMasterDetail({
    required this.master,
    required this.detail,
    this.initialMasterRatio = .25,
    super.key,
  });

  final Widget master;
  final Widget detail;
  final double initialMasterRatio;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < context.tokens.layout.contentSplit) {
          return AppScrollArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                master,
                const AppDivider(margin: EdgeInsets.zero),
                detail,
              ],
            ),
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
