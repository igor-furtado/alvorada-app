sealed class DisciplinasFormEvent {
  const DisciplinasFormEvent();
}

final class DisciplinasFormSubmitted extends DisciplinasFormEvent {
  const DisciplinasFormSubmitted(this.name);

  final String name;
}
