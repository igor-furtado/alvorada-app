import '../../../core/content/app_messages.dart';
import '../domain/models/concurso.dart';
import 'concurso_formatters.dart';

class ConcursoViewData {
  const ConcursoViewData({
    required this.id,
    required this.institution,
    required this.shortName,
    required this.role,
    required this.board,
    required this.examDate,
    required this.days,
    required this.progress,
    required this.disciplines,
    required this.organizationAcronym,
    required this.vacancies,
    required this.remuneration,
    required this.weeklyWorkload,
    required this.examLocation,
    required this.examTime,
    required this.requirements,
    required this.scoringCriteria,
    this.isPrimary = false,
  });

  factory ConcursoViewData.fromDomain(
    Concurso concurso, {
    DateTime? now,
  }) => ConcursoViewData(
    id: concurso.id,
    institution: concurso.instituicao,
    shortName: concurso.instituicao,
    role: concurso.cargo,
    board: formatBoard(concurso.banca),
    examDate: formatExamDate(concurso.dataProva),
    days: concurso.diasAteProva(now ?? DateTime.now()),
    progress: concurso.progressoEdital / 100,
    disciplines: [
      for (final disciplina in concurso.disciplinas)
        ConcursoDisciplinaProgress(
          id: disciplina.id,
          name: disciplina.nome,
          topics: [
            for (final topico in disciplina.topicos)
              ConcursoTopicoViewData(
                id: topico.id,
                name: topico.nome,
                mandatory: topico.obrigatorio,
              ),
          ],
        ),
    ],
    organizationAcronym: concurso.sigla,
    vacancies: concurso.quantidadeVagas == null
        ? AppMessages.toBeDefined
        : AppMessages.vacanciesCount(concurso.quantidadeVagas!),
    remuneration: formatBrazilianCurrency(concurso.vencimentoCentavos),
    weeklyWorkload: concurso.cargaHorariaSemanal == null
        ? AppMessages.toBeDefined
        : '${concurso.cargaHorariaSemanal} horas/semana',
    examLocation: concurso.localProva ?? AppMessages.toBeDefined,
    examTime: formatExamTimeRange(concurso.horarioInicioProva, concurso.horarioFimProva),
    requirements: concurso.requisitos ?? AppMessages.toBeDefined,
    scoringCriteria: concurso.criteriosPontuacao ?? AppMessages.toBeDefined,
    isPrimary: concurso.prioritario,
  );

  final String id;
  final String institution;
  final String shortName;
  final String role;
  final String board;
  final String examDate;
  final int? days;
  final double progress;
  final List<ConcursoDisciplinaProgress> disciplines;
  final bool isPrimary;
  final String? organizationAcronym;
  final String vacancies;
  final String remuneration;
  final String weeklyWorkload;
  final String examLocation;
  final String examTime;
  final String requirements;
  final String scoringCriteria;
}

class ConcursoDisciplinaProgress {
  const ConcursoDisciplinaProgress({
    required this.name,
    this.id = '',
    this.topics = const [],
    this.progress,
    this.performance,
    this.weight,
  });

  final String id;
  final String name;
  final List<ConcursoTopicoViewData> topics;
  final double? progress;
  final double? performance;
  final int? weight;
}

class ConcursoTopicoViewData {
  const ConcursoTopicoViewData({
    required this.id,
    required this.name,
    required this.mandatory,
  });

  final String id;
  final String name;
  final bool mandatory;
}
