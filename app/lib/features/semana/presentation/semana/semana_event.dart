import '../../domain/models/planejamento_semanal.dart';

sealed class SemanaEvent {
  const SemanaEvent();
}

class SemanaLoadRequested extends SemanaEvent {
  const SemanaLoadRequested();
}

class SemanaChanged extends SemanaEvent {
  const SemanaChanged(this.offset);

  final int offset;
}

class SemanaConcursoFilterChanged extends SemanaEvent {
  const SemanaConcursoFilterChanged(this.concursoId);

  final String? concursoId;
}

class SemanaHideCompletedChanged extends SemanaEvent {
  const SemanaHideCompletedChanged();
}

class SemanaTopicoPlanejado extends SemanaEvent {
  const SemanaTopicoPlanejado({required this.topico, required this.data});

  final TopicoDisponivelSemana topico;
  final DateTime data;
}

class SemanaItemMoved extends SemanaEvent {
  const SemanaItemMoved({required this.item, required this.data});

  final ItemSemana item;
  final DateTime data;
}

class SemanaRevisaoConcluida extends SemanaEvent {
  const SemanaRevisaoConcluida(this.revisaoId);

  final String revisaoId;
}
