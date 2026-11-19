enum TipoItemSemana { estudoInicial, revisao }

class ItemSemana {
  const ItemSemana({
    required this.id,
    required this.tipo,
    required this.concursoId,
    required this.concursoNome,
    required this.concursoSigla,
    required this.topicoId,
    required this.topicoNome,
    required this.disciplinaNome,
    required this.dataPlanejada,
    required this.posicaoDia,
    required this.teoriaConcluida,
    required this.memoriaConcluida,
    required this.conferenciaConcluida,
    required this.acertos,
    required this.erros,
    required this.versaoMetodologia,
    required this.concluido,
    required this.intervaloRevisaoDias,
  });

  final String id;
  final TipoItemSemana tipo;
  final String concursoId;
  final String concursoNome;
  final String? concursoSigla;
  final String topicoId;
  final String topicoNome;
  final String disciplinaNome;
  final DateTime dataPlanejada;
  final int posicaoDia;
  final bool teoriaConcluida;
  final bool memoriaConcluida;
  final bool conferenciaConcluida;
  final int acertos;
  final int erros;
  final int? versaoMetodologia;
  final bool concluido;
  final int? intervaloRevisaoDias;

  String get rotuloConcurso => concursoSigla ?? concursoNome;
  int get totalQuestoes => acertos + erros;
  double? get desempenho => totalQuestoes == 0 ? null : acertos / totalQuestoes;

  ItemSemana copyWith({
    bool? teoriaConcluida,
    bool? memoriaConcluida,
    bool? conferenciaConcluida,
    int? acertos,
    int? erros,
    bool? concluido,
    DateTime? dataPlanejada,
  }) => ItemSemana(
    id: id,
    tipo: tipo,
    concursoId: concursoId,
    concursoNome: concursoNome,
    concursoSigla: concursoSigla,
    topicoId: topicoId,
    topicoNome: topicoNome,
    disciplinaNome: disciplinaNome,
    dataPlanejada: dataPlanejada ?? this.dataPlanejada,
    posicaoDia: posicaoDia,
    teoriaConcluida: teoriaConcluida ?? this.teoriaConcluida,
    memoriaConcluida: memoriaConcluida ?? this.memoriaConcluida,
    conferenciaConcluida: conferenciaConcluida ?? this.conferenciaConcluida,
    acertos: acertos ?? this.acertos,
    erros: erros ?? this.erros,
    versaoMetodologia: versaoMetodologia,
    concluido: concluido ?? this.concluido,
    intervaloRevisaoDias: intervaloRevisaoDias,
  );
}

class TopicoDisponivelSemana {
  const TopicoDisponivelSemana({
    required this.concursoId,
    required this.concursoNome,
    required this.concursoSigla,
    required this.topicoId,
    required this.topicoNome,
    required this.disciplinaNome,
  });

  final String concursoId;
  final String concursoNome;
  final String? concursoSigla;
  final String topicoId;
  final String topicoNome;
  final String disciplinaNome;

  String get rotuloConcurso => concursoSigla ?? concursoNome;
}

class PlanejamentoSemanal {
  PlanejamentoSemanal({
    required this.inicio,
    required this.fim,
    required List<ItemSemana> itens,
    required List<TopicoDisponivelSemana> disponiveis,
  }) : itens = List.unmodifiable(itens),
       disponiveis = List.unmodifiable(disponiveis);

  final DateTime inicio;
  final DateTime fim;
  final List<ItemSemana> itens;
  final List<TopicoDisponivelSemana> disponiveis;
}

class ProgressoTopicoInput {
  const ProgressoTopicoInput({
    this.teoriaConcluida,
    this.memoriaConcluida,
    this.conferenciaConcluida,
  });

  final bool? teoriaConcluida;
  final bool? memoriaConcluida;
  final bool? conferenciaConcluida;
}

enum ResultadoQuestao { certa, errada }
