import '../../../core/http/erros.dart';
import '../../../core/paginacao/paginacao.dart';
import 'erros_quadra.dart';
import 'quadra.dart';
import 'quadra_repositorio.dart';

class ServicoDeQuadras {
  ServicoDeQuadras(this._quadras);

  final QuadraRepositorio _quadras;

  Future<Pagina<Quadra>> listar(ParametrosPaginacao parametros) =>
      _quadras.listar(parametros);

  Future<Quadra> buscar(int id) async =>
      await _quadras.buscarPorId(id) ?? (throw const QuadraNaoEncontrada());

  Future<Quadra> criar(DadosDaQuadra dados) async {
    _validarHorarios(dados);
    if (await _quadras.existeComNome(dados.nome)) {
      throw const QuadraJaCadastrada();
    }
    return _quadras.criar(dados);
  }

  Future<Quadra> atualizar(int id, DadosDaQuadra dados) async {
    _validarHorarios(dados);
    if (await _quadras.existeComNome(dados.nome, ignorarId: id)) {
      throw const QuadraJaCadastrada();
    }
    return await _quadras.atualizar(id, dados) ??
        (throw const QuadraNaoEncontrada());
  }

  Future<void> remover(int id) async {
    if (!await _quadras.desativar(id)) throw const QuadraNaoEncontrada();
  }

  void _validarHorarios(DadosDaQuadra dados) {
    final erros = <String, String>{};
    final horarios = dados.horarios;

    if (horarios.isEmpty) {
      erros['horarios'] = 'Informe pelo menos um horário de funcionamento.';
    }

    for (var i = 0; i < horarios.length; i++) {
      final atual = horarios[i];
      if (atual.duracaoEmMinutos < dados.duracaoSessaoMin) {
        erros['horarios[$i]'] =
            'O intervalo precisa comportar pelo menos uma sessão de '
            '${dados.duracaoSessaoMin} minutos.';
        continue;
      }
      for (var j = 0; j < i; j++) {
        if (atual.sobrepoe(horarios[j])) {
          erros['horarios[$i]'] =
              'Sobrepõe o intervalo ${horarios[j].inicio}–${horarios[j].fim} '
              'do mesmo dia.';
          break;
        }
      }
    }

    if (erros.isNotEmpty) {
      throw ErroValidacao(
        'Horários de funcionamento inválidos.',
        campos: erros,
        codigo: 'HORARIOS_INVALIDOS',
      );
    }
  }
}
