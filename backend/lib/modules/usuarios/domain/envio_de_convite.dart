import 'usuario.dart';

abstract interface class EnvioDeConvite {
  Future<void> enviarConvite(Usuario usuario);
}
