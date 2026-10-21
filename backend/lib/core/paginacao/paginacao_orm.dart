import 'package:orm/sql.dart';

import 'paginacao.dart';

typedef CampoOrdenavel<F> = Expr<Object?> Function(F campos);
typedef CampoDeBusca<F> = Expr<String> Function(F campos);

extension PaginacaoDaConsulta<R, F extends Fields> on Query<R, F> {
  Query<R, F> buscar(String? termo, List<CampoDeBusca<F>> campos) {
    if (termo == null || termo.trim().isEmpty || campos.isEmpty) return this;
    final padrao = '%${_escaparCuringas(termo.trim().toLowerCase())}%';
    return where(
      (f) => campos
          .map((campo) => campo(f).lower().like(padrao))
          .reduce((a, b) => a.or(b)),
    );
  }

  Future<Pagina<R>> paginar(
    ParametrosPaginacao parametros, {
    required Map<String, CampoOrdenavel<F>> ordenacao,
    required CampoOrdenavel<F> desempate,
  }) async {
    final campo =
        ordenacao[parametros.ordenar] ??
        (throw ArgumentError.value(
          parametros.ordenar,
          'ordenar',
          'Campo sem ordenação configurada',
        ));

    final total = await count();
    if (parametros.deslocamento >= total) {
      return Pagina(
        itens: const [],
        pagina: parametros.pagina,
        tamanho: parametros.tamanho,
        total: total,
      );
    }

    final itens = await orderBy(
      (f) => [
        parametros.direcao == DirecaoOrdenacao.asc
            ? campo(f).asc()
            : campo(f).desc(),
        desempate(f).asc(),
      ],
    ).skip(parametros.deslocamento).take(parametros.tamanho).get();

    return Pagina(
      itens: itens,
      pagina: parametros.pagina,
      tamanho: parametros.tamanho,
      total: total,
    );
  }
}

String _escaparCuringas(String texto) =>
    texto.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
