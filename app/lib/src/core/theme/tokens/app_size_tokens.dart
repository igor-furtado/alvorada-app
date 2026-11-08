import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Dimensões semânticas de componentes que não representam espaçamento.
@immutable
class AppSizeTokens {
  const AppSizeTokens({
    this.hairline = 1,
    this.progressLine = 2,
    this.accentBar = 6,
    this.progressIndicatorThin = 6,
    this.progressIndicatorRegular = 8,
    this.dotSm = 8,
    this.dotMd = 10,
    this.dotLg = 14,
    this.dayMarker = 26,
    this.stepIndicator = 30,
    this.topicCheckbox = 34,
    this.rowIcon = 38,
    this.iconContainerSm = 40,
    this.iconContainerMd = 42,
    this.sundayIcon = 48,
    this.identityIcon = 56,
    this.rowDividerHeight = 58,
    this.iconContainerLg = 62,
    this.largeVisual = 72,
    this.weightColumn = 105,
    this.progressColumn = 110,
    this.compactField = 120,
    this.navigationBrand = 184,
    this.weekSummary = 220,
    this.overviewPanel = 240,
    this.reviewAccentHeight = 260,
    this.guideMaxWidth = 450,
    this.noteMaxWidth = 460,
    this.dialogNarrow = 480,
    this.dialogMedium = 500,
    this.dialogWide = 560,
    this.detailsTable = 950,
    this.disciplineTable = 1080,
    this.disciplinePage = 1180,
    this.horizonPage = 1220,
  });

  final double hairline;
  final double progressLine;
  final double accentBar;
  final double progressIndicatorThin;
  final double progressIndicatorRegular;
  final double dotSm;
  final double dotMd;
  final double dotLg;
  final double dayMarker;
  final double stepIndicator;
  final double topicCheckbox;
  final double rowIcon;
  final double iconContainerSm;
  final double iconContainerMd;
  final double sundayIcon;
  final double identityIcon;
  final double rowDividerHeight;
  final double iconContainerLg;
  final double largeVisual;
  final double weightColumn;
  final double progressColumn;
  final double compactField;
  final double navigationBrand;
  final double weekSummary;
  final double overviewPanel;
  final double reviewAccentHeight;
  final double guideMaxWidth;
  final double noteMaxWidth;
  final double dialogNarrow;
  final double dialogMedium;
  final double dialogWide;
  final double detailsTable;
  final double disciplineTable;
  final double disciplinePage;
  final double horizonPage;

  AppSizeTokens lerp(AppSizeTokens other, double t) => AppSizeTokens(
    hairline: lerpDouble(hairline, other.hairline, t)!,
    progressLine: lerpDouble(progressLine, other.progressLine, t)!,
    accentBar: lerpDouble(accentBar, other.accentBar, t)!,
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
    dayMarker: lerpDouble(dayMarker, other.dayMarker, t)!,
    stepIndicator: lerpDouble(stepIndicator, other.stepIndicator, t)!,
    topicCheckbox: lerpDouble(topicCheckbox, other.topicCheckbox, t)!,
    rowIcon: lerpDouble(rowIcon, other.rowIcon, t)!,
    iconContainerSm: lerpDouble(iconContainerSm, other.iconContainerSm, t)!,
    iconContainerMd: lerpDouble(iconContainerMd, other.iconContainerMd, t)!,
    sundayIcon: lerpDouble(sundayIcon, other.sundayIcon, t)!,
    identityIcon: lerpDouble(identityIcon, other.identityIcon, t)!,
    rowDividerHeight: lerpDouble(rowDividerHeight, other.rowDividerHeight, t)!,
    iconContainerLg: lerpDouble(iconContainerLg, other.iconContainerLg, t)!,
    largeVisual: lerpDouble(largeVisual, other.largeVisual, t)!,
    weightColumn: lerpDouble(weightColumn, other.weightColumn, t)!,
    progressColumn: lerpDouble(progressColumn, other.progressColumn, t)!,
    compactField: lerpDouble(compactField, other.compactField, t)!,
    navigationBrand: lerpDouble(navigationBrand, other.navigationBrand, t)!,
    weekSummary: lerpDouble(weekSummary, other.weekSummary, t)!,
    overviewPanel: lerpDouble(overviewPanel, other.overviewPanel, t)!,
    reviewAccentHeight: lerpDouble(
      reviewAccentHeight,
      other.reviewAccentHeight,
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
    horizonPage: lerpDouble(horizonPage, other.horizonPage, t)!,
  );
}
