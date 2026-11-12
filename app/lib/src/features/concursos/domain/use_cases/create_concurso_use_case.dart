import '../../../../core/domain/resultado.dart';
import '../models/concurso.dart';
import '../models/concurso_input.dart';
import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';
import 'concursos_use_case_support.dart';

class CreateConcursoUseCase {
  const CreateConcursoUseCase(this._repository);

  final ConcursosRepository _repository;

  Future<Resultado<Concurso>> call(CreateConcursoInput input) {
    final normalizado = normalizarConcursoInput<Concurso>(input);
    final erro = normalizado.erro;
    if (erro != null) return Future.value(erro);
    final valor = normalizado.valor!;
    return executarConcursosUseCase(
      operacao: () => _repository.createConcurso(
        CreateConcursoInput(
          instituicao: valor.instituicao,
          cargo: valor.cargo,
          banca: valor.banca,
          dataProva: valor.dataProva,
          prioritario: valor.prioritario,
          sigla: valor.sigla,
          quantidadeVagas: valor.quantidadeVagas,
          vencimentoCentavos: valor.vencimentoCentavos,
          cargaHorariaSemanal: valor.cargaHorariaSemanal,
          localProva: valor.localProva,
          horarioInicioProva: valor.horarioInicioProva,
          horarioFimProva: valor.horarioFimProva,
          requisitos: valor.requisitos,
          criteriosPontuacao: valor.criteriosPontuacao,
        ),
      ),
      codigoFalha: ConcursosResultadoCodes.criacaoFalhou,
    );
  }
}
