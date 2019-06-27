import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format-json&key-5cec1b68";

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.white, primaryColor: Colors.blue),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final bitcointController = TextEditingController();

  double dolar;
  double bitcoin;

  void _realChangend(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    bitcointController.text = (real / bitcoin).toStringAsFixed(2);
  }

  void _dolarChangend(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    bitcointController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(2);
  }

  void _bitcointChangend(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    bitcointController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepPurple,
        appBar: AppBar(
          title: Text("Conversor Bitcoin"),
          backgroundColor: Colors.black12,
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando dados...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao carregar dados",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    bitcoin =
                        snapshot.data["results"]["currencies"]["BTC"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.white,
                          ),
                          buildTextField("Bitcoin", "ß", bitcointController,
                              _bitcointChangend),
                          Divider(),
                          buildTextField(
                              "Dolar", "\$", dolarController, _dolarChangend),
                          Divider(),
                          buildTextField(
                              "Real", "R\$", realController, _realChangend),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.white, fontSize: 25.0),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
  );
}
