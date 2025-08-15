import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


const String cartaoApiUrl = "http://localhost:8080/cadcartao";

Future<Map<String, dynamic>?> getUsuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  final usuarioStr = prefs.getString('usuario');
  if (usuarioStr == null) return null;
  try {
    final usuarioMap = jsonDecode(usuarioStr) as Map<String, dynamic>;
    return usuarioMap;
  } catch (e) {
    return null;
  }
}

Future<List<Map<String, dynamic>>> buscarCartoesCliente(int clienteId) async {
  try {
    final response = await http.get(Uri.parse('$cartaoApiUrl/cliente/$clienteId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
  } catch (e) {
    print('Erro ao buscar cartões: $e');
  }
  return [];
}

class CartoesPage extends StatefulWidget {
  const CartoesPage({Key? key}) : super(key: key);

  @override
  State<CartoesPage> createState() => _CartoesPageState();
}

class _CartoesPageState extends State<CartoesPage> {
  List<Map<String, dynamic>> cartoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  Future<void> _carregarCartoes() async {
    try {
      final usuarioData = await getUsuarioLogado();
      if (usuarioData != null && usuarioData['id'] != null) {
        final cartoesData = await buscarCartoesCliente(usuarioData['id']);
        setState(() {
          cartoes = cartoesData;
          carregando = false;
        });
      } else {
        setState(() {
          carregando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faça login para ver seus cartões'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        carregando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _adicionarCartao() {
    Navigator.pushNamed(context, '/perfil');
  }

  IconData _getCardIcon(String bandeira) {
    switch (bandeira.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'elo':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Meus Cartões'),
        backgroundColor: const Color(0xFF90017F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _adicionarCartao,
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar Cartão',
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : cartoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.credit_card_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum cartão cadastrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90017F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _adicionarCartao,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Primeiro Cartão'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartoes.length,
                  itemBuilder: (context, index) {
                    final cartao = cartoes[index];
                    final numero = cartao['numC'].toString();
                    final ultimos4 = numero.length >= 4 
                        ? numero.substring(numero.length - 4) 
                        : numero;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF90017F), Color(0xFFB8439C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  _getCardIcon(cartao['bandeira'] ?? ''),
                                  color: Colors.white,
                                  size: 32,
                                ),
                                Text(
                                  cartao['bandeira'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '**** **** **** $ultimos4',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'NOME',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      cartao['nomeT'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'VALIDADE',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      cartao['validade'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: cartoes.isNotEmpty
          ? FloatingActionButton(
              onPressed: _adicionarCartao,
              backgroundColor: const Color(0xFF90017F),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
