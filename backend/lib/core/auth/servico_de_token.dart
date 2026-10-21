import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../modules/usuarios/domain/perfil.dart';
import '../config/ambiente.dart';
import '../http/erros.dart';

class UsuarioAutenticado {
  const UsuarioAutenticado({required this.id, required this.perfil});

  final int id;
  final Perfil perfil;
}

class TokenGerado {
  const TokenGerado({required this.valor, required this.expiraEm});

  final String valor;
  final DateTime expiraEm;
}

class ServicoDeToken {
  ServicoDeToken({required String segredo, required this.validade})
    : _chave = SecretKey(segredo) {
    if (segredo.length < tamanhoMinimoDoSegredo) {
      throw ArgumentError(
        'JWT_SEGREDO deve ter pelo menos $tamanhoMinimoDoSegredo caracteres.',
      );
    }
  }

  factory ServicoDeToken.doAmbiente(Ambiente ambiente) => ServicoDeToken(
    segredo: ambiente.obrigatorio('JWT_SEGREDO'),
    validade: Duration(
      hours: ambiente.inteiro('JWT_VALIDADE_HORAS', padrao: 12),
    ),
  );

  static const tamanhoMinimoDoSegredo = 32;
  static const _emissor = 'gerenciador-quadras';

  final SecretKey _chave;
  final Duration validade;

  TokenGerado gerar(UsuarioAutenticado usuario) {
    final valor = JWT(
      {'perfil': usuario.perfil.name},
      subject: '${usuario.id}',
      issuer: _emissor,
    ).sign(_chave, algorithm: JWTAlgorithm.HS256, expiresIn: validade);
    return TokenGerado(
      valor: valor,
      expiraEm: DateTime.now().toUtc().add(validade),
    );
  }

  UsuarioAutenticado validar(String token) {
    final JWT jwt;
    try {
      jwt = JWT.verify(token, _chave, issuer: _emissor);
    } on JWTExpiredException {
      throw const NaoAutenticado(
        'Sua sessão expirou. Faça login novamente.',
        'TOKEN_EXPIRADO',
      );
    } on JWTException {
      throw const NaoAutenticado('Token inválido.', 'TOKEN_INVALIDO');
    }

    final id = int.tryParse(jwt.subject ?? '');
    final payload = jwt.payload;
    final perfil = payload is Map
        ? Perfil.values.asNameMap()[payload['perfil']]
        : null;
    if (jwt.header?['alg'] != 'HS256' || id == null || perfil == null) {
      throw const NaoAutenticado('Token inválido.', 'TOKEN_INVALIDO');
    }
    return UsuarioAutenticado(id: id, perfil: perfil);
  }
}
