import 'package:shelf/shelf.dart';

import '../../modules/usuarios/domain/perfil.dart';
import '../http/erros.dart';
import 'servico_de_token.dart';

const _chaveDoContexto = 'auth/usuario';

extension UsuarioDaRequisicao on Request {
  UsuarioAutenticado get usuarioAutenticado =>
      context[_chaveDoContexto] as UsuarioAutenticado? ??
      (throw StateError('Rota sem o middleware exigirLogin.'));
}

Middleware exigirLogin(ServicoDeToken servicoDeToken) {
  return (Handler interno) {
    return (Request requisicao) {
      final cabecalho = requisicao.headers['authorization'] ?? '';
      final partes = cabecalho.trim().split(RegExp(r'\s+'));
      if (partes.length != 2 || partes.first.toLowerCase() != 'bearer') {
        throw const NaoAutenticado();
      }
      final usuario = servicoDeToken.validar(partes.last);
      return interno(requisicao.change(context: {_chaveDoContexto: usuario}));
    };
  };
}

Middleware exigirPerfis(Set<Perfil> perfisPermitidos) {
  return (Handler interno) {
    return (Request requisicao) {
      if (!perfisPermitidos.contains(requisicao.usuarioAutenticado.perfil)) {
        throw const SemPermissao();
      }
      return interno(requisicao);
    };
  };
}
