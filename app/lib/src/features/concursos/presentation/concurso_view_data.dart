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
    disciplines: const [],
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
}

class ConcursoDisciplinaProgress {
  const ConcursoDisciplinaProgress({
    required this.name,
    required this.progress,
    this.performance = 0,
    this.weight = 0,
  });

  final String name;
  final double progress;
  final double performance;
  final int weight;
}
