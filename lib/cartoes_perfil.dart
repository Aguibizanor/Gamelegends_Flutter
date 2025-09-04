import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro_cartao.dart';

const String cartaoApiUrl = "http://localhost:8080/cadcartao";

// Função para obter usuário logado
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

// Função para buscar cartões do cliente
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

// Função para excluir cartão
Future<bool> excluirCartao(int cartaoId) async {
  try {
    final response = await http.delete(Uri.parse('$cartaoApiUrl/$cartaoId'));
    return response.statusCode == 204;
  } catch (e) {
    print('Erro ao excluir cartão: $e');
    return false;
  }
}

class CartoesPerfil extends StatefulWidget {
  const CartoesPerfil({Key? key}) : super(key: key);

  @override
  State<CartoesPerfil> createState() => _CartoesPerfilState();
}

class _CartoesPerfilState extends State<CartoesPerfil> {
  List<Map<String, dynamic>> cartoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  Future<void> _carregarCartoes() async {
    final usuarioData = await getUsuarioLogado();
    print('Debug - Usuario data: $usuarioData');
    
    if (usuarioData != null && usuarioData['id'] != null) {
      print('Debug - Usuario ID: ${usuarioData['id']}');
      final cartoesData = await buscarCartoesCliente(usuarioData['id']);
      print('Debug - Cartoes encontrados: ${cartoesData.length}');
      setState(() {
        cartoes = cartoesData;
        carregando = false;
      });
    } else {
      print('Debug - Usuario nao identificado ou sem ID');
      setState(() {
        carregando = false;
      });
    }
  }

  void _mostrarOpcoesCartao(Map<String, dynamic> cartao, String ultimos4) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cartão **** $ultimos4',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir Cartão'),
              onTap: () {
                Navigator.pop(context);
                _excluirCartao(cartao['id'], ultimos4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _excluirCartao(int cartaoId, String ultimos4) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cartão'),
        content: Text('Deseja excluir o cartão **** $ultimos4?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await excluirCartao(cartaoId);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cartão excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        await _carregarCartoes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir cartão'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      appBar: AppBar(
        title: const Text('Meus Cartões'),
        backgroundColor: const Color(0xFF90017F),
        foregroundColor: Colors.white,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : cartoes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum cartão cadastrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartoes.length,
                  itemBuilder: (context, index) {
                    final cartao = cartoes[index];
                    final numero = cartao['numC'].toString();
                    final ultimos4 = numero.length >= 4 ? numero.substring(numero.length - 4) : numero;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _mostrarOpcoesCartao(cartao, ultimos4),
                        borderRadius: BorderRadius.circular(12),
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
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroCartaoScreen(),
            ),
          );
          if (resultado == true) {
            await _carregarCartoes();
          }
        },
        backgroundColor: const Color(0xFF90017F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
