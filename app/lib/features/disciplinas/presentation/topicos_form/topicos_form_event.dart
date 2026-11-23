import '../../domain/models/disciplina_input.dart';

sealed class TopicosFormEvent {
  const TopicosFormEvent();
}

final class TopicosFormSubmitted extends TopicosFormEvent {
  const TopicosFormSubmitted(this.topics);

  final List<ReplaceTopicoInput> topics;
}
