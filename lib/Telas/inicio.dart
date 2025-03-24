// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, unused_element, prefer_const_literals_to_create_immutables
// ignore_for_file: prefer_const_constructors

import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:financas/funcoes/funcoes.dart';
import 'package:financas/telas/adicionar.dart';
import 'package:financas/telas/feedback.dart';
import 'package:financas/telas/futuro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:financas/objetos/atualizacao.dart';
import 'package:financas/telas/consultar.dart';

final NumberFormat _formatador = NumberFormat("#,##0.00", "pt_BR");

class Inicio extends StatefulWidget {
  final User? user;

  final Function notify;

  List<Atualizacao> listaEntrada, listaSaida;

  final BancoDeDados bd;

  Inicio(
      {required this.user,
      required this.notify,
      required this.listaEntrada,
      required this.listaSaida,
      required this.bd});

  @override
  State<StatefulWidget> createState() => InicioState(listaEntrada, listaSaida);
}

class InicioState extends State<Inicio> {
  List<Atualizacao> listaEntrada = [], listaSaida = [];

  InicioState(this.listaEntrada, this.listaSaida);

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    _initializeMobileAdsSDK();
    return Scaffold(
      drawer: Menu(notify:widget.notify, bd: widget.bd,),
      appBar: AppBar(
        title: Text(
          "Ponta do Lápis",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(1000, 20, 20, 20),
                borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(20),
                    bottomEnd: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Saldo",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        textoValor(
                            listaEntrada: listaEntrada,
                            listaSaida: listaSaida,
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        textoValor(
                          listaEntrada: listaEntrada,
                          listaSaida: List.empty(),
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                        textoValor(
                          listaEntrada: List.empty(),
                          listaSaida: listaSaida,
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Text(
                "Gastos",
                style: TextStyle(fontSize: 28),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              width: 300,
              alignment: Alignment.center,
              child: criaPieChart(
                listaSaida: listaSaida,
                legendPosition: LegendPosition.bottom,
                legendsInRow: true,
              ),
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
      ),
      //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return Consultar(
                    bd: widget.bd,
                    listaEntrada: listaEntrada,
                    listaSaida: listaSaida);
              }));
              refresh(widget.bd);
            },
            child: Icon(Icons.remove_red_eye),
            //Por algum motivo ele da erro colocando 2 floatingActionButton
            //sem definir heroTags diferentes
            heroTag: "btn2",
          ),
          FloatingActionButton(
            onPressed: () {
              try {
                final Future<Atualizacao?> future = Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return Adicionar();
                }));
                future.then((atualizacao) {
                  if (atualizacao != null) {
                    setState(() {
                      widget.bd.add(atualizacao);
                    });
                    refresh(widget.bd);
                  } else {
                    refresh(widget.bd);
                  }
                });
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            child: Icon(Icons.add),
            heroTag: "btn1",
          ),
        ],
      ),
      //
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  refresh(bd) async {
    debugPrint("inicializando refresh");
    DateTime dt = DateTime.now();
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

class Menu extends StatelessWidget {

  final Function notify;
  final BancoDeDados bd;
  

  Menu({required this.notify, required this.bd});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(title: Center(child: Text("Menu",style: TextStyle(fontWeight: FontWeight.bold, ),),),),
          ListTile(
            title: Text("O que vem por ai?"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Futuro(bd: bd,);
                }));
            },
          ),
          ListTile(
            title: Text("Deixe seu feedback"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FeedbackPage(bd: bd);
              }));
            },
          ),
          ListTile(
            title: Text("Excluir Dados"),
            onTap: bd.apagaBanco,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
                notify(null, true);
              },
          ),
        ],
      )
    );
  }
}
