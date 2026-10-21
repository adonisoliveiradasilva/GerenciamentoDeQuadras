import '../../../core/auth/hash_de_senha.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/erros.dart';
import '../../usuarios/domain/usuario.dart';
import '../../usuarios/domain/usuario_repositorio.dart';

class CredenciaisInvalidas extends NaoAutenticado {
  const CredenciaisInvalidas()
    : super('Email ou senha incorretos.', 'CREDENCIAIS_INVALIDAS');
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
    final hash = usuario?.senhaHash;

    if (usuario == null || hash == null) {
      await _hashDeSenha.conferir(
        senha,
        await (_hashParaEmailInexistente ??= _hashDeSenha.gerar(
          'senha-de-usuario-inexistente',
        )),
      );
      throw const CredenciaisInvalidas();
    }

    if (!await _hashDeSenha.conferir(senha, hash)) {
      throw const CredenciaisInvalidas();
    }

    final token = _servicoDeToken.gerar(
      UsuarioAutenticado(id: usuario.id, perfil: usuario.perfil),
    );
    return ResultadoDoLogin(token: token, usuario: usuario);
  }
}
