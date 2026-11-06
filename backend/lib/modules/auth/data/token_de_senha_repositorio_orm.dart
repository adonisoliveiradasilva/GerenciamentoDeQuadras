import '../../../core/database/database.dart' as bd;
import '../domain/tipo_de_token_de_senha.dart';
import '../domain/token_de_senha_repositorio.dart';

class TokenDeSenhaRepositorioOrm implements TokenDeSenhaRepositorio {
  TokenDeSenhaRepositorioOrm(this._db);

  final bd.Database<bd.Postgres> _db;

  @override
  Future<void> salvar({
    required int usuarioId,
    required String tokenHash,
    required TipoDeTokenDeSenha tipo,
    required DateTime expiraEm,
  }) {
    return _db.transaction((tx) async {
      await _inutilizarAbertos(tx, usuarioId);
      await tx.tokenDeSenha.create(
        usuarioId: usuarioId,
        tokenHash: tokenHash,
        tipo: tipo,
        expiraEm: expiraEm.toUtc(),
      );
    });
  }

  @override
  Future<bool> usarParaDefinirSenha({
    required String tokenHash,
    required String senhaHash,
  }) {
    return _db.transaction((tx) async {
      final agora = DateTime.now().toUtc();
      final token = await tx.tokenDeSenha
          .where((t) => t.tokenHash.eq(tokenHash))
          .where((t) => t.usadoEm.eq(null))
          .where((t) => t.expiraEm.gt(agora))
          .firstOrNull();
      if (token == null) return false;

      final marcados = await tx.tokenDeSenha
          .where((t) => t.id.eq(token.id))
          .where((t) => t.usadoEm.eq(null))
          .patch(usadoEm: .set(agora));
      if (marcados == 0) return false;

      final alterados = await tx.usuario
          .where((u) => u.id.eq(token.usuarioId))
          .where((u) => u.ativo.eq(true))
          .patch(senhaHash: .set(senhaHash), atualizadoEm: .set(agora));
      if (alterados == 0) return false;

      await _inutilizarAbertos(tx, token.usuarioId);
      return true;
    });
  }

  Future<void> _inutilizarAbertos(bd.QueryContext contexto, int usuarioId) =>
      contexto.tokenDeSenha
          .where((t) => t.usuarioId.eq(usuarioId))
          .where((t) => t.usadoEm.eq(null))
          .patch(usadoEm: .set(DateTime.now().toUtc()));
}
