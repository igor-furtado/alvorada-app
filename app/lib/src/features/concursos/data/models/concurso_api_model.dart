import '../../../../core/data/serializacao/leitor_json.dart';
import '../../domain/models/concurso.dart';

class ConcursoApiModel {
  const ConcursoApiModel({
    required this.id,
    required this.instituicao,
    required this.cargo,
    required this.banca,
    required this.dataProva,
    required this.prioritario,
    required this.progressoEdital,
  });

  factory ConcursoApiModel.fromJson(Map<String, Object?> json) => ConcursoApiModel(
    id: readJsonString(json, 'id'),
    instituicao: readJsonString(json, 'instituicao'),
    cargo: readJsonString(json, 'cargo'),
    banca: readJsonNullableString(json, 'banca'),
    dataProva: readJsonNullableString(json, 'data_prova'),
    prioritario: readJsonBoolean(json, 'prioritario'),
    progressoEdital: readJsonInteger(json, 'progresso_edital'),
  );

  final String id;
  final String instituicao;
  final String cargo;
  final String? banca;
  final String? dataProva;
  final bool prioritario;
  final int progressoEdital;

  Concurso toDomain() => Concurso(
    id: id,
    instituicao: instituicao,
    cargo: cargo,
    banca: banca,
    dataProva: dataProva == null ? null : DateTime.parse(dataProva!),
    prioritario: prioritario,
    progressoEdital: progressoEdital,
  );
}
