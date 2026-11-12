import '../../../disciplinas/domain/models/disciplina.dart';

enum EditalEditorStatus { initial, loading, ready, failure }

enum EditalEditorMutationType { disciplina, topico }

enum EditalEditorFeedback {
  disciplinaAdicionada,
  topicoAdicionado,
  topicoRemovido,
  violacaoRegra,
  falhaTecnica,
}

class EditalEditorMutation {
  const EditalEditorMutation({required this.type, required this.id});

  final EditalEditorMutationType type;
  final String id;

  bool matches(EditalEditorMutationType candidateType, String candidateId) =>
      type == candidateType && id == candidateId;
}

class EditalEditorState {
  factory EditalEditorState({
    EditalEditorStatus status = EditalEditorStatus.initial,
    List<Disciplina> catalogo = const [],
    Set<String> topicosVinculados = const {},
    String? disciplinaSelecionada,
    EditalEditorMutation? mutation,
    EditalEditorFeedback? feedback,
    String buscaDisciplina = '',
    String buscaTopico = '',
  }) => EditalEditorState._(
    status: status,
    catalogo: List.unmodifiable(catalogo),
    topicosVinculados: Set.unmodifiable(topicosVinculados),
    disciplinaSelecionada: disciplinaSelecionada,
    mutation: mutation,
    feedback: feedback,
    buscaDisciplina: buscaDisciplina,
    buscaTopico: buscaTopico,
  );

  const EditalEditorState._({
    required this.status,
    required this.catalogo,
    required this.topicosVinculados,
    required this.disciplinaSelecionada,
    required this.mutation,
    required this.feedback,
    required this.buscaDisciplina,
    required this.buscaTopico,
  });

  final EditalEditorStatus status;
  final List<Disciplina> catalogo;
  final Set<String> topicosVinculados;
  final String? disciplinaSelecionada;
  final EditalEditorMutation? mutation;
  final EditalEditorFeedback? feedback;
  final String buscaDisciplina;
  final String buscaTopico;

  List<Disciplina> get disciplinasFiltradas {
    final query = buscaDisciplina.trim().toLowerCase();
    return List.unmodifiable(
      catalogo.where((item) => query.isEmpty || item.name.toLowerCase().contains(query)),
    );
  }

  bool disciplinaEstaVinculada(Disciplina disciplina) => disciplina.topics.any(
    (topico) => !topico.mandatory && topicosVinculados.contains(topico.id),
  );

  EditalEditorState copyWith({
    EditalEditorStatus? status,
    List<Disciplina>? catalogo,
    Set<String>? topicosVinculados,
    Object? disciplinaSelecionada = _unset,
    Object? mutation = _unset,
    Object? feedback = _unset,
    String? buscaDisciplina,
    String? buscaTopico,
  }) => EditalEditorState(
    status: status ?? this.status,
    catalogo: catalogo ?? this.catalogo,
    topicosVinculados: topicosVinculados ?? this.topicosVinculados,
    disciplinaSelecionada: disciplinaSelecionada == _unset
        ? this.disciplinaSelecionada
        : disciplinaSelecionada as String?,
    mutation: mutation == _unset ? this.mutation : mutation as EditalEditorMutation?,
    feedback: feedback == _unset ? this.feedback : feedback as EditalEditorFeedback?,
    buscaDisciplina: buscaDisciplina ?? this.buscaDisciplina,
    buscaTopico: buscaTopico ?? this.buscaTopico,
  );
}

const _unset = Object();
