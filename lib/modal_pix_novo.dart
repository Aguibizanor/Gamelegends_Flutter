import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String doacaoApiUrl = "http://localhost:8080/doacao";

// Modal PIX Simplificado
class ModalPixNovo extends StatefulWidget {
  final VoidCallback fechar;

  const ModalPixNovo({
    required this.fechar,
  });

  @override
  State<ModalPixNovo> createState() => _ModalPixNovoState();
}

class _ModalPixNovoState extends State<ModalPixNovo> {
  String? pixCode;
  bool carregandoPix = false;
  bool pagamentoConfirmado = false;

  @override
  void initState() {
    super.initState();
    gerarPix();
  }

  Future<void> gerarPix() async {
    setState(() {
      carregandoPix = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$doacaoApiUrl/pix'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "valor": 1000, // Valor fixo para gerar o PIX
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pixCode = data['pixCode'];
          carregandoPix = false;
        });
      } else {
        setState(() {
          carregandoPix = false;
        });
      }
    } catch (e) {
      setState(() {
        carregandoPix = false;
      });
    }
  }

  void confirmarPagamento() {
    setState(() {
      pagamentoConfirmado = true;
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
            child: pagamentoConfirmado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 60),
                      SizedBox(height: 16),
                      Text(
                        "Obrigado por doar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sua doação foi processada com sucesso.",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.qr_code, color: Color(0xFF32BCAD), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Doação via PIX',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.fechar,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (carregandoPix) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF32BCAD)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gerando código PIX...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ] else if (pixCode != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_mobile_English_Wikipedia.svg/256px-QR_code_for_mobile_English_Wikipedia.svg.png',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.qr_code, size: 80, color: Colors.black54),
                                            SizedBox(height: 8),
                                            Text(
                                              'QR Code PIX',
                                              style: TextStyle(color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Escaneie o QR Code com seu app do banco',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Escolha o valor no seu app',
                                style: TextStyle(fontSize: 14, color: Color(0xFF32BCAD)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Código PIX:',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            if (pixCode != null) {
                                              Clipboard.setData(ClipboardData(text: pixCode!));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Código PIX copiado!'),
                                                  backgroundColor: Color(0xFF32BCAD),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.copy, size: 16),
                                          tooltip: 'Copiar código PIX',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 24,
                                            minHeight: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      pixCode ?? '',
                                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: confirmarPagamento,
                            child: const Text('Já Paguei'),
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Erro ao gerar código PIX',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: gerarPix,
                          child: const Text('Tentar Novamente'),
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