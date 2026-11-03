import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

const _bytesDoToken = 32;
final _gerador = Random.secure();

({String token, String hash}) gerarTokenAleatorio() {
  final bytes = List<int>.generate(_bytesDoToken, (_) => _gerador.nextInt(256));
  final token = base64Url.encode(bytes).replaceAll('=', '');
  return (token: token, hash: hashDoToken(token));
}

String hashDoToken(String token) =>
    sha256.convert(utf8.encode(token)).toString();
