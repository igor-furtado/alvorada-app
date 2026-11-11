import '../../domain/models/concurso_input.dart';

sealed class ConcursosFormEvent {
  const ConcursosFormEvent();
}

final class ConcursosFormSubmitted extends ConcursosFormEvent {
  const ConcursosFormSubmitted(this.input);

  final CreateConcursoInput input;
}
