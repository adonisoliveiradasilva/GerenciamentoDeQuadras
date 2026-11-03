import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../config/ambiente.dart';
import 'enviador_de_email.dart';

class EnviadorDeEmailSmtp implements EnviadorDeEmail {
  EnviadorDeEmailSmtp({
    required this._servidor,
    required this._remetente,
    this._saidaDeErros,
  });

  factory EnviadorDeEmailSmtp.doAmbiente(Ambiente ambiente) {
    final usuario = ambiente.opcional('SMTP_USUARIO');
    return EnviadorDeEmailSmtp(
      servidor: SmtpServer(
        ambiente.obrigatorio('SMTP_HOST'),
        port: ambiente.inteiro('SMTP_PORTA', padrao: 587),
        ssl: ambiente.booleano('SMTP_SSL', padrao: false),
        allowInsecure: ambiente.booleano(
          'SMTP_PERMITIR_SEM_TLS',
          padrao: false,
        ),
        username: usuario,
        password: usuario == null ? null : ambiente.opcional('SMTP_SENHA'),
      ),
      remetente: Address(
        ambiente.obrigatorio('EMAIL_REMETENTE'),
        ambiente.opcional('EMAIL_REMETENTE_NOME'),
      ),
    );
  }

  static const _tempoLimite = Duration(seconds: 15);

  final SmtpServer _servidor;
  final Address _remetente;
  final IOSink? _saidaDeErros;

  @override
  Future<void> enviar(EmailParaEnviar email) async {
    final mensagem = Message()
      ..from = _remetente
      ..recipients.add(Address(email.para, email.nomeDoDestinatario))
      ..subject = email.assunto
      ..text = email.texto
      ..html = email.html;
    try {
      await send(mensagem, _servidor, timeout: _tempoLimite);
    } on Object catch (erro) {
      (_saidaDeErros ?? stderr).writeln(
        'Falha ao enviar email para ${email.para}: $erro',
      );
      throw const EmailIndisponivel();
    }
  }
}
