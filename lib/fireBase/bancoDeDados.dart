// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/objetos/atualizacao.dart';
import 'package:flutter/foundation.dart';

class BancoDeDados {
  final String id;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  BancoDeDados({
    required this.id,
  });

  //add
  add(Atualizacao atu) {
    String tipoAtualizacao;
    if (atu.isEntrada) {
      tipoAtualizacao = "Entrada";
    } else {
      tipoAtualizacao = "Saida";
    }

    try {
      firestore
          .collection(id)
          .doc("Registros")
          .collection(atu.ano().toString())
          .doc(atu.mes().toString())
          .collection(tipoAtualizacao)
          .doc(atu.idUnico)
          .set(atu.getMap());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  //edit

  //delete

  //get
  //Lista

  Future<List<Atualizacao>> getListaEntradas(DateTime dt) async{
    List<Atualizacao> entradas = [];

    try {
      //await necessario para esperar terminar a 
      //busca no banco antes de devolver a lista
       await firestore
          .collection(id)
          .doc("Registros")
          .collection(dt.year.toString())
          .doc(dt.month.toString())
          .collection("Entrada")
          .get()
          .then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            entradas.add(Atualizacao.fromMap(docSnapshot.data()));
          }
        },
        onError: (e) => debugPrint("Error completing: $e"),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return entradas;
  }

  Future<List<Atualizacao>> getListaSaidas(DateTime dt) async {
    List<Atualizacao> saidas = [];

    try {
      await firestore
          .collection(id)
          .doc("Registros")
          .collection(dt.year.toString())
          .doc(dt.month.toString())
          .collection("Saida")
          .get()
          .then(
        (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            saidas.add(Atualizacao.fromMap(docSnapshot.data()));
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return saidas;
  }
}
