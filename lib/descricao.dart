import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';

// Imagens e assets
final String logo = 'assets/logo.site.tcc.png';
final String gato1 = 'assets/gato1.png';
final String gato2 = 'assets/gato2.png';
final String gato3 = 'assets/gato3.png';
final String esquerda = 'assets/esquerda.png';

// Endpoints do backend Spring Boot
const String avaliacaoApiUrl = "http://localhost:8080/avaliacao";
const String doacaoApiUrl = "http://localhost:8080/doacao";
const String cartaoApiUrl = "http://localhost:8080/cadcartao/cliente/";
const String clienteApiUrl = "http://localhost:8080/cliente/";

// Função para buscar o id do cliente do storage
Future<int?> getClienteId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('clienteId');
}

class PaginaDescricao extends StatefulWidget {
  const PaginaDescricao({Key? key}) : super(key: key);

  @override
  State<PaginaDescricao> createState() => _PaginaDescricaoState();
}

class _PaginaDescricaoState extends State<PaginaDescricao> {
  bool menuAberto = false;
  bool modalImagemAberto = false;
  int imagemAtual = 0;
  bool modalAvaliacaoAberto = false;
  bool modalDoacaoAberto = false;

  final List<String> imagens = [gato1, gato2, gato1];
  final TextEditingController _searchController = TextEditingController();

  // Dados do usuário
  bool usuarioLogado = false;
  int? idCliente;
  String? nomeUsuario;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;

  @override
  void initState() {
    super.initState();
    buscarDadosUsuario();
  }

  Future<void> buscarDadosUsuario() async {
    idCliente = await getClienteId();
    if (idCliente == null) {
      setState(() {
        usuarioLogado = false;
        nomeUsuario = null;
        cartoesUsuario = [];
        cartaoSelecionadoId = null;
      });
      return;
    }
    // Buscar Cliente
    final usuarioResp = await http.get(Uri.parse('$clienteApiUrl$idCliente'));
    // Buscar cartões do cliente
    final cartoesResp = await http.get(Uri.parse('$cartaoApiUrl$idCliente'));

    if (usuarioResp.statusCode == 200 && cartoesResp.statusCode == 200) {
      final usuario = jsonDecode(usuarioResp.body);
      final cartoes = List<Map<String, dynamic>>.from(jsonDecode(cartoesResp.body));
      setState(() {
        usuarioLogado = true;
        nomeUsuario = usuario['nome'];
        cartoesUsuario = cartoes;
        if (cartoesUsuario.isNotEmpty) {
          cartaoSelecionadoId = cartoesUsuario.first['id'].toString();
        } else {
          cartaoSelecionadoId = null;
        }
      });
    } else {
      setState(() {
        usuarioLogado = false;
        nomeUsuario = null;
        cartoesUsuario = [];
        cartaoSelecionadoId = null;
      });
    }
  }

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
  }

  void abrirModalImagem(int index) {
    setState(() {
      imagemAtual = index;
      modalImagemAberto = true;
    });
  }

  void fecharModalImagem() {
    setState(() {
      modalImagemAberto = false;
    });
  }

  void imagemAnterior() {
    setState(() {
      imagemAtual = (imagemAtual - 1 + imagens.length) % imagens.length;
    });
  }

  void proximaImagem() {
    setState(() {
      imagemAtual = (imagemAtual + 1) % imagens.length;
    });
  }

  void abrirModalAvaliacao() {
    setState(() {
      modalAvaliacaoAberto = true;
    });
  }

  void fecharModalAvaliacao() {
    setState(() {
      modalAvaliacaoAberto = false;
    });
  }

  void abrirModalDoacao() {
    setState(() {
      modalDoacaoAberto = true;
    });
  }

  void fecharModalDoacao() {
    setState(() {
      modalDoacaoAberto = false;
    });
  }

  void onCadastrarCartao() async {
    // Redirecione para tela de cadastro de cartão
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Implementar tela de cadastro de cartão!')),
    );
    await Future.delayed(const Duration(seconds: 2));
    await buscarDadosUsuario();
  }

  void onCartaoSelecionado(String? id) {
    setState(() {
      cartaoSelecionadoId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Navbar(
          isMenuOpen: menuAberto,
          onMenuTap: toggleMenu,
          searchController: _searchController,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!isWide && menuAberto)
                Container(
                  color: const Color(0xFF90017F),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Início', style: TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.home, color: Colors.white),
                        onTap: () {
                          setState(() => menuAberto = false);
                          Navigator.pushNamed(context, '/index');
                        },
                      ),
                      ListTile(
                        title: const Text('Games', style: TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.videogame_asset, color: Colors.white),
                        onTap: () {
                          setState(() => menuAberto = false);
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                      ListTile(
                        title: const Text('Sobre', style: TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.info, color: Colors.white),
                        onTap: () {
                          setState(() => menuAberto = false);
                          Navigator.pushNamed(context, '/que');
                        },
                      ),
                      ListTile(
                        title: const Text('Suporte', style: TextStyle(color: Colors.white)),
                        leading: const Icon(Icons.headset, color: Colors.white),
                        onTap: () {
                          setState(() => menuAberto = false);
                          Navigator.pushNamed(context, '/suporte');
                        },
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 900),
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Image.asset(
                                                    gato3,
                                                    height: 320,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: imagens
                                                      .asMap()
                                                      .entries
                                                      .map((entry) => GestureDetector(
                                                            onTap: () => abrirModalImagem(entry.key),
                                                            child: Container(
                                                              margin: const EdgeInsets.symmetric(horizontal: 6),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: Image.asset(
                                                                  entry.value,
                                                                  height: 56,
                                                                  width: 56,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                          Expanded(
                                            flex: 7,
                                            child: _DescricaoEInfo(
                                              abrirModalAvaliacao: usuarioLogado ? abrirModalAvaliacao : null,
                                              abrirModalDoacao: usuarioLogado ? abrirModalDoacao : null,
                                              usuarioLogado: usuarioLogado,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Image.asset(
                                              gato3,
                                              height: 220,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: imagens
                                                .asMap()
                                                .entries
                                                .map((entry) => GestureDetector(
                                                      onTap: () => abrirModalImagem(entry.key),
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: Image.asset(
                                                            entry.value,
                                                            height: 44,
                                                            width: 44,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 24),
                                          _DescricaoEInfo(
                                            abrirModalAvaliacao: usuarioLogado ? abrirModalAvaliacao : null,
                                            abrirModalDoacao: usuarioLogado ? abrirModalDoacao : null,
                                            usuarioLogado: usuarioLogado,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0, bottom: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(esquerda, height: 46),
                              ),
                            ),
                          ),
                          Container(
                            color: const Color(0xFF90017F),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "GameLegends",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, color: Colors.white70, size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '(99) 99999-9999',
                                          style: TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                        const SizedBox(width: 20),
                                        const Icon(Icons.email, color: Colors.white70, size: 20),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'info@gamelegends.com',
                                          style: TextStyle(color: Colors.white70, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        IconButton(icon: const Icon(Icons.facebook, color: Colors.white), onPressed: () {}),
                                        IconButton(icon: const Icon(Icons.sports_esports, color: Colors.white), onPressed: () {}),
                                        IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () {}),
                                        IconButton(icon: const Icon(Icons.linked_camera, color: Colors.white), onPressed: () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (modalImagemAberto)
                      _ModalImagem(
                        imagem: imagens[imagemAtual],
                        fechar: fecharModalImagem,
                        proxima: proximaImagem,
                        anterior: imagemAnterior,
                      ),
                    if (modalAvaliacaoAberto)
                      _ModalAvaliacao(
                        fechar: fecharModalAvaliacao,
                        nomeUsuario: nomeUsuario,
                        idCliente: idCliente,
                        usuarioLogado: usuarioLogado,
                      ),
                    if (modalDoacaoAberto)
                      _ModalDoacao(
                        fechar: fecharModalDoacao,
                        nomeUsuario: nomeUsuario,
                        cartoesUsuario: cartoesUsuario,
                        onCadastrarCartao: onCadastrarCartao,
                        cartaoSelecionadoId: cartaoSelecionadoId,
                        onCartaoSelecionado: onCartaoSelecionado,
                        idCliente: idCliente,
                        usuarioLogado: usuarioLogado,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescricaoEInfo extends StatelessWidget {
  final VoidCallback? abrirModalAvaliacao;
  final VoidCallback? abrirModalDoacao;
  final bool usuarioLogado;

  const _DescricaoEInfo({
    required this.abrirModalAvaliacao,
    required this.abrirModalDoacao,
    required this.usuarioLogado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Happy Cat Tavern: Typing Challenge',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFF90017F)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Batou quer beber o máximo de milkshakes que puder enquanto os clientes da taverna o animam. Cada palavra é um milkshake para Batou beber. Digite com rapidez e precisão para ganhar pontos e desbloquear conquistas!',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        const Text(
          'Créditos:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: 'Artista: Miyaualit ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Twitter',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ' / '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Etsy',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ')\nProgramador: OnyxHeart ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Twitter',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ')'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!usuarioLogado) ...[
          const Text(
            "Você precisa estar logado para avaliar ou doar.",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05B7E7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Avaliações'),
              onPressed: abrirModalAvaliacao,
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90017F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Doações'),
              onPressed: abrirModalDoacao,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModalImagem extends StatelessWidget {
  final String imagem;
  final VoidCallback fechar;
  final VoidCallback proxima;
  final VoidCallback anterior;

  const _ModalImagem({
    required this.imagem,
    required this.fechar,
    required this.proxima,
    required this.anterior,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(imagem, height: 320),
              ),
            ),
            Positioned(
              left: 30,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                onPressed: anterior,
              ),
            ),
            Positioned(
              right: 30,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                onPressed: proxima,
              ),
            ),
            Positioned(
              right: 30,
              top: 50,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 36),
                onPressed: fechar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ENVIO DE AVALIAÇÃO
Future<bool> enviarAvaliacaoParaBackend(int estrelas, String comentario, int? idCliente) async {
  if (idCliente == null) return false;
  final response = await http.post(
    Uri.parse(avaliacaoApiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "comentario": comentario,
      "avalia": estrelas.toString(),
      "fk_Cliente_ID": idCliente,
    }),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

// ENVIO DE DOAÇÃO
Future<bool> enviarDoacaoParaBackend(double valor, int? idCliente, String? cartaoId) async {
  if (idCliente == null || cartaoId == null) return false;
  final response = await http.post(
    Uri.parse(doacaoApiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "valor": valor.toInt(),
      "fk_Cliente_ID": idCliente,
      "cartaoId": cartaoId,
    }),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

// MODAL DE AVALIAÇÃO
class _ModalAvaliacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final int? idCliente;
  final bool usuarioLogado;
  const _ModalAvaliacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.idCliente,
    required this.usuarioLogado,
  });

  @override
  State<_ModalAvaliacao> createState() => _ModalAvaliacaoState();
}

class _ModalAvaliacaoState extends State<_ModalAvaliacao> {
  int estrelasSelecionadas = 0;
  bool enviado = false;
  final TextEditingController motivoController = TextEditingController();

  Future<void> enviarAvaliacao() async {
    if (!widget.usuarioLogado || widget.idCliente == null) return;
    bool sucesso = await enviarAvaliacaoParaBackend(
      estrelasSelecionadas,
      motivoController.text.trim(),
      widget.idCliente,
    );
    setState(() {
      enviado = sucesso;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
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
            child: !widget.usuarioLogado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Faça login para avaliar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : enviado
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 50),
                          SizedBox(height: 10),
                          Text(
                            "Obrigado pela sua avaliação!",
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
                            'Avalie o jogo como ${widget.nomeUsuario ?? ""}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < estrelasSelecionadas ? Icons.star : Icons.star_border,
                                  color: Color(0xFFFFC107),
                                  size: 36,
                                ),
                                onPressed: () => setState(() {
                                  estrelasSelecionadas = index + 1;
                                }),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: motivoController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Deixe seu comentário ou motivo da avaliação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.feedback_outlined),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: estrelasSelecionadas == 0 ||
                                    motivoController.text.trim().isEmpty
                                ? null
                                : enviarAvaliacao,
                            child: const Text('Enviar Avaliação'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

// MODAL DE DOAÇÃO
class _ModalDoacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final List<Map<String, dynamic>> cartoesUsuario;
  final Function onCadastrarCartao;
  final String? cartaoSelecionadoId;
  final ValueChanged<String?> onCartaoSelecionado;
  final int? idCliente;
  final bool usuarioLogado;
  const _ModalDoacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.cartoesUsuario,
    required this.onCadastrarCartao,
    required this.cartaoSelecionadoId,
    required this.onCartaoSelecionado,
    required this.idCliente,
    required this.usuarioLogado,
  });

  @override
  State<_ModalDoacao> createState() => _ModalDoacaoState();
}

class _ModalDoacaoState extends State<_ModalDoacao> {
  final TextEditingController valorController = TextEditingController();
  bool enviado = false;

  Future<void> enviarDoacao() async {
    double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null ||
        widget.idCliente == null ||
        widget.cartaoSelecionadoId == null ||
        !widget.usuarioLogado) return;
    bool sucesso = await enviarDoacaoParaBackend(
      valor,
      widget.idCliente,
      widget.cartaoSelecionadoId,
    );
    setState(() {
      enviado = sucesso;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
  }

  @override
  void dispose() {
    valorController.dispose();
    super.dispose();
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
            child: !widget.usuarioLogado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Faça login para doar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : enviado
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
                          const SizedBox(height: 12),
                          widget.cartoesUsuario.isEmpty
                              ? Column(
                                  children: [
                                    const Text('Nenhum cartão cadastrado.'),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: () => widget.onCadastrarCartao(),
                                      icon: const Icon(Icons.credit_card),
                                      label: const Text('Cadastrar cartão'),
                                    ),
                                  ],
                                )
                              : DropdownButtonFormField<String>(
                                  value: widget.cartaoSelecionadoId,
                                  items: widget.cartoesUsuario
                                      .map((cartao) => DropdownMenuItem(
                                            value: cartao['id'].toString(),
                                            child: Text(
                                                '${cartao['bandeira'] ?? ""} - ${cartao['numC']?.toString().substring(cartao['numC'].toString().length - 4) ?? ""}'),
                                          ))
                                      .toList(),
                                  onChanged: widget.onCartaoSelecionado,
                                  decoration: const InputDecoration(
                                    labelText: "Cartão para doação",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.credit_card),
                                  ),
                                ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: valorController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Valor da doação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: valorController.text.trim().isEmpty ||
                                    widget.cartoesUsuario.isEmpty
                                ? null
                                : enviarDoacao,
                            child: const Text('Enviar Doação'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}