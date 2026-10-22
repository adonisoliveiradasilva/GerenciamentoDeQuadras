import '../../../core/paginacao/paginacao.dart';
import 'perfil.dart';
import 'usuario.dart';

const camposOrdenaveisDeUsuario = {'nome', 'email', 'criadoEm'};

abstract interface class UsuarioRepositorio {
  Future<Usuario?> buscarPorId(int id, {Perfil? perfil});

  Future<Usuario?> buscarPorEmail(String email);

  Future<Usuario?> buscarRemovidoPorEmail(String email);

  Future<Usuario?> reativar(int id, NovoUsuario dados);

  Future<Pagina<Usuario>> listar(Perfil perfil, ParametrosPaginacao parametros);

  Future<Usuario> criar(NovoUsuario dados);

  Future<Usuario?> atualizar(int id, AlteracaoUsuario dados, {Perfil? perfil});

  Future<bool> definirSenha(int id, String senhaHash);

  Future<bool> desativar(int id, {Perfil? perfil});
}
