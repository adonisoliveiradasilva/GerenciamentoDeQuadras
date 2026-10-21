import 'package:shelf/shelf.dart';

import '../http/erros.dart';
import 'paginacao.dart';

extension PaginacaoDaRequisicao on Request {
  ParametrosPaginacao lerPaginacao({
    required Set<String> camposOrdenaveis,
    required String ordenarPadrao,
    DirecaoOrdenacao direcaoPadrao = DirecaoOrdenacao.asc,
    int tamanhoPadrao = ParametrosPaginacao.tamanhoPadrao,
  }) {
    final consulta = url.queryParameters;
    final erros = <String, String>{};

    int lerInteiro(String campo, int padrao, int minimo, int maximo) {
      final texto = consulta[campo]?.trim();
      if (texto == null || texto.isEmpty) return padrao;
      final valor = int.tryParse(texto);
      if (valor == null || valor < minimo || valor > maximo) {
        erros[campo] = maximo == _semLimite
            ? 'Deve ser um número inteiro maior ou igual a $minimo.'
            : 'Deve ser um número inteiro entre $minimo e $maximo.';
        return padrao;
      }
      return valor;
    }

    final pagina = lerInteiro('pagina', 1, 1, _semLimite);
    final tamanho = lerInteiro(
      'tamanho',
      tamanhoPadrao,
      1,
      ParametrosPaginacao.tamanhoMaximo,
    );

    final ordenar = consulta['ordenar']?.trim();
    if (ordenar != null &&
        ordenar.isNotEmpty &&
        !camposOrdenaveis.contains(ordenar)) {
      erros['ordenar'] =
          'Use um destes campos: ${camposOrdenaveis.join(', ')}.';
    }

    final direcaoTexto = consulta['direcao']?.trim().toLowerCase();
    final direcao = switch (direcaoTexto) {
      null || '' => direcaoPadrao,
      'asc' => DirecaoOrdenacao.asc,
      'desc' => DirecaoOrdenacao.desc,
      _ => null,
    };
    if (direcao == null) erros['direcao'] = 'Use asc ou desc.';

    final busca = consulta['busca']?.trim();
    if (busca != null && busca.length > _tamanhoMaximoBusca) {
      erros['busca'] = 'Deve ter no máximo $_tamanhoMaximoBusca caracteres.';
    }

    if (erros.isNotEmpty) {
      throw ErroValidacao('Parâmetros de listagem inválidos.', campos: erros);
    }

    return ParametrosPaginacao(
      pagina: pagina,
      tamanho: tamanho,
      busca: busca == null || busca.isEmpty ? null : busca,
      ordenar: ordenar == null || ordenar.isEmpty ? ordenarPadrao : ordenar,
      direcao: direcao!,
    );
  }
}

const _semLimite = 1 << 31;
const _tamanhoMaximoBusca = 100;
