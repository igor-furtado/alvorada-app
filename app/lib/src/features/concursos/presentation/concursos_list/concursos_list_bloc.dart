import 'package:bloc/bloc.dart';

import '../../../../core/domain/resultado.dart';
import '../../domain/models/concurso.dart';
import '../../domain/use_cases/archive_concurso_use_case.dart';
import '../../domain/use_cases/concursos_resultado_codes.dart';
import '../../domain/use_cases/delete_concurso_use_case.dart';
import '../../domain/use_cases/get_concursos_use_case.dart';
import '../../domain/use_cases/restore_concurso_use_case.dart';
import '../../domain/use_cases/set_concurso_prioritario_use_case.dart';
import 'concursos_list_event.dart';
import 'concursos_list_state.dart';

class ConcursosListBloc extends Bloc<ConcursosListEvent, ConcursosListState> {
  ConcursosListBloc({
    required this.getConcursos,
    required this.setConcursoPrioritario,
    required this.archiveConcurso,
    required this.restoreConcurso,
    required this.deleteConcurso,
  }) : super(ConcursosListState()) {
    on<ConcursosListLoadRequested>(_onLoad);
    on<ConcursosListRefreshRequested>(_onRefresh);
    on<ConcursoPrioritarioSetRequested>(_onSetPrioritario);
    on<ConcursoArchiveRequested>(_onArchive);
    on<ConcursoRestoreRequested>(_onRestore);
    on<ConcursoDeleteRequested>(_onDelete);
  }

  final GetConcursosUseCase getConcursos;
  final SetConcursoPrioritarioUseCase setConcursoPrioritario;
  final ArchiveConcursoUseCase archiveConcurso;
  final RestoreConcursoUseCase restoreConcurso;
  final DeleteConcursoUseCase deleteConcurso;

  Future<void> _onLoad(
    ConcursosListLoadRequested event,
    Emitter<ConcursosListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ConcursosListStatus.loading,
        feedback: null,
      ),
    );
    final result = await getConcursos(forceRefresh: true);
    switch (result) {
      case Sucesso<List<Concurso>>(:final valor):
        emit(
          state.copyWith(
            status: ConcursosListStatus.success,
            items: valor,
          ),
        );
      case ViolacaoRegra<List<Concurso>>() || FalhaTecnica<List<Concurso>>():
        emit(state.copyWith(status: ConcursosListStatus.failure));
    }
  }

  Future<void> _onRefresh(
    ConcursosListRefreshRequested event,
    Emitter<ConcursosListState> emit,
  ) async {
    if (state.isRefreshing || state.isMutating) return;
    emit(state.copyWith(isRefreshing: true, feedback: null));
    final result = await getConcursos(forceRefresh: event.forceRefresh);
    switch (result) {
      case Sucesso<List<Concurso>>(:final valor):
        emit(
          state.copyWith(
            status: ConcursosListStatus.success,
            items: valor,
            isRefreshing: false,
            feedback: event.feedback,
          ),
        );
      case ViolacaoRegra<List<Concurso>>() || FalhaTecnica<List<Concurso>>():
        emit(
          state.copyWith(
            isRefreshing: false,
            feedback: const ConcursosListFeedback(
              ConcursosListFeedbackType.refreshFailed,
            ),
          ),
        );
    }
  }

  Future<void> _onSetPrioritario(
    ConcursoPrioritarioSetRequested event,
    Emitter<ConcursosListState> emit,
  ) => _mutate(
    emit,
    operation: () => setConcursoPrioritario(event.concursoId),
    success: const ConcursosListFeedback(
      ConcursosListFeedbackType.prioritized,
    ),
  );

  Future<void> _onArchive(
    ConcursoArchiveRequested event,
    Emitter<ConcursosListState> emit,
  ) {
    final concurso = _find(event.concursoId);
    if (concurso == null) return Future.value();
    return _mutate(
      emit,
      operation: () => archiveConcurso(event.concursoId),
      success: ConcursosListFeedback(
        ConcursosListFeedbackType.archived,
        concurso: concurso,
      ),
    );
  }

  Future<void> _onRestore(
    ConcursoRestoreRequested event,
    Emitter<ConcursosListState> emit,
  ) => _mutate(
    emit,
    operation: () => restoreConcurso(event.concursoId),
    success: const ConcursosListFeedback(
      ConcursosListFeedbackType.restored,
    ),
  );

  Future<void> _onDelete(
    ConcursoDeleteRequested event,
    Emitter<ConcursosListState> emit,
  ) => _mutate(
    emit,
    operation: () => deleteConcurso(event.concursoId),
    success: const ConcursosListFeedback(
      ConcursosListFeedbackType.deleted,
    ),
  );

  Future<void> _mutate(
    Emitter<ConcursosListState> emit, {
    required Future<Resultado<void>> Function() operation,
    required ConcursosListFeedback success,
  }) async {
    if (!state.canMutate) return;
    emit(state.copyWith(isMutating: true, feedback: null));
    final result = await operation();
    switch (result) {
      case Sucesso<void>():
        await _reloadAfterMutation(emit, success);
      case FalhaTecnica<void>(
        codigo: ConcursosResultadoCodes.sincronizacaoPendente,
      ):
        emit(
          state.copyWith(
            isMutating: false,
            feedback: const ConcursosListFeedback(
              ConcursosListFeedbackType.synchronizationPending,
            ),
          ),
        );
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(
          state.copyWith(
            isMutating: false,
            feedback: const ConcursosListFeedback(
              ConcursosListFeedbackType.operationFailed,
            ),
          ),
        );
    }
  }

  Future<void> _reloadAfterMutation(
    Emitter<ConcursosListState> emit,
    ConcursosListFeedback success,
  ) async {
    final result = await getConcursos();
    switch (result) {
      case Sucesso<List<Concurso>>(:final valor):
        emit(
          state.copyWith(
            items: valor,
            isMutating: false,
            feedback: success,
          ),
        );
      case ViolacaoRegra<List<Concurso>>() || FalhaTecnica<List<Concurso>>():
        emit(
          state.copyWith(
            isMutating: false,
            feedback: const ConcursosListFeedback(
              ConcursosListFeedbackType.synchronizationPending,
            ),
          ),
        );
    }
  }

  Concurso? _find(String id) {
    for (final concurso in state.items) {
      if (concurso.id == id) return concurso;
    }
    return null;
  }
}
