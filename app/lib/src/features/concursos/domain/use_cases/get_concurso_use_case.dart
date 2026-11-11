import '../../../../core/domain/resultado.dart';
import '../models/concurso.dart';
import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';
import 'concursos_use_case_support.dart';

class GetConcursoUseCase {
  const GetConcursoUseCase(this._repository);

  final ConcursosRepository _repository;

  Future<Resultado<Concurso>> call(
    String id, {
    bool forceRefresh = false,
  }) async {
    final result = await executarConcursosUseCase<List<Concurso>>(
      operacao: () => _repository.getConcursos(
        forceRefresh: forceRefresh,
      ),
      codigoFalha: ConcursosResultadoCodes.carregamentoFalhou,
    );

    return switch (result) {
      Sucesso<List<Concurso>>(:final valor) => _findById(valor, id),
      ViolacaoRegra<List<Concurso>>(:final codigo, :final mensagem) => ViolacaoRegra(
        codigo: codigo,
        mensagem: mensagem,
      ),
      FalhaTecnica<List<Concurso>>(:final codigo, :final mensagem) => FalhaTecnica(codigo: codigo, mensagem: mensagem),
    };
  }

  Resultado<Concurso> _findById(List<Concurso> concursos, String id) {
    for (final concurso in concursos) {
      if (concurso.id == id) return Sucesso(concurso);
    }
    return const ViolacaoRegra(
      codigo: ConcursosResultadoCodes.concursoNaoEncontrado,
      mensagem: 'Concurso não encontrado.',
    );
  }
}
