class Concurso {
  Concurso({
    required this.id,
    required this.instituicao,
    required this.cargo,
    required this.banca,
    required this.dataProva,
    required this.prioritario,
    required this.progressoEdital,
  }) {
    if (id.trim().isEmpty) {
      throw const FormatException('O Concurso deve ter identificador.');
    }
    if (instituicao.trim().isEmpty) {
      throw const FormatException('O Concurso deve informar o órgão ou instituição.');
    }
    if (cargo.trim().isEmpty) {
      throw const FormatException('O Concurso deve informar o cargo.');
    }
    if (banca != null && banca!.trim().isEmpty) {
      throw const FormatException('A banca deve ser nula ou conter texto.');
    }
    if (progressoEdital < 0 || progressoEdital > 100) {
      throw const FormatException('O avanço no Edital deve estar entre 0 e 100.');
    }
  }

  final String id;
  final String instituicao;
  final String cargo;
  final String? banca;
  final DateTime? dataProva;
  final bool prioritario;
  final int progressoEdital;

  int? diasAteProva(DateTime referencia) {
    final prova = dataProva;
    if (prova == null) return null;
    final inicio = DateTime(referencia.year, referencia.month, referencia.day);
    final fim = DateTime(prova.year, prova.month, prova.day);
    final dias = fim.difference(inicio).inDays;
    return dias < 0 ? 0 : dias;
  }
}
