class CreateConcursoInput {
  const CreateConcursoInput({
    required this.instituicao,
    required this.cargo,
    this.banca,
    this.dataProva,
    this.prioritario = false,
  });

  final String instituicao;
  final String cargo;
  final String? banca;
  final DateTime? dataProva;
  final bool prioritario;
}
