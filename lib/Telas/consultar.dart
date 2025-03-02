// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'dart:io';

import 'package:financas/Telas/adicionar.dart';
import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:financas/funcoes/funcoes.dart';
import 'package:flutter/material.dart';

import 'package:financas/objetos/atualizacao.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class Consultar extends StatefulWidget {
  final BancoDeDados bd;
  final List<Atualizacao> listaEntrada, listaSaida;
  Consultar(
      {required this.bd, required this.listaEntrada, required this.listaSaida});

  DateTime dt = DateTime.now();

  @override
  State<StatefulWidget> createState() {
    return ConsultarState(listaEntrada, listaSaida, dt);
  }
}

final NumberFormat _formatador = NumberFormat("#,##0.00", "pt_BR");

class ConsultarState extends State<Consultar> {
  List<Atualizacao> listaEntrada, listaSaida;

  DateTime dt;

  ConsultarState(this.listaEntrada, this.listaSaida, this.dt);

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    double valorTotal =
        calculaValor(listaEntrada: listaEntrada, listaSaida: listaSaida);
    String data = dt.month.toString() + "/" + dt.year.toString();

    _initializeMobileAdsSDK();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registros"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    dt = voltaMes(dt);
                    refresh(bd: widget.bd, dt: dt);
                  });
                },
                icon: Icon(Icons.arrow_left),
              ),
              TextButton(
                onPressed: () {},
                child: Text(data),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    dt = passaMes(dt);
                    refresh(bd: widget.bd, dt: dt);
                  });
                },
                icon: Icon(Icons.arrow_right),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text(
              "R\$${_formatador.format(valorTotal)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corValor(valorTotal),
                fontSize: 42,
              ),
            ),
          ),
          Container(
            width: 400,
            height: 300,
            alignment: Alignment.center,
            child: criaPieChart(
              listaSaida: listaSaida, 
              legendPosition: LegendPosition.right,
              isPersantage: false)
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(1000, 20, 20, 20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "R\$${_formatador.format(calculaValor(listaEntrada: listaEntrada, listaSaida: List.empty()))}",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(1000, 20, 20, 20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "R\$${_formatador.format(calculaValor(listaEntrada: List.empty(), listaSaida: listaSaida))}",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Listagem(
            lista: juntaLista(listaEntrada, listaSaida),
            bd: widget.bd,
            refreshCallback: () {
              refresh(bd: widget.bd, dt: dt);
            },
          ),
          if (_bannerAd != null && _isLoaded)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  refresh({required BancoDeDados bd, required DateTime dt}) async {
    List<Atualizacao> entradas = await bd.getListaEntradas(dt);
    List<Atualizacao> saidas = await bd.getListaSaidas(dt);
    setState(() {
      listaEntrada = entradas;
      listaSaida = saidas;
    });
  }

  void _initializeMobileAdsSDK() async {
    // Inicializa o SDK do Google Mobile Ads.
    MobileAds.instance.initialize();
    // Carrega o banner ad.
    _loadAd();
  }

  void _loadAd() async {
    //Captura o tamanho da tela
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      //Nao foi possivel carregar o tamanho do banner
      return;
    }

    BannerAd(
      adUnitId: widget.bd.getBannerAdUnitId(),
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Chama quando o banner é carregado
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // Chama quando o banner falha ao carregar  
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Chama quando o banner é clicado
        onAdOpened: (ad) {},
      ),
    ).load();
  }

}

Color corValor(double valor) {
  Color cor;

  if (valor > 0) {
    cor = const Color.fromARGB(255, 0, 255, 8);
  } else {
    cor = const Color.fromARGB(255, 255, 17, 1);
  }

  return cor;
}

Color corValorAtu(Atualizacao atu) {
  Color cor;

  if (atu.isEntrada) {
    cor = const Color.fromARGB(255, 0, 255, 8);
  } else {
    cor = const Color.fromARGB(255, 255, 17, 1);
  }

  return cor;
}

List<Atualizacao> juntaLista(List<Atualizacao> lEntrada, lSaida) {
  List<Atualizacao> lista = lEntrada + lSaida;

  lista.sort((a, b) => a.dia().compareTo(b.dia()));

  return lista;
}

class Listagem extends StatelessWidget {
  final List<Atualizacao> lista;
  final BancoDeDados bd;
  final Function refreshCallback;

  const Listagem({
    required this.lista,
    required this.bd,
    required this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: lista.length,
          itemBuilder: (context, indice) {
            return ItemAtualizacao(
              atualizacao: lista[indice],
              bd: bd,
              refreshCallback: refreshCallback,
            );
          },
        ),
      ),
    );
  }
}

class ItemAtualizacao extends StatelessWidget {
  final Atualizacao atualizacao;
  final BancoDeDados bd;
  final Function refreshCallback;

  ItemAtualizacao({
    required this.atualizacao,
    required this.bd,
    required this.refreshCallback,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Adicionar(
              atualizacao: atualizacao,
            ),
          ),
        );

        if (result != null) {
          final Atualizacao novaAtu = result[0];
          final int action = result[1];

          if (action == 1) {
            await bd.edit(atualizacao, novaAtu);
          } else if (action == 2) {
            await bd.delete(atualizacao);
          }

          refreshCallback();
        }
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(atualizacao.nome), Text(atualizacao.data)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "R\$${_formatador.format(atualizacao.valor).toString()}",
                    style: TextStyle(color: corValorAtu(atualizacao)),
                  ),
                  Text(atualizacao.tag)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}