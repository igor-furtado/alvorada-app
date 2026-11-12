class Concurso {
  Concurso({
    required this.id,
    required this.instituicao,
    required this.cargo,
    required this.banca,
    required this.dataProva,
    required this.prioritario,
    required this.progressoEdital,
    this.sigla,
    this.quantidadeVagas,
    this.vencimentoCentavos,
    this.cargaHorariaSemanal,
    this.localProva,
    this.horarioInicioProva,
    this.horarioFimProva,
    this.requisitos,
    this.criteriosPontuacao,
    List<DisciplinaEdital> disciplinas = const [],
  }) : disciplinas = List.unmodifiable(disciplinas) {
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
    for (final field in [sigla, localProva, requisitos, criteriosPontuacao]) {
      if (field != null && field.trim().isEmpty) {
        throw const FormatException('Campos opcionais devem ser nulos ou conter texto.');
      }
    }
    if (quantidadeVagas != null && quantidadeVagas! < 0) {
      throw const FormatException('A quantidade de vagas não pode ser negativa.');
    }
    if (vencimentoCentavos != null && vencimentoCentavos! < 0) {
      throw const FormatException('O vencimento não pode ser negativo.');
    }
    if (cargaHorariaSemanal != null && (cargaHorariaSemanal! < 1 || cargaHorariaSemanal! > 168)) {
      throw const FormatException('A carga horária semanal deve estar entre 1 e 168 horas.');
    }
    if ((horarioInicioProva == null) != (horarioFimProva == null)) {
      throw const FormatException('Informe os horários de início e término da prova.');
    }
    if (horarioInicioProva != null &&
        (!_isTime(horarioInicioProva!) ||
            !_isTime(horarioFimProva!) ||
            horarioFimProva!.compareTo(horarioInicioProva!) <= 0)) {
      throw const FormatException('O término da prova deve ser posterior ao início.');
    }
    if (progressoEdital < 0 || progressoEdital > 100) {
      throw const FormatException('O avanço no Edital deve estar entre 0 e 100.');
    }
    if (_hasDuplicateIds(disciplinas.map((item) => item.id))) {
      throw const FormatException('O Edital não pode repetir uma Disciplina.');
    }
  }

  final String id;
  final String instituicao;
  final String cargo;
  final String? banca;
  final DateTime? dataProva;
  final bool prioritario;
  final int progressoEdital;
  final String? sigla;
  final int? quantidadeVagas;
  final int? vencimentoCentavos;
  final int? cargaHorariaSemanal;
  final String? localProva;
  final String? horarioInicioProva;
  final String? horarioFimProva;
  final String? requisitos;
  final String? criteriosPontuacao;
  final List<DisciplinaEdital> disciplinas;

  int? diasAteProva(DateTime referencia) {
    final prova = dataProva;
    if (prova == null) return null;
    final inicio = DateTime(referencia.year, referencia.month, referencia.day);
    final fim = DateTime(prova.year, prova.month, prova.day);
    final dias = fim.difference(inicio).inDays;
    return dias < 0 ? 0 : dias;
  }
}

class DisciplinaEdital {
  DisciplinaEdital({
    required this.id,
    required this.nome,
    required List<TopicoEdital> topicos,
  }) : topicos = List.unmodifiable(topicos) {
    if (id.trim().isEmpty || nome.trim().isEmpty) {
      throw const FormatException('A Disciplina do Edital deve ter identificador e nome.');
    }
    if (topicos.isEmpty) {
      throw const FormatException('A Disciplina do Edital deve conter ao menos um Tópico.');
    }
    if (_hasDuplicateIds(topicos.map((item) => item.id))) {
      throw const FormatException('A Disciplina do Edital não pode repetir um Tópico.');
    }
    final mandatoryTopics = topicos.where((item) => item.obrigatorio).toList(growable: false);
    if (mandatoryTopics.length != 1 || !topicos.last.obrigatorio) {
      throw const FormatException(
        'A Disciplina do Edital deve terminar com um único Tópico Revisão de Véspera.',
      );
    }
    if (!topicos.any((item) => !item.obrigatorio)) {
      throw const FormatException(
        'A Disciplina do Edital deve ser derivada de ao menos um Tópico comum.',
      );
    }
  }

  final String id;
  final String nome;
  final List<TopicoEdital> topicos;
}

class TopicoEdital {
  TopicoEdital({
    required this.id,
    required this.nome,
    required this.obrigatorio,
  }) {
    if (id.trim().isEmpty || nome.trim().isEmpty) {
      throw const FormatException('O Tópico do Edital deve ter identificador e nome.');
    }
    if (obrigatorio && nome != 'Revisão de Véspera') {
      throw const FormatException('O Tópico obrigatório deve se chamar Revisão de Véspera.');
    }
    if (!obrigatorio && nome == 'Revisão de Véspera') {
      throw const FormatException('Revisão de Véspera é um nome reservado ao Tópico obrigatório.');
    }
  }

  final String id;
  final String nome;
  final bool obrigatorio;
}

bool _isTime(String value) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
  if (match == null) return false;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  return hour <= 23 && minute <= 59;
}

bool _hasDuplicateIds(Iterable<String> ids) {
  final unique = <String>{};
  return ids.any((id) => !unique.add(id));
}
