import 'dart:async';

import 'package:estudos_app/src/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/src/features/concursos/domain/models/concurso_input.dart';
import 'package:estudos_app/src/features/concursos/domain/repositories/concursos_repository.dart';

class FakeConcursosRepository implements ConcursosRepository {
  FakeConcursosRepository({List<Concurso>? concursos}) : _concursos = [...?concursos];

  final List<Concurso> _concursos;
  final Map<String, Concurso> _archived = {};
  bool failLoad = false;
  bool failMutation = false;
  bool failRuleViolation = false;
  bool failSynchronization = false;
  int loadCalls = 0;
  int addDisciplinaCalls = 0;
  int addTopicoCalls = 0;
  int removeTopicoCalls = 0;
  Completer<void>? editalMutationGate;
  var _nextId = 10;

  @override
  Future<List<Concurso>> getConcursos({bool forceRefresh = false}) async {
    loadCalls++;
    if (failLoad) throw const ConcursosRepositoryException('Falha simulada.');
    return List.unmodifiable(_concursos);
  }

  @override
  Future<Concurso> createConcurso(CreateConcursoInput input) async {
    _throwIfMutationFails();
    final concurso = Concurso(
      id: 'concurso-${_nextId++}',
      instituicao: input.instituicao,
      cargo: input.cargo,
      banca: input.banca,
      dataProva: input.dataProva,
      prioritario: input.prioritario,
      progressoEdital: 0,
      sigla: input.sigla,
      quantidadeVagas: input.quantidadeVagas,
      vencimentoCentavos: input.vencimentoCentavos,
      cargaHorariaSemanal: input.cargaHorariaSemanal,
      localProva: input.localProva,
      horarioInicioProva: input.horarioInicioProva,
      horarioFimProva: input.horarioFimProva,
      requisitos: input.requisitos,
      criteriosPontuacao: input.criteriosPontuacao,
    );
    if (input.prioritario) _clearPriority();
    _concursos.add(concurso);
    return concurso;
  }

  @override
  Future<void> updateConcurso(String id, UpdateConcursoInput input) async {
    _throwIfMutationFails();
    if (input.prioritario) _clearPriority();
    _replace(
      id,
      (item) => Concurso(
        id: item.id,
        instituicao: input.instituicao,
        cargo: input.cargo,
        banca: input.banca,
        dataProva: input.dataProva,
        prioritario: input.prioritario,
        progressoEdital: item.progressoEdital,
        sigla: input.sigla,
        quantidadeVagas: input.quantidadeVagas,
        vencimentoCentavos: input.vencimentoCentavos,
        cargaHorariaSemanal: input.cargaHorariaSemanal,
        localProva: input.localProva,
        horarioInicioProva: input.horarioInicioProva,
        horarioFimProva: input.horarioFimProva,
        requisitos: input.requisitos,
        criteriosPontuacao: input.criteriosPontuacao,
        disciplinas: item.disciplinas,
      ),
    );
  }

  @override
  Future<void> setPrioritario(String id) async {
    _throwIfMutationFails();
    _clearPriority();
    _replace(id, (item) => _copy(item, prioritario: true));
  }

  @override
  Future<void> archiveConcurso(String id) async {
    _throwIfMutationFails();
    final index = _concursos.indexWhere((item) => item.id == id);
    final concurso = _concursos.removeAt(index);
    _archived[id] = _copy(concurso, prioritario: false);
  }

  @override
  Future<void> restoreConcurso(String id) async {
    _throwIfMutationFails();
    final concurso = _archived.remove(id);
    if (concurso != null) _concursos.add(concurso);
  }

  @override
  Future<void> deleteConcurso(String id) async {
    _throwIfMutationFails();
    _concursos.removeWhere((item) => item.id == id);
    _archived.remove(id);
  }

  @override
  Future<void> addDisciplinaToEdital({required String concursoId, required String disciplinaId}) async {
    addDisciplinaCalls++;
    await editalMutationGate?.future;
    _throwIfMutationFails();
  }

  @override
  Future<void> addTopicoToEdital({required String concursoId, required String topicoId}) async {
    addTopicoCalls++;
    await editalMutationGate?.future;
    _throwIfMutationFails();
  }

  @override
  Future<void> removeTopicoFromEdital({required String concursoId, required String topicoId}) async {
    removeTopicoCalls++;
    await editalMutationGate?.future;
    _throwIfMutationFails();
  }

  void _clearPriority() {
    for (final concurso in [..._concursos]) {
      _replace(concurso.id, (item) => _copy(item, prioritario: false));
    }
  }

  void _replace(String id, Concurso Function(Concurso) transform) {
    final index = _concursos.indexWhere((item) => item.id == id);
    _concursos[index] = transform(_concursos[index]);
  }

  void _throwIfMutationFails() {
    if (failRuleViolation) {
      throw const ConcursosRuleViolationException(
        code: 'concursos.teste.regra',
        message: 'Alteração rejeitada.',
      );
    }
    if (failSynchronization) {
      throw const ConcursosSynchronizationException();
    }
    if (failMutation) throw const ConcursosRepositoryException('Falha simulada.');
  }
}

Concurso _copy(Concurso source, {bool? prioritario}) => Concurso(
  id: source.id,
  instituicao: source.instituicao,
  cargo: source.cargo,
  banca: source.banca,
  dataProva: source.dataProva,
  prioritario: prioritario ?? source.prioritario,
  progressoEdital: source.progressoEdital,
  sigla: source.sigla,
  quantidadeVagas: source.quantidadeVagas,
  vencimentoCentavos: source.vencimentoCentavos,
  cargaHorariaSemanal: source.cargaHorariaSemanal,
  localProva: source.localProva,
  horarioInicioProva: source.horarioInicioProva,
  horarioFimProva: source.horarioFimProva,
  requisitos: source.requisitos,
  criteriosPontuacao: source.criteriosPontuacao,
  disciplinas: source.disciplinas,
);

List<Concurso> concursosFixture() => [
  Concurso(
    id: 'trf5',
    instituicao: 'Tribunal Regional Federal da 5ª Região',
    cargo: 'Técnico Judiciário — Área Administrativa',
    banca: 'FCC',
    dataProva: DateTime(2026, 12, 13),
    prioritario: false,
    progressoEdital: 72,
  ),
  Concurso(
    id: 'camara',
    instituicao: 'Câmara dos Deputados',
    cargo: 'Analista Legislativo — Técnica Legislativa',
    banca: 'Cebraspe',
    dataProva: DateTime(2027, 2, 21),
    prioritario: true,
    progressoEdital: 48,
  ),
];
