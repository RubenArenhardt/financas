import 'package:financas/objetos/atualizacao.dart';

Map<String, double> atualizaGrafico(List<Atualizacao> listaSaida, listaEntrada) {

    Map<String, double> mapa = ({});

    if (listaSaida.length == 0) {
      mapa = ({"Sem dados suficientes": 1});
    }else{
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