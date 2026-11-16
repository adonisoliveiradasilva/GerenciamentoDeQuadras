import 'package:flutter/material.dart';

import '../../../core/models/agendamento_model.dart';
import '../../../core/models/quadra_model.dart';
import '../../../core/services/agendamentos_service.dart';
import '../../../core/services/quadras_service.dart';

class AgendamentosFormController extends ChangeNotifier {
  final AgendamentosService _agendamentosService = AgendamentosService();
  final QuadrasService _quadrasService = QuadrasService();

  List<QuadraModel> quadras = [];
  QuadraModel? quadraSelecionada;
  DateTime? dataSelecionada;
  List<DateTime> horariosLivres = [];
  String? horarioSelecionado;
  String? quantidadeSecoes = '1';

  final dataController = TextEditingController();

  int? agendamentoId;
  bool isLoadingQuadras = false;
  bool isLoadingHorarios = false;
  bool isLoading = false;

  final List<String> opcoesSecoes = ['1', '2', '3', '4'];

  List<String> get quadrasDisponiveis => quadras.map((q) => q.nome).toList();

  String get duracaoDaQuadra {
    if (quadraSelecionada == null) return '';
    return '${quadraSelecionada!.duracaoSessaoMin}m';
  }

  List<String> get horariosDisponiveisFormatados =>
      horariosLivres.map(_formatarHora).toList();

  String _formatarHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> inicializar(AgendamentoModel? agendamentoExistente) async {
    isLoadingQuadras = true;
    notifyListeners();

    try {
      final pagina = await _quadrasService.listarQuadras(
        pagina: 1,
        tamanho: 100,
      );
      quadras = pagina.itens;

      if (agendamentoExistente != null) {
        agendamentoId = agendamentoExistente.id;
        quadraSelecionada = quadras
            .where((q) => q.id == agendamentoExistente.quadraId)
            .firstOrNull;

        dataSelecionada = DateTime(
          agendamentoExistente.dataInicio.year,
          agendamentoExistente.dataInicio.month,
          agendamentoExistente.dataInicio.day,
        );
        final dia = dataSelecionada!.day.toString().padLeft(2, '0');
        final mes = dataSelecionada!.month.toString().padLeft(2, '0');
        dataController.text = '$dia/$mes/${dataSelecionada!.year}';

        if (quadraSelecionada != null) {
          final duracaoTotalMin = agendamentoExistente.dataFim
              .difference(agendamentoExistente.dataInicio)
              .inMinutes;
          final qtd = (duracaoTotalMin / quadraSelecionada!.duracaoSessaoMin)
              .round();
          if (opcoesSecoes.contains(qtd.toString())) {
            quantidadeSecoes = qtd.toString();
          }
        }

        await _carregarHorariosLivres();

        final horaAtual = _formatarHora(agendamentoExistente.dataInicio);
        if (!horariosDisponiveisFormatados.contains(horaAtual)) {
          horariosLivres.insert(0, agendamentoExistente.dataInicio);
        }
        horarioSelecionado = horaAtual;
      }
    } finally {
      isLoadingQuadras = false;
      notifyListeners();
    }
  }

  Future<void> alterarQuadra(String? nomeQuadra) async {
    if (nomeQuadra == null) return;
    quadraSelecionada = quadras.where((q) => q.nome == nomeQuadra).firstOrNull;
    horarioSelecionado = null;
    horariosLivres = [];
    notifyListeners();

    if (quadraSelecionada != null && dataSelecionada != null) {
      await _carregarHorariosLivres();
    }
  }

  void alterarSecoes(String? nova) {
    quantidadeSecoes = nova;
    notifyListeners();
  }

  void alterarHorario(String? novo) {
    horarioSelecionado = novo;
    notifyListeners();
  }

  Future<void> selecionarData(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataSelecionada != null && !dataSelecionada!.isBefore(today)
          ? dataSelecionada!
          : today,
      firstDate: today,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      dataSelecionada = picked;
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      dataController.text = '$dia/$mes/${picked.year}';
      horarioSelecionado = null;
      horariosLivres = [];
      notifyListeners();

      if (quadraSelecionada != null) {
        await _carregarHorariosLivres();
      }
    }
  }

  Future<void> _carregarHorariosLivres() async {
    if (quadraSelecionada == null || dataSelecionada == null) return;

    isLoadingHorarios = true;
    notifyListeners();

    try {
      horariosLivres = await _agendamentosService.buscarHorariosLivres(
        quadraId: quadraSelecionada!.id,
        data: dataSelecionada!,
        ignorarAgendamentoId: agendamentoId,
      );
    } catch (_) {
      horariosLivres = [];
    } finally {
      isLoadingHorarios = false;
      notifyListeners();
    }
  }

  Future<String?> salvar() async {
    if (quadraSelecionada == null) return 'Selecione uma quadra.';
    if (dataSelecionada == null) return 'Selecione o dia do agendamento.';
    if (horarioSelecionado == null) return 'Selecione o horário de início.';
    if (quantidadeSecoes == null) return 'Selecione a quantidade de seções.';

    final partesHora = horarioSelecionado!.split(':');
    final hora = int.parse(partesHora[0]);
    final minuto = int.parse(partesHora[1]);

    final dataInicio = DateTime(
      dataSelecionada!.year,
      dataSelecionada!.month,
      dataSelecionada!.day,
      hora,
      minuto,
    );

    final secoes = int.parse(quantidadeSecoes!);
    final duracaoTotalMin = quadraSelecionada!.duracaoSessaoMin * secoes;
    final dataFim = dataInicio.add(Duration(minutes: duracaoTotalMin));

    isLoading = true;
    notifyListeners();

    try {
      if (agendamentoId == null) {
        await _agendamentosService.criarAgendamento(
          quadraId: quadraSelecionada!.id,
          dataInicio: dataInicio,
          dataFim: dataFim,
        );
      } else {
        await _agendamentosService.atualizarAgendamento(
          id: agendamentoId!,
          quadraId: quadraSelecionada!.id,
          dataInicio: dataInicio,
          dataFim: dataFim,
        );
      }

      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  @override
  void dispose() {
    dataController.dispose();
    super.dispose();
  }
}
