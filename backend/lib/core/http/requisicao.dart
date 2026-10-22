import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'erros.dart';

extension LeituraDaRequisicao on Request {
  Future<Map<String, Object?>> lerJson() async {
    final corpo = await readAsString();
    if (corpo.trim().isEmpty) {
      throw const ErroValidacao('O corpo da requisição está vazio.');
    }
    try {
      final dados = jsonDecode(corpo);
      if (dados is Map<String, Object?>) return dados;
    } on FormatException {
      throw const ErroValidacao('O corpo da requisição não é um JSON válido.');
    }
    throw const ErroValidacao('O corpo da requisição deve ser um objeto JSON.');
  }

  int idDaRota([String parametro = 'id']) {
    final valor = this.params[parametro];
    final id = valor == null ? null : int.tryParse(valor);
    if (id == null || id <= 0) {
      throw ErroValidacao(
        'Identificador inválido.',
        campos: {parametro: 'Deve ser um número inteiro positivo.'},
      );
    }
    return id;
  }
}

class LeitorDeCampos {
  LeitorDeCampos(this._dados) : _prefixo = '', _erros = {};

  LeitorDeCampos._doItem(this._dados, this._prefixo, this._erros);

  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _formatoData = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final Map<String, Object?> _dados;
  final String _prefixo;
  final Map<String, String> _erros;

  Map<String, String> get erros => Map.unmodifiable(_erros);

  void adicionarErro(String campo, String mensagem) =>
      _erros.putIfAbsent('$_prefixo$campo', () => mensagem);

  String? texto(
    String campo, {
    bool obrigatorio = true,
    int minimo = 0,
    int? maximo,
  }) {
    final valor = _dados[campo];
    if (valor == null || (valor is String && valor.trim().isEmpty)) {
      if (obrigatorio) adicionarErro(campo, 'Campo obrigatório.');
      return null;
    }
    if (valor is! String) {
      adicionarErro(campo, 'Deve ser um texto.');
      return null;
    }
    final limpo = valor.trim();
    if (limpo.length < minimo) {
      adicionarErro(campo, 'Deve ter pelo menos $minimo caracteres.');
      return null;
    }
    if (maximo != null && limpo.length > maximo) {
      adicionarErro(campo, 'Deve ter no máximo $maximo caracteres.');
      return null;
    }
    return limpo;
  }

  String? email(String campo, {bool obrigatorio = true}) {
    final valor = texto(campo, obrigatorio: obrigatorio, maximo: 254);
    if (valor == null) return null;
    if (!_formatoEmail.hasMatch(valor)) {
      adicionarErro(campo, 'Email inválido.');
      return null;
    }
    return valor.toLowerCase();
  }

  int? inteiro(
    String campo, {
    bool obrigatorio = true,
    int? minimo,
    int? maximo,
  }) {
    final valor = _dados[campo];
    if (valor == null) {
      if (obrigatorio) adicionarErro(campo, 'Campo obrigatório.');
      return null;
    }
    if (valor is! int) {
      adicionarErro(campo, 'Deve ser um número inteiro.');
      return null;
    }
    if (minimo != null && valor < minimo) {
      adicionarErro(campo, 'Deve ser maior ou igual a $minimo.');
      return null;
    }
    if (maximo != null && valor > maximo) {
      adicionarErro(campo, 'Deve ser menor ou igual a $maximo.');
      return null;
    }
    return valor;
  }

  List<LeitorDeCampos>? listaDeObjetos(
    String campo, {
    bool obrigatorio = true,
    int? maximo,
  }) {
    final valor = _dados[campo];
    if (valor == null) {
      if (obrigatorio) adicionarErro(campo, 'Campo obrigatório.');
      return null;
    }
    if (valor is! List) {
      adicionarErro(campo, 'Deve ser uma lista.');
      return null;
    }
    if (maximo != null && valor.length > maximo) {
      adicionarErro(campo, 'Deve ter no máximo $maximo itens.');
      return null;
    }
    final itens = <LeitorDeCampos>[];
    for (var i = 0; i < valor.length; i++) {
      final item = valor[i];
      if (item is! Map<String, Object?>) {
        adicionarErro('$campo[$i]', 'Deve ser um objeto.');
        continue;
      }
      itens.add(LeitorDeCampos._doItem(item, '$_prefixo$campo[$i].', _erros));
    }
    return itens;
  }

  DateTime? data(
    String campo, {
    bool obrigatorio = true,
    DateTime? minima,
    DateTime? maxima,
  }) {
    final texto = this.texto(campo, obrigatorio: obrigatorio, maximo: 10);
    if (texto == null) return null;
    final partes = _formatoData.firstMatch(texto);
    final data = partes == null
        ? null
        : DateTime.utc(
            int.parse(partes[1]!),
            int.parse(partes[2]!),
            int.parse(partes[3]!),
          );
    if (data == null || _formatarData(data) != texto) {
      adicionarErro(campo, 'Use uma data válida no formato AAAA-MM-DD.');
      return null;
    }
    if (minima != null && data.isBefore(minima)) {
      adicionarErro(campo, 'Deve ser a partir de ${_formatarData(minima)}.');
      return null;
    }
    if (maxima != null && data.isAfter(maxima)) {
      adicionarErro(campo, 'Deve ser até ${_formatarData(maxima)}.');
      return null;
    }
    return data;
  }

  bool? booleano(String campo, {bool obrigatorio = true}) {
    final valor = _dados[campo];
    if (valor == null) {
      if (obrigatorio) adicionarErro(campo, 'Campo obrigatório.');
      return null;
    }
    if (valor is! bool) {
      adicionarErro(campo, 'Deve ser verdadeiro ou falso.');
      return null;
    }
    return valor;
  }

  void validar() {
    if (_erros.isNotEmpty) {
      throw ErroValidacao('Dados inválidos.', campos: Map.of(_erros));
    }
  }
}

String _formatarData(DateTime data) => data.toIso8601String().substring(0, 10);
