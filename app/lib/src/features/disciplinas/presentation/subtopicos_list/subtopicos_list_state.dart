import 'package:flutter/foundation.dart';

enum SubtopicosListStatus { initial, loading, success, failure }

enum SubtopicosListFeedback {
  created,
  renamed,
  deleted,
  synchronizationPending,
  operationFailed,
}

@immutable
class SubtopicoListItemData {
  const SubtopicoListItemData({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SubtopicoListItemData && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

@immutable
class SubtopicosTopicState {
  SubtopicosTopicState({
    required this.topicId,
    List<SubtopicoListItemData> items = const [],
    this.isDeleting = false,
  }) : items = List.unmodifiable(items);

  final String topicId;
  final List<SubtopicoListItemData> items;
  final bool isDeleting;

  bool get canMutate => !isDeleting;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtopicosTopicState &&
          topicId == other.topicId &&
          listEquals(items, other.items) &&
          isDeleting == other.isDeleting;

  @override
  int get hashCode => Object.hash(topicId, Object.hashAll(items), isDeleting);
}

@immutable
class SubtopicosListState {
  SubtopicosListState({
    this.status = SubtopicosListStatus.initial,
    this.disciplineId,
    Map<String, SubtopicosTopicState> byTopic = const {},
    this.feedback,
  }) : byTopic = Map.unmodifiable(byTopic);

  final SubtopicosListStatus status;
  final String? disciplineId;
  final Map<String, SubtopicosTopicState> byTopic;
  final SubtopicosListFeedback? feedback;

  SubtopicosTopicState? topic(String topicId) => byTopic[topicId];
}
