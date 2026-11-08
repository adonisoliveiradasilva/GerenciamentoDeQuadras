import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'relatorios_controller.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final RelatoriosController _controller = RelatoriosController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Relatórios', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Acompanhe as métricas', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () => _controller.selecionarPeriodo(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.calendarDay, color: Color(0xFF1E65D0), size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _controller.periodoFormatado,
                            style: TextStyle(
                              color: _controller.periodoSelecionado == null ? Colors.grey.shade500 : const Color(0xFF0D253F),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                      ],
                    ),
                  ),
                );
              }
            ),
            
            const SizedBox(height: 24),

            // Conteúdo dos Gráficos
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  if (_controller.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF1E65D0)));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildChartCard('Quadras mais usadas', _buildBarChart(_controller.quadrasUsadas)),
                        _buildChartCard('Clientes mais frequentes', _buildBarChart(_controller.clientesFrequentes)),
                        _buildChartCard('Dias mais movimentados', _buildLineChart(_controller.diasMovimentados)),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data) {
    final keys = data.keys.toList();
    final values = data.values.toList();
    double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + (maxY * 0.2),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(keys[value.toInt()], style: const TextStyle(color: Colors.blueGrey, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(keys.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: const Color(0xFF1E65D0),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Lógica do Gráfico de Linha
  Widget _buildLineChart(Map<String, double> data) {
    final keys = data.keys.toList();
    final values = data.values.toList();
    double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY + (maxY * 0.2),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= keys.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(keys[value.toInt()], style: const TextStyle(color: Colors.blueGrey, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(keys.length, (index) => FlSpot(index.toDouble(), values[index])),
            isCurved: true,
            color: const Color(0xFF1E65D0),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF1E65D0).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}