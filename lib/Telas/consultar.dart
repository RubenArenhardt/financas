// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:financas/funcoes/funcoes.dart';
import 'package:flutter/material.dart';

import 'package:financas/objetos/atualizacao.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class Consultar extends StatefulWidget {
  final BancoDeDados bd;
  final List<Atualizacao> listaEntrada, listaSaida;
  Consultar({required this.bd, required this.listaEntrada, required this.listaSaida});

  DateTime dt = DateTime.now();

  @override
  State<StatefulWidget> createState() {
    return ConsultarState(listaEntrada, listaSaida, dt);
  } 
  
}

class ConsultarState extends State<Consultar> {

  List<Atualizacao> listaEntrada, listaSaida;

  DateTime dt;

  ConsultarState(this.listaEntrada, this.listaSaida, this.dt);

  final NumberFormat _formatador = NumberFormat("#,##0.00", "pt_BR");

  @override
  Widget build(BuildContext context) {
    
    double valorTotal = calculaValor(
        bd: widget.bd, listaEntrada: listaEntrada, listaSaida: listaSaida);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registros"),
      ),
      body: Column(
        children: [
          Header(),
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
            child: PieChart(
              dataMap: atualizaGrafico(listaSaida, listaEntrada),
              chartType: ChartType.disc,
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                decimalPlaces: 0,
              ),
            ),
          ),
          Listagem(lista: juntaLista(listaEntrada, listaSaida)),
        ],
      ),
    );
  }

  atualizaState({required BancoDeDados bd, required DateTime dt}) async {
    listaEntrada = await bd.getListaEntradas(dt);
    listaSaida = await bd.getListaSaida(dt);
    setState(() {});
  }
}  

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_left),
        ),
        TextButton(
          onPressed: () {},
          child: Text("Mês / Ano"),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_right),
        ),
      ],
    );
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

  const Listagem({
    required this.lista,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: lista.length,
        itemBuilder: (context, indice) {
          return ItemAtualizacao(atualizacao: lista[indice]);
        },
      ),
    );
  }
}

class ItemAtualizacao extends StatelessWidget {
  final Atualizacao atualizacao;

  ItemAtualizacao({required this.atualizacao});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [Text(atualizacao.nome), Text(atualizacao.data)],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            Row(
              children: [
                Text(
                  atualizacao.valor.toString(),
                  style: TextStyle(color: corValorAtu(atualizacao)),
                ),
                Text(atualizacao.tag)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        ),
      ),
    );
  }
}
