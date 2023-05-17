import 'package:damamiflutter/models/DadosGraficos.dart';
class Relatorio {
    int ano;
   String nomeRelatorio;
   List<DadosGraficos> dadosGraficosList;

  Relatorio(
      {required this.ano,
        required this.nomeRelatorio,
        required this.dadosGraficosList});
}