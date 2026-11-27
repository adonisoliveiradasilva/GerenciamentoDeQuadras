import '../../../core/auth/hash_de_senha.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/erros.dart';
import '../../usuarios/domain/usuario.dart';
import '../../usuarios/domain/usuario_repositorio.dart';

class CredenciaisInvalidas extends NaoAutenticado {
  const CredenciaisInvalidas()
    : super('Email ou senha incorretos.', 'CREDENCIAIS_INVALIDAS');
}

class UsuarioRemovido extends ErroApi {
  const UsuarioRemovido()
    : super(
        403,
        'USUARIO_REMOVIDO',
        'Seu acesso foi removido. Fale com o gerente.',
      );
}

class ResultadoDoLogin {
  const ResultadoDoLogin({required this.token, required this.usuario});

  final TokenGerado token;
  final Usuario usuario;
}

class FazerLogin {
  FazerLogin({
    required this._usuarios,
    required this._hashDeSenha,
    required this._servicoDeToken,
  });

  final UsuarioRepositorio _usuarios;
  final HashDeSenha _hashDeSenha;
  final ServicoDeToken _servicoDeToken;
  Future<String>? _hashParaEmailInexistente;

  Future<ResultadoDoLogin> executar({
    required String email,
    required String senha,
  }) async {
    final usuario = await _usuarios.buscarPorEmail(email);

    if (usuario == null) {
      final removido = await _usuarios.buscarRemovidoPorEmail(email);
      if (await _senhaConfere(senha, removido?.senhaHash)) {
        throw const UsuarioRemovido();
      }
      throw const CredenciaisInvalidas();
    }

    if (!await _senhaConfere(senha, usuario.senhaHash)) {
      throw const CredenciaisInvalidas();
    }

    final token = _servicoDeToken.gerar(
      UsuarioAutenticado(id: usuario.id, perfil: usuario.perfil),
    );
    return ResultadoDoLogin(token: token, usuario: usuario);
  }

  Future<bool> _senhaConfere(String senha, String? hash) async {
    if (hash != null) return _hashDeSenha.conferir(senha, hash);
    await _hashDeSenha.conferir(
      senha,
      await (_hashParaEmailInexistente ??= _hashDeSenha.gerar(
        'senha-de-usuario-inexistente',
      )),
    );
    return false;
  }
}
