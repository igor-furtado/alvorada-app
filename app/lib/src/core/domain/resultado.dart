sealed class Resultado<T> {
  const Resultado();
}

final class Sucesso<T> extends Resultado<T> {
  const Sucesso(this.valor);

  final T valor;
}

final class ViolacaoRegra<T> extends Resultado<T> {
  const ViolacaoRegra({required this.codigo, required this.mensagem});

  final String codigo;
  final String mensagem;
}

final class FalhaTecnica<T> extends Resultado<T> {
  const FalhaTecnica({required this.codigo, this.mensagem});

  final String codigo;
  final String? mensagem;
}
