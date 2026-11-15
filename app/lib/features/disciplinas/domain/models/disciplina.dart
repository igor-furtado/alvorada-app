const nomeTopicoRevisaoVespera = 'Revisão de Véspera';

enum DificuldadeDisciplina {
  veryEasy(1),
  easy(2),
  medium(3),
  hard(4),
  veryHard(5);

  const DificuldadeDisciplina(this.apiValue);

  final int apiValue;

  static DificuldadeDisciplina fromApiValue(int value) => values.firstWhere(
    (difficulty) => difficulty.apiValue == value,
    orElse: () => throw FormatException('Dificuldade de Disciplina inválida: $value'),
  );
}

class Disciplina {
  Disciplina({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.color,
    required List<Topico> topics,
  }) : topics = List.unmodifiable(topics) {
    final mandatoryTopicos = topics.where((topic) => topic.mandatory).length;
    if (mandatoryTopicos != 1 || topics.lastOrNull?.mandatory != true) {
      throw const FormatException(
        'Toda Disciplina deve ter exatamente um Tópico Revisão de Véspera na última posição.',
      );
    }
  }

  final String id;
  final String name;
  final DificuldadeDisciplina difficulty;
  final String color;
  final List<Topico> topics;
}

class Topico {
  Topico({
    required this.id,
    required this.name,
    required this.mandatory,
  }) {
    if (mandatory && name != nomeTopicoRevisaoVespera) {
      throw const FormatException('O Tópico obrigatório deve se chamar Revisão de Véspera.');
    }
  }

  final String id;
  final String name;
  final bool mandatory;
}

extension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
