import 'package:financas/objetos/atualizacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

Map<String, double> atualizaGrafico(List<Atualizacao> listaSaida) {
  Map<String, double> mapa = ({});

  if (listaSaida.length == 0) {
    mapa = ({"Sem dados suficientes": 1});
  } else {
    final int tamanho = listaSaida.length;

    mapa = ({});

    for (int i = 0; i < tamanho; i++) {
      Atualizacao temp = listaSaida[i];

      temp.tag;
      temp.valor;
      Map<String, double> mTemp = ({temp.tag: temp.valor});
      mapa.addEntries(mTemp.entries);
    }
  }
  return mapa;
}

double calculaValor({required List<Atualizacao> listaEntrada, listaSaida}) {
  double valor = 0;
  for (int i = 0; i < listaEntrada.length; i++) {
    valor = valor + listaEntrada[i].valor;
  }
  for (int i = 0; i < listaSaida.length; i++) {
    valor = valor - listaSaida[i].valor;
  }
  return valor;
}

criaPieChart(
    {required List<Atualizacao> listaSaida,
    LegendPosition legendPosition = LegendPosition.right,
    bool isPersantage = true,
    bool legendsInRow = false}) {
  if (listaSaida.length == 0) {
    return Image(
      image: AssetImage("assets/semDados.png"),
      height: 200,
    );
  } else {
    return PieChart(
      dataMap: atualizaGrafico(listaSaida),
      chartType: ChartType.disc,
      chartValuesOptions: ChartValuesOptions(
        showChartValuesInPercentage: isPersantage,
        decimalPlaces: 2,
      ),
      legendOptions: LegendOptions(
        showLegendsInRow: legendsInRow,
        legendPosition: legendPosition,
      ),
    );
  }
}

textoValor(
    {required List<Atualizacao> listaEntrada,
    required List<Atualizacao> listaSaida,
    TextStyle? style,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration}) {
  final NumberFormat _formatador = NumberFormat("#,##0.00", "pt_BR");

  return Container(
    padding: padding,
    margin: margin,
    decoration: decoration,
    child: Text(
      "R\$${_formatador.format(calculaValor(listaEntrada: listaEntrada, listaSaida: listaSaida))}",
      style: style,
    ),
  );
}