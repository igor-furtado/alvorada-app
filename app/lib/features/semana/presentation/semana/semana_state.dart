import '../../domain/models/planejamento_semanal.dart';

enum SemanaStatus { initial, loading, success, failure }

class SemanaState {
  SemanaState({
    this.status = SemanaStatus.initial,
    DateTime? inicio,
    List<ItemSemana> itens = const [],
    List<TopicoDisponivelSemana> disponiveis = const [],
    this.concursoFiltro,
    this.ocultarConcluidos = false,
    this.mutating = false,
  }) : inicio = inicio ?? inicioDaSemana(DateTime.now()),
       itens = List.unmodifiable(itens),
       disponiveis = List.unmodifiable(disponiveis);

  final SemanaStatus status;
  final DateTime inicio;
  final List<ItemSemana> itens;
  final List<TopicoDisponivelSemana> disponiveis;
  final String? concursoFiltro;
  final bool ocultarConcluidos;
  final bool mutating;

  DateTime get fim => inicio.add(const Duration(days: 6));

  List<ItemSemana> get itensVisiveis => itens
      .where((item) => concursoFiltro == null || item.concursoId == concursoFiltro)
      .where((item) => !ocultarConcluidos || !item.concluido)
      .toList(growable: false);

  Set<String> get concursos => {
    for (final item in itens) item.concursoId,
    for (final item in disponiveis) item.concursoId,
  };

  String rotuloConcurso(String id) {
    for (final item in itens) {
      if (item.concursoId == id) return item.rotuloConcurso;
    }
    for (final item in disponiveis) {
      if (item.concursoId == id) return item.rotuloConcurso;
    }
    return id;
  }

  SemanaState copyWith({
    SemanaStatus? status,
    DateTime? inicio,
    List<ItemSemana>? itens,
    List<TopicoDisponivelSemana>? disponiveis,
    Object? concursoFiltro = _unchanged,
    bool? ocultarConcluidos,
    bool? mutating,
  }) => SemanaState(
    status: status ?? this.status,
    inicio: inicio ?? this.inicio,
    itens: itens ?? this.itens,
    disponiveis: disponiveis ?? this.disponiveis,
    concursoFiltro: identical(concursoFiltro, _unchanged) ? this.concursoFiltro : concursoFiltro as String?,
    ocultarConcluidos: ocultarConcluidos ?? this.ocultarConcluidos,
    mutating: mutating ?? this.mutating,
  );
}

const _unchanged = Object();

DateTime inicioDaSemana(DateTime value) {
  final date = DateTime(value.year, value.month, value.day);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}
