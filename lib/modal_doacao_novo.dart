import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro_cartao.dart';

// Modal de Doação Reformulado
class ModalDoacaoNovo extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final bool usuarioLogado;
  final VoidCallback abrirPix;

  const ModalDoacaoNovo({
    required this.fechar,
    required this.nomeUsuario,
    required this.usuarioLogado,
    required this.abrirPix,
  });

  @override
  State<ModalDoacaoNovo> createState() => _ModalDoacaoNovoState();
}

class _ModalDoacaoNovoState extends State<ModalDoacaoNovo> {
  final TextEditingController valorController = TextEditingController();
  bool enviado = false;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;
  bool carregandoCartoes = true;
  bool mostrarCartao = false;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  Future<void> _carregarCartoes() async {
    if (!widget.usuarioLogado) {
      setState(() => carregandoCartoes = false);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioStr = prefs.getString('usuario');
      if (usuarioStr != null) {
        final usuarioData = jsonDecode(usuarioStr) as Map<String, dynamic>;
        final clienteId = usuarioData['id'];
        
        if (clienteId != null) {
          final response = await http.get(Uri.parse('http://localhost:8080/cadcartao/cliente/$clienteId'));
          if (response.statusCode == 200) {
            final cartoes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
            setState(() {
              cartoesUsuario = cartoes;
              cartaoSelecionadoId = cartoes.isNotEmpty ? cartoes.first['id'].toString() : null;
              carregandoCartoes = false;
            });
          } else {
            setState(() => carregandoCartoes = false);
          }
        } else {
          setState(() => carregandoCartoes = false);
        }
      } else {
        setState(() => carregandoCartoes = false);
      }
    } catch (e) {
      setState(() => carregandoCartoes = false);
    }
  }

  Future<void> enviarDoacao() async {
    double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null || cartaoSelecionadoId == null || !widget.usuarioLogado) return;
    
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      enviado = true;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: enviado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.favorite, color: Colors.pink, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Obrigado pela sua doação!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.fechar,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bem-vindo, ${widget.nomeUsuario ?? ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      if (!mostrarCartao) ...[
                        const Text(
                          'Escolha a forma de pagamento:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF90017F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  setState(() {
                                    mostrarCartao = true;
                                  });
                                },
                                icon: const Icon(Icons.credit_card),
                                label: const Text('Cartão'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF32BCAD),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  widget.fechar();
                                  widget.abrirPix();
                                },
                                icon: const Icon(Icons.qr_code),
                                label: const Text('PIX'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  mostrarCartao = false;
                                  valorController.clear();
                                });
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Text(
                              'Pagamento com Cartão',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        carregandoCartoes
                            ? const Center(child: CircularProgressIndicator())
                            : cartoesUsuario.isEmpty
                                ? Column(
                                    children: [
                                      const Icon(Icons.credit_card_off, size: 48, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      const Text('Nenhum cartão cadastrado.', style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF90017F),
                                          foregroundColor: Colors.white,
                                        ),
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
                                        icon: const Icon(Icons.add),
                                        label: const Text('Cadastrar Cartão'),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value: cartaoSelecionadoId,
                                        items: cartoesUsuario
                                            .map<DropdownMenuItem<String>>((cartao) {
                                              final numero = cartao['numC']?.toString() ?? '';
                                              final ultimos4 = numero.length >= 4 ? numero.substring(numero.length - 4) : numero;
                                              return DropdownMenuItem<String>(
                                                value: cartao['id'].toString(),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.credit_card, color: Color(0xFF90017F), size: 20),
                                                    const SizedBox(width: 8),
                                                    Text('${cartao['bandeira'] ?? "Cartão"} - **** $ultimos4'),
                                                  ],
                                                ),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            cartaoSelecionadoId = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText: "Selecione o cartão",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.credit_card),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: valorController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          labelText: 'Valor da doação (R\$)',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.attach_money),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF90017F),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          onPressed: valorController.text.trim().isEmpty ||
                                                  cartaoSelecionadoId == null
                                              ? null
                                              : enviarDoacao,
                                          child: const Text('Confirmar Pagamento'),
                                        ),
                                      ),
                                    ],
                                  ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}