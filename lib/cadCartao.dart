import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';

/// Função para buscar o id do cliente do storage (caso precise associar o cartão ao cliente)
Future<int?> getClienteId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('clienteId');
}

/// Função para cadastrar o cartão no backend
Future<bool> cadastrarCartao({
  required String nomeT,
  required String numC,
  required String validade,
  required String cvv,
  required String bandeira,
}) async {
  const String baseUrl = "http://10.0.2.2:8080"; // Troque para seu IP se for no celular real
  final idCliente = await getClienteId(); // Se quiser associar ao cliente

  // Se o backend espera o id do cliente no JSON, descomente e envie "fk_Cliente_ID": idCliente
  final Map<String, dynamic> data = {
    "nomeT": nomeT,
    "numC": numC,
    "validade": validade,
    "CVV": cvv,
    "bandeira": bandeira,
    // "fk_Cliente_ID": idCliente, // Adicione se o backend exigir
  };

  final response = await http.post(
    Uri.parse('$baseUrl/cadcartao'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

class CadastroCartaoScreen extends StatefulWidget {
  final VoidCallback onCartaoCadastrado;

  const CadastroCartaoScreen({required this.onCartaoCadastrado, super.key});

  @override
  State<CadastroCartaoScreen> createState() => _CadastroCartaoScreenState();
}

class _CadastroCartaoScreenState extends State<CadastroCartaoScreen> {
  final nomeCtrl = TextEditingController();
  final numCtrl = TextEditingController();
  final validadeCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();
  final bandeiraCtrl = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nomeCtrl.dispose();
    numCtrl.dispose();
    validadeCtrl.dispose();
    cvvCtrl.dispose();
    bandeiraCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() => loading = true);
    bool sucesso = await cadastrarCartao(
      nomeT: nomeCtrl.text,
      numC: numCtrl.text,
      validade: validadeCtrl.text,
      cvv: cvvCtrl.text,
      bandeira: bandeiraCtrl.text,
    );
    setState(() => loading = false);
    if (sucesso) {
      widget.onCartaoCadastrado();
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cartão cadastrado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar cartão.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Cartão")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: "Nome do Titular"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numCtrl,
              decoration: const InputDecoration(labelText: "Número do Cartão"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: validadeCtrl,
              decoration: const InputDecoration(labelText: "Validade (MM/AA)"),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cvvCtrl,
              decoration: const InputDecoration(labelText: "CVV"),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bandeiraCtrl,
              decoration: const InputDecoration(labelText: "Bandeira (Visa, Master, etc)"),
            ),
            const SizedBox(height: 24),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _cadastrar,
                    child: const Text("Cadastrar"),
                  ),
          ],
        ),
      ),
    );
  }
}