// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/objetos/atualizacao.dart';
import 'package:flutter/foundation.dart';

class BancoDeDados {
  final String id;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-7976065858956466/6790330121'
      : 'ca-app-pub-3940256099942544/2435281174';

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

  //delete
  delete(Atualizacao atu) {
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
          .delete();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  //edit
  edit(Atualizacao atuAntiga, Atualizacao atuNova) async {
    try {
      await delete(atuAntiga);
      add(atuNova);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  //get
  //Lista
  Future<List<Atualizacao>> getListaEntradas(DateTime dt) async {
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

  //para utilizar o msm ID em diferentes paginas
  getBannerAdUnitId() {
    return _adUnitId;
  }

  apagaBanco() {
    try{
      firestore.collection(id).doc("Registros").delete();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<List<Map<String,dynamic>>> getFuturo() async {
    List<Map<String, dynamic>> lista = [];
    firestore.collection("Futuro").get().then((snapshot) {
      List l = snapshot.docs;
      for (int i = 0; i < l.length; i++) {
        lista.add(l[i].data());
      }
    });
    return lista;
  }

  addFeedback(String feedback) {
    firestore.collection("Feedback").add({"Feedback": feedback});
  }

  //in progress
  getAllAtualizacao()async{

    final List<Atualizacao> listaEntrada = [], listaSaida = [];
    

    firestore.collection(id).get().then((snapshot) {

      snapshot.docs.forEach((lista){

        lista.data().forEach((key, value){



        });
        
      });
      
    });


  }

}