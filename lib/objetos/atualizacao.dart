// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:intl/intl.dart';

class Atualizacao {
  String nome;
  bool isEntrada;
  double valor;
  String tag;
  String data;
  String observacao;
  String idUnico;

  Atualizacao(
      {required this.nome,
      required this.isEntrada,
      required this.valor,
      required this.tag,
      required this.data,
      required this.observacao,
      required this.idUnico});

  @override
  String toString() {
    return 'Atualizacao(nome: $nome, isEntrada: $isEntrada, valor: $valor, tag: $tag, data: $data, observacao: $observacao)';
  }

  //Adicionar separação de data
  DateTime dataTime() {
    return DateFormat("dd/MM/yyyy").parse(data);
  }

  int dia() {
    return dataTime().day;
  }

  int mes() {
    return dataTime().month;
  }

  int ano() {
    return dataTime().year;
  }

  //Adicionar CreateMap
  Map<String, dynamic> getMap() {
    return {
      "nome": nome,
      "valor": valor,
      "tag": tag,
      "isEntrada": isEntrada,
      "data": data,
      "dataDia": dia().toString(),
      "dataMes": mes().toString(),
      "dataAno": ano().toString(),
      "observacao": observacao,
      "idUnico": idUnico,
    };
  }

  Atualizacao.fromMap(Map<String, dynamic> mapa)
      : nome = mapa["nome"],
        valor = mapa["valor"],
        tag = mapa["tag"],
        isEntrada = mapa["isEntrada"],
        data = mapa["data"],
        observacao = mapa["observacao"],
        idUnico = mapa["idUnico"];
}
