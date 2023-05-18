import 'dart:convert';


import 'package:damamiflutter/view/widgets/globalsearch.textform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:damamiflutter/services/ApiService.dart';
import 'package:damamiflutter/models/Relatorio.dart';
import 'package:damamiflutter/models/DadosGraficos.dart';
import 'package:damamiflutter/utils/global.colors.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime now = DateTime.now();
  late Future<List<Relatorio>> _cachosColhidos;
  late Future<List<Relatorio>> _cachosVendidos;
  late Future<List<Relatorio>> _valoresVendidos;
  late Future<List<Relatorio>> _precoMedioCachoVendido;
  late Future<List<Relatorio>> _pesoMedioCachoVendido;
  late Future<List<Relatorio>> _despesas;
  late Future<List<Relatorio>> _receitas;
  late Future<List<Relatorio>> _resultados;
  late Future<List<Relatorio>> _perdas;
  final TextEditingController anoInicialInput = TextEditingController();
  FocusNode focusNodeInicial = FocusNode();
  final TextEditingController anoFinalInput = TextEditingController();
  FocusNode focusNodeFinal = FocusNode();
  late Future<String> _vendasClientes;
  String inicioPesquisa = (DateTime.now().year-2).toString();
  String fimPesquisa = (DateTime.now().year).toString();
  double inicio = (DateTime.now().year-2).toDouble();
  double fim = (DateTime.now().year).toDouble();
  String selectedOption = "";
  int selectedIndex = 0;

  late List<String> options = ["Todas"];

  @override
  void initState() {
    super.initState();
    selectedOption = "Todas";
    anoInicialInput.text = inicioPesquisa;
    anoFinalInput.text = fimPesquisa;
    _cachosColhidos = _fetchRelatorios("1", "0", inicioPesquisa, fimPesquisa);
    _cachosVendidos = _fetchRelatorios("2","0",inicioPesquisa,fimPesquisa);
    _valoresVendidos = _fetchRelatoriosDecimais("3","0",inicioPesquisa,fimPesquisa);
    _precoMedioCachoVendido = _fetchRelatoriosDecimais("4","0",inicioPesquisa,fimPesquisa);
    _pesoMedioCachoVendido = _fetchRelatoriosDecimais("5","0",inicioPesquisa,fimPesquisa);
    _despesas = _fetchRelatoriosDecimais("6","0",inicioPesquisa,fimPesquisa);
    _receitas = _fetchRelatoriosDecimais("7","0",inicioPesquisa,fimPesquisa);
    _resultados = _fetchRelatoriosDecimais("8","0",inicioPesquisa,fimPesquisa);

    _vendasClientes = _fetchRelatoriosDinamicos("9","0",inicioPesquisa,fimPesquisa);
    _perdas = _fetchRelatorios("10", "0", inicioPesquisa, fimPesquisa);
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
  Future<List<Relatorio>> _fetchRelatoriosDecimais(String relatorio, String unidade, String anoInicial, String anoFinal) async {
    final apiService = ApiService();
    final chartDataString =
    await apiService.GetChartDecimal(relatorio, unidade, anoInicial, anoFinal);
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
    final List<Relatorio> relatorios = [];
    final meujson = json.decode(jsonInput);


    List<List<DadosGraficos>> dadosGraficosList = meujson.map<List<DadosGraficos>>((list) {
      List<DadosGraficos> innerList = list.map<DadosGraficos>((data) {
        return DadosGraficos(
          key: data['key'],
          value: double.parse(data['value'].replaceAll(',', '.')),
        );
      }).toList();

      return innerList;
    }).toList();

    for (var dadosList in dadosGraficosList) {
      if(dadosList.isNotEmpty){
        Relatorio relatorio = Relatorio(ano: dadosList[0].value.toInt(),nomeRelatorio: "Resultados de Vendas por Cliente (em R\$)",dadosGraficosList: dadosList.sublist(1,dadosList.length-1));
        relatorios.add(relatorio);
      }


    }

    return relatorios;
  }

  void _openStringPicker(int initialIndex, Function(String, int) onSelectionChanged) {
    String selectedOptionTemp = selectedOption; // Create a temporary variable to store the selected option
    int selectedIndexTemp = selectedIndex;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Stack(
            children: [
              CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex,
                ),
                itemExtent: 50.0,
                onSelectedItemChanged: (int index) {
                  selectedOptionTemp = options[index];
                  selectedIndexTemp = index;
                  onSelectionChanged(selectedOptionTemp, selectedIndexTemp);
                },
                children: options.map((String option) {
                  return Text(
                    option,
                    style: TextStyle(fontSize: 20),
                  );
                }).toList(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    onSelectionChanged(selectedOptionTemp, selectedIndexTemp);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.transparent,
                    child:  Text(
                      'Pronto',
                      style: TextStyle(
                        color: GlobalColors.mainColor.withOpacity(0.8),
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    final Orientation orientation = MediaQuery.of(context).orientation;
    bool isDark = brightnessValue == Brightness.dark;

    final ScrollController _scrollController = ScrollController();
    int selectedValue = 0;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        backgroundColor: isDark ? Colors.black :Colors.white ,
        foregroundColor: isDark ? Colors.white:Colors.black,
        title: Text('Damami App - '+ 'Todas - ' + inicioPesquisa.trim() + ' a ' + fimPesquisa.trim(),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontFamily: '.SF Pro Text' ),),
      ),
      body:Scrollbar(
        radius: Radius.circular(2),
        controller: _scrollController,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                const SizedBox(height: 25),
                Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 33,
                        width: 130,
                        child: DecoratedBox(
                              decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark? Colors.white.withOpacity(0.4): Colors.black.withOpacity(0.2),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                                child: TextButton(
                        onPressed: () {
                          // Display the picker when tapped
                          _openStringPicker(selectedIndex, (selectedOption, selectedIndex) {
                            setState(() {
                              this.selectedOption = selectedOption;
                              this.selectedIndex = selectedIndex;
                            });
                          });
                        },
                                    child: Text(
                                      selectedOption,
                                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                                    ),
                    ),
        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: GlobalSearchTextForm(
                          controller: anoInicialInput,
                          text: '',
                          focusNode: focusNodeInicial,
                          textInputType: TextInputType.number,
                          obscure: false,
                        ),
                      ),
                      const SizedBox(width: 17,),
                      Text('a',style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white: Colors.black),),
                      const SizedBox(width: 10,),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        child: GlobalSearchTextForm(
                          controller: anoFinalInput,
                          text: '',
                          focusNode: focusNodeFinal,
                          textInputType: TextInputType.number,
                          obscure: false,
                        ),
                      ),
                      const SizedBox(width: 18,),

                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.grey.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2), // changes the position of the shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.search),
                          color: isDark ? Colors.white : Colors.black,
                          onPressed: () {
                            bool erro = false;
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(anoInicialInput.text.trim()=="" || anoFinalInput.text.trim()==""){
                              erro = true;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Dados não inseridos."),
                                    content: Text("Por favor, insira os dados para consulta."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Ok"),
                                      ),
                                    ],
                                  );
                                },
                              );

                            }
                            if(int.parse(anoInicialInput.text.trim()) > int.parse(anoFinalInput.text.trim())){
                              erro = true;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Dados inválidos."),
                                    content: Text("Por favor, corrija o período da consulta."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Ok"),
                                      ),
                                    ],
                                  );
                                },
                              );

                            }
                            if(!erro){
                              setState(() {
                                inicio = int.parse(anoInicialInput.text).toDouble();
                                fim = int.parse(anoFinalInput.text).toDouble();
                                inicioPesquisa = anoInicialInput.text ;
                                fimPesquisa = anoFinalInput.text;
                                _cachosColhidos = _fetchRelatorios("1", "0", inicioPesquisa, fimPesquisa);
                                _cachosVendidos = _fetchRelatorios("2","0",inicioPesquisa,fimPesquisa);
                                _valoresVendidos = _fetchRelatoriosDecimais("3","0",inicioPesquisa,fimPesquisa);
                                _precoMedioCachoVendido = _fetchRelatoriosDecimais("4","0",inicioPesquisa,fimPesquisa);
                                _pesoMedioCachoVendido = _fetchRelatoriosDecimais("5","0",inicioPesquisa,fimPesquisa);
                                _despesas = _fetchRelatoriosDecimais("6","0",inicioPesquisa,fimPesquisa);
                                _receitas = _fetchRelatoriosDecimais("7","0",inicioPesquisa,fimPesquisa);
                                _resultados = _fetchRelatoriosDecimais("8","0",inicioPesquisa,fimPesquisa);

                                _vendasClientes = _fetchRelatoriosDinamicos("9","0",inicioPesquisa,fimPesquisa);
                                _perdas = _fetchRelatorios("10", "0", inicioPesquisa, fimPesquisa);
                              });
                            }


                          },
                        ),
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(color: Colors.black.withOpacity(0.2),
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                ),



                const SizedBox(height: 10),


                //Cachos Colhidos
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Cachos Colhidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _cachosColhidos,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

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
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 12 : 13),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),

                const SizedBox(height: 15),
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Quilos Vendidos",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _cachosVendidos,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

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
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),

                const SizedBox(height: 15),

                //Valores vendidos
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Valores Vendidos (em R\$)",
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
                    future: _valoresVendidos,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Valores Vendidos (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _valoresVendidos,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Valores Vendidos (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _valoresVendidos,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimal(relatorios,context,"1"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),



                const SizedBox(height: 15),

                //	Preço Médio do Cacho Vendido (em R$)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Preço Médio do Cacho Vendido (em R\$)",
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
                    future: _precoMedioCachoVendido,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Preço Médio do Cacho Vendido (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _precoMedioCachoVendido,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Preço Médio do Cacho Vendido (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _precoMedioCachoVendido,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimalMedia(relatorios,context,"2"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                            GridColumn(
                                columnName: 'media',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Média',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5)

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),

                const SizedBox(height: 15),

                //Peso Médio do Cacho Vendido (em Kg)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "	Peso Médio do Cacho Vendido (em KG)",
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
                    future: _pesoMedioCachoVendido,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 3,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Peso Médio do Cacho Vendido (em KG)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _pesoMedioCachoVendido,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 3,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Peso Médio do Cacho Vendido (em KG)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _pesoMedioCachoVendido,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimalMedia(relatorios,context,"3"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                            GridColumn(
                                columnName: 'media',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Média',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5)

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),

                const SizedBox(height: 15),


                //Despesas (em R$)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Despesas (em R\$)",
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
                    future: _despesas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Despesas (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _despesas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Despesas (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _despesas,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimal(relatorios,context,"1"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                            GridColumn(
                                columnName: 'media',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Média',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5)

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),


                const SizedBox(height: 15),


                //Receitas (em R$)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Receitas (em R\$)",
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
                    future: _receitas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Receitas (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _receitas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Receitas (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _receitas,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimal(relatorios,context,"1"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5)

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),


                const SizedBox(height: 15),

                //Resultados (em R$)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Resultados (em R\$)",
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
                    future: _resultados,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Resultados (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _resultados,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Resultados (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _resultados,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

                          verticalScrollPhysics: NeverScrollableScrollPhysics(),
                          source: _RelatorioDataSourceDecimal(relatorios,context,"1"),
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,


                          columns: [
                            GridColumn(
                                columnName: 'ano',
                                label: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  alignment: Alignment.center,
                                  child: Text('Ano'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5)

                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),


                const SizedBox(height: 15),


                //Vendas por cliente em R$
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
                        final List<Relatorio> relatorioMap = _mapRelatorios(snapshot.data.toString());
                        return SfCartesianChart(
                          backgroundColor: Colors.white,
                          primaryXAxis: CategoryAxis(
                            labelStyle: const TextStyle(
                              color: Colors.black, // Defina a cor do texto do eixo X aqui
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 2,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
                          ),

                          legend: Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                              textStyle: const TextStyle(color: Colors.black),
                              iconHeight: 15,
                              iconWidth: 15,
                              toggleSeriesVisibility: true
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true,

                          ),
                          series: relatorioMap!
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
                const SizedBox(height: 15,),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Resultados de Vendas por Cliente (em R\$)",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 3,),
                ConstrainedBox(constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
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
                              width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/dataList[0].length: MediaQuery.of(context).size.width.toDouble()/5,
                              label: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                alignment: Alignment.center,
                                color: GlobalColors.mainColor.withOpacity(0.8),
                                child: Center(child: Text(columnName,style: const TextStyle(fontSize: 12),textAlign: TextAlign.center,)),
                              ));
                        }));

                        return SfDataGrid(
                          source: _DataSource(dataList,context),

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
                  ),),


                //Perdas
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Perdas",
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
                    future: _perdas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                  child: Text("Perdas",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 2,),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _perdas,
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
                              color: Colors.black, // Define the Y-axis text color here
                            ),
                            numberFormat: NumberFormat.currency(
                                locale: 'pt_BR',
                                decimalDigits: 0,
                                name: ''
                            ),
                            // numberFormat: NumberFormat('###,##0.00', 'pt_BR'),
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
                const SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Perdas",style: TextStyle(fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black),),
                ),
                const SizedBox(height: 5,),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 80  ,maxHeight: fim == inicio ? 100: (75 * (fim+1-inicio))),
                  child: FutureBuilder<List<Relatorio>>(
                    future: _perdas,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final relatorios = snapshot.data!;
                        return SfDataGrid(

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
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jan',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jan'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'fev',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Fev'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mar',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Mar'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'abr',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Abr'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'mai',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Mai'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jun',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jun'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'jul',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Jul'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'ago',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Ago'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'set',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Set'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'out',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Out'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'nov',
                                label: Container(

                                  alignment: Alignment.center,
                                  child: Text('Nov'),
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'dez',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Dez'),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),
                            GridColumn(
                                columnName: 'total',
                                label: Container(

                                  alignment: Alignment.center,
                                  color: GlobalColors.mainColor.withOpacity(0.8),
                                  child: Text('Total',style: TextStyle(fontSize: orientation == Orientation.portrait ? 14 : 15),),
                                ),width: orientation == Orientation.landscape?  MediaQuery.of(context).size.width.toDouble()/14: MediaQuery.of(context).size.width.toDouble()/6.5),


                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),),
              ],
            )),
      ),
    );


  }

}

class _DataSource extends DataGridSource {
  var context;
  _DataSource(this._dataList,this.context);

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
    final Orientation orientation = MediaQuery.of(context).orientation;
    return DataGridRowAdapter(
      color: isEven ? Color.fromRGBO(236, 236, 236, 1) : Colors.white,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Center(

          child: Text(dataGridCell.value.toString(),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 13),),
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
              : e.columnName == 'total' ? Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 10),) :Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 11),));
    }).toList());
  }
}
class _RelatorioDataSourceDecimal extends DataGridSource {
  var context;
  String casasDecimais;

  _RelatorioDataSourceDecimal(this.relatorios,this.context,this.casasDecimais) {
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
    var formatter = NumberFormat('#,##0.00', 'pt_BR');
     formatter = NumberFormat('#,##0.00', 'pt_BR');
    if(casasDecimais == "3" ){
      formatter = NumberFormat('#,##0.000', 'pt_BR');
    }
    final index = _relatorioData.indexOf(row);
    final isEven = index % 2 == 0;
    return DataGridRowAdapter(color: isEven ? Color.fromRGBO(236, 236, 236, 1) : Colors.white,cells: row.getCells().map<Widget>((e) {
      return Container(

          alignment: Alignment.center,
          child: e.columnName == 'ano'
              ? Text(e.value.toString(),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 13,color: e.value.toString().contains('-')? Colors.red:Colors.black ))
              : e.columnName == 'total' ? Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 9,color: e.value.toString().contains('-')? Colors.red:Colors.black ),) :Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 10,color: e.value.toString().contains('-')? Colors.red:Colors.black ),));
    }).toList());
  }
}
class _RelatorioDataSourceDecimalMedia extends DataGridSource {
  var context;
  String casasDecimais;
  _RelatorioDataSourceDecimalMedia(this.relatorios,this.context,this.casasDecimais) {
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
          columnName: 'media', value: _getValorPorMes(e, 'Jan')/12 + _getValorPorMes(e, 'Fev')/12 + _getValorPorMes(e, 'Mar')/12 + _getValorPorMes(e, 'Abr')/12 + _getValorPorMes(e, 'Mai')/12 + _getValorPorMes(e, 'Jun')/12 + _getValorPorMes(e, 'Jul')/12 + _getValorPorMes(e, 'Ago')/12 + _getValorPorMes(e, 'Set')/12 + _getValorPorMes(e, 'Out')/12 + _getValorPorMes(e, 'Nov')/12 + _getValorPorMes(e, 'Dez')/12),


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

    var formatter = NumberFormat('#,##0.00', 'pt_BR');
    if(casasDecimais == "3" ){
      formatter = NumberFormat('#,##0.000', 'pt_BR');
    }
    final index = _relatorioData.indexOf(row);
    final isEven = index % 2 == 0;
    return DataGridRowAdapter(color: isEven ? Color.fromRGBO(236, 236, 236, 1) : Colors.white,cells: row.getCells().map<Widget>((e) {
      return Container(

          alignment: Alignment.center,
          child: e.columnName == 'ano'
              ? Text(e.value.toString(),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 13))
              : e.columnName == 'total' ? Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 9),) :Text(formatter.format(e.value),style: TextStyle(fontSize: orientation == Orientation.portrait ? 10 : 10),));
    }).toList());
  }
}