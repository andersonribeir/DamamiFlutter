import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:damamiflutter/services/ApiService.dart';
import 'package:damamiflutter/models/Relatorio.dart';
import 'package:damamiflutter/models/DadosGraficos.dart';
import 'package:damamiflutter/utils/global.colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Relatorio>> _relatorios;
  late Future<List<Relatorio>> _relatoriosCachosVendidos;

  @override
  void initState() {
    super.initState();
    _relatorios = _fetchRelatorios("1", "0", "2021", "2023");
    // _relatoriosCachosVendidos = _fetchRelatorios("2","0","2021","2023");
  }

  Future<List<Relatorio>> _fetchRelatorios(String relatorio, String unidade,
      String anoInicial, String anoFinal) async {
    final apiService = ApiService();
    final chartDataString =
        await apiService.GetChart(relatorio, unidade, anoInicial, anoFinal);
    final jsonData = json.decode(chartDataString);
    final chartDataList = jsonData is List ? jsonData : [jsonData];
    return chartDataList
        .map((chartData) => Relatorio(
              ano: chartData['ano'],
              nomeRelatorio: chartData['nomeRelatorio'],
              dadosGraficosList: (chartData['dadosGraficosList'] as List)
                  .map((dadosGraficos) => DadosGraficos(
                        key: dadosGraficos['key'],
                        value: dadosGraficos['value'],
                      ))
                  .toList(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;
    final linearGradient = LinearGradient(
      colors: [Colors.blue.withOpacity(0.2), Colors.white.withOpacity(0)],
      stops: [0, 1],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Damami App'),
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Cachos Colhidos",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<List<Relatorio>>(
                  future: _relatorios,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SfCartesianChart(
                        backgroundColor: Colors.white,
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(
                            color: Colors
                                .black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(
                            color: Colors
                                .black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: const TextStyle(color: Colors.black),
                            iconHeight: 15,
                            iconWidth: 15,
                            toggleSeriesVisibility: true),
                        tooltipBehavior:
                            TooltipBehavior(enable: true, duration: 5),
                        series: snapshot.data!
                            .map(
                              (relatorio) => AreaSeries<DadosGraficos, String>(
                                name: relatorio.nomeRelatorio,
                                dataSource: relatorio.dadosGraficosList,
                                xValueMapper: (dadosGraficos, _) =>
                                    dadosGraficos.key,
                                yValueMapper: (dadosGraficos, _) =>
                                    dadosGraficos.value,
                                legendItemText: relatorio.ano.toString(),
                                color: GlobalColors.graphicColors[
                                        relatorio.ano %
                                            GlobalColors.graphicColors.length]
                                    .withOpacity(1)
                                    .withOpacity(0.3),
                                borderColor: GlobalColors.graphicColors[
                                        relatorio.ano %
                                            GlobalColors.graphicColors.length]
                                    .withOpacity(1),
                                borderWidth: 2,
                                enableTooltip: true,
                                legendIconType: LegendIconType.circle,
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  color: GlobalColors.graphicColors[
                                      relatorio.ano %
                                          GlobalColors.graphicColors.length],
                                  shape: DataMarkerType.circle,
                                  height: 6,
                                  width: 6,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('${snapshot.error}'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
