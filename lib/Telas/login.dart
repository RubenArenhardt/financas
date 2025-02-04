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
    return ChecardorLoginState();
  }
}

class ChecardorLoginState extends State<ChecadorLogin> {
  User? usuario = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    
    if (usuario != null) {
      DateTime dt = DateTime.now();
      List<Atualizacao> listaEntrada = [], listaSaida = [];
      final bd = BancoDeDados(id: usuario!.uid);

      return FutureBuilder(
          future: Future.wait([bd.getListaEntradas(dt), bd.getListaSaidas(dt)]),
          builder: (context, AsyncSnapshot<List<List<Atualizacao>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text("Erro ao carregar dados"));
              }
              listaEntrada = snapshot.data![0];
              listaSaida = snapshot.data![1];

              return Inicio(
                user: usuario,
                notify: refresh,
                listaEntrada: listaEntrada,
                listaSaida: listaSaida,
                bd: bd,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          });
    } else {
      return FazerLogin(refresh);
    }
  }

  void refresh(User? user, bool _isSignOut) {
    if (_isSignOut) {
      signOut().then((_) {
        setState(() {
          usuario = null;
        });
      });
    } else {
      setState(() {
        usuario = user;
      });
    }
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
                notify(user, false);
              });
            } on Exception catch (e) {
              debugPrint(e.toString());
            }
          },
          child: Text("Fazer Login com Google")),
    );
  }
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
