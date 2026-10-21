import 'dart:isolate';

import 'package:bcrypt/bcrypt.dart';

abstract interface class HashDeSenha {
  Future<String> gerar(String senha);

  Future<bool> conferir(String senha, String hash);
}

class HashDeSenhaBcrypt implements HashDeSenha {
  const HashDeSenhaBcrypt({this.custo = 10});

  final int custo;

  @override
  Future<String> gerar(String senha) {
    final custo = this.custo;
    return Isolate.run(
      () => BCrypt.hashpw(senha, BCrypt.gensalt(logRounds: custo)),
    );
  }

  @override
  Future<bool> conferir(String senha, String hash) {
    return Isolate.run(() {
      try {
        return BCrypt.checkpw(senha, hash);
      } on Object {
        return false;
      }
    });
  }
}
