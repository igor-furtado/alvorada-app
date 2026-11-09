import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import 'primitives/app_dimension_primitives.dart';

@immutable
class AppLayoutTokens {
  const AppLayoutTokens({
    this.compact = AppDimensionPrimitives.breakpointCompact,
    this.medium = AppDimensionPrimitives.breakpointMedium,
    this.expanded = AppDimensionPrimitives.breakpointExpanded,
    this.wide = AppDimensionPrimitives.breakpointWide,
    this.contentMaxWidth = AppDimensionPrimitives.contentMaxWidth,
    this.dialogMaxWidth = 600,
    this.sideNavigationWidth = 256,
    this.brandWidth = 178,
    this.controlHeight = AppDimensionPrimitives.size48,
    this.topicSelectionIndent = 42,
    this.tableActionsColumn = 56,
    this.narrow = 520,
    this.toolbar = 620,
    this.twoColumn = 680,
    this.header = 700,
    this.reading = 720,
    this.detail = 820,
    this.contentSplit = 860,
    this.threeColumn = 1040,
    this.infiniteScrollExtent = AppDimensionPrimitives.size240,
    this.timelineRailCompact = AppDimensionPrimitives.size64,
    this.timelineRailExpanded = 112,
    this.timelineGapCompact = AppDimensionPrimitives.size12,
    this.timelineGapExpanded = 18,
    this.sundayContentOffset = 72,
  });

  final double compact;
  final double medium;
  final double expanded;
  final double wide;
  final double contentMaxWidth;
  final double dialogMaxWidth;
  final double sideNavigationWidth;
  final double brandWidth;
  final double controlHeight;
  final double topicSelectionIndent;
  final double tableActionsColumn;
  final double narrow;
  final double toolbar;
  final double twoColumn;
  final double header;
  final double reading;
  final double detail;
  final double contentSplit;
  final double threeColumn;
  final double infiniteScrollExtent;
  final double timelineRailCompact;
  final double timelineRailExpanded;
  final double timelineGapCompact;
  final double timelineGapExpanded;
  final double sundayContentOffset;

  AppLayoutTokens lerp(AppLayoutTokens other, double t) => AppLayoutTokens(
    compact: lerpDouble(compact, other.compact, t)!,
    medium: lerpDouble(medium, other.medium, t)!,
    expanded: lerpDouble(expanded, other.expanded, t)!,
    wide: lerpDouble(wide, other.wide, t)!,
    contentMaxWidth: lerpDouble(contentMaxWidth, other.contentMaxWidth, t)!,
    dialogMaxWidth: lerpDouble(dialogMaxWidth, other.dialogMaxWidth, t)!,
    sideNavigationWidth: lerpDouble(
      sideNavigationWidth,
      other.sideNavigationWidth,
      t,
    )!,
    brandWidth: lerpDouble(brandWidth, other.brandWidth, t)!,
    controlHeight: lerpDouble(controlHeight, other.controlHeight, t)!,
    topicSelectionIndent: lerpDouble(
      topicSelectionIndent,
      other.topicSelectionIndent,
      t,
    )!,
    tableActionsColumn: lerpDouble(
      tableActionsColumn,
      other.tableActionsColumn,
      t,
    )!,
    narrow: lerpDouble(narrow, other.narrow, t)!,
    toolbar: lerpDouble(toolbar, other.toolbar, t)!,
    twoColumn: lerpDouble(twoColumn, other.twoColumn, t)!,
    header: lerpDouble(header, other.header, t)!,
    reading: lerpDouble(reading, other.reading, t)!,
    detail: lerpDouble(detail, other.detail, t)!,
    contentSplit: lerpDouble(contentSplit, other.contentSplit, t)!,
    threeColumn: lerpDouble(threeColumn, other.threeColumn, t)!,
    infiniteScrollExtent: lerpDouble(infiniteScrollExtent, other.infiniteScrollExtent, t)!,
    timelineRailCompact: lerpDouble(timelineRailCompact, other.timelineRailCompact, t)!,
    timelineRailExpanded: lerpDouble(timelineRailExpanded, other.timelineRailExpanded, t)!,
    timelineGapCompact: lerpDouble(timelineGapCompact, other.timelineGapCompact, t)!,
    timelineGapExpanded: lerpDouble(timelineGapExpanded, other.timelineGapExpanded, t)!,
    sundayContentOffset: lerpDouble(sundayContentOffset, other.sundayContentOffset, t)!,
  );
}
