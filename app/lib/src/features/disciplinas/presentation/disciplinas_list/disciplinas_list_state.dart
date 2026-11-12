import 'package:flutter/foundation.dart';

enum DisciplinasListStatus { initial, loading, success, failure }

enum DisciplinasListFeedback {
  updated,
  created,
  renamed,
  deleted,
  refreshFailed,
  synchronizationPending,
  operationFailed,
}

@immutable
class DisciplinaListItemData {
  const DisciplinaListItemData({
    required this.id,
    required this.name,
    required this.topicCount,
  });

  final String id;
  final String name;
  final int topicCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisciplinaListItemData && id == other.id && name == other.name && topicCount == other.topicCount;

  @override
  int get hashCode => Object.hash(id, name, topicCount);
}

@immutable
class DisciplinasListState {
  DisciplinasListState({
    this.status = DisciplinasListStatus.initial,
    List<DisciplinaListItemData> items = const [],
    this.query = '',
    this.selectedDisciplineId,
    this.isRefreshing = false,
    this.isDeleting = false,
    this.feedback,
  }) : items = List.unmodifiable(items);

  final DisciplinasListStatus status;
  final List<DisciplinaListItemData> items;
  final String query;
  final String? selectedDisciplineId;
  final bool isRefreshing;
  final bool isDeleting;
  final DisciplinasListFeedback? feedback;

  bool get canMutate => status == DisciplinasListStatus.success && !isRefreshing && !isDeleting;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisciplinasListState &&
          status == other.status &&
          listEquals(items, other.items) &&
          query == other.query &&
          selectedDisciplineId == other.selectedDisciplineId &&
          isRefreshing == other.isRefreshing &&
          isDeleting == other.isDeleting &&
          feedback == other.feedback;

  @override
  int get hashCode => Object.hash(
    status,
    Object.hashAll(items),
    query,
    selectedDisciplineId,
    isRefreshing,
    isDeleting,
    feedback,
  );
}
