import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String cartaoApiUrl = "http://localhost:8080/cadcartao";

Future<int?> getClienteId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usuarioStr = prefs.getString('usuario');
  if (usuarioStr != null) {
    try {
      final usuarioData = jsonDecode(usuarioStr) as Map<String, dynamic>;
      return usuarioData['id']?.toInt();
    } catch (e) {
      print('Erro ao obter ID do cliente: $e');
    }
  }
  return null;
}

class CadastroCartaoScreen extends StatefulWidget {
  const CadastroCartaoScreen({Key? key}) : super(key: key);

  @override
  State<CadastroCartaoScreen> createState() => _CadastroCartaoScreenState();
}

class _CadastroCartaoScreenState extends State<CadastroCartaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String? _bandeiraSelecionada;
  bool _carregando = false;

  final List<String> _bandeiras = ['Visa', 'Mastercard', 'Elo', 'American Express'];

  Future<void> _cadastrarCartao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final clienteId = await getClienteId();
      if (clienteId == null) {
        _mostrarErro('Erro: Usuário não identificado. Faça login novamente.');
        return;
      }

      final dados = {
        "numC": _numeroController.text.replaceAll(' ', ''),
        "nomeT": _nomeController.text.trim(),
        "validade": _validadeController.text.trim(),
        "CVV": _cvvController.text.trim(),
        "bandeira": _bandeiraSelecionada,
        "clienteId": clienteId
      };
      
      print('Dados: $dados');
      print('ClienteId: $clienteId');

      final response = await http.post(
        Uri.parse(cartaoApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dados),
      );
      
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cartão cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _mostrarErro('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _mostrarErro('Erro: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Cadastrar Cartão'),
        backgroundColor: const Color(0xFF90017F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.credit_card,
                    size: 64,
                    color: Color(0xFF90017F),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Adicionar Novo Cartão',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF90017F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  DropdownButtonFormField<String>(
                    value: _bandeiraSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Bandeira',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card_outlined),
                    ),
                    items: _bandeiras.map((bandeira) => 
                      DropdownMenuItem(value: bandeira, child: Text(bandeira))
                    ).toList(),
                    onChanged: (value) => setState(() => _bandeiraSelecionada = value),
                    validator: (value) => value == null ? 'Selecione uma bandeira' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _numeroController,
                    decoration: const InputDecoration(
                      labelText: 'Número do Cartão',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Digite o número do cartão';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome no Cartão',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Digite o nome no cartão';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _validadeController,
                          decoration: const InputDecoration(
                            labelText: 'Validade (MM/AA)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ValidadeFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Digite a validade';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.security),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Digite o CVV';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _carregando ? null : _cadastrarCartao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90017F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Cadastrar Cartão', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nomeController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ValidadeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
