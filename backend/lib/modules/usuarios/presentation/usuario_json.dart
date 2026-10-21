import '../domain/usuario.dart';

extension UsuarioJson on Usuario {
  Map<String, Object?> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'perfil': perfil.name,
    'telefone': telefone,
    'dataNascimento': dataNascimento?.toIso8601String().substring(0, 10),
    'possuiSenha': possuiSenha,
    'criadoEm': criadoEm.toUtc().toIso8601String(),
    'atualizadoEm': atualizadoEm.toUtc().toIso8601String(),
  };
}
