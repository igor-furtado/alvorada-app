import 'package:flutter/foundation.dart';

enum TopicosListStatus { initial, loading, success, failure }

enum TopicosListFeedback {
  created,
  renamed,
  deleted,
  synchronizationPending,
  operationFailed,
}

@immutable
class TopicoListItemData {
  const TopicoListItemData({
    required this.id,
    required this.name,
    required this.mandatory,
  });

  final String id;
  final String name;
  final bool mandatory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicoListItemData && id == other.id && name == other.name && mandatory == other.mandatory;

  @override
  int get hashCode => Object.hash(id, name, mandatory);
}

@immutable
class TopicosListState {
  TopicosListState({
    this.status = TopicosListStatus.initial,
    this.disciplineId,
    List<TopicoListItemData> items = const [],
    this.isDeleting = false,
    this.feedback,
  }) : items = List.unmodifiable(items);

  final TopicosListStatus status;
  final String? disciplineId;
  final List<TopicoListItemData> items;
  final bool isDeleting;
  final TopicosListFeedback? feedback;

  bool get canMutate => status == TopicosListStatus.success && !isDeleting;

  List<TopicoListItemData> get regularItems => items.where((item) => !item.mandatory).toList(growable: false);

  List<TopicoListItemData> get mandatoryItems => items.where((item) => item.mandatory).toList(growable: false);
}
