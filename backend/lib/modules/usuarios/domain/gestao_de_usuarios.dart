import '../../../core/auth/hash_de_senha.dart';
import '../../../core/paginacao/paginacao.dart';
import 'erros_usuario.dart';
import 'perfil.dart';
import 'usuario.dart';
import 'usuario_repositorio.dart';

class GestaoDeUsuarios {
  GestaoDeUsuarios(
    this._usuarios, {
    required this.perfil,
    required this._hashDeSenha,
  });

  final UsuarioRepositorio _usuarios;
  final HashDeSenha _hashDeSenha;
  final Perfil perfil;

  Future<Pagina<Usuario>> listar(ParametrosPaginacao parametros) =>
      _usuarios.listar(perfil, parametros);

  Future<Usuario> buscar(int id) async =>
      await _usuarios.buscarPorId(id, perfil: perfil) ??
      (throw UsuarioNaoEncontrado(perfil));

  Future<Usuario> cadastrar(AlteracaoUsuario dados, {String? senha}) async {
    if (await _usuarios.buscarPorEmail(dados.email) != null) {
      throw const EmailJaCadastrado();
    }

    final novo = NovoUsuario(
      nome: dados.nome,
      email: dados.email,
      perfil: perfil,
      telefone: dados.telefone,
      dataNascimento: dados.dataNascimento,
      senhaHash: senha == null ? null : await _hashDeSenha.gerar(senha),
    );

    final removido = await _usuarios.buscarRemovidoPorEmail(dados.email);
    if (removido != null) {
      return await _usuarios.reativar(removido.id, novo) ??
          (throw const EmailJaCadastrado());
    }
    return _usuarios.criar(novo);
  }

  Future<Usuario> atualizar(
    int id,
    AlteracaoUsuario dados, {
    String? novaSenha,
  }) async =>
      await _usuarios.atualizar(
        id,
        dados,
        perfil: perfil,
        novaSenhaHash: novaSenha == null
            ? null
            : await _hashDeSenha.gerar(novaSenha),
      ) ??
      (throw UsuarioNaoEncontrado(perfil));

  Future<void> remover(int id) async {
    if (!await _usuarios.desativar(id, perfil: perfil)) {
      throw UsuarioNaoEncontrado(perfil);
    }
  }
}
