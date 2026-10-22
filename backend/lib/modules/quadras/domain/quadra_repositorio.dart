import '../../../core/paginacao/paginacao.dart';
import 'quadra.dart';

const camposOrdenaveisDeQuadra = {'nome', 'localizacao', 'criadoEm'};

abstract interface class QuadraRepositorio {
  Future<Pagina<Quadra>> listar(ParametrosPaginacao parametros);

  Future<Quadra?> buscarPorId(int id);

  Future<bool> existeComNome(String nome, {int? ignorarId});

  Future<Quadra> criar(DadosDaQuadra dados);

  Future<Quadra?> atualizar(int id, DadosDaQuadra dados);

  Future<bool> desativar(int id);
}
