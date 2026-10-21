import 'perfil.dart';

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
    this.senhaHash,
    this.telefone,
    this.dataNascimento,
  });

  final int id;
  final String nome;
  final String email;
  final Perfil perfil;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final String? senhaHash;
  final String? telefone;
  final DateTime? dataNascimento;

  bool get possuiSenha => senhaHash != null;
}

class NovoUsuario {
  const NovoUsuario({
    required this.nome,
    required this.email,
    required this.perfil,
    this.senhaHash,
    this.telefone,
    this.dataNascimento,
  });

  final String nome;
  final String email;
  final Perfil perfil;
  final String? senhaHash;
  final String? telefone;
  final DateTime? dataNascimento;
}

class AlteracaoUsuario {
  const AlteracaoUsuario({
    required this.nome,
    required this.email,
    this.telefone,
    this.dataNascimento,
  });

  final String nome;
  final String email;
  final String? telefone;
  final DateTime? dataNascimento;
}
