import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/disciplina.dart';
import '../../domain/use_cases/delete_disciplina_use_case.dart';
import '../../domain/use_cases/disciplinas_resultado_codes.dart';
import '../../domain/use_cases/get_disciplinas_use_case.dart';
import 'disciplinas_list_event.dart';
import 'disciplinas_list_state.dart';

class DisciplinasListBloc extends Bloc<DisciplinasListEvent, DisciplinasListState> {
  DisciplinasListBloc({
    required this.getDisciplinas,
    required this.deleteDisciplina,
    String initialQuery = '',
  }) : super(
         DisciplinasListState(
           query: initialQuery,
         ),
       ) {
    on<DisciplinasListLoadRequested>(_onLoad);
    on<DisciplinasListRefreshRequested>(_onRefresh);
    on<DisciplinasListSearchChanged>(_onSearchChanged);
    on<DisciplinasListSelectionChanged>(_onSelectionChanged);
    on<DisciplinasListDeleteRequested>(_onDelete);
  }

  final GetDisciplinasUseCase getDisciplinas;
  final DeleteDisciplinaUseCase deleteDisciplina;
  List<Disciplina> _catalog = const [];
  String? _preferredDisciplineId;

  Future<void> _onLoad(
    DisciplinasListLoadRequested event,
    Emitter<DisciplinasListState> emit,
  ) async {
    emit(_state(status: DisciplinasListStatus.loading, feedback: null));
    final result = await getDisciplinas(forceRefresh: true);
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        _catalog = valor;
        emit(_state(status: DisciplinasListStatus.success, feedback: null));
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(_state(status: DisciplinasListStatus.failure));
    }
  }

  Future<void> _onRefresh(
    DisciplinasListRefreshRequested event,
    Emitter<DisciplinasListState> emit,
  ) async {
    if (state.isRefreshing || state.isDeleting) return;
    emit(_state(isRefreshing: true, feedback: null));
    final result = await getDisciplinas(forceRefresh: event.forceRefresh);
    switch (result) {
      case Sucesso<List<Disciplina>>(:final valor):
        _catalog = valor;
        emit(
          _state(
            status: DisciplinasListStatus.success,
            isRefreshing: false,
            feedback: event.feedback,
          ),
        );
      case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
        emit(
          _state(
            isRefreshing: false,
            feedback: DisciplinasListFeedback.refreshFailed,
          ),
        );
    }
  }

  void _onSearchChanged(
    DisciplinasListSearchChanged event,
    Emitter<DisciplinasListState> emit,
  ) => emit(_state(query: event.query, feedback: null));

  void _onSelectionChanged(
    DisciplinasListSelectionChanged event,
    Emitter<DisciplinasListState> emit,
  ) {
    _preferredDisciplineId = event.disciplineId;
    emit(_state());
  }

  Future<void> _onDelete(
    DisciplinasListDeleteRequested event,
    Emitter<DisciplinasListState> emit,
  ) async {
    if (state.isDeleting || state.isRefreshing) return;
    emit(_state(isDeleting: true, feedback: null));
    final result = await deleteDisciplina(event.disciplineId);
    switch (result) {
      case Sucesso<void>():
        final catalogResult = await getDisciplinas();
        switch (catalogResult) {
          case Sucesso<List<Disciplina>>(:final valor):
            _catalog = valor;
            emit(
              _state(
                isDeleting: false,
                feedback: DisciplinasListFeedback.deleted,
              ),
            );
          case ViolacaoRegra<List<Disciplina>>() || FalhaTecnica<List<Disciplina>>():
            emit(
              _state(
                isDeleting: false,
                feedback: DisciplinasListFeedback.refreshFailed,
              ),
            );
        }
      case FalhaTecnica<void>(
        codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      ):
        emit(
          _state(
            isDeleting: false,
            feedback: DisciplinasListFeedback.synchronizationPending,
          ),
        );
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(
          _state(
            isDeleting: false,
            feedback: DisciplinasListFeedback.operationFailed,
          ),
        );
    }
  }

  DisciplinasListState _state({
    DisciplinasListStatus? status,
    String? query,
    bool? isRefreshing,
    bool? isDeleting,
    Object? feedback = _unchanged,
  }) {
    final effectiveQuery = query ?? state.query;
    if (_preferredDisciplineId != null && !_catalog.any((item) => item.id == _preferredDisciplineId)) {
      _preferredDisciplineId = null;
    }
    _preferredDisciplineId ??= _catalog.firstOrNull?.id;
    final items = _visibleItems(effectiveQuery);
    final selectedId = items.any((item) => item.id == _preferredDisciplineId)
        ? _preferredDisciplineId
        : items.firstOrNull?.id;
    return DisciplinasListState(
      status: status ?? state.status,
      items: items,
      query: effectiveQuery,
      selectedDisciplineId: selectedId,
      isRefreshing: isRefreshing ?? state.isRefreshing,
      isDeleting: isDeleting ?? state.isDeleting,
      feedback: identical(feedback, _unchanged) ? state.feedback : feedback as DisciplinasListFeedback?,
    );
  }

  List<DisciplinaListItemData> _visibleItems(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    final items = <DisciplinaListItemData>[
      for (final disciplina in _catalog)
        if (normalizedQuery.isEmpty || _matches(disciplina, normalizedQuery))
          DisciplinaListItemData(
            id: disciplina.id,
            name: disciplina.name,
            topicCount: disciplina.topics.length,
          ),
    ];
    return items;
  }

  bool _matches(Disciplina disciplina, String query) =>
      disciplina.name.toLowerCase().contains(query) ||
      disciplina.topics.any((topic) => topic.name.toLowerCase().contains(query));
}

const _unchanged = Object();
