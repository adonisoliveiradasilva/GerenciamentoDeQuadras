import '../../../core/auth/hash_de_senha.dart';
import '../../../core/auth/token_aleatorio.dart';
import '../../../core/email/enviador_de_email.dart';
import '../../../core/http/erros.dart';
import '../../usuarios/domain/envio_de_convite.dart';
import '../../usuarios/domain/usuario.dart';
import '../../usuarios/domain/usuario_repositorio.dart';
import 'mensagens_de_email.dart';
import 'tipo_de_token_de_senha.dart';
import 'token_de_senha_repositorio.dart';

class TokenDeSenhaInvalido extends ErroValidacao {
  const TokenDeSenhaInvalido()
    : super(
        'Este link é inválido, já foi usado ou expirou. Peça um novo.',
        codigo: 'TOKEN_INVALIDO_OU_EXPIRADO',
      );
}

class ServicoDeSenhas implements EnvioDeConvite {
  ServicoDeSenhas({
    required this._usuarios,
    required this._tokens,
    required this._hashDeSenha,
    required this._enviador,
    required this._urlPublica,
  });

  static const validadeParaCriar = Duration(hours: 48);
  static const validadeParaRedefinir = Duration(hours: 1);
  static const caminhoDaPagina = '/auth/definir-senha';

  final UsuarioRepositorio _usuarios;
  final TokenDeSenhaRepositorio _tokens;
  final HashDeSenha _hashDeSenha;
  final EnviadorDeEmail _enviador;
  final Uri _urlPublica;

  @override
  Future<void> enviarConvite(Usuario usuario) =>
      _gerarEEnviar(usuario, TipoDeTokenDeSenha.criar);

  Future<void> solicitarRedefinicao(String email) async {
    final usuario = await _usuarios.buscarPorEmail(email);
    if (usuario == null) return;
    await _gerarEEnviar(
      usuario,
      usuario.possuiSenha
          ? TipoDeTokenDeSenha.redefinir
          : TipoDeTokenDeSenha.criar,
    );
  }

  Future<void> definirSenha({
    required String token,
    required String novaSenha,
  }) async {
    final senhaDefinida = await _tokens.usarParaDefinirSenha(
      tokenHash: hashDoToken(token),
      senhaHash: await _hashDeSenha.gerar(novaSenha),
    );
    if (!senhaDefinida) throw const TokenDeSenhaInvalido();
  }

  Future<void> _gerarEEnviar(Usuario usuario, TipoDeTokenDeSenha tipo) async {
    final validade = tipo == TipoDeTokenDeSenha.criar
        ? validadeParaCriar
        : validadeParaRedefinir;
    final (:token, :hash) = gerarTokenAleatorio();

    await _tokens.salvar(
      usuarioId: usuario.id,
      tokenHash: hash,
      tipo: tipo,
      expiraEm: DateTime.now().toUtc().add(validade),
    );

    await _enviador.enviar(
      mensagemDeSenha(
        usuario: usuario,
        tipo: tipo,
        validade: validade,
        link: _urlPublica.replace(
          path: caminhoDaPagina,
          queryParameters: {'token': token},
        ),
      ),
    );
  }
}
