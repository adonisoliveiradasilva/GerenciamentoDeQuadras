import '../../../core/http/erros.dart';

class QuadraJaCadastrada extends Conflito {
  const QuadraJaCadastrada()
    : super('QUADRA_JA_CADASTRADA', 'Já existe uma quadra com este nome.');
}

class QuadraNaoEncontrada extends NaoEncontrado {
  const QuadraNaoEncontrada()
    : super('Quadra não encontrada.', 'QUADRA_NAO_ENCONTRADA');
}
