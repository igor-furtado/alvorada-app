import 'package:flutter/foundation.dart';

import '../../domain/models/concurso.dart';
import 'concurso_details_event.dart';

enum ConcursoDetailsStatus { initial, loading, success, notFound, failure }

@immutable
class ConcursoDetailsState {
  const ConcursoDetailsState({
    this.status = ConcursoDetailsStatus.initial,
    this.concurso,
    this.query = '',
    this.tab = ConcursoDetailsTab.edital,
    this.isRefreshing = false,
    this.refreshFailed = false,
  });

  final ConcursoDetailsStatus status;
  final Concurso? concurso;
  final String query;
  final ConcursoDetailsTab tab;
  final bool isRefreshing;
  final bool refreshFailed;

  ConcursoDetailsState copyWith({
    ConcursoDetailsStatus? status,
    Concurso? concurso,
    String? query,
    ConcursoDetailsTab? tab,
    bool? isRefreshing,
    bool? refreshFailed,
  }) => ConcursoDetailsState(
    status: status ?? this.status,
    concurso: concurso ?? this.concurso,
    query: query ?? this.query,
    tab: tab ?? this.tab,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    refreshFailed: refreshFailed ?? this.refreshFailed,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConcursoDetailsState &&
          status == other.status &&
          concurso == other.concurso &&
          query == other.query &&
          tab == other.tab &&
          isRefreshing == other.isRefreshing &&
          refreshFailed == other.refreshFailed;

  @override
  int get hashCode => Object.hash(status, concurso, query, tab, isRefreshing, refreshFailed);
}
