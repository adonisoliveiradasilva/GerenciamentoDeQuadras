import '../../../core/http/requisicao.dart';
import '../domain/hora_do_dia.dart';
import '../domain/quadra.dart';

const duracaoMinimaDaSessao = 15;
const duracaoMaximaDaSessao = 480;
const _maximoDeIntervalos = 50;

DadosDaQuadra lerDadosDaQuadra(Map<String, Object?> json) {
  final campos = LeitorDeCampos(json);
  final nome = campos.texto('nome', maximo: 80);
  final localizacao = campos.texto('localizacao', maximo: 120);
  final descricao = campos.texto('descricao', obrigatorio: false, maximo: 500);
  final duracao = campos.inteiro(
    'duracaoSessaoMin',
    minimo: duracaoMinimaDaSessao,
    maximo: duracaoMaximaDaSessao,
  );
  final itens = campos.listaDeObjetos('horarios', maximo: _maximoDeIntervalos);

  final horarios = <IntervaloDeFuncionamento>[];
  for (final item in itens ?? const <LeitorDeCampos>[]) {
    final dia = item.inteiro(
      'diaSemana',
      minimo: IntervaloDeFuncionamento.segunda,
      maximo: IntervaloDeFuncionamento.domingo,
    );
    final inicio = _lerHora(item, 'inicio');
    final fim = _lerHora(item, 'fim');
    if (inicio != null && fim != null && !(inicio < fim)) {
      item.adicionarErro('fim', 'Deve ser depois do início.');
      continue;
    }
    if (dia != null && inicio != null && fim != null) {
      horarios.add(
        IntervaloDeFuncionamento(diaSemana: dia, inicio: inicio, fim: fim),
      );
    }
  }

  campos.validar();
  return DadosDaQuadra(
    nome: nome!,
    localizacao: localizacao!,
    descricao: descricao,
    duracaoSessaoMin: duracao!,
    horarios: horarios,
  );
}

HoraDoDia? _lerHora(LeitorDeCampos campos, String campo) {
  final texto = campos.texto(campo, maximo: 5);
  if (texto == null) return null;
  final hora = HoraDoDia.tentarLer(texto);
  if (hora == null) campos.adicionarErro(campo, 'Use o formato HH:MM.');
  return hora;
}
