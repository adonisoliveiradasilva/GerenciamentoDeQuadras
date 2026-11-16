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
  Future<List<Agendamento>> buscarPorQuadraEData(
    int quadraId,
    DateTime inicio,
    DateTime fim,
  ) async {
    return itens.where((a) {
      return a.quadraId == quadraId &&
          !a.dataFim.isBefore(inicio) &&
          !a.dataInicio.isAfter(fim);
    }).toList();
  }

  @override
  Future<bool> existeConflitoDeHorario(
    int quadraId,
    DateTime inicio,
    DateTime fim,
  ) async {
    return itens.any((a) {
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
  });

  group('ServicoDeAgendamentos - Testes Unitários', () {
    test('deve criar agendamento com sucesso quando horário está livre', () async {
      final inicio = DateTime.now().add(const Duration(days: 1, hours: 2));
      final fim = inicio.add(const Duration(hours: 1));

      final resultado = await servico.criarAgendamento(
        quadraId: 1,
        clienteId: 10,
        dataInicio: inicio,
        dataFim: fim,
        valorTotal: 120.0,
      );

      expect(resultado.id, 1);
      expect(resultado.status, 'pendente');
      expect(resultado.valorTotal, 120.0);
      expect(agendamentoRepo.itens.length, 1);
    });

    test('deve lançar exceção quando dataFim for igual ou anterior a dataInicio', () async {
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
    });

    test('deve bloquear agendamento em horário já ocupado (conflito)', () async {
      final inicio = DateTime.now().add(const Duration(days: 1, hours: 3));
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
    });

    test('deve listar apenas horários livres excluindo os já agendados', () async {
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
        dataInicio: DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day, 9, 0),
        dataFim: DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day, 10, 0),
        valorTotal: 80.0,
      );

      final livres = await servico.buscarHorariosLivres(1, dataAlvo);

      expect(livres.length, 2);
      expect(livres[0].hour, 8);
      expect(livres[1].hour, 10);
    });

    test('deve lançar exceção ao buscar horários livres de quadra inexistente', () async {
      expect(
        () => servico.buscarHorariosLivres(999, DateTime.now().add(const Duration(days: 1))),
        throwsA(isA<Exception>()),
      );
    });
  });
}
