import '../../../core/http/requisicao.dart';
import '../domain/usuario.dart';

enum ExigenciaDeSenha { nenhuma, opcional, obrigatoria }

final _dataMinimaDeNascimento = DateTime.utc(1900);
const _tamanhoMinimoDaSenha = 8;
const _tamanhoMaximoDaSenha = 72;

({AlteracaoUsuario dados, String? senha}) lerDadosDoUsuario(
  LeitorDeCampos campos, {
  ExigenciaDeSenha senha = ExigenciaDeSenha.nenhuma,
}) {
  final nome = campos.texto('nome', minimo: 2, maximo: 120);
  final email = campos.email('email');
  final telefone = lerTelefone(campos, 'telefone');
  final dataNascimento = campos.data(
    'dataNascimento',
    obrigatorio: false,
    minima: _dataMinimaDeNascimento,
    maxima: DateTime.now().toUtc(),
  );
  final senhaLida = switch (senha) {
    ExigenciaDeSenha.nenhuma => null,
    ExigenciaDeSenha.opcional => _lerSenha(campos, obrigatoria: false),
    ExigenciaDeSenha.obrigatoria => _lerSenha(campos, obrigatoria: true),
  };
  campos.validar();

  return (
    dados: AlteracaoUsuario(
      nome: nome!,
      email: email!,
      telefone: telefone,
      dataNascimento: dataNascimento,
    ),
    senha: senhaLida,
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

String? _lerSenha(LeitorDeCampos campos, {required bool obrigatoria}) {
  final senha = campos.texto(
    'senha',
    obrigatorio: obrigatoria,
    minimo: _tamanhoMinimoDaSenha,
    maximo: _tamanhoMaximoDaSenha,
  );
  if (senha == null) return null;
  final confirmacao = campos.texto('confirmarSenha');
  if (confirmacao != null && confirmacao != senha) {
    campos.adicionarErro('confirmarSenha', 'As senhas não conferem.');
    return null;
  }
  return senha;
}
