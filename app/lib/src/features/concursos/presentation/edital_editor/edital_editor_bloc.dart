import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../../disciplinas/domain/models/disciplina.dart';
import '../../../disciplinas/domain/use_cases/get_disciplinas_use_case.dart';
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
      super(
        EditalEditorState(
          topicosVinculados: {
            for (final disciplina in concurso.disciplinas)
              for (final topico in disciplina.topicos)
                if (!topico.obrigatorio) topico.id,
          },
        ),
      ) {
    on<EditalEditorLoaded>(_onLoad);
    on<EditalEditorRetried>(_onRetry);
    on<EditalEditorDisciplinaAdded>(_onAddDisciplina);
    on<EditalEditorTopicoToggled>(_onToggleTopico);
    on<EditalEditorDisciplinaSelected>(_onSelectDisciplina);
    on<EditalEditorDisciplinaSearched>(_onSearchDisciplina);
    on<EditalEditorTopicoSearched>(_onSearchTopico);
  }

  final String _concursoId;
  final GetDisciplinasUseCase _getDisciplinas;
  final EditalUseCases _edital;

  Future<void> _onLoad(EditalEditorLoaded event, Emitter<EditalEditorState> emit) => _load(emit);

  Future<void> _onRetry(EditalEditorRetried event, Emitter<EditalEditorState> emit) => _load(emit);

  Future<void> _load(Emitter<EditalEditorState> emit) async {
    emit(state.copyWith(status: EditalEditorStatus.loading, feedback: null));
    final result = await _getDisciplinas(forceRefresh: true);
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        final vinculadas = valor.where(state.disciplinaEstaVinculada).toList(growable: false);
        emit(
          state.copyWith(
            status: EditalEditorStatus.ready,
            catalogo: valor,
            disciplinaSelecionada: vinculadas.firstOrNull?.id,
          ),
        );
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(state.copyWith(status: EditalEditorStatus.failure));
    }
  }

  Future<void> _onAddDisciplina(
    EditalEditorDisciplinaAdded event,
    Emitter<EditalEditorState> emit,
  ) async {
    final comuns = event.disciplina.topics.where((topico) => !topico.mandatory).toList(growable: false);
    if (comuns.isEmpty || state.mutation != null) return;
    emit(
      state.copyWith(
        feedback: null,
        mutation: EditalEditorMutation(
          type: EditalEditorMutationType.disciplina,
          id: event.disciplina.id,
        ),
      ),
    );
    final result = await _edital.addDisciplina(
      concursoId: _concursoId,
      disciplinaId: event.disciplina.id,
    );
    switch (result) {
      case Sucesso<void>():
        emit(
          state.copyWith(
            topicosVinculados: {...state.topicosVinculados, ...comuns.map((item) => item.id)},
            disciplinaSelecionada: state.disciplinaSelecionada ?? event.disciplina.id,
            mutation: null,
            feedback: EditalEditorFeedback.disciplinaAdicionada,
          ),
        );
      case ViolacaoRegra<void>():
        _emitMutationFailure(emit, EditalEditorFeedback.violacaoRegra);
      case FalhaTecnica<void>():
        _emitMutationFailure(emit, EditalEditorFeedback.falhaTecnica);
    }
  }

  Future<void> _onToggleTopico(
    EditalEditorTopicoToggled event,
    Emitter<EditalEditorState> emit,
  ) async {
    if (state.mutation != null || event.topico.mandatory) return;
    final vinculado = state.topicosVinculados.contains(event.topico.id);
    emit(
      state.copyWith(
        feedback: null,
        mutation: EditalEditorMutation(
          type: EditalEditorMutationType.topico,
          id: event.topico.id,
        ),
      ),
    );
    final result = vinculado
        ? await _edital.removeTopico(concursoId: _concursoId, topicoId: event.topico.id)
        : await _edital.addTopico(concursoId: _concursoId, topicoId: event.topico.id);
    switch (result) {
      case Sucesso<void>():
        final vinculados = {...state.topicosVinculados};
        vinculado ? vinculados.remove(event.topico.id) : vinculados.add(event.topico.id);
        emit(
          state.copyWith(
            topicosVinculados: vinculados,
            disciplinaSelecionada: _normalizedSelection(vinculados),
            mutation: null,
            feedback: vinculado ? EditalEditorFeedback.topicoRemovido : EditalEditorFeedback.topicoAdicionado,
          ),
        );
      case ViolacaoRegra<void>():
        _emitMutationFailure(emit, EditalEditorFeedback.violacaoRegra);
      case FalhaTecnica<void>():
        _emitMutationFailure(emit, EditalEditorFeedback.falhaTecnica);
    }
  }

  void _onSelectDisciplina(
    EditalEditorDisciplinaSelected event,
    Emitter<EditalEditorState> emit,
  ) => emit(state.copyWith(disciplinaSelecionada: event.disciplinaId));

  void _onSearchDisciplina(
    EditalEditorDisciplinaSearched event,
    Emitter<EditalEditorState> emit,
  ) => emit(state.copyWith(buscaDisciplina: event.query));

  void _onSearchTopico(
    EditalEditorTopicoSearched event,
    Emitter<EditalEditorState> emit,
  ) => emit(state.copyWith(buscaTopico: event.query));

  String? _normalizedSelection(Set<String> vinculados) {
    bool linked(Disciplina disciplina) => disciplina.topics.any(
      (topico) => !topico.mandatory && vinculados.contains(topico.id),
    );
    final disciplinas = state.catalogo.where(linked).toList(growable: false);
    if (disciplinas.any((item) => item.id == state.disciplinaSelecionada)) {
      return state.disciplinaSelecionada;
    }
    return disciplinas.firstOrNull?.id;
  }

  void _emitMutationFailure(
    Emitter<EditalEditorState> emit,
    EditalEditorFeedback feedback,
  ) => emit(
    state.copyWith(
      mutation: null,
      feedback: feedback,
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
