import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class TestConnection extends StatefulWidget {
  @override
  _TestConnectionState createState() => _TestConnectionState();
}

class _TestConnectionState extends State<TestConnection> {
  String resultado = 'Testando...';

  @override
  void initState() {
    super.initState();
    testarConexao();
  }

  Future<void> testarConexao() async {
    try {
      print('Testando URL: ${ApiConfig.baseUrl}');
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/projetos'));
      setState(() {
        resultado = 'Status: ${response.statusCode}\nURL: ${ApiConfig.baseUrl}';
      });
    } catch (e) {
      setState(() {
        resultado = 'Erro: $e\nURL: ${ApiConfig.baseUrl}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teste Conexão')),
      body: Center(child: Text(resultado)),
    );
  }
}