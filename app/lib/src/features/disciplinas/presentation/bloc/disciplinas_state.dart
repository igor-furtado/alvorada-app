import '../../domain/models/disciplina.dart';

enum DisciplinasStatus { initial, loading, success, failure }

enum DisciplinasFeedback {
  disciplinasAtualizadas,
  disciplinaCriada,
  disciplinaAtualizada,
  disciplinaExcluida,
  topicoCriado,
  topicoAtualizado,
  topicoExcluido,
  subtopicoCriado,
  subtopicoAtualizado,
  subtopicoExcluido,
  atualizacaoFalhou,
  operacaoFalhou,
}

class DisciplinasState {
  DisciplinasState({
    this.status = DisciplinasStatus.initial,
    List<Disciplina> disciplinas = const [],
    this.query = '',
    Set<String> expandedTopicIds = const {},
    this.isRefreshing = false,
    this.isMutating = false,
    this.feedback,
  }) : disciplinas = List.unmodifiable(disciplinas),
       expandedTopicIds = Set.unmodifiable(expandedTopicIds);

  final DisciplinasStatus status;
  final List<Disciplina> disciplinas;
  final String query;
  final Set<String> expandedTopicIds;
  final bool isRefreshing;
  final bool isMutating;
  final DisciplinasFeedback? feedback;

  List<Disciplina> get disciplinasVisiveis {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return disciplinas;
    return disciplinas
        .where(
          (disciplina) =>
              disciplina.name.toLowerCase().contains(normalizedQuery) ||
              disciplina.topics.any(
                (topico) =>
                    topico.name.toLowerCase().contains(normalizedQuery) ||
                    topico.subtopics.any(
                      (subtopico) => subtopico.name.toLowerCase().contains(normalizedQuery),
                    ),
              ),
        )
        .toList(growable: false);
  }

  DisciplinasState copyWith({
    DisciplinasStatus? status,
    List<Disciplina>? disciplinas,
    String? query,
    Set<String>? expandedTopicIds,
    bool? isRefreshing,
    bool? isMutating,
    Object? feedback = _unchanged,
  }) => DisciplinasState(
    status: status ?? this.status,
    disciplinas: disciplinas ?? this.disciplinas,
    query: query ?? this.query,
    expandedTopicIds: expandedTopicIds ?? this.expandedTopicIds,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isMutating: isMutating ?? this.isMutating,
    feedback: identical(feedback, _unchanged) ? this.feedback : feedback as DisciplinasFeedback?,
  );
}

const _unchanged = Object();
