import 'package:flutter/foundation.dart';

import '../../domain/models/concurso.dart';

enum ConcursosListStatus { initial, loading, success, failure }

enum ConcursosListFeedbackType {
  updated,
  created,
  prioritized,
  archived,
  restored,
  deleted,
  refreshFailed,
  synchronizationPending,
  operationFailed,
}

@immutable
class ConcursosListFeedback {
  const ConcursosListFeedback(this.type, {this.concurso});

  final ConcursosListFeedbackType type;
  final Concurso? concurso;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConcursosListFeedback && type == other.type && concurso?.id == other.concurso?.id;

  @override
  int get hashCode => Object.hash(type, concurso?.id);
}

@immutable
class ConcursosListState {
  ConcursosListState({
    this.status = ConcursosListStatus.initial,
    List<Concurso> items = const [],
    this.isRefreshing = false,
    this.isMutating = false,
    this.feedback,
  }) : items = List.unmodifiable(items);

  final ConcursosListStatus status;
  final List<Concurso> items;
  final bool isRefreshing;
  final bool isMutating;
  final ConcursosListFeedback? feedback;

  bool get canMutate => status == ConcursosListStatus.success && !isRefreshing && !isMutating;

  ConcursosListState copyWith({
    ConcursosListStatus? status,
    List<Concurso>? items,
    bool? isRefreshing,
    bool? isMutating,
    Object? feedback = _unchanged,
  }) => ConcursosListState(
    status: status ?? this.status,
    items: items ?? this.items,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isMutating: isMutating ?? this.isMutating,
    feedback: identical(feedback, _unchanged) ? this.feedback : feedback as ConcursosListFeedback?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConcursosListState &&
          status == other.status &&
          listEquals(items, other.items) &&
          isRefreshing == other.isRefreshing &&
          isMutating == other.isMutating &&
          feedback == other.feedback;

  @override
  int get hashCode => Object.hash(
    status,
    Object.hashAll(items),
    isRefreshing,
    isMutating,
    feedback,
  );
}

const _unchanged = Object();
