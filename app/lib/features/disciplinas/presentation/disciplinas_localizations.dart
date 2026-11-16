import 'package:estudos_app/l10n/generated/app_localizations.dart';

import '../domain/models/disciplina.dart';
import '../domain/use_cases/disciplinas_resultado_codes.dart';

extension DisciplinasLocalizations on AppLocalizations {
  String disciplineDifficulty(DificuldadeDisciplina difficulty) => switch (difficulty) {
    DificuldadeDisciplina.veryEasy => difficultyVeryEasy,
    DificuldadeDisciplina.easy => difficultyEasy,
    DificuldadeDisciplina.medium => difficultyMedium,
    DificuldadeDisciplina.hard => difficultyHard,
    DificuldadeDisciplina.veryHard => difficultyVeryHard,
  };

  String disciplineFormError(String? code) => switch (code) {
    DisciplinasResultadoCodes.disciplinaNomeObrigatorio => requiredField,
    DisciplinasResultadoCodes.disciplinaNomeMuitoLongo => disciplineNameTooLong,
    DisciplinasResultadoCodes.disciplinaCorInvalida => disciplineColorInvalid,
    _ => disciplineSaveFailed,
  };

  String topicFormError(String? code) => switch (code) {
    DisciplinasResultadoCodes.topicoNomeObrigatorio => requiredField,
    DisciplinasResultadoCodes.topicoNomeMuitoLongo => topicNameTooLong,
    _ => topicSaveFailed,
  };
}
