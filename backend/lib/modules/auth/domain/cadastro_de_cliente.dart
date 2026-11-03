import '../../usuarios/domain/envio_de_convite.dart';
import '../../usuarios/domain/erros_usuario.dart';
import '../../usuarios/domain/gestao_de_usuarios.dart';
import '../../usuarios/domain/perfil.dart';
import '../../usuarios/domain/usuario.dart';
import '../../usuarios/domain/usuario_repositorio.dart';

class CadastroDeCliente {
  CadastroDeCliente({
    required this._usuarios,
    required this._clientes,
    required this._convites,
  });

  final UsuarioRepositorio _usuarios;
  final GestaoDeUsuarios _clientes;
  final EnvioDeConvite _convites;

  Future<void> executar(AlteracaoUsuario dados) async {
    final existente = await _usuarios.buscarPorEmail(dados.email);
    if (existente == null) {
      await _clientes.cadastrar(dados);
      return;
    }
    if (existente.perfil == Perfil.cliente && !existente.possuiSenha) {
      await _convites.enviarConvite(existente);
      return;
    }
    throw const EmailJaCadastrado();
  }
}
