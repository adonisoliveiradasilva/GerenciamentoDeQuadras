class UsuarioModel {
  final int id;
  final String nome;
  final String email;
  final String perfil;
  final String? telefone;
  final String? dataNascimento; // Formato ISO YYYY-MM-DD vindo da API
  final bool possuiSenha;

  const UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    this.telefone,
    this.dataNascimento,
    this.possuiSenha = false,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      perfil: json['perfil'] as String,
      telefone: json['telefone'] as String?,
      dataNascimento: json['dataNascimento'] as String?,
      possuiSenha: (json['possuiSenha'] as bool?) ?? false,
    );
  }

  /// Converte YYYY-MM-DD (API) para dd/MM/yyyy (exibição na tela)
  String? get dataNascimentoFormatada {
    if (dataNascimento == null || dataNascimento!.length < 10) return null;
    final partes = dataNascimento!.substring(0, 10).split('-');
    if (partes.length != 3) return null;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  /// Converte dd/MM/yyyy (tela) para YYYY-MM-DD (envio para API)
  static String? formatarDataParaApi(String dataBr) {
    final texto = dataBr.trim();
    if (texto.isEmpty) return null;
    final partes = texto.split('/');
    if (partes.length != 3) return null;
    return '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}';
  }
}
