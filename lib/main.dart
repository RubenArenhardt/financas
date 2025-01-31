// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, body_might_complete_normally_nullable

//alt shift F = identação
//alt Z = quebra linha automatico

import 'package:financas/telas/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'fireBase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", "US"),
        Locale("pt", "BR"),
      ],
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47)),
      home: ChecadorLogin()));
}
//Packadges:
//pie_chart (https://pub.dev/packages/pie_chart),
//flutter_masked_text (https://pub.dev/packages/flutter_masked_text2/install),
