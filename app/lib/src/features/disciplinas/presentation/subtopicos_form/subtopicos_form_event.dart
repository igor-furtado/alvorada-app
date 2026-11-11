sealed class SubtopicosFormEvent {
  const SubtopicosFormEvent();
}

final class SubtopicosFormSubmitted extends SubtopicosFormEvent {
  const SubtopicosFormSubmitted(this.name);

  final String name;
}
