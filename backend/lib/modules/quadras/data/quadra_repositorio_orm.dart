import '../../../core/database/database.dart' as bd;
import '../../../core/paginacao/paginacao.dart';
import '../../../core/paginacao/paginacao_orm.dart';
import '../domain/hora_do_dia.dart';
import '../domain/quadra.dart';
import '../domain/quadra_repositorio.dart';

class QuadraRepositorioOrm implements QuadraRepositorio {
  QuadraRepositorioOrm(this._db);

  final bd.Database<bd.Postgres> _db;

  static final _ordenacao = <String, CampoOrdenavel<bd.QuadraFields>>{
    'nome': (q) => q.nome,
    'localizacao': (q) => q.localizacao,
    'criadoEm': (q) => q.criadoEm,
  };

  bd.Query<bd.Quadra, bd.QuadraFields> _ativas(bd.QueryContext contexto) =>
      contexto.quadra.where((q) => q.ativo.eq(true));

  @override
  Future<Pagina<Quadra>> listar(ParametrosPaginacao parametros) async {
    final pagina = await _ativas(_db)
        .buscar(parametros.busca, [(q) => q.nome, (q) => q.localizacao])
        .paginar(parametros, ordenacao: _ordenacao, desempate: (q) => q.id);

    final horariosPorQuadra = await _horariosDe(
      _db,
      pagina.itens.map((q) => q.id),
    );
    return pagina.mapear(
      (linha) => linha._paraDominio(horariosPorQuadra[linha.id] ?? const []),
    );
  }

  @override
  Future<Quadra?> buscarPorId(int id) => _buscarPorId(_db, id);

  @override
  Future<bool> existeComNome(String nome, {int? ignorarId}) {
    var consulta = _ativas(_db)
        .where((q) => q.nome.lower().eq(nome.trim().toLowerCase()));
    if (ignorarId != null) {
      consulta = consulta.where((q) => q.id.ne(ignorarId));
    }
    return consulta.exists();
  }

  @override
  Future<Quadra> criar(DadosDaQuadra dados) {
    return _db.transaction((tx) async {
      final linha = await tx.quadra.create(
        nome: dados.nome,
        localizacao: dados.localizacao,
        descricao: dados.descricao,
        duracaoSessaoMin: dados.duracaoSessaoMin,
      );
      await _inserirHorarios(tx, linha.id, dados.horarios);
      return (await _buscarPorId(tx, linha.id))!;
    });
  }

  @override
  Future<Quadra?> atualizar(int id, DadosDaQuadra dados) {
    return _db.transaction((tx) async {
      final alteradas = await _ativas(tx)
          .where((q) => q.id.eq(id))
          .patch(
            nome: .set(dados.nome),
            localizacao: .set(dados.localizacao),
            descricao: .set(dados.descricao),
            duracaoSessaoMin: .set(dados.duracaoSessaoMin),
            atualizadoEm: .set(DateTime.now().toUtc()),
          );
      if (alteradas == 0) return null;

      await tx.horarioFuncionamento
          .where((h) => h.quadraId.eq(id))
          .delete()
          .execute();
      await _inserirHorarios(tx, id, dados.horarios);
      return _buscarPorId(tx, id);
    });
  }

  @override
  Future<bool> desativar(int id) async {
    final alteradas = await _ativas(_db)
        .where((q) => q.id.eq(id))
        .patch(ativo: .set(false), atualizadoEm: .set(DateTime.now().toUtc()));
    return alteradas > 0;
  }

  Future<Quadra?> _buscarPorId(bd.QueryContext contexto, int id) async {
    final linha = await _ativas(contexto)
        .where((q) => q.id.eq(id))
        .firstOrNull();
    if (linha == null) return null;
    final horarios = await _horariosDe(contexto, [id]);
    return linha._paraDominio(horarios[id] ?? const []);
  }

  Future<Map<int, List<IntervaloDeFuncionamento>>> _horariosDe(
    bd.QueryContext contexto,
    Iterable<int> idsDasQuadras,
  ) async {
    final ids = idsDasQuadras.toList();
    if (ids.isEmpty) return const {};

    final linhas = await contexto.horarioFuncionamento
        .where((h) => h.quadraId.isIn(ids))
        .orderBy((h) => [h.diaSemana.asc(), h.inicio.asc()])
        .get();

    final porQuadra = <int, List<IntervaloDeFuncionamento>>{};
    for (final linha in linhas) {
      porQuadra
          .putIfAbsent(linha.quadraId, () => [])
          .add(
            IntervaloDeFuncionamento(
              diaSemana: linha.diaSemana,
              inicio: _paraHoraDoDia(linha.inicio),
              fim: _paraHoraDoDia(linha.fim),
            ),
          );
    }
    return porQuadra;
  }

  Future<void> _inserirHorarios(
    bd.QueryContext contexto,
    int quadraId,
    List<IntervaloDeFuncionamento> horarios,
  ) async {
    if (horarios.isEmpty) return;
    await contexto.horarioFuncionamento
        .insertMany(
          horarios,
          (h, intervalo) => [
            h.quadraId.set(quadraId),
            h.diaSemana.set(intervalo.diaSemana),
            h.inicio.set(_paraLocalTime(intervalo.inicio)),
            h.fim.set(_paraLocalTime(intervalo.fim)),
          ],
        )
        .execute();
  }
}

const _microssegundosPorMinuto = 60 * 1000 * 1000;

HoraDoDia _paraHoraDoDia(bd.LocalTime hora) {
  final minutos = hora.microseconds ~/ _microssegundosPorMinuto;
  return HoraDoDia(minutos ~/ 60, minutos % 60);
}

bd.LocalTime _paraLocalTime(HoraDoDia hora) =>
    bd.LocalTime(hora.hora, hora.minuto);

extension on bd.Quadra {
  Quadra _paraDominio(List<IntervaloDeFuncionamento> horarios) => Quadra(
    id: id,
    nome: nome,
    localizacao: localizacao,
    descricao: descricao,
    duracaoSessaoMin: duracaoSessaoMin,
    horarios: horarios,
    criadoEm: criadoEm,
    atualizadoEm: atualizadoEm,
  );
}
