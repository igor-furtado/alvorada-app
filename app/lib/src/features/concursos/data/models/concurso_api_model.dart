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
    this.sigla,
    this.quantidadeVagas,
    this.vencimentoCentavos,
    this.cargaHorariaSemanal,
    this.localProva,
    this.horarioInicioProva,
    this.horarioFimProva,
    this.requisitos,
    this.criteriosPontuacao,
  });

  factory ConcursoApiModel.fromJson(Map<String, Object?> json) => ConcursoApiModel(
    id: readJsonString(json, 'id'),
    instituicao: readJsonString(json, 'instituicao'),
    cargo: readJsonString(json, 'cargo'),
    banca: readJsonNullableString(json, 'banca'),
    dataProva: readJsonNullableString(json, 'data_prova'),
    prioritario: readJsonBoolean(json, 'prioritario'),
    progressoEdital: readJsonInteger(json, 'progresso_edital'),
    sigla: readJsonNullableString(json, 'sigla'),
    quantidadeVagas: readJsonNullableInteger(json, 'quantidade_vagas'),
    vencimentoCentavos: readJsonNullableInteger(json, 'vencimento_centavos'),
    cargaHorariaSemanal: readJsonNullableInteger(json, 'carga_horaria_semanal'),
    localProva: readJsonNullableString(json, 'local_prova'),
    horarioInicioProva: readJsonNullableString(json, 'horario_inicio_prova'),
    horarioFimProva: readJsonNullableString(json, 'horario_fim_prova'),
    requisitos: readJsonNullableString(json, 'requisitos'),
    criteriosPontuacao: readJsonNullableString(json, 'criterios_pontuacao'),
  );

  final String id;
  final String instituicao;
  final String cargo;
  final String? banca;
  final String? dataProva;
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

  Concurso toDomain() => Concurso(
    id: id,
    instituicao: instituicao,
    cargo: cargo,
    banca: banca,
    dataProva: dataProva == null ? null : DateTime.parse(dataProva!),
    prioritario: prioritario,
    progressoEdital: progressoEdital,
    sigla: sigla,
    quantidadeVagas: quantidadeVagas,
    vencimentoCentavos: vencimentoCentavos,
    cargaHorariaSemanal: cargaHorariaSemanal,
    localProva: localProva,
    horarioInicioProva: horarioInicioProva,
    horarioFimProva: horarioFimProva,
    requisitos: requisitos,
    criteriosPontuacao: criteriosPontuacao,
  );
}
