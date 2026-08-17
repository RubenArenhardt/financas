import 'package:financas/fireBase/bancoDeDados.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final BancoDeDados bd;
  final TextEditingController controller = TextEditingController();

  FeedbackPage({required this.bd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              const Text(
                "Deixe sua sugestão, critica construtiva ou até ideias de novos programas",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Digite aqui",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    bd.addFeedback(controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Enviar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
