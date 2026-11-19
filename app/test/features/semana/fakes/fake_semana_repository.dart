import 'package:estudos_app/features/semana/domain/models/planejamento_semanal.dart';
import 'package:estudos_app/features/semana/domain/repositories/semana_repository.dart';

class FakeSemanaRepository implements SemanaRepository {
  FakeSemanaRepository({List<ItemSemana>? items, List<TopicoDisponivelSemana>? available})
    : _items = [...?items],
      _available = [...?available];

  final List<ItemSemana> _items;
  final List<TopicoDisponivelSemana> _available;
  final Set<int> selectedReviews = {};
  int loadCalls = 0;
  int progressCalls = 0;
  int questionCalls = 0;

  @override
  Future<PlanejamentoSemanal> getPlanejamento({required DateTime inicio, required DateTime fim}) async {
    loadCalls++;
    return PlanejamentoSemanal(
      inicio: inicio,
      fim: fim,
      itens: _items.where((item) => !item.dataPlanejada.isBefore(inicio) && !item.dataPlanejada.isAfter(fim)).toList(),
      disponiveis: _available,
    );
  }

  @override
  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    int posicaoDia = 0,
  }) async {
    final availableIndex = _available.indexWhere(
      (item) => item.concursoId == concursoId && item.topicoId == topicoId,
    );
    if (availableIndex < 0) return;
    final item = _available.removeAt(availableIndex);
    _items.add(
      ItemSemana(
        id: 'estudo:$concursoId:$topicoId',
        tipo: TipoItemSemana.estudoInicial,
        concursoId: concursoId,
        concursoNome: item.concursoNome,
        concursoSigla: item.concursoSigla,
        topicoId: topicoId,
        topicoNome: item.topicoNome,
        disciplinaNome: item.disciplinaNome,
        dataPlanejada: data,
        posicaoDia: posicaoDia,
        teoriaConcluida: false,
        memoriaConcluida: false,
        conferenciaConcluida: false,
        acertos: 0,
        erros: 0,
        versaoMetodologia: null,
        concluido: false,
        intervaloRevisaoDias: null,
      ),
    );
  }

  @override
  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required ProgressoTopicoInput input,
  }) async {
    progressCalls++;
    final index = _find(concursoId, topicoId);
    final current = _items[index];
    final theory = input.teoriaConcluida ?? current.teoriaConcluida;
    final memory = input.memoriaConcluida ?? current.memoriaConcluida;
    final conference = input.conferenciaConcluida ?? current.conferenciaConcluida;
    _items[index] = current.copyWith(
      teoriaConcluida: theory,
      memoriaConcluida: memory,
      conferenciaConcluida: conference,
      concluido: theory && memory && conference,
    );
  }

  @override
  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required ResultadoQuestao resultado,
  }) async {
    questionCalls++;
    final index = _find(concursoId, topicoId);
    final current = _items[index];
    _items[index] = resultado == ResultadoQuestao.certa
        ? current.copyWith(acertos: current.acertos + 1)
        : current.copyWith(erros: current.erros + 1);
  }

  @override
  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required Set<int> intervalosDias,
  }) async {
    selectedReviews
      ..clear()
      ..addAll(intervalosDias);
  }

  @override
  Future<void> moverRevisao({required String revisaoId, required DateTime data, int posicaoDia = 0}) async {
    final index = _items.indexWhere((item) => item.id == revisaoId);
    _items[index] = _items[index].copyWith(dataPlanejada: data);
  }

  @override
  Future<void> concluirRevisao(String revisaoId) async {
    final index = _items.indexWhere((item) => item.id == revisaoId);
    _items[index] = _items[index].copyWith(concluido: true);
  }

  int _find(String concursoId, String topicoId) =>
      _items.indexWhere((item) => item.concursoId == concursoId && item.topicoId == topicoId);
}

ItemSemana semanaItemFixture({
  DateTime? date,
  bool theory = false,
  bool memory = false,
  bool conference = false,
}) => ItemSemana(
  id: 'estudo:tce:atos',
  tipo: TipoItemSemana.estudoInicial,
  concursoId: 'tce',
  concursoNome: 'Tribunal de Contas do Estado',
  concursoSigla: 'TCE-CE',
  topicoId: 'atos',
  topicoNome: 'Atos administrativos',
  disciplinaNome: 'Direito Administrativo',
  dataPlanejada: date ?? DateTime.now(),
  posicaoDia: 0,
  teoriaConcluida: theory,
  memoriaConcluida: memory,
  conferenciaConcluida: conference,
  acertos: 0,
  erros: 0,
  versaoMetodologia: null,
  concluido: theory && memory && conference,
  intervaloRevisaoDias: null,
);
