import 'package:bloc/bloc.dart';
import 'package:estudos_app/core/result.dart';

import '../../domain/models/planejamento_semanal.dart';
import '../../domain/use_cases/semana_use_cases.dart';
import 'semana_event.dart';
import 'semana_state.dart';

class SemanaBloc extends Bloc<SemanaEvent, SemanaState> {
  SemanaBloc({required this.useCases}) : super(SemanaState()) {
    on<SemanaLoadRequested>(_onLoad);
    on<SemanaChanged>(_onWeekChanged);
    on<SemanaConcursoFilterChanged>(_onFilterChanged);
    on<SemanaHideCompletedChanged>(_onHideCompleted);
    on<SemanaTopicoPlanejado>(_onTopicScheduled);
    on<SemanaItemMoved>(_onItemMoved);
    on<SemanaRevisaoConcluida>(_onReviewCompleted);
  }

  final SemanaUseCases useCases;

  Future<void> _onLoad(SemanaLoadRequested event, Emitter<SemanaState> emit) async {
    emit(state.copyWith(status: SemanaStatus.loading));
    await _load(emit);
  }

  Future<void> _onWeekChanged(SemanaChanged event, Emitter<SemanaState> emit) async {
    emit(
      state.copyWith(
        inicio: state.inicio.add(Duration(days: event.offset * 7)),
        status: SemanaStatus.loading,
      ),
    );
    await _load(emit);
  }

  void _onFilterChanged(SemanaConcursoFilterChanged event, Emitter<SemanaState> emit) {
    emit(state.copyWith(concursoFiltro: event.concursoId));
  }

  void _onHideCompleted(SemanaHideCompletedChanged event, Emitter<SemanaState> emit) {
    emit(state.copyWith(ocultarConcluidos: !state.ocultarConcluidos));
  }

  Future<void> _onTopicScheduled(SemanaTopicoPlanejado event, Emitter<SemanaState> emit) => _mutate(
    emit,
    () => useCases.planejar(
      concursoId: event.topico.concursoId,
      topicoId: event.topico.topicoId,
      data: event.data,
    ),
  );

  Future<void> _onItemMoved(SemanaItemMoved event, Emitter<SemanaState> emit) => _mutate(
    emit,
    () => event.item.tipo == TipoItemSemana.revisao
        ? useCases.moverRevisao(revisaoId: event.item.id, data: event.data)
        : useCases.planejar(
            concursoId: event.item.concursoId,
            topicoId: event.item.topicoId,
            data: event.data,
          ),
  );

  Future<void> _onReviewCompleted(SemanaRevisaoConcluida event, Emitter<SemanaState> emit) =>
      _mutate(emit, () => useCases.concluirRevisao(event.revisaoId));

  Future<void> _mutate(
    Emitter<SemanaState> emit,
    Future<Resultado<void>> Function() operation,
  ) async {
    if (state.mutating) return;
    emit(state.copyWith(mutating: true));
    final result = await operation();
    switch (result) {
      case Sucesso<void>():
        await _load(emit, mutating: false);
      case ViolacaoRegra<void>() || FalhaTecnica<void>():
        emit(state.copyWith(mutating: false));
    }
  }

  Future<void> _load(Emitter<SemanaState> emit, {bool mutating = false}) async {
    final result = await useCases.carregar(state.inicio, state.fim);
    switch (result) {
      case Sucesso<PlanejamentoSemanal>(:final valor):
        final filter = state.concursoFiltro;
        final knownIds = {
          for (final item in valor.itens) item.concursoId,
          for (final item in valor.disponiveis) item.concursoId,
        };
        emit(
          state.copyWith(
            status: SemanaStatus.success,
            itens: valor.itens,
            disponiveis: valor.disponiveis,
            concursoFiltro: filter != null && knownIds.contains(filter) ? filter : null,
            mutating: mutating,
          ),
        );
      case ViolacaoRegra<PlanejamentoSemanal>() || FalhaTecnica<PlanejamentoSemanal>():
        emit(state.copyWith(status: SemanaStatus.failure, mutating: mutating));
    }
  }
}
