import '../../../core/http/requisicao.dart';
import '../domain/usuario.dart';

final _dataMinimaDeNascimento = DateTime.utc(1900);

AlteracaoUsuario lerDadosDoUsuario(LeitorDeCampos campos) {
  final nome = campos.texto('nome', minimo: 2, maximo: 120);
  final email = campos.email('email');
  final telefone = lerTelefone(campos, 'telefone');
  final dataNascimento = campos.data(
    'dataNascimento',
    obrigatorio: false,
    minima: _dataMinimaDeNascimento,
    maxima: DateTime.now().toUtc(),
  );
  campos.validar();

  return AlteracaoUsuario(
    nome: nome!,
    email: email!,
    telefone: telefone,
    dataNascimento: dataNascimento,
  );
}

String? lerTelefone(LeitorDeCampos campos, String campo) {
  final texto = campos.texto(campo, obrigatorio: false, maximo: 20);
  if (texto == null) return null;
  final digitos = texto.replaceAll(RegExp(r'\D'), '');
  if (digitos.length < 10 || digitos.length > 11) {
    campos.adicionarErro(campo, 'Informe o DDD e o número (10 ou 11 dígitos).');
    return null;
  }
  return digitos;
}
