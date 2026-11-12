import '../../../../core/data/serializacao/leitor_json.dart';
import '../../domain/models/disciplina.dart';

class DisciplinaApiModel {
  const DisciplinaApiModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.color,
    required this.topics,
  });

  factory DisciplinaApiModel.fromJson(Map<String, Object?> json) => DisciplinaApiModel(
    id: readJsonString(json, 'id'),
    name: readJsonString(json, 'nome'),
    difficulty: readJsonInteger(json, 'dificuldade'),
    color: readJsonString(json, 'cor'),
    topics: readJsonList(json, 'topicos').map(TopicoApiModel.fromJson).toList(growable: false),
  );

  final String id;
  final String name;
  final int difficulty;
  final String color;
  final List<TopicoApiModel> topics;

  Disciplina toDomain() => Disciplina(
    id: id,
    name: name,
    difficulty: DificuldadeDisciplina.fromApiValue(difficulty),
    color: color,
    topics: topics.map((topic) => topic.toDomain()).toList(growable: false),
  );
}

class TopicoApiModel {
  const TopicoApiModel({required this.id, required this.name, required this.mandatory});

  factory TopicoApiModel.fromJson(Map<String, Object?> json) => TopicoApiModel(
    id: readJsonString(json, 'id'),
    name: readJsonString(json, 'nome'),
    mandatory: readJsonBoolean(json, 'obrigatorio'),
  );

  final String id;
  final String name;
  final bool mandatory;

  Topico toDomain() => Topico(
    id: id,
    name: name,
    mandatory: mandatory,
  );
}
