// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable, unused_element, prefer_const_literals_to_create_immutables
// ignore_for_file: prefer_const_constructors

import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:financas/funcoes/funcoes.dart';
import 'package:financas/telas/adicionar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

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

  @override
  Widget build(BuildContext context) {
    debugPrint(listaEntrada.toString());
    return Scaffold(
      //
      appBar: AppBar(
        title: Text(
          "Na Ponta do Lápis",
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
              onPressed: () {
                widget.notify(null, true);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      //
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(25, 25, 25, 0),
              child: Text(
                "Saldo",
                style: TextStyle(fontSize: 28),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Text(
                "R\$${_formatador.format(calculaValor(listaEntrada: listaEntrada, listaSaida: listaSaida))}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                ),
              ),
            ),
            Container(
              child: Text(
                "Gastos",
                style: TextStyle(fontSize: 28),
              ),
            ),
            Container(
              width: 300,
              alignment: Alignment.center,
              child: PieChart(
                dataMap: atualizaGrafico(listaSaida, listaEntrada),
                chartType: ChartType.disc,
                legendOptions: LegendOptions(
                  showLegendsInRow: true,
                  legendPosition: LegendPosition.bottom,
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  decimalPlaces: 2,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
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
                        child:Text(
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

  refresh(bd) async {
    print("inicializando refresh");
    DateTime dt = DateTime.now();
    List<Atualizacao> entradas = await bd.getListaEntradas(dt);
    List<Atualizacao> saidas = await bd.getListaSaidas(dt);
    setState(() {
      listaEntrada = entradas;
      listaSaida = saidas;
    });
  }
}
