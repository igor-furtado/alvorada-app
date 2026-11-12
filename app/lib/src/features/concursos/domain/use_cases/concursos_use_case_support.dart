import '../../../../core/domain/resultado.dart';
import '../models/concurso_input.dart';
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

class ConcursoInputNormalizado {
  const ConcursoInputNormalizado({
    required this.instituicao,
    required this.cargo,
    required this.banca,
    required this.dataProva,
    required this.prioritario,
    required this.sigla,
    required this.quantidadeVagas,
    required this.vencimentoCentavos,
    required this.cargaHorariaSemanal,
    required this.localProva,
    required this.horarioInicioProva,
    required this.horarioFimProva,
    required this.requisitos,
    required this.criteriosPontuacao,
  });

  final String instituicao;
  final String cargo;
  final String? banca;
  final DateTime? dataProva;
  final bool prioritario;
  final String? sigla;
  final int? quantidadeVagas;
  final int? vencimentoCentavos;
  final int? cargaHorariaSemanal;
  final String? localProva;
  final String? horarioInicioProva;
  final String? horarioFimProva;
  final String? requisitos;
  final String? criteriosPontuacao;
}

({ConcursoInputNormalizado? valor, ViolacaoRegra<T>? erro}) normalizarConcursoInput<T>(ConcursoInput input) {
  final instituicao = input.instituicao.trim();
  final cargo = input.cargo.trim();
  final banca = _textoOpcional(input.banca);
  final sigla = _textoOpcional(input.sigla);
  final localProva = _textoOpcional(input.localProva);
  final horarioInicio = _textoOpcional(input.horarioInicioProva);
  final horarioFim = _textoOpcional(input.horarioFimProva);
  final requisitos = _textoOpcional(input.requisitos);
  final criterios = _textoOpcional(input.criteriosPontuacao);
  final instituicaoInvalida = validarTextoConcurso<T>(
    instituicao,
    mensagemObrigatorio: 'Informe o órgão ou instituição do Concurso.',
    codigoObrigatorio: ConcursosResultadoCodes.instituicaoObrigatoria,
    limite: 160,
    mensagemMuitoLongo: 'O órgão ou instituição deve ter no máximo 160 caracteres.',
    codigoMuitoLongo: ConcursosResultadoCodes.instituicaoMuitoLonga,
  );
  if (instituicaoInvalida != null) return (valor: null, erro: instituicaoInvalida);
  final cargoInvalido = validarTextoConcurso<T>(
    cargo,
    mensagemObrigatorio: 'Informe o cargo ou especialidade do Concurso.',
    codigoObrigatorio: ConcursosResultadoCodes.cargoObrigatorio,
    limite: 160,
    mensagemMuitoLongo: 'O cargo ou especialidade deve ter no máximo 160 caracteres.',
    codigoMuitoLongo: ConcursosResultadoCodes.cargoMuitoLongo,
  );
  if (cargoInvalido != null) return (valor: null, erro: cargoInvalido);
  if (banca != null && banca.runes.length > 120) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.bancaMuitoLonga,
        mensagem: 'A banca deve ter no máximo 120 caracteres.',
      ),
    );
  }
  if (sigla != null && sigla.runes.length > 24) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.siglaMuitoLonga,
        mensagem: 'A sigla do órgão deve ter no máximo 24 caracteres.',
      ),
    );
  }
  if (input.quantidadeVagas != null && (input.quantidadeVagas! < 0 || input.quantidadeVagas! > 1000000)) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.quantidadeVagasInvalida,
        mensagem: 'A quantidade de vagas deve estar entre 0 e 1.000.000.',
      ),
    );
  }
  if (input.vencimentoCentavos != null && input.vencimentoCentavos! < 0) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.vencimentoInvalido,
        mensagem: 'O vencimento não pode ser negativo.',
      ),
    );
  }
  if (input.cargaHorariaSemanal != null && (input.cargaHorariaSemanal! < 1 || input.cargaHorariaSemanal! > 168)) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.cargaHorariaInvalida,
        mensagem: 'A carga horária semanal deve estar entre 1 e 168 horas.',
      ),
    );
  }
  if (localProva != null && localProva.runes.length > 240) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.localProvaMuitoLongo,
        mensagem: 'O local da prova deve ter no máximo 240 caracteres.',
      ),
    );
  }
  if ((horarioInicio == null) != (horarioFim == null) ||
      (horarioInicio != null &&
          (!_horarioValido(horarioInicio) ||
              !_horarioValido(horarioFim!) ||
              horarioFim.compareTo(horarioInicio) <= 0))) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.horariosProvaInvalidos,
        mensagem: 'Informe início e término válidos, com o término posterior ao início.',
      ),
    );
  }
  if (requisitos != null && requisitos.runes.length > 10000) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.requisitosMuitoLongos,
        mensagem: 'Os requisitos devem ter no máximo 10.000 caracteres.',
      ),
    );
  }
  if (criterios != null && criterios.runes.length > 10000) {
    return (
      valor: null,
      erro: const ViolacaoRegra(
        codigo: ConcursosResultadoCodes.criteriosPontuacaoMuitoLongos,
        mensagem: 'As informações de pontuação devem ter no máximo 10.000 caracteres.',
      ),
    );
  }
  return (
    valor: ConcursoInputNormalizado(
      instituicao: instituicao,
      cargo: cargo,
      banca: banca,
      dataProva: input.dataProva,
      prioritario: input.prioritario,
      sigla: sigla,
      quantidadeVagas: input.quantidadeVagas,
      vencimentoCentavos: input.vencimentoCentavos,
      cargaHorariaSemanal: input.cargaHorariaSemanal,
      localProva: localProva,
      horarioInicioProva: horarioInicio,
      horarioFimProva: horarioFim,
      requisitos: requisitos,
      criteriosPontuacao: criterios,
    ),
    erro: null,
  );
}

String? _textoOpcional(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

bool _horarioValido(String value) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
  if (match == null) return false;
  return int.parse(match.group(1)!) <= 23 && int.parse(match.group(2)!) <= 59;
}
