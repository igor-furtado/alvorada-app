sealed class ConcursosFormEvent {
  const ConcursosFormEvent();
}

final class ConcursosFormSubmitted extends ConcursosFormEvent {
  const ConcursosFormSubmitted({
    required this.instituicao,
    required this.cargo,
    required this.banca,
    required this.dataProva,
    required this.prioritario,
    this.sigla,
    this.quantidadeVagas,
    this.vencimentoCentavos,
    this.cargaHorariaSemanal,
    this.localProva,
    this.horarioInicioProva,
    this.horarioFimProva,
    this.requisitos,
    this.criteriosPontuacao,
  });

  final String instituicao;
  final String cargo;
  final String? banca;
  final DateTime? dataProva;
  final bool prioritario;
  final String? sigla;
  final int? quantidadeVagas;
  final int? vencimentoCentavos;
  final int? cargaHorariaSemanal;
  final String? localProva;
  final String? horarioInicioProva;
  final String? horarioFimProva;
  final String? requisitos;
  final String? criteriosPontuacao;
}
