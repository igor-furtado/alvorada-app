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
    final instituicao = input.instituicao.trim();
    final cargo = input.cargo.trim();
    final banca = input.banca?.trim();
    final instituicaoInvalida = validarTextoConcurso<Concurso>(
      instituicao,
      mensagemObrigatorio: 'Informe o órgão ou instituição do Concurso.',
      codigoObrigatorio: ConcursosResultadoCodes.instituicaoObrigatoria,
      limite: 160,
      mensagemMuitoLongo: 'O órgão ou instituição deve ter no máximo 160 caracteres.',
      codigoMuitoLongo: ConcursosResultadoCodes.instituicaoMuitoLonga,
    );
    if (instituicaoInvalida != null) return Future.value(instituicaoInvalida);
    final cargoInvalido = validarTextoConcurso<Concurso>(
      cargo,
      mensagemObrigatorio: 'Informe o cargo do Concurso.',
      codigoObrigatorio: ConcursosResultadoCodes.cargoObrigatorio,
      limite: 160,
      mensagemMuitoLongo: 'O cargo deve ter no máximo 160 caracteres.',
      codigoMuitoLongo: ConcursosResultadoCodes.cargoMuitoLongo,
    );
    if (cargoInvalido != null) return Future.value(cargoInvalido);
    if (banca != null && banca.runes.length > 120) {
      return Future.value(
        const ViolacaoRegra(
          codigo: ConcursosResultadoCodes.bancaMuitoLonga,
          mensagem: 'A banca deve ter no máximo 120 caracteres.',
        ),
      );
    }
    return executarConcursosUseCase(
      operacao: () => _repository.createConcurso(
        CreateConcursoInput(
          instituicao: instituicao,
          cargo: cargo,
          banca: banca == null || banca.isEmpty ? null : banca,
          dataProva: input.dataProva,
          prioritario: input.prioritario,
        ),
      ),
      codigoFalha: ConcursosResultadoCodes.criacaoFalhou,
    );
  }
}
