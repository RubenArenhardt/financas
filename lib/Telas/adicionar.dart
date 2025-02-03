// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

import 'package:financas/objetos/atualizacao.dart';

final TextEditingController _controllerNome = TextEditingController();

enum radioButtonList { Entrada, Saida }

radioButtonList? _radioButtonSelecionado = radioButtonList.Entrada;

final MoneyMaskedTextController _controllerValor =
    MoneyMaskedTextController(leftSymbol: 'R\$ ');

Map<String,radioButtonList> tags = {
  "Salario":radioButtonList.Entrada,
  "Investimento":radioButtonList.Entrada,
  "Outros":radioButtonList.Entrada,
  "Mercado":radioButtonList.Saida,
  "Transporte":radioButtonList.Saida,
  "Comida":radioButtonList.Saida,
  "Casa":radioButtonList.Saida,
  "Lazer":radioButtonList.Saida,
  "Outros":radioButtonList.Saida
};

final TextEditingController _controllerTag = TextEditingController();

final TextEditingController _controllerData = TextEditingController(
    text: DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, "pt_Br")
        .format(DateTime.now()));

final TextEditingController _controllerObservacao = TextEditingController();

class Adicionar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AdicionarState();
}

class AdicionarState extends State<Adicionar> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en", "US"),
        Locale("pt", "BR"),
      ],
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47)),
      home: Scaffold(
        //
        //
        appBar: AppBar(
          title: Text("Adicionar Entrada/Saída"),
        ),
        //
        //
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: TextField(
                    controller: _controllerNome,
                    decoration: InputDecoration(
                      label: Text("Título"),
                    ),
                  ),
                ),
                //
                Center(
                  child: RadioButton(),
                ),
                //
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                  child: DropdownMenuTag(),
                ),
                //ToDo:
                //Separar tags de entrada e saida em listas
                //Adicionar opção de adicionar itens personalizados para as listas
                //
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: TextField(
                    controller: _controllerValor,
                    decoration: InputDecoration(
                      label: Text("Valor"),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                //
                //
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: SelecionarData(),
                ),
                //
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: TextField(
                    controller: _controllerObservacao,
                    decoration: InputDecoration(
                      label: Text("Obs."),
                    ),
                  ),
                ),

                //
              ],
            ),
          ),
        ),
        //
        //
        persistentFooterButtons: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    final Atualizacao atualizacao = _criaAtualizacao();
                    Navigator.pop(context, atualizacao);
                  },
                  child: Text("Confirmar"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadioButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EntradaSaidaRadio();
}

class _EntradaSaidaRadio extends State<RadioButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            child: ListTile(
              title: Text("Entrada"),
              leading: Radio(
                  value: radioButtonList.Entrada,
                  groupValue: _radioButtonSelecionado,
                  onChanged: (radioButtonList? value) {
                    setState(() {
                      _radioButtonSelecionado = value;
                    });
                  }),
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: ListTile(
              title: Text("Saída"),
              leading: Radio(
                  value: radioButtonList.Saida,
                  groupValue: _radioButtonSelecionado,
                  onChanged: (radioButtonList? value) {
                    setState(() {
                      _radioButtonSelecionado = value;
                    });
                  }),
            ),
          ),
        ),
      ],
    );
  }
}

class DropdownMenuTag extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TagState();
}

class _TagState extends State<DropdownMenuTag> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: _controllerTag,
      initialSelection: tags.keys.first,
      onSelected: (String? value) {
        setState(() {
          value!;
        });
      },
      dropdownMenuEntries: tags.entries.map((entry) {
        return DropdownMenuEntry<String>(value: entry.key, label: entry.key);
      }).toList(),
    );
  }
}

class SelecionarData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DatePicker();
}

class _DatePicker extends State {
  final _formatacaoData = DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, "pt_Br");

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: _controllerData,
        decoration: InputDecoration(
          labelText: "Data",
        ),
        readOnly: true,
        onTap: () {
          _selecionaData();
        });
  }

  Future<void> _selecionaData() async {
    DateTime? _selecionado = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_selecionado != null) {
      final _dataFormatada = _formatacaoData.format(_selecionado);

      setState(() {
        _controllerData.text = _dataFormatada.toString();
      });
    }
  }
}

Atualizacao _criaAtualizacao() {
  final String nome = _controllerNome.text,
      tag = _controllerTag.text,
      obs = _controllerObservacao.text,
      data = _controllerData.text;
  final double valor = _controllerValor.numberValue;
  final bool isEntrada;
  if (_radioButtonSelecionado == radioButtonList.Entrada) {
    isEntrada = true;
  } else {
    isEntrada = false;
  }
  final atualizacao = Atualizacao(
      nome: nome,
      isEntrada: isEntrada,
      valor: valor,
      tag: tag,
      data: data,
      observacao: obs,
      idUnico: DateTime.now().microsecondsSinceEpoch.toString());
  print(atualizacao.toString());
  return atualizacao;
}
