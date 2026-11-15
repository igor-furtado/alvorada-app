import 'package:bloc/bloc.dart';
import 'package:estudos_app/core/result.dart';

import '../../domain/models/concurso.dart';
import '../../domain/use_cases/get_concurso_use_case.dart';
import 'concurso_details_event.dart';
import 'concurso_details_state.dart';

class ConcursoDetailsBloc extends Bloc<ConcursoDetailsEvent, ConcursoDetailsState> {
  ConcursoDetailsBloc({required this.concursoId, required this.getConcurso}) : super(const ConcursoDetailsState()) {
    on<ConcursoDetailsLoadRequested>(_onLoad);
    on<ConcursoDetailsQueryChanged>(_onQueryChanged);
    on<ConcursoDetailsTabChanged>(_onTabChanged);
  }

  final String concursoId;
  final GetConcursoUseCase getConcurso;

  Future<void> _onLoad(
    ConcursoDetailsLoadRequested event,
    Emitter<ConcursoDetailsState> emit,
  ) async {
    if (state.status == ConcursoDetailsStatus.loading || state.isRefreshing) return;
    final hasContent = state.concurso != null;
    emit(
      state.copyWith(
        status: hasContent ? ConcursoDetailsStatus.success : ConcursoDetailsStatus.loading,
        isRefreshing: hasContent,
        refreshFailed: false,
      ),
    );
    final result = await getConcurso(concursoId, forceRefresh: event.forceRefresh);
    switch (result) {
      case Sucesso<Concurso>(:final valor):
        emit(
          state.copyWith(
            status: ConcursoDetailsStatus.success,
            concurso: valor,
            isRefreshing: false,
          ),
        );
      case ViolacaoRegra<Concurso>():
        emit(state.copyWith(status: ConcursoDetailsStatus.notFound, isRefreshing: false));
      case FalhaTecnica<Concurso>():
        emit(
          state.copyWith(
            status: hasContent ? ConcursoDetailsStatus.success : ConcursoDetailsStatus.failure,
            isRefreshing: false,
            refreshFailed: hasContent,
          ),
        );
    }
  }

  void _onQueryChanged(ConcursoDetailsQueryChanged event, Emitter<ConcursoDetailsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onTabChanged(ConcursoDetailsTabChanged event, Emitter<ConcursoDetailsState> emit) {
    emit(state.copyWith(tab: event.tab));
  }
}
