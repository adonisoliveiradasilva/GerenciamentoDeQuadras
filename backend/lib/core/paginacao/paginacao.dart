enum DirecaoOrdenacao { asc, desc }

class ParametrosPaginacao {
  const ParametrosPaginacao({
    required this.ordenar,
    this.pagina = 1,
    this.tamanho = tamanhoPadrao,
    this.busca,
    this.direcao = DirecaoOrdenacao.asc,
  });

  static const tamanhoPadrao = 10;
  static const tamanhoMaximo = 100;

  final int pagina;
  final int tamanho;
  final String? busca;
  final String ordenar;
  final DirecaoOrdenacao direcao;

  int get deslocamento => (pagina - 1) * tamanho;
}

class Pagina<T> {
  const Pagina({
    required this.itens,
    required this.pagina,
    required this.tamanho,
    required this.total,
  });

  final List<T> itens;
  final int pagina;
  final int tamanho;
  final int total;

  int get totalPaginas => total == 0 ? 0 : (total / tamanho).ceil();

  Pagina<R> mapear<R>(R Function(T item) converter) => Pagina(
    itens: itens.map(converter).toList(),
    pagina: pagina,
    tamanho: tamanho,
    total: total,
  );

  Map<String, Object?> toJson(Object? Function(T item) itemParaJson) => {
    'itens': itens.map(itemParaJson).toList(),
    'pagina': pagina,
    'tamanho': tamanho,
    'total': total,
    'totalPaginas': totalPaginas,
  };
}
