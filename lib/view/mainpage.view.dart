import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:damamiflutter/services/ApiService.dart';
import 'package:damamiflutter/models/Relatorio.dart';
import 'package:damamiflutter/models/DadosGraficos.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Relatorio>> _relatorios;

  @override
  void initState() {
    super.initState();
    _relatorios = _fetchRelatorios();
  }

  Future<List<Relatorio>> _fetchRelatorios() async {
    final apiService = ApiService();
    final chartDataString = await apiService.GetChart("1", "0", "2021", "2023");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Damami App'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: FutureBuilder<List<Relatorio>>(
            future: _relatorios,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                    legend: Legend(isVisible: true, position: LegendPosition.bottom),
                  series: snapshot.data!
                      .map((relatorio) => LineSeries<DadosGraficos, String>(
                    name: relatorio.nomeRelatorio,
                    dataSource: relatorio.dadosGraficosList,
                    xValueMapper: (dadosGraficos, _) =>
                    dadosGraficos.key,
                    yValueMapper: (dadosGraficos, _) =>
                    dadosGraficos.value,
                    legendItemText: relatorio.ano.toString(),

                  ))
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
      ),
    );
  }
}
