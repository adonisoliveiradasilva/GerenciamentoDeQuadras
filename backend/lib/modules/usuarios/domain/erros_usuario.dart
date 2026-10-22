import '../../../core/http/erros.dart';
import 'perfil.dart';

class EmailJaCadastrado extends Conflito {
  const EmailJaCadastrado()
    : super('EMAIL_JA_CADASTRADO', 'Este email já está cadastrado.');
}

class UsuarioNaoEncontrado extends NaoEncontrado {
  UsuarioNaoEncontrado(Perfil perfil)
    : super(
        '${perfil.rotulo} não encontrado.',
        '${perfil.name.toUpperCase()}_NAO_ENCONTRADO',
      );
}

extension RotuloDoPerfil on Perfil {
  String get rotulo => switch (this) {
    Perfil.gerente => 'Gerente',
    Perfil.funcionario => 'Funcionário',
    Perfil.cliente => 'Cliente',
  };
}
