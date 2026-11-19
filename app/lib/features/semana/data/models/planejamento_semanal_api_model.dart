import 'package:estudos_app/core/json_reader.dart';

import '../../domain/models/planejamento_semanal.dart';

class PlanejamentoSemanalApiModel {
  const PlanejamentoSemanalApiModel({
    required this.inicio,
    required this.fim,
    required this.itens,
    required this.disponiveis,
  });

  factory PlanejamentoSemanalApiModel.fromJson(Map<String, Object?> json) => PlanejamentoSemanalApiModel(
    inicio: readJsonString(json, 'inicio'),
    fim: readJsonString(json, 'fim'),
    itens: readJsonList(json, 'itens').map(ItemSemanaApiModel.fromJson).toList(growable: false),
    disponiveis: readJsonList(json, 'disponiveis').map(TopicoDisponivelSemanaApiModel.fromJson).toList(growable: false),
  );

  final String inicio;
  final String fim;
  final List<ItemSemanaApiModel> itens;
  final List<TopicoDisponivelSemanaApiModel> disponiveis;

  PlanejamentoSemanal toDomain() => PlanejamentoSemanal(
    inicio: DateTime.parse(inicio),
    fim: DateTime.parse(fim),
    itens: itens.map((item) => item.toDomain()).toList(growable: false),
    disponiveis: disponiveis.map((item) => item.toDomain()).toList(growable: false),
  );
}

class ItemSemanaApiModel {
  const ItemSemanaApiModel(this.json);

  factory ItemSemanaApiModel.fromJson(Map<String, Object?> json) => ItemSemanaApiModel(json);

  final Map<String, Object?> json;

  ItemSemana toDomain() => ItemSemana(
    id: readJsonString(json, 'id'),
    tipo: switch (readJsonString(json, 'tipo')) {
      'estudo_inicial' => TipoItemSemana.estudoInicial,
      'revisao' => TipoItemSemana.revisao,
      final value => throw FormatException('Tipo de item semanal inválido: $value.'),
    },
    concursoId: readJsonString(json, 'concurso_id'),
    concursoNome: readJsonString(json, 'concurso_nome'),
    concursoSigla: readJsonNullableString(json, 'concurso_sigla'),
    topicoId: readJsonString(json, 'topico_id'),
    topicoNome: readJsonString(json, 'topico_nome'),
    disciplinaNome: readJsonString(json, 'disciplina_nome'),
    dataPlanejada: DateTime.parse(readJsonString(json, 'data_planejada')),
    posicaoDia: readJsonInteger(json, 'posicao_dia'),
    teoriaConcluida: readJsonBoolean(json, 'teoria_concluida'),
    memoriaConcluida: readJsonBoolean(json, 'memoria_concluida'),
    conferenciaConcluida: readJsonBoolean(json, 'conferencia_concluida'),
    acertos: readJsonInteger(json, 'acertos'),
    erros: readJsonInteger(json, 'erros'),
    versaoMetodologia: readJsonNullableInteger(json, 'versao_metodologia'),
    concluido: readJsonBoolean(json, 'concluido'),
    intervaloRevisaoDias: readJsonNullableInteger(json, 'intervalo_revisao_dias'),
  );
}

class TopicoDisponivelSemanaApiModel {
  const TopicoDisponivelSemanaApiModel(this.json);

  factory TopicoDisponivelSemanaApiModel.fromJson(Map<String, Object?> json) => TopicoDisponivelSemanaApiModel(json);

  final Map<String, Object?> json;

  TopicoDisponivelSemana toDomain() => TopicoDisponivelSemana(
    concursoId: readJsonString(json, 'concurso_id'),
    concursoNome: readJsonString(json, 'concurso_nome'),
    concursoSigla: readJsonNullableString(json, 'concurso_sigla'),
    topicoId: readJsonString(json, 'topico_id'),
    topicoNome: readJsonString(json, 'topico_nome'),
    disciplinaNome: readJsonString(json, 'disciplina_nome'),
  );
}
