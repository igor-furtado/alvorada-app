abstract class ConcursoInput {
  const ConcursoInput({
    required this.instituicao,
    required this.cargo,
    this.banca,
    this.dataProva,
    this.prioritario = false,
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

class CreateConcursoInput extends ConcursoInput {
  const CreateConcursoInput({
    required super.instituicao,
    required super.cargo,
    super.banca,
    super.dataProva,
    super.prioritario,
    super.sigla,
    super.quantidadeVagas,
    super.vencimentoCentavos,
    super.cargaHorariaSemanal,
    super.localProva,
    super.horarioInicioProva,
    super.horarioFimProva,
    super.requisitos,
    super.criteriosPontuacao,
  });
}

class UpdateConcursoInput extends ConcursoInput {
  const UpdateConcursoInput({
    required super.instituicao,
    required super.cargo,
    super.banca,
    super.dataProva,
    super.prioritario,
    super.sigla,
    super.quantidadeVagas,
    super.vencimentoCentavos,
    super.cargaHorariaSemanal,
    super.localProva,
    super.horarioInicioProva,
    super.horarioFimProva,
    super.requisitos,
    super.criteriosPontuacao,
  });
}
