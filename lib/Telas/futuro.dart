import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Futuro extends StatefulWidget {
  final BancoDeDados bd;
  Futuro({required this.bd});

  @override
  State<StatefulWidget> createState() => FuturoState();
}

class FuturoState extends State<Futuro> {
  List<Map<String, dynamic>> lista = [];
  @override
  Widget build(BuildContext context) {
    if (lista.length == 0) {
      refresh();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Atualizações que tenho em vista"),
      ),
      body: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, indice) {
          return FuturoItem(item: lista[indice]);
        },
      ),
    );
  }

  refresh() async {
    List<Map<String, dynamic>> l = await widget.bd.getFuturo();
    setState(() {
      lista = l;
    });
  }
}

class FuturoItem extends StatelessWidget {
  final Map<String, dynamic> item;

  FuturoItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListTile(
        title: Text(item["Titulo"]),
        subtitle: Text(item["Mensagem"]),
        shape: Border.all(color: Colors.black,strokeAlign: BorderSide.strokeAlignCenter),
      ),
    );
  }
}
