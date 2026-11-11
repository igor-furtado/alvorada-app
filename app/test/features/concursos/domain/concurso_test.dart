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
