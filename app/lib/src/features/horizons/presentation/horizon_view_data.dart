class HorizonViewData {
  const HorizonViewData({
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

  final String id;
  final String institution;
  final String shortName;
  final String role;
  final String board;
  final String examDate;
  final int days;
  final double progress;
  final List<HorizonDisciplineProgress> disciplines;
  final bool isPrimary;
}

class HorizonDisciplineProgress {
  const HorizonDisciplineProgress({
    required this.name,
    required this.progress,
    this.performance = 0,
    this.weight = 0,
  });

  final String name;
  final double progress;
  final double performance;
  final int weight;

  HorizonDisciplineProgress copyWith({int? weight}) =>
      HorizonDisciplineProgress(
        name: name,
        progress: progress,
        performance: performance,
        weight: weight ?? this.weight,
      );
}

const demoHorizons = [
  HorizonViewData(
    id: 'trf5-tecnico-administrativo',
    institution: 'Tribunal Regional Federal da 5ª Região',
    shortName: 'TRF da 5ª Região',
    role: 'Técnico Judiciário — Área Administrativa',
    board: 'FCC',
    examDate: '13 dez. 2026',
    days: 36,
    progress: .72,
    disciplines: [
      HorizonDisciplineProgress(
        name: 'Língua Portuguesa',
        progress: .82,
        performance: .74,
        weight: 24,
      ),
      HorizonDisciplineProgress(
        name: 'Direito Constitucional',
        progress: .76,
        performance: .81,
        weight: 20,
      ),
      HorizonDisciplineProgress(
        name: 'Direito Administrativo',
        progress: .68,
        performance: .69,
        weight: 18,
      ),
      HorizonDisciplineProgress(
        name: 'Administração Pública',
        progress: .55,
        performance: .62,
        weight: 14,
      ),
      HorizonDisciplineProgress(
        name: 'Raciocínio Lógico',
        progress: .61,
        performance: .57,
        weight: 10,
      ),
      HorizonDisciplineProgress(
        name: 'Informática',
        progress: .47,
        performance: .66,
        weight: 7,
      ),
      HorizonDisciplineProgress(
        name: 'Ética no Serviço Público',
        progress: .91,
        performance: .86,
        weight: 4,
      ),
      HorizonDisciplineProgress(
        name: 'Legislação Institucional',
        progress: .38,
        performance: .51,
        weight: 3,
      ),
    ],
  ),
  HorizonViewData(
    id: 'camara-analista-tecnica-legislativa',
    institution: 'Câmara dos Deputados',
    shortName: 'Câmara dos Deputados',
    role: 'Analista Legislativo — Técnica Legislativa',
    board: 'Cebraspe',
    examDate: '21 fev. 2027',
    days: 106,
    progress: .48,
    isPrimary: true,
    disciplines: [
      HorizonDisciplineProgress(
        name: 'Língua Portuguesa',
        progress: .64,
        performance: .72,
        weight: 28,
      ),
      HorizonDisciplineProgress(
        name: 'Direito Constitucional',
        progress: .53,
        performance: .68,
        weight: 26,
      ),
      HorizonDisciplineProgress(
        name: 'Processo Legislativo',
        progress: .41,
        performance: .54,
        weight: 25,
      ),
      HorizonDisciplineProgress(
        name: 'Ciência Política',
        progress: .29,
        performance: .47,
        weight: 21,
      ),
    ],
  ),
  HorizonViewData(
    id: 'tce-pe-auditor-controle-externo',
    institution: 'Tribunal de Contas do Estado de Pernambuco',
    shortName: 'TCE-PE',
    role: 'Auditor de Controle Externo',
    board: 'FGV',
    examDate: '16 mai. 2027',
    days: 190,
    progress: .23,
    disciplines: [
      HorizonDisciplineProgress(
        name: 'Auditoria Governamental',
        progress: .34,
        performance: .58,
        weight: 32,
      ),
      HorizonDisciplineProgress(
        name: 'Controle Externo',
        progress: .27,
        performance: .49,
        weight: 28,
      ),
      HorizonDisciplineProgress(
        name: 'Contabilidade Pública',
        progress: .19,
        performance: .44,
        weight: 24,
      ),
      HorizonDisciplineProgress(
        name: 'Administração Financeira',
        progress: .12,
        performance: .39,
        weight: 16,
      ),
    ],
  ),
];

HorizonViewData? demoHorizonById(String id) {
  for (final horizon in demoHorizons) {
    if (horizon.id == id) return horizon;
  }
  return null;
}
