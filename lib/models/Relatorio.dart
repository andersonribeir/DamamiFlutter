import 'dart:ui';

import 'package:damamiflutter/models/DadosGraficos.dart';
import 'package:flutter/material.dart';
class Relatorio {
  final int ano;
  final String nomeRelatorio;
  final List<DadosGraficos> dadosGraficosList;

  Relatorio(
      {required this.ano,
        required this.nomeRelatorio,
        required this.dadosGraficosList});
}