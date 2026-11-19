import 'package:material_ui/material_ui.dart';

import '../app_typography.dart';
import 'app_color_tokens.dart';
import 'app_opacity_tokens.dart';

@immutable
class AppTypographyTokens {
  const AppTypographyTokens._(this.textTheme, this._colors, this._opacity);

  factory AppTypographyTokens.fromTokens(
    AppColorTokens colors,
    AppOpacityTokens opacity,
  ) => AppTypographyTokens._(
    AppTypography.textTheme(colors.onSurface, colors.onSurfaceMuted),
    colors,
    opacity,
  );

  final TextTheme textTheme;
  final AppColorTokens _colors;
  final AppOpacityTokens _opacity;

  TextStyle get displayMedium => textTheme.displayMedium!;
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;

  // Ações
  TextStyle get button => _button.copyWith(color: _colors.onSurface);
  TextStyle get buttonPrimary => _button.copyWith(color: _colors.onPrimary);
  TextStyle get buttonDestructive => _button.copyWith(color: _colors.error);
  TextStyle get buttonAction => _button.copyWith(color: _colors.actionForeground);
  TextStyle get controlLabel => labelLarge.copyWith(color: _colors.onSurface);
  TextStyle get controlLabelMuted => labelLarge.copyWith(color: _colors.onSurfaceMuted);
  TextStyle get controlLabelOnPrimary => labelLarge.copyWith(color: _colors.onPrimary);
  TextStyle get controlLabelError => labelLarge.copyWith(color: _colors.error);
  TextStyle get linkMuted => labelLarge.copyWith(
    color: _colors.onSurfaceMuted,
    decoration: TextDecoration.underline,
    decorationColor: _colors.onSurfaceMuted,
  );

  // Conteúdo e apoio
  TextStyle get supportingText => bodySmall;
  TextStyle get supportingTextStrong => bodySmall.copyWith(color: _colors.onSurface);
  TextStyle get description => bodyMedium.copyWith(color: _colors.onSurfaceMuted);
  TextStyle get leadDescription => bodyLarge.copyWith(color: _colors.onSurfaceMuted);
  TextStyle get overline => labelSmall;
  TextStyle get overlineStrong => labelSmall.copyWith(color: _colors.onSurface);
  TextStyle get overlineInfo => labelSmall.copyWith(color: _colors.info);
  TextStyle get catalogOverline => labelSmall.copyWith(letterSpacing: .8);
  TextStyle get contentTitle => titleMedium.copyWith(fontWeight: FontWeight.w500);
  TextStyle get contentTitleCompleted => contentTitle.copyWith(
    decoration: TextDecoration.lineThrough,
    decorationColor: _colors.onSurfaceMuted,
  );
  TextStyle get stateTitle => titleLarge.copyWith(fontWeight: FontWeight.w500);
  TextStyle get dialogDescription => bodySmall.copyWith(letterSpacing: 0);

  // Estados semânticos
  TextStyle get errorText => bodySmall.copyWith(color: _colors.error);
  TextStyle get alertTitle => titleSmall.copyWith(color: _colors.errorForeground);
  TextStyle get alertDescription => bodySmall.copyWith(color: _colors.errorForeground);
  TextStyle get destructiveLabel => labelMedium.copyWith(color: _colors.errorForeground);
  TextStyle get successLabel => labelMedium.copyWith(color: _colors.success);

  // Componentes com estados próprios
  TextStyle get compactLabel => labelMedium.copyWith(color: _colors.onSurface);
  TextStyle get compactLabelOnPrimary => labelMedium.copyWith(color: _colors.onPrimary);
  TextStyle get tooltipLabel => labelMedium.copyWith(color: _colors.canvas);
  TextStyle get listItemTitle => bodyMedium.copyWith(fontWeight: FontWeight.w500);
  TextStyle get listItemTitleOnPrimary => listItemTitle.copyWith(color: _colors.onPrimary);
  TextStyle get listItemDescription => bodyMedium.copyWith(color: _colors.onSurfaceMuted);
  TextStyle get listItemDescriptionCompact => bodySmall;
  TextStyle get listItemDescriptionOnPrimary => bodyMedium.copyWith(
    color: _colors.onPrimary.withValues(alpha: _opacity.hint),
  );
  TextStyle get listItemDescriptionCompactOnPrimary => bodySmall.copyWith(
    color: _colors.onPrimary.withValues(alpha: _opacity.hint),
  );
  TextStyle get disciplineSelected => titleSmall.copyWith(fontWeight: FontWeight.w700);
  TextStyle get disciplineUnselected => titleSmall.copyWith(color: _colors.onSurfaceMuted);

  // Navegação principal
  TextStyle get navigationBrand => titleSmall.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: -.2,
  );
  TextStyle get navigationLabel => controlLabel.copyWith(fontWeight: FontWeight.w600);
  TextStyle get navigationLabelMuted => controlLabelMuted.copyWith(fontWeight: FontWeight.w600);
  TextStyle get navigationCompactLabel => labelSmall.copyWith(
    color: _colors.onSurface,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
  TextStyle get navigationCompactLabelMuted => navigationCompactLabel.copyWith(
    color: _colors.onSurfaceMuted,
  );

  // Semana em trilhos
  TextStyle get weekPageTitle => headlineLarge.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -1.2,
  );
  TextStyle get weekPageTitleCompact => weekPageTitle.copyWith(fontSize: 26);
  TextStyle get weekPageDescription => bodyLarge.copyWith(
    color: _colors.onSurfaceMuted,
    height: 1.5,
  );
  TextStyle get weekPrimaryAction => buttonPrimary.copyWith(fontWeight: FontWeight.w700);
  TextStyle get weekFilterLabel => labelMedium.copyWith(
    color: _colors.onSurface,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  TextStyle get weekFilterLabelSelected => weekFilterLabel.copyWith(color: _colors.onPrimary);
  TextStyle get weekFilterDetail => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
  TextStyle get weekFilterDetailSelected => weekFilterDetail.copyWith(
    color: _colors.onPrimary.withValues(alpha: .62),
  );
  TextStyle get weekToggleLabel => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
  TextStyle get weekToggleLabelSelected => weekToggleLabel.copyWith(color: _colors.onSurface);
  TextStyle get weekToolbarLabel => labelMedium.copyWith(
    color: _colors.onSurface,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  TextStyle get weekLegendLabel => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
  TextStyle get weekDayLabel => labelMedium.copyWith(
    color: _colors.onSurface,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  TextStyle get weekDayDate => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 11,
  );
  TextStyle get weekDayMeta => weekLegendLabel;
  TextStyle get weekCardDiscipline => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: .4,
  );
  TextStyle get weekCardTitle => labelMedium.copyWith(
    color: _colors.onSurface,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );
  TextStyle get weekCardTitleCompleted => weekCardTitle.copyWith(
    decoration: TextDecoration.lineThrough,
  );
  TextStyle get weekCardMeta => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 10,
  );
  TextStyle get weekCardMetaStrong => weekCardMeta.copyWith(fontWeight: FontWeight.w700);
  TextStyle get weekTagLabel => labelSmall.copyWith(
    color: _colors.onSurfaceMuted,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: .35,
  );
  TextStyle get weekEmptyLabel => weekCardMeta;

  TextStyle get _button => labelLarge.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: AppTypography.trackingWider,
  );

  AppTypographyTokens lerp(AppTypographyTokens other, double t) => AppTypographyTokens._(
    TextTheme.lerp(textTheme, other.textTheme, t),
    _colors.lerp(other._colors, t),
    _opacity.lerp(other._opacity, t),
  );
}
