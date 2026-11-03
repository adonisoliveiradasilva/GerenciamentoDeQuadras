import 'tipo_de_token_de_senha.dart';

abstract interface class TokenDeSenhaRepositorio {
  Future<void> salvar({
    required int usuarioId,
    required String tokenHash,
    required TipoDeTokenDeSenha tipo,
    required DateTime expiraEm,
  });

  Future<bool> usarParaDefinirSenha({
    required String tokenHash,
    required String senhaHash,
  });
}
