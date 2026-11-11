import '../../../../core/domain/resultado.dart';
import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';

Future<Resultado<T>> executarConcursosUseCase<T>({
  required Future<T> Function() operacao,
  required String codigoFalha,
}) async {
  try {
    return Sucesso(await operacao());
  } on ConcursosSynchronizationException catch (error) {
    return FalhaTecnica(
      codigo: ConcursosResultadoCodes.sincronizacaoPendente,
      mensagem: error.message,
    );
  } on ConcursosRepositoryException catch (error) {
    return FalhaTecnica(codigo: codigoFalha, mensagem: error.message);
  } on Object {
    return FalhaTecnica(codigo: codigoFalha);
  }
}

ViolacaoRegra<T>? validarTextoConcurso<T>(
  String valor, {
  required String mensagemObrigatorio,
  required String codigoObrigatorio,
  required int limite,
  required String mensagemMuitoLongo,
  required String codigoMuitoLongo,
}) {
  if (valor.isEmpty) {
    return ViolacaoRegra(
      codigo: codigoObrigatorio,
      mensagem: mensagemObrigatorio,
    );
  }
  if (valor.runes.length > limite) {
    return ViolacaoRegra(
      codigo: codigoMuitoLongo,
      mensagem: mensagemMuitoLongo,
    );
  }
  return null;
}
