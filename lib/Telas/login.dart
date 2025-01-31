// ignore_for_file: body_might_complete_normally_nullable, must_be_immutable, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:financas/objetos/atualizacao.dart';
import 'package:financas/telas/inicio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class ChecadorLogin extends StatefulWidget {
  Future<User?> usuarioFuturo = signInWithGoogle();
  User? usuario;
  @override
  State<StatefulWidget> createState() {
    usuarioFuturo.then((user) {
      usuario = user;
    });
    return ChecardorLoginState(usuario);
  }
}

class ChecardorLoginState extends State<ChecadorLogin> {
  
    //Não uso widget.usuario(para usar o widget da classe pai) 
    //pq preciso trocar a informação dele em uma função interna;
    //Não tenho certeza se é necessário 
  User? usuario;
  ChecardorLoginState(this.usuario);

  @override
  Widget build(BuildContext context) {
    Widget widgetEscolhido = selecionadorDeClasse(usuario, refresh); //Enviar o refresh 
    return widgetEscolhido;                                          //para poder atualizar a classe
  }

  void refresh(User? user, bool _isSignOut) {
    if(_isSignOut) signOut();   //Preciso saber se é signOut pra não excluir o usuario junto com o signIn
    setState(() {
      usuario = user;
    });
  }
}

class FazerLogin extends StatelessWidget {
  Function notify;
  FazerLogin(this.notify);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () async {
            try {
              Future<User?> future = signInWithGoogle();
              future.then((user) {
                notify(user,false);
              });
            } on Exception catch (e) {
              debugPrint(e.toString());
            }
          },
          child: Text("Fazer Login com Google")),
    );
  }
}

Widget selecionadorDeClasse(User? usuario, Function notify) {
  Widget qualWidgetEntrar;

  if (usuario != null) {
    print("usuario encontrado");
    List<Atualizacao> listaEntrada = [], listaSaida = [];

    final bd = BancoDeDados(id: usuario.uid);

    DateTime dt = DateTime.now();

    bd.getListaEntradas(dt).then((lista){listaEntrada = lista;});
    bd.getListaSaida(dt).then((lista){listaSaida = lista;});

    qualWidgetEntrar = Inicio(
      user: usuario,
      notify: notify,
      listaEntrada: listaEntrada,
      listaSaida: listaSaida,
      bd: bd
    );
  } else {
    print("usuario nao encontrado");
    qualWidgetEntrar = FazerLogin(notify);
  }

  return qualWidgetEntrar;
}

//Codigos prontos do FireBase
final GoogleSignIn googleSignIn = GoogleSignIn();
Future<User?> signInWithGoogle() async {
  print("entrou no signInWithGoogle");
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;
    print("signInWithGoogle succeeded: $user");
    return user;

  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> signOut() async {
  try {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  } on Exception catch (e) {
    debugPrint(e.toString());
  }
}
