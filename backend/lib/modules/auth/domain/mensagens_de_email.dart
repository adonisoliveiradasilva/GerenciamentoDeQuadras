import 'dart:convert';

import '../../../core/email/enviador_de_email.dart';
import '../../usuarios/domain/usuario.dart';
import 'tipo_de_token_de_senha.dart';

const _html = HtmlEscape();

EmailParaEnviar mensagemDeSenha({
  required Usuario usuario,
  required TipoDeTokenDeSenha tipo,
  required Uri link,
  required Duration validade,
}) {
  final primeiroNome = usuario.nome.split(' ').first;
  final prazo = _descreverPrazo(validade);
  final (assunto, chamada, botao) = switch (tipo) {
    TipoDeTokenDeSenha.criar => (
      'Crie sua senha no Gerenciador de Quadras',
      'Sua conta foi criada. Para acessar o aplicativo, crie a sua senha.',
      'Criar senha',
    ),
    TipoDeTokenDeSenha.redefinir => (
      'Redefina sua senha do Gerenciador de Quadras',
      'Recebemos um pedido para redefinir a sua senha.',
      'Redefinir senha',
    ),
  };
  const aviso = 'Se você não fez este pedido, ignore este email.';

  return EmailParaEnviar(
    para: usuario.email,
    nomeDoDestinatario: usuario.nome,
    assunto: assunto,
    texto:
        'Olá, $primeiroNome!\n\n'
        '$chamada\n\n'
        '$botao: $link\n\n'
        'O link vale por $prazo e só pode ser usado uma vez.\n'
        '$aviso\n',
    html:
        '<p>Olá, ${_html.convert(primeiroNome)}!</p>'
        '<p>${_html.convert(chamada)}</p>'
        '<p><a href="${_html.convert('$link')}" '
        'style="display:inline-block;padding:12px 20px;background:#1565C0;'
        'color:#fff;border-radius:8px;text-decoration:none">$botao</a></p>'
        '<p>O link vale por $prazo e só pode ser usado uma vez.<br>$aviso</p>',
  );
}

String _descreverPrazo(Duration validade) =>
    validade.inHours == 1 ? '1 hora' : '${validade.inHours} horas';
