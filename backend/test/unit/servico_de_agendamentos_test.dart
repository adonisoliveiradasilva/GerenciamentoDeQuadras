import 'package:backend/modules/agendamentos/domain/agendamento.dart';
import 'package:backend/modules/agendamentos/domain/agendamento_repositorio.dart';
import 'package:backend/modules/agendamentos/domain/servico_de_agendamentos.dart';
import 'package:backend/modules/quadras/domain/hora_do_dia.dart';
import 'package:backend/modules/quadras/domain/quadra.dart';
import 'package:backend/modules/quadras/domain/quadra_repositorio.dart';
import 'package:test/test.dart';

class FakeAgendamentoRepositorio implements AgendamentoRepositorio {
  final List<Agendamento> itens = [];
  int _sequenciaId = 1;

  @override
  Future<Agendamento> criar(Agendamento agendamento) async {
    final salvo = Agendamento(
      id: _sequenciaId++,
      quadraId: agendamento.quadraId,
      clienteId: agendamento.clienteId,
      dataInicio: agendamento.dataInicio,
      dataFim: agendamento.dataFim,
      status: agendamento.status,
      valorTotal: agendamento.valorTotal,
      criadoEm: agendamento.criadoEm,
      atualizadoEm: agendamento.atualizadoEm,
    );
    itens.add(salvo);
    return salvo;
  }

  @override
  Future<Agendamento?> buscarPorId(int id) async {
    for (final item in itens) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<Agendamento>> listarTodos({int? clienteId}) async {
    return itens.where((a) {
      if (a.status == StatusAgendamento.cancelado) return false;
      if (clienteId != null && a.clienteId != clienteId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Agendamento> atualizar(Agendamento agendamento) async {
    final index = itens.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      itens[index] = agendamento;
    }
    return agendamento;
  }

  @override
  Future<void> cancelar(int id) async {
    final index = itens.indexWhere((a) => a.id == id);
    if (index != -1) {
      final atual = itens[index];
      itens[index] = Agendamento(
        id: atual.id,
        quadraId: atual.quadraId,
        clienteId: atual.clienteId,
        quadraNome: atual.quadraNome,
        clienteNome: atual.clienteNome,
        dataInicio: atual.dataInicio,
        dataFim: atual.dataFim,
        status: StatusAgendamento.cancelado,
        valorTotal: atual.valorTotal,
        criadoEm: atual.criadoEm,
        atualizadoEm: DateTime.now(),
      );
    }
  }

  @override
  Future<List<Agendamento>> buscarPorQuadraEData(
    int quadraId,
    DateTime inicio,
    DateTime fim,
  ) async {
    return itens.where((a) {
      return a.quadraId == quadraId &&
          a.status != StatusAgendamento.cancelado &&
          !a.dataFim.isBefore(inicio) &&
          !a.dataInicio.isAfter(fim);
    }).toList();
  }

  @override
  Future<bool> existeConflitoDeHorario(
    int quadraId,
    DateTime inicio,
    DateTime fim, {
    int? ignorarAgendamentoId,
  }) async {
    return itens.any((a) {
      if (a.status == StatusAgendamento.cancelado) return false;
      if (ignorarAgendamentoId != null && a.id == ignorarAgendamentoId) {
        return false;
      }
      return a.quadraId == quadraId &&
          inicio.isBefore(a.dataFim) &&
          fim.isAfter(a.dataInicio);
    });
  }
}

class FakeQuadraRepositorio implements QuadraRepositorio {
  final Map<int, Quadra> quadras = {};

  @override
  Future<Quadra?> buscarPorId(int id) async => quadras[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAgendamentoRepositorio agendamentoRepo;
  late FakeQuadraRepositorio quadraRepo;
  late ServicoDeAgendamentos servico;

  setUp(() {
    agendamentoRepo = FakeAgendamentoRepositorio();
    quadraRepo = FakeQuadraRepositorio();
    servico = ServicoDeAgendamentos(agendamentoRepo, quadraRepo);

    final amanha = DateTime.now().add(const Duration(days: 1));
    quadraRepo.quadras[1] = Quadra(
      id: 1,
      nome: 'Quadra Teste',
      localizacao: 'Bloco Principal',
      duracaoSessaoMin: 60,
      horarios: [
        IntervaloDeFuncionamento(
          diaSemana: amanha.weekday,
          inicio: HoraDoDia(0, 0),
          fim: HoraDoDia(23, 59),
        ),
      ],
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );
  });

  group('ServicoDeAgendamentos - Testes Unitários', () {
    test(
      'deve criar agendamento com sucesso quando horário está livre',
      () async {
        final amanha = DateTime.now().add(const Duration(days: 1));
        final inicio = DateTime(amanha.year, amanha.month, amanha.day, 14, 0);
        final fim = inicio.add(const Duration(hours: 1));

        final resultado = await servico.criarAgendamento(
          quadraId: 1,
          clienteId: 10,
          dataInicio: inicio,
          dataFim: fim,
          valorTotal: 120.0,
        );

        expect(resultado.id, 1);
        expect(resultado.status, StatusAgendamento.pendente);
        expect(resultado.valorTotal, 120.0);
        expect(agendamentoRepo.itens.length, 1);
      },
    );

    test(
      'deve lançar exceção quando dataFim for igual ou anterior a dataInicio',
      () async {
        final inicio = DateTime.now().add(const Duration(days: 1));

        expect(
          () => servico.criarAgendamento(
            quadraId: 1,
            clienteId: 10,
            dataInicio: inicio,
            dataFim: inicio,
            valorTotal: 100.0,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'deve bloquear agendamento em horário já ocupado (conflito)',
      () async {
        final amanha = DateTime.now().add(const Duration(days: 1));
        final inicio = DateTime(amanha.year, amanha.month, amanha.day, 15, 0);
        final fim = inicio.add(const Duration(hours: 1));

        await servico.criarAgendamento(
          quadraId: 1,
          clienteId: 10,
          dataInicio: inicio,
          dataFim: fim,
          valorTotal: 100.0,
        );

        expect(
          () => servico.criarAgendamento(
            quadraId: 1,
            clienteId: 20,
            dataInicio: inicio,
            dataFim: fim,
            valorTotal: 100.0,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'deve listar apenas horários livres excluindo os já agendados',
      () async {
        final amanha = DateTime.now().add(const Duration(days: 2));
        final dataAlvo = DateTime(amanha.year, amanha.month, amanha.day);

        quadraRepo.quadras[1] = Quadra(
          id: 1,
          nome: 'Quadra Central',
          localizacao: 'Bloco A',
          duracaoSessaoMin: 60,
          horarios: [
            IntervaloDeFuncionamento(
              diaSemana: dataAlvo.weekday,
              inicio: HoraDoDia(8, 0),
              fim: HoraDoDia(11, 0),
            ),
          ],
          criadoEm: DateTime.now(),
          atualizadoEm: DateTime.now(),
        );

        await servico.criarAgendamento(
          quadraId: 1,
          clienteId: 10,
          dataInicio: DateTime(
            dataAlvo.year,
            dataAlvo.month,
            dataAlvo.day,
            9,
            0,
          ),
          dataFim: DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day, 10, 0),
          valorTotal: 80.0,
        );

        final livres = await servico.buscarHorariosLivres(1, dataAlvo);

        expect(livres.length, 2);
        expect(livres[0].hour, 8);
        expect(livres[1].hour, 10);
      },
    );

    test(
      'deve lançar exceção ao buscar horários livres de quadra inexistente',
      () async {
        expect(
          () => servico.buscarHorariosLivres(
            999,
            DateTime.now().add(const Duration(days: 1)),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
