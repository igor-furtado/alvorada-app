import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:flutter/foundation.dart';

enum EditalEditorStatus { initial, loading, ready, failure }

enum EditalEditorFeedback { editalSalvo, violacaoRegra, falhaTecnica }

class EditalEditorState {
  factory EditalEditorState({
    EditalEditorStatus status = EditalEditorStatus.initial,
    List<Disciplina> catalogo = const [],
    Set<String> topicosOriginais = const {},
    Set<String> topicosVinculados = const {},
    String? disciplinaSelecionada,
    bool saving = false,
    EditalEditorFeedback? feedback,
    String buscaTopico = '',
  }) => EditalEditorState._(
    status: status,
    catalogo: List.unmodifiable(catalogo),
    topicosOriginais: Set.unmodifiable(topicosOriginais),
    topicosVinculados: Set.unmodifiable(topicosVinculados),
    disciplinaSelecionada: disciplinaSelecionada,
    saving: saving,
    feedback: feedback,
    buscaTopico: buscaTopico,
  );

  const EditalEditorState._({
    required this.status,
    required this.catalogo,
    required this.topicosOriginais,
    required this.topicosVinculados,
    required this.disciplinaSelecionada,
    required this.saving,
    required this.feedback,
    required this.buscaTopico,
  });

  final EditalEditorStatus status;
  final List<Disciplina> catalogo;
  final Set<String> topicosOriginais;
  final Set<String> topicosVinculados;
  final String? disciplinaSelecionada;
  final bool saving;
  final EditalEditorFeedback? feedback;
  final String buscaTopico;

  Disciplina? get disciplinaAtiva {
    for (final disciplina in catalogo) {
      if (disciplina.id == disciplinaSelecionada) return disciplina;
    }
    return null;
  }

  List<Topico> get topicosAtivos {
    final query = buscaTopico.trim().toLowerCase();
    return List.unmodifiable(
      (disciplinaAtiva?.topics ?? const <Topico>[]).where(
        (topico) => query.isEmpty || topico.name.toLowerCase().contains(query),
      ),
    );
  }

  int quantidadeSelecionada(Disciplina disciplina) =>
      disciplina.topics.where((topico) => !topico.mandatory && topicosVinculados.contains(topico.id)).length;

  int get totalSelecionado => topicosVinculados.length;

  bool get temAlteracoes => !setEquals(topicosOriginais, topicosVinculados);

  EditalEditorState copyWith({
    EditalEditorStatus? status,
    List<Disciplina>? catalogo,
    Set<String>? topicosOriginais,
    Set<String>? topicosVinculados,
    Object? disciplinaSelecionada = _unset,
    bool? saving,
    Object? feedback = _unset,
    String? buscaTopico,
  }) => EditalEditorState(
    status: status ?? this.status,
    catalogo: catalogo ?? this.catalogo,
    topicosOriginais: topicosOriginais ?? this.topicosOriginais,
    topicosVinculados: topicosVinculados ?? this.topicosVinculados,
    disciplinaSelecionada: disciplinaSelecionada == _unset
        ? this.disciplinaSelecionada
        : disciplinaSelecionada as String?,
    saving: saving ?? this.saving,
    feedback: feedback == _unset ? this.feedback : feedback as EditalEditorFeedback?,
    buscaTopico: buscaTopico ?? this.buscaTopico,
  );
}

const _unset = Object();
