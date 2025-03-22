// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, equal_keys_in_map

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

import 'package:financas/objetos/atualizacao.dart';

final TextEditingController _controllerNome = TextEditingController();

enum radioButtonList { Entrada, Saida }

radioButtonList? _radioButtonSelecionado = radioButtonList.Entrada;

final MoneyMaskedTextController _controllerValor =
    MoneyMaskedTextController(leftSymbol: 'R\$ ');

List<String> tagsEntrada = [
  "Salario",
  "Investimento",
  "Outras Entradas",
], tagsSaida = [
  "Investimento",
  "Mercado",
  "Transporte",
  "Comida",
  "Casa",
  "Lazer",
  "Outras Saídas",
];

final TextEditingController _controllerTag = TextEditingController();
String tagAnterior = "";
final TextEditingController _controllerData = TextEditingController(
    text: DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, "pt_Br")
        .format(DateTime.now()));

final TextEditingController _controllerObservacao = TextEditingController();

class Adicionar extends StatefulWidget {
  final Atualizacao? atualizacao;

  Adicionar({this.atualizacao});

  @override
  State<StatefulWidget> createState() => AdicionarState();
}

class AdicionarState extends State<Adicionar> {
  final _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-7976065858956466/6790330121'
      : 'ca-app-pub-3940256099942544/2435281174';

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  

  @override
  void initState() {
    super.initState();
    if (widget.atualizacao != null) {
      _controllerNome.text = widget.atualizacao!.nome;
      _controllerValor.updateValue(widget.atualizacao!.valor);
      _controllerTag.text = widget.atualizacao!.tag;
      tagAnterior = widget.atualizacao!.tag;
      _controllerData.text = widget.atualizacao!.data;
      _controllerObservacao.text = widget.atualizacao!.observacao;
      _radioButtonSelecionado = widget.atualizacao!.isEntrada
          ? radioButtonList.Entrada
          : radioButtonList.Saida;
    } else {
      _controllerNome.text = "";
      _controllerValor.updateValue(0);
      _controllerTag.text = "Salario";
      _controllerData.text = DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, "pt_Br")
          .format(DateTime.now());
      _controllerObservacao.text = "";
      _radioButtonSelecionado = radioButtonList.Entrada;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeMobileAdsSDK();
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
        appBar: AppBar(
          title: Text(widget.atualizacao == null
              ? "Adicionar Entrada/Saída"
              : "Editar Entrada/Saída"),
        ),
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

                Center(
                  child: RadioButton(
                    onChanged: (radioButtonList? value) {
                      setState(() {
                        _radioButtonSelecionado = value;
                      });
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                  child: DropdownMenuTag(),
                ),
                //ToDo:
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
                if (_bannerAd != null && _isLoaded)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
        persistentFooterButtons: [
          Row(
            children: [
              if (widget.atualizacao == null) ...[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final Atualizacao atualizacao = _criaAtualizacao();
                      Navigator.pop(context, atualizacao);
                    },
                    child: Text("Confirmar"),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, [_criaAtualizacao(), 1]);
                    },
                    child: Text("Editar"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, [_criaAtualizacao(), 2]);
                    },
                    child: Text("Deletar"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    child: Text("Cancelar"),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _initializeMobileAdsSDK() async {
    // Inicializa o SDK do Google Mobile Ads.
    MobileAds.instance.initialize();
    // Carrega o banner ad.
    _loadAd();
  }

  void _loadAd() async {
    //Captura o tamanho da tela
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      //Nao foi possivel carregar o tamanho do banner
      return;
    }

    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Chama quando o banner é carregado
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // Chama quando o banner falha ao carregar
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Chama quando o banner é clicado
        onAdOpened: (ad) {},
      ),
    ).load();
  }
}

class RadioButton extends StatefulWidget {
  final ValueChanged<radioButtonList?> onChanged;

  RadioButton({required this.onChanged});

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
                    widget.onChanged(value);
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
                    widget.onChanged(value);
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
    List<String> tagsFiltradas = (_isEntrada() ? tagsEntrada : tagsSaida);
    String tagSelecionada;
    if (tagAnterior != "") {
      tagSelecionada = tagAnterior;
    }else{
      tagSelecionada = tagsFiltradas.first;
    }
    return DropdownMenu<String>(
      controller: _controllerTag,
      initialSelection: tagSelecionada,
      onSelected: (String? value) {
        setState(() {
          _controllerTag.text = value!;
        });
      },
      dropdownMenuEntries: tagsFiltradas.map((tag) {
        return DropdownMenuEntry<String>(value: tag, label: tag);
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
  isEntrada = _isEntrada();
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

bool _isEntrada() {
  return _radioButtonSelecionado == radioButtonList.Entrada;
}
