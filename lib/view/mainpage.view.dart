import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:damamiflutter/services/ApiService.dart';
import 'package:damamiflutter/models/Relatorio.dart';
import 'package:damamiflutter/models/DadosGraficos.dart';
import 'package:damamiflutter/utils/global.colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Relatorio>> _cachosColhidos;
  late Future<List<Relatorio>> _cachosVendidos;
  late Future<String> _vendasClientes;
  double inicio = 2021;
  double fim = 2023;


  @override
  void initState() {
    super.initState();
    _cachosColhidos = _fetchRelatorios("1", "0", inicio.toInt().toString(), fim.toInt().toString());
    _cachosVendidos = _fetchRelatorios("2","0",inicio.toInt().toString(),fim.toInt().toString());
    _vendasClientes = _fetchRelatoriosDinamicos("9","0",inicio.toInt().toString(),fim.toInt().toString());

  }
  Future<List<Relatorio>> _fetchRelatorios(String relatorio, String unidade, String anoInicial, String anoFinal) async {
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
  Future<String> _fetchRelatoriosDinamicos(String relatorio, String unidade, String anoInicial, String anoFinal) async {final apiService = ApiService();    return await apiService.GetChart(relatorio, unidade, anoInicial, anoFinal);
  }
  List<Relatorio> _mapRelatorios(String jsonInput){
    final List<Relatorio> teste = [];
    final meujson = json.encode(jsonInput);
    return teste;
  }
  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    final Orientation orientation = MediaQuery.of(context).orientation;
    bool isDark = brightnessValue == Brightness.dark;



    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Damami App'),
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Cachos Colhidos
              const SizedBox(height: 140),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Cachos Colhidos",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosColhidos,
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
                        TooltipBehavior(enable: true),
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
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Cachos Colhidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
              ),
              const SizedBox(height: 2,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosColhidos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SfCartesianChart(
                        backgroundColor: Colors.white,
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: const TextStyle(color: Colors.black),
                            iconHeight: 15,
                            iconWidth: 15,
                            toggleSeriesVisibility: true
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: snapshot.data!
                            .map(
                              (relatorio) => ColumnSeries<DadosGraficos, String>(
                            name: relatorio.nomeRelatorio,
                            dataSource: relatorio.dadosGraficosList,
                            xValueMapper: (dadosGraficos, _) => dadosGraficos.key,
                            yValueMapper: (dadosGraficos, _) => dadosGraficos.value,
                            legendItemText: relatorio.ano.toString(),
                            color: GlobalColors.graphicColors[relatorio.ano % GlobalColors.graphicColors.length].withOpacity(0.9),
                            borderColor: GlobalColors.graphicColors[relatorio.ano % GlobalColors.graphicColors.length].withOpacity(1),
                            borderWidth: 2,
                            width: 0.8,
                            enableTooltip: true,
                            legendIconType: LegendIconType.circle,

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
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Cachos Colhidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
              ),
              const SizedBox(height: 2,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 120 * (fim-inicio)),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosColhidos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final relatorios = snapshot.data!;
                      return SfDataGrid(
                        horizontalScrollPhysics: NeverScrollableScrollPhysics(),
                        verticalScrollPhysics: NeverScrollableScrollPhysics(),
                        source: _RelatorioDataSource(relatorios,context),
                        headerGridLinesVisibility: GridLinesVisibility.both,
                        gridLinesVisibility: GridLinesVisibility.both,


                        columns: [
                          GridColumn(
                              columnName: 'ano',
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                alignment: Alignment.center,
                                child: Text('Ano'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 -20),
                          GridColumn(
                              columnName: 'jan',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jan'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'fev',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Fev'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'mar',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Mar'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'abr',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Abr'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'mai',
                              label: Container(

                                alignment: Alignment.center,
                                child: Text('Mai'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'jun',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jun'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'jul',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jul'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'ago',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Ago'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'set',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Set'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'out',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Out'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'nov',
                              label: Container(

                                alignment: Alignment.center,
                                child: Text('Nov'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'dez',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Dez'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'total',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 12 : 13),),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),


                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),),


              //Quilos Vendidos
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Quilos Vendidos",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosVendidos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SfCartesianChart(
                        backgroundColor: Colors.white,
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
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
                        TooltipBehavior(enable: true),
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
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Quilos Vendidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
              ),
              const SizedBox(height: 2,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosVendidos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SfCartesianChart(
                        backgroundColor: Colors.white,
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: const TextStyle(color: Colors.black),
                            iconHeight: 15,
                            iconWidth: 15,
                            toggleSeriesVisibility: true
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: snapshot.data!
                            .map(
                              (relatorio) => ColumnSeries<DadosGraficos, String>(
                            name: relatorio.nomeRelatorio,
                            dataSource: relatorio.dadosGraficosList,
                            xValueMapper: (dadosGraficos, _) => dadosGraficos.key,
                            yValueMapper: (dadosGraficos, _) => dadosGraficos.value,
                            legendItemText: relatorio.ano.toString(),
                            color: GlobalColors.graphicColors[relatorio.ano % GlobalColors.graphicColors.length].withOpacity(0.9),
                            borderColor: GlobalColors.graphicColors[relatorio.ano % GlobalColors.graphicColors.length].withOpacity(1),
                            borderWidth: 2,
                            width: 0.8,
                            enableTooltip: true,
                            legendIconType: LegendIconType.circle,

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
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Quilos Vendidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
              ),
              const SizedBox(height: 2,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 120 * (fim-inicio)),
                child: FutureBuilder<List<Relatorio>>(
                  future: _cachosVendidos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final relatorios = snapshot.data!;
                      return SfDataGrid(
                        horizontalScrollPhysics: NeverScrollableScrollPhysics(),
                        verticalScrollPhysics: NeverScrollableScrollPhysics(),
                        source: _RelatorioDataSource(relatorios,context),
                        headerGridLinesVisibility: GridLinesVisibility.both,
                        gridLinesVisibility: GridLinesVisibility.both,


                        columns: [
                          GridColumn(
                              columnName: 'ano',
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                alignment: Alignment.center,
                                child: Text('Ano'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 -20),
                          GridColumn(
                              columnName: 'jan',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jan'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'fev',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Fev'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'mar',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Mar'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'abr',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Abr'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'mai',
                              label: Container(

                                alignment: Alignment.center,
                                child: Text('Mai'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'jun',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jun'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'jul',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Jul'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'ago',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Ago'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'set',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Set'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'out',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Out'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'nov',
                              label: Container(

                                alignment: Alignment.center,
                                child: Text('Nov'),
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'dez',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Dez'),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),
                          GridColumn(
                              columnName: 'total',
                              label: Container(

                                alignment: Alignment.center,
                                color: Color.fromRGBO(191, 245, 249, 0.3),
                                child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 12 : 13),),
                              ),width: MediaQuery.of(context).size.width.toDouble()/14 + 20/14),


                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),),



              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Resultados de Vendas por Cliente (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
              ),
              const SizedBox(height: 2,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: FutureBuilder<String>(
                  future: _vendasClientes,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<Relatorio> relatorioMap = [];
                      return SfCartesianChart(
                        backgroundColor: Colors.white,
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelStyle: const TextStyle(
                            color: Colors.black, // Defina a cor do texto do eixo X aqui
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
                        TooltipBehavior(enable: true),
                        series: relatorioMap!
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
              ConstrainedBox(constraints: BoxConstraints(maxHeight: 120 * (fim-inicio)),
              child: FutureBuilder<String>(
                future: _vendasClientes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final jsonString = snapshot.data;
                    if (jsonString == null) {
                      return const Center(
                        child: Text('No data found'),
                      );
                    }
                    final List<dynamic> data = json.decode(jsonString);

                    final List<Map<String, dynamic>> dataList = data.map((item) {
                      final Map<String, dynamic> map = {};
                      for (final field in item) {
                        map[field['key']] = field['value'];
                      }
                      return map;
                    }).toList();

                    final List<GridColumn> columns = List<GridColumn>.from(data[0].map((field) {
                      final String columnName = field['key'];
                      return GridColumn(columnName: columnName,
                          width: MediaQuery.of(context).size.width.toDouble()/dataList[0].length,
                          label: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        alignment: Alignment.center,
                        color: const Color.fromRGBO(191, 245, 249, 0.3),
                        child: Text(columnName,style: const TextStyle(fontSize: 12),),
                      ));
                    }));

                    return SfDataGrid(
                      source: _DataSource(dataList),

                      verticalScrollPhysics: NeverScrollableScrollPhysics(),
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      gridLinesVisibility: GridLinesVisibility.both,

                      columns: columns,

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
              ),)

            ],
          )),
    );
  }

}

class _DataSource extends DataGridSource {
  _DataSource(this._dataList);

  final List<Map<String, dynamic>> _dataList;
  int _rowCount = 0;

  @override
  List<DataGridRow> get rows => _dataList.map((data) {
    final cells = data.entries.map((entry) {
      final key = entry.key.toString();
      final value = key == "Ano"?entry.value.toString():  double.parse(entry.value.toString().replaceAll(",", "."));

      final formattedValue =  value is num
          ? NumberFormat('###,##0.00', 'pt_BR').format(value)
          : value.toString();
      return DataGridCell<String>(
        columnName: entry.key,
        value: formattedValue,
      );
    }).toList();
    return DataGridRow(cells: cells);
  }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isEven = _rowCount.isEven;
    _rowCount++;
    return DataGridRowAdapter(
      color: isEven ? Color.fromRGBO(236, 236, 236, 1) : Colors.white,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Center(
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}
class _RelatorioDataSource extends DataGridSource {
  var context;

  _RelatorioDataSource(this.relatorios,this.context) {
    _relatorioData = relatorios.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'ano', value: e.ano.toString()),
      DataGridCell<double>(
          columnName: 'jan', value: _getValorPorMes(e, 'Jan')),
      DataGridCell<double>(
          columnName: 'fev', value: _getValorPorMes(e, 'Fev')),
      DataGridCell<double>(
          columnName: 'mar', value: _getValorPorMes(e, 'Mar')),
      DataGridCell<double>(
          columnName: 'abr', value: _getValorPorMes(e, 'Abr')),
      DataGridCell<double>(
          columnName: 'mai', value: _getValorPorMes(e, 'Mai')),
      DataGridCell<double>(
          columnName: 'jun', value: _getValorPorMes(e, 'Jun')),
      DataGridCell<double>(
          columnName: 'jul', value: _getValorPorMes(e, 'Jul')),
      DataGridCell<double>(
          columnName: 'ago', value: _getValorPorMes(e, 'Ago')),
      DataGridCell<double>(
          columnName: 'set', value: _getValorPorMes(e, 'Set')),
      DataGridCell<double>(
          columnName: 'out', value: _getValorPorMes(e, 'Out')),
      DataGridCell<double>(
          columnName: 'nov', value: _getValorPorMes(e, 'Nov')),
      DataGridCell<double>(
          columnName: 'dez', value: _getValorPorMes(e, 'Dez')),
      DataGridCell<double>(
          columnName: 'total', value: _getValorPorMes(e, 'Jan') + _getValorPorMes(e, 'Fev')+ _getValorPorMes(e, 'Mar')+ _getValorPorMes(e, 'Abr')+ _getValorPorMes(e, 'Mai')+ _getValorPorMes(e, 'Jun')+ _getValorPorMes(e, 'Jul')+ _getValorPorMes(e, 'Ago')+ _getValorPorMes(e, 'Set')+ _getValorPorMes(e, 'Out')+ _getValorPorMes(e, 'Nov')+ _getValorPorMes(e, 'Dez')),

    ])).toList();
  }

  List<DataGridRow> _relatorioData = [];
  List<Relatorio> relatorios;

  double _getValorPorMes(Relatorio relatorio, String mes) {
    var dadosGraficos =
    relatorio.dadosGraficosList.firstWhere((e) => e.key == mes);
    return dadosGraficos.value;
  }

  @override
  List<DataGridRow> get rows => _relatorioData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final formatter = NumberFormat('#,##0', 'pt_BR');
    final index = _relatorioData.indexOf(row);
    final isEven = index % 2 == 0;
    return DataGridRowAdapter(color: isEven ? Color.fromRGBO(236, 236, 236, 1) : Colors.white,cells: row.getCells().map<Widget>((e) {
      return Container(

          alignment: Alignment.center,
          child: e.columnName == 'ano'
              ? Text(e.value.toString(),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 13))
              : e.columnName == 'total' ? Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 9 : 11),) :Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 11),));
    }).toList());
  }
}