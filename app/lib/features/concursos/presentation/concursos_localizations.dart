import 'package:estudos_app/l10n/generated/app_localizations.dart';
import '../domain/use_cases/concursos_resultado_codes.dart';

extension ConcursosLocalizations on AppLocalizations {
  String formError(String? code) => switch (code) {
    ConcursosResultadoCodes.instituicaoObrigatoria => institutionRequired,
    ConcursosResultadoCodes.instituicaoMuitoLonga => institutionTooLong,
    ConcursosResultadoCodes.cargoObrigatorio => roleRequired,
    ConcursosResultadoCodes.cargoMuitoLongo => roleTooLong,
    ConcursosResultadoCodes.bancaMuitoLonga => boardTooLong,
    ConcursosResultadoCodes.siglaMuitoLonga => acronymTooLong,
    ConcursosResultadoCodes.quantidadeVagasInvalida => invalidNonNegativeInteger,
    ConcursosResultadoCodes.vencimentoInvalido => invalidRemuneration,
    ConcursosResultadoCodes.cargaHorariaInvalida => invalidWeeklyWorkload,
    ConcursosResultadoCodes.localProvaMuitoLongo => examLocationTooLong,
    ConcursosResultadoCodes.horariosProvaInvalidos => invalidExamTimeRange,
    ConcursosResultadoCodes.requisitosMuitoLongos => requirementsTooLong,
    ConcursosResultadoCodes.criteriosPontuacaoMuitoLongos => scoringCriteriaTooLong,
    _ => concursoSaveFailed,
  };
}
