import 'package:financas/objetos/atualizacao.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

carregarAnuncio() {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = 'ca-app-pub-3940256099942544/2247696110';

  NativeAd loadAd() {
    return _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            _nativeAdIsLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
          // Called when a click is recorded for a NativeAd.
          onAdClicked: (ad) {},
          // Called when an impression occurs on the ad.
          onAdImpression: (ad) {},
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (ad) {},
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (ad) {},
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  return ConstrainedBox(
    constraints: const BoxConstraints(
      minWidth: 320, // minimum recommended width
      minHeight: 90, // minimum recommended height
      maxWidth: 400,
      maxHeight: 90,
    ),
    child: AdWidget(ad: loadAd()),
  );
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
