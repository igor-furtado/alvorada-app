import 'package:bloc/bloc.dart';
import 'package:estudos_app/core/result.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/get_disciplinas_use_case.dart';

import '../../domain/models/concurso.dart';
import '../../domain/use_cases/edital_use_cases.dart';
import 'edital_editor_event.dart';
import 'edital_editor_state.dart';

class EditalEditorBloc extends Bloc<EditalEditorEvent, EditalEditorState> {
  factory EditalEditorBloc({
    required Concurso concurso,
    required GetDisciplinasUseCase getDisciplinas,
    required EditalUseCases edital,
  }) => EditalEditorBloc._(concurso, getDisciplinas, edital);

  EditalEditorBloc._(Concurso concurso, this._getDisciplinas, this._edital)
    : _concursoId = concurso.id,
      super(_initialState(concurso)) {
    on<EditalEditorLoaded>(_onLoad);
    on<EditalEditorRetried>(_onRetry);
    on<EditalEditorTopicoToggled>(_onToggleTopico);
    on<EditalEditorDisciplinaSelected>(_onSelectDisciplina);
    on<EditalEditorDisciplinaSelectionChanged>(_onChangeDisciplinaSelection);
    on<EditalEditorTopicoSearched>(_onSearchTopico);
    on<EditalEditorSaved>(_onSave);
  }

  final String _concursoId;
  final GetDisciplinasUseCase _getDisciplinas;
  final EditalUseCases _edital;

  static EditalEditorState _initialState(Concurso concurso) {
    final vinculados = {
      for (final disciplina in concurso.disciplinas)
        for (final topico in disciplina.topicos)
          if (!topico.obrigatorio) topico.id,
    };
    return EditalEditorState(
      topicosOriginais: vinculados,
      topicosVinculados: vinculados,
    );
  }

  Future<void> _onLoad(EditalEditorLoaded event, Emitter<EditalEditorState> emit) => _load(emit);

  Future<void> _onRetry(EditalEditorRetried event, Emitter<EditalEditorState> emit) => _load(emit);

  Future<void> _load(Emitter<EditalEditorState> emit) async {
    emit(state.copyWith(status: EditalEditorStatus.loading, feedback: null));
    final result = await _getDisciplinas(forceRefresh: true);
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        final selectionExists = valor.any((item) => item.id == state.disciplinaSelecionada);
        emit(
          state.copyWith(
            status: EditalEditorStatus.ready,
            catalogo: valor,
            disciplinaSelecionada: selectionExists ? state.disciplinaSelecionada : valor.firstOrNull?.id,
          ),
        );
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(state.copyWith(status: EditalEditorStatus.failure));
    }
  }

  void _onToggleTopico(EditalEditorTopicoToggled event, Emitter<EditalEditorState> emit) {
    if (state.saving || event.topico.mandatory) return;
    final vinculados = {...state.topicosVinculados};
    vinculados.contains(event.topico.id) ? vinculados.remove(event.topico.id) : vinculados.add(event.topico.id);
    emit(state.copyWith(topicosVinculados: vinculados, feedback: null));
  }

  void _onSelectDisciplina(EditalEditorDisciplinaSelected event, Emitter<EditalEditorState> emit) {
    if (state.saving) return;
    emit(state.copyWith(disciplinaSelecionada: event.disciplinaId));
  }

  void _onChangeDisciplinaSelection(
    EditalEditorDisciplinaSelectionChanged event,
    Emitter<EditalEditorState> emit,
  ) {
    if (state.saving) return;
    final ids = event.disciplina.topics.where((item) => !item.mandatory).map((item) => item.id);
    final vinculados = {...state.topicosVinculados};
    event.selected ? vinculados.addAll(ids) : vinculados.removeAll(ids);
    emit(state.copyWith(topicosVinculados: vinculados, feedback: null));
  }

  void _onSearchTopico(EditalEditorTopicoSearched event, Emitter<EditalEditorState> emit) {
    if (state.saving) return;
    final searched = state.copyWith(buscaTopico: event.query);
    final selectionMatches = searched.disciplinasAtivas.any(
      (disciplina) => disciplina.id == searched.disciplinaSelecionada,
    );
    emit(
      searched.copyWith(
        disciplinaSelecionada: selectionMatches
            ? searched.disciplinaSelecionada
            : searched.disciplinasAtivas.firstOrNull?.id,
      ),
    );
  }

  Future<void> _onSave(EditalEditorSaved event, Emitter<EditalEditorState> emit) async {
    if (state.saving || !state.temAlteracoes) return;
    emit(state.copyWith(saving: true, feedback: null));

    final persisted = {...state.topicosOriginais};
    final desired = {...state.topicosVinculados};
    final ordered = [
      for (final disciplina in state.catalogo)
        for (final topico in disciplina.topics)
          if (!topico.mandatory) topico.id,
    ];

    for (final id in ordered.where((id) => persisted.contains(id) && !desired.contains(id))) {
      final result = await _edital.removeTopico(concursoId: _concursoId, topicoId: id);
      switch (result) {
        case Sucesso<void>():
          persisted.remove(id);
        case ViolacaoRegra<void>():
          return _emitSaveFailure(emit, persisted, EditalEditorFeedback.violacaoRegra);
        case FalhaTecnica<void>():
          return _emitSaveFailure(emit, persisted, EditalEditorFeedback.falhaTecnica);
      }
    }

    for (final id in ordered.where((id) => desired.contains(id) && !persisted.contains(id))) {
      final result = await _edital.addTopico(concursoId: _concursoId, topicoId: id);
      switch (result) {
        case Sucesso<void>():
          persisted.add(id);
        case ViolacaoRegra<void>():
          return _emitSaveFailure(emit, persisted, EditalEditorFeedback.violacaoRegra);
        case FalhaTecnica<void>():
          return _emitSaveFailure(emit, persisted, EditalEditorFeedback.falhaTecnica);
      }
    }

    emit(
      state.copyWith(
        topicosOriginais: persisted,
        saving: false,
        feedback: EditalEditorFeedback.editalSalvo,
      ),
    );
  }

  void _emitSaveFailure(
    Emitter<EditalEditorState> emit,
    Set<String> persisted,
    EditalEditorFeedback feedback,
  ) => emit(
    state.copyWith(
      topicosOriginais: persisted,
      saving: false,
      feedback: feedback,
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
