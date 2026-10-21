import '../../../core/http/erros.dart';

class EmailJaCadastrado extends Conflito {
  const EmailJaCadastrado()
    : super('EMAIL_JA_CADASTRADO', 'Este email já está cadastrado.');
}
