class ErroApi implements Exception {
  const ErroApi(this.status, this.codigo, this.mensagem, {this.campos});

  final int status;
  final String codigo;
  final String mensagem;
  final Map<String, String>? campos;

  Map<String, Object?> toJson() => {
    'erro': {
      'codigo': codigo,
      'mensagem': mensagem,
      if (campos != null) 'campos': campos,
    },
  };

  @override
  String toString() => '$runtimeType($status, $codigo): $mensagem';
}

class ErroValidacao extends ErroApi {
  const ErroValidacao(
    String mensagem, {
    super.campos,
    String codigo = 'DADOS_INVALIDOS',
  }) : super(400, codigo, mensagem);
}

class NaoAutenticado extends ErroApi {
  const NaoAutenticado([
    String mensagem = 'É preciso estar autenticado.',
    String codigo = 'NAO_AUTENTICADO',
  ]) : super(401, codigo, mensagem);
}

class SemPermissao extends ErroApi {
  const SemPermissao([
    String mensagem = 'Você não tem permissão para esta ação.',
  ]) : super(403, 'SEM_PERMISSAO', mensagem);
}

class NaoEncontrado extends ErroApi {
  const NaoEncontrado([
    String mensagem = 'Recurso não encontrado.',
    String codigo = 'NAO_ENCONTRADO',
  ]) : super(404, codigo, mensagem);
}

class Conflito extends ErroApi {
  const Conflito(String codigo, String mensagem) : super(409, codigo, mensagem);
}

class ErroInterno extends ErroApi {
  const ErroInterno()
    : super(500, 'ERRO_INTERNO', 'Ocorreu um erro inesperado no servidor.');
}
