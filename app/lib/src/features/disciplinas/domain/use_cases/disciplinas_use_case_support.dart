import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';

Future<Resultado<T>> executarDisciplinasUseCase<T>({
  required Future<T> Function() operacao,
  required String codigoFalha,
}) async {
  try {
    return Sucesso(await operacao());
  } on DisciplinasRuleViolationException catch (error) {
    return ViolacaoRegra(codigo: error.code, mensagem: error.message);
  } on DisciplinasSynchronizationException catch (error) {
    return FalhaTecnica(
      codigo: DisciplinasResultadoCodes.sincronizacaoPendente,
      mensagem: error.message,
    );
  } on DisciplinasRepositoryException catch (error) {
    return FalhaTecnica(codigo: codigoFalha, mensagem: error.message);
  } on Object {
    return FalhaTecnica(codigo: codigoFalha);
  }
}

ViolacaoRegra<T>? validarNome<T>(
  String nome, {
  required String nomeConceito,
  required String codigoObrigatorio,
  required String codigoMuitoLongo,
}) {
  if (nome.isEmpty) {
    return ViolacaoRegra(
      codigo: codigoObrigatorio,
      mensagem: 'Informe um nome para $nomeConceito.',
    );
  }
  if (nome.runes.length > 120) {
    return ViolacaoRegra(
      codigo: codigoMuitoLongo,
      mensagem: 'O nome de $nomeConceito deve ter no máximo 120 caracteres.',
    );
  }
  return null;
}
