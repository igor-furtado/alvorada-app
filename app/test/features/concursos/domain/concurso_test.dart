import 'package:estudos_app/src/features/concursos/domain/models/concurso.dart';
import 'package:estudos_app/src/features/concursos/presentation/concurso_view_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcula dias até a prova ignorando horário', () {
    final concurso = _concurso(dataProva: DateTime(2026, 12, 13));

    final days = concurso.diasAteProva(DateTime(2026, 11, 11, 23, 59));

    expect(days, 32);
  });

  test('não retorna prazo negativo para prova passada', () {
    final concurso = _concurso(dataProva: DateTime(2026, 1, 1));

    expect(concurso.diasAteProva(DateTime(2026, 11, 11)), 0);
  });

  test('rejeita avanço no Edital fora do intervalo', () {
    expect(
      () => _concurso(progressoEdital: 101),
      throwsA(isA<FormatException>()),
    );
  });

  test('preserva prazo ausente para a apresentação exibir A definir', () {
    final viewData = ConcursoViewData.fromDomain(_concurso());

    expect(viewData.days, isNull);
  });

  test('rejeita término de prova anterior ao início', () {
    expect(
      () => Concurso(
        id: 'concurso-1',
        instituicao: 'TRF da 5ª Região',
        cargo: 'Técnico Judiciário',
        banca: null,
        dataProva: null,
        prioritario: false,
        progressoEdital: 0,
        horarioInicioProva: '18:00',
        horarioFimProva: '13:00',
      ),
      throwsFormatException,
    );
  });

  test('rejeita Disciplina do Edital sem Revisão de Véspera', () {
    expect(
      () => DisciplinaEdital(
        id: 'direito',
        nome: 'Direito',
        topicos: [
          TopicoEdital(id: 'constitucional', nome: 'Constituição', obrigatorio: false),
        ],
      ),
      throwsFormatException,
    );
  });

  test('rejeita Tópicos repetidos na Disciplina do Edital', () {
    expect(
      () => DisciplinaEdital(
        id: 'direito',
        nome: 'Direito',
        topicos: [
          TopicoEdital(id: 'revisao', nome: 'Revisão de Véspera', obrigatorio: true),
          TopicoEdital(id: 'revisao', nome: 'Revisão de Véspera', obrigatorio: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('rejeita Disciplina do Edital sem Tópico comum vinculado', () {
    expect(
      () => DisciplinaEdital(
        id: 'direito',
        nome: 'Direito',
        topicos: [
          TopicoEdital(id: 'revisao', nome: 'Revisão de Véspera', obrigatorio: true),
        ],
      ),
      throwsFormatException,
    );
  });

  test('reserva Revisão de Véspera ao Tópico obrigatório', () {
    expect(
      () => TopicoEdital(
        id: 'revisao-comum',
        nome: 'Revisão de Véspera',
        obrigatorio: false,
      ),
      throwsFormatException,
    );
  });

  test('não fabrica métricas de Disciplina ainda não definidas', () {
    final concurso = Concurso(
      id: 'concurso-1',
      instituicao: 'TRF da 5ª Região',
      cargo: 'Técnico Judiciário',
      banca: null,
      dataProva: null,
      prioritario: false,
      progressoEdital: 0,
      disciplinas: [
        DisciplinaEdital(
          id: 'direito',
          nome: 'Direito',
          topicos: [
            TopicoEdital(id: 'constitucional', nome: 'Constituição', obrigatorio: false),
            TopicoEdital(id: 'revisao', nome: 'Revisão de Véspera', obrigatorio: true),
          ],
        ),
      ],
    );

    final disciplina = ConcursoViewData.fromDomain(concurso).disciplines.single;

    expect(disciplina.progress, isNull);
    expect(disciplina.performance, isNull);
  });
}

Concurso _concurso({DateTime? dataProva, int progressoEdital = 0}) => Concurso(
  id: 'concurso-1',
  instituicao: 'TRF da 5ª Região',
  cargo: 'Técnico Judiciário',
  banca: 'FCC',
  dataProva: dataProva,
  prioritario: false,
  progressoEdital: progressoEdital,
);
