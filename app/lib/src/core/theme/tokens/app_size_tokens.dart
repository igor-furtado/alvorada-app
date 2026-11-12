import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Dimensões semânticas de componentes que não representam espaçamento.
@immutable
class AppSizeTokens {
  const AppSizeTokens({
    this.hairline = 1,
    this.progressLine = 2,
    this.accentBar = 6,
    this.dialogBackdropBlur = 4,
    this.progressIndicatorThin = 6,
    this.progressIndicatorRegular = 8,
    this.dotSm = 8,
    this.dotMd = 10,
    this.dotLg = 14,
    this.stepIndicator = 30,
    this.avatarSm = 24,
    this.avatarMd = 32,
    this.avatarLg = 40,
    this.rowIcon = 38,
    this.iconContainerSm = 40,
    this.iconContainerMd = 42,
    this.identityIcon = 56,
    this.rowDividerHeight = 58,
    this.iconContainerLg = 62,
    this.disciplineRowHeight = 68,
    this.largeVisual = 72,
    this.drawerHandleLength = 100,
    this.weightColumn = 105,
    this.progressColumn = 110,
    this.compactField = 120,
    this.summaryRail = 250,
    this.searchField = 270,
    this.navigationBrand = 184,
    this.summaryPanel = 220,
    this.overviewPanel = 240,
    this.listItemHeaderHeight = 260,
    this.guideMaxWidth = 450,
    this.noteMaxWidth = 460,
    this.dialogNarrow = 480,
    this.dialogMedium = 500,
    this.dialogWide = 560,
    this.detailsTable = 950,
    this.disciplineTable = 1080,
    this.disciplinePage = 1216,
    this.concursosPage = 1220,
  });

  final double hairline;
  final double progressLine;
  final double accentBar;
  final double dialogBackdropBlur;
  final double progressIndicatorThin;
  final double progressIndicatorRegular;
  final double dotSm;
  final double dotMd;
  final double dotLg;
  final double stepIndicator;
  final double avatarSm;
  final double avatarMd;
  final double avatarLg;
  final double rowIcon;
  final double iconContainerSm;
  final double iconContainerMd;
  final double identityIcon;
  final double rowDividerHeight;
  final double iconContainerLg;
  final double disciplineRowHeight;
  final double largeVisual;
  final double drawerHandleLength;
  final double weightColumn;
  final double progressColumn;
  final double compactField;
  final double summaryRail;
  final double searchField;
  final double navigationBrand;
  final double summaryPanel;
  final double overviewPanel;
  final double listItemHeaderHeight;
  final double guideMaxWidth;
  final double noteMaxWidth;
  final double dialogNarrow;
  final double dialogMedium;
  final double dialogWide;
  final double detailsTable;
  final double disciplineTable;
  final double disciplinePage;
  final double concursosPage;

  AppSizeTokens lerp(AppSizeTokens other, double t) => AppSizeTokens(
    hairline: lerpDouble(hairline, other.hairline, t)!,
    progressLine: lerpDouble(progressLine, other.progressLine, t)!,
    accentBar: lerpDouble(accentBar, other.accentBar, t)!,
    dialogBackdropBlur: lerpDouble(
      dialogBackdropBlur,
      other.dialogBackdropBlur,
      t,
    )!,
    progressIndicatorThin: lerpDouble(
      progressIndicatorThin,
      other.progressIndicatorThin,
      t,
    )!,
    progressIndicatorRegular: lerpDouble(
      progressIndicatorRegular,
      other.progressIndicatorRegular,
      t,
    )!,
    dotSm: lerpDouble(dotSm, other.dotSm, t)!,
    dotMd: lerpDouble(dotMd, other.dotMd, t)!,
    dotLg: lerpDouble(dotLg, other.dotLg, t)!,
    stepIndicator: lerpDouble(stepIndicator, other.stepIndicator, t)!,
    avatarSm: lerpDouble(avatarSm, other.avatarSm, t)!,
    avatarMd: lerpDouble(avatarMd, other.avatarMd, t)!,
    avatarLg: lerpDouble(avatarLg, other.avatarLg, t)!,
    rowIcon: lerpDouble(rowIcon, other.rowIcon, t)!,
    iconContainerSm: lerpDouble(iconContainerSm, other.iconContainerSm, t)!,
    iconContainerMd: lerpDouble(iconContainerMd, other.iconContainerMd, t)!,
    identityIcon: lerpDouble(identityIcon, other.identityIcon, t)!,
    rowDividerHeight: lerpDouble(rowDividerHeight, other.rowDividerHeight, t)!,
    iconContainerLg: lerpDouble(iconContainerLg, other.iconContainerLg, t)!,
    disciplineRowHeight: lerpDouble(disciplineRowHeight, other.disciplineRowHeight, t)!,
    largeVisual: lerpDouble(largeVisual, other.largeVisual, t)!,
    drawerHandleLength: lerpDouble(drawerHandleLength, other.drawerHandleLength, t)!,
    weightColumn: lerpDouble(weightColumn, other.weightColumn, t)!,
    progressColumn: lerpDouble(progressColumn, other.progressColumn, t)!,
    compactField: lerpDouble(compactField, other.compactField, t)!,
    summaryRail: lerpDouble(summaryRail, other.summaryRail, t)!,
    searchField: lerpDouble(searchField, other.searchField, t)!,
    navigationBrand: lerpDouble(navigationBrand, other.navigationBrand, t)!,
    summaryPanel: lerpDouble(summaryPanel, other.summaryPanel, t)!,
    overviewPanel: lerpDouble(overviewPanel, other.overviewPanel, t)!,
    listItemHeaderHeight: lerpDouble(
      listItemHeaderHeight,
      other.listItemHeaderHeight,
      t,
    )!,
    guideMaxWidth: lerpDouble(guideMaxWidth, other.guideMaxWidth, t)!,
    noteMaxWidth: lerpDouble(noteMaxWidth, other.noteMaxWidth, t)!,
    dialogNarrow: lerpDouble(dialogNarrow, other.dialogNarrow, t)!,
    dialogMedium: lerpDouble(dialogMedium, other.dialogMedium, t)!,
    dialogWide: lerpDouble(dialogWide, other.dialogWide, t)!,
    detailsTable: lerpDouble(detailsTable, other.detailsTable, t)!,
    disciplineTable: lerpDouble(disciplineTable, other.disciplineTable, t)!,
    disciplinePage: lerpDouble(disciplinePage, other.disciplinePage, t)!,
    concursosPage: lerpDouble(concursosPage, other.concursosPage, t)!,
  );
}
