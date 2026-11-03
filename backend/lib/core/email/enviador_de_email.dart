import '../http/erros.dart';

class EmailParaEnviar {
  const EmailParaEnviar({
    required this.para,
    required this.assunto,
    required this.texto,
    required this.html,
    this.nomeDoDestinatario,
  });

  final String para;
  final String? nomeDoDestinatario;
  final String assunto;
  final String texto;
  final String html;
}

abstract interface class EnviadorDeEmail {
  Future<void> enviar(EmailParaEnviar email);
}

class EmailIndisponivel extends ErroApi {
  const EmailIndisponivel()
    : super(
        503,
        'EMAIL_INDISPONIVEL',
        'Não foi possível enviar o email agora. Tente novamente em instantes.',
      );
}
