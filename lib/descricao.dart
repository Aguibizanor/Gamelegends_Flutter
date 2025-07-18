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

// Função para obter usuário logado
Future<Map<String, dynamic>?> getUsuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  final usuarioStr = prefs.getString('usuario');
  if (usuarioStr == null) return null;
  try {
    final usuarioMap = jsonDecode(usuarioStr) as Map<String, dynamic>;
    return usuarioMap;
  } catch (e) {
    return {"nome": usuarioStr};
  }
}

// Função para buscar cartões do cliente
Future<List<Map<String, dynamic>>> buscarCartoesCliente(int clienteId) async {
  try {
    final response = await http.get(Uri.parse('${cartaoApiUrl}$clienteId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
  } catch (e) {
    print('Erro ao buscar cartões: $e');
  }
  return [];
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
    final usuarioData = await getUsuarioLogado();
    if (usuarioData != null && usuarioData['nome'] != null) {
      final clienteIdValue = usuarioData['id'] ?? await getClienteId();
      final cartoes = clienteIdValue != null ? await buscarCartoesCliente(clienteIdValue) : <Map<String, dynamic>>[];
      setState(() {
        usuarioLogado = true;
        nomeUsuario = usuarioData['nome'];
        idCliente = clienteIdValue;
        cartoesUsuario = cartoes;
        cartaoSelecionadoId = cartoes.isNotEmpty ? cartoes.first['id'].toString() : null;
      });
    } else {
      setState(() {
        usuarioLogado = false;
        nomeUsuario = null;
        idCliente = null;
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

  void onCadastrarCartao() {
    showDialog(
      context: context,
      builder: (context) => _ModalCadastroCartao(
        onCartaoCadastrado: () async {
          Navigator.pop(context);
          await buscarDadosUsuario();
        },
      ),
    );
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
      body: Stack(
        children: [
          Column(
            children: [
              Navbar(
                isMenuOpen: menuAberto,
                onMenuTap: toggleMenu,
                searchController: _searchController,
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
                                              onAvaliacaoEnviada: () => setState(() {}),
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
                                            onAvaliacaoEnviada: () => setState(() {}),
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
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }
}

class _DescricaoEInfo extends StatefulWidget {
  final VoidCallback? abrirModalAvaliacao;
  final VoidCallback? abrirModalDoacao;
  final bool usuarioLogado;
  final VoidCallback? onAvaliacaoEnviada;

  const _DescricaoEInfo({
    required this.abrirModalAvaliacao,
    required this.abrirModalDoacao,
    required this.usuarioLogado,
    this.onAvaliacaoEnviada,
  });

  @override
  State<_DescricaoEInfo> createState() => _DescricaoEInfoState();
}

class _DescricaoEInfoState extends State<_DescricaoEInfo> {
  List<Map<String, dynamic>> avaliacoes = [];
  double mediaEstrelas = 0.0;
  bool carregandoAvaliacoes = true;

  @override
  void initState() {
    super.initState();
    carregarAvaliacoes();
  }

  Future<void> carregarAvaliacoes() async {
    final avaliacoesData = await buscarAvaliacoesJogo("Happy Cat Tavern");
    final media = await buscarMediaEstrelas("Happy Cat Tavern");
    setState(() {
      avaliacoes = avaliacoesData;
      mediaEstrelas = media;
      carregandoAvaliacoes = false;
    });
  }

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
        
        // Seção de Avaliações
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Avaliações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  if (!carregandoAvaliacoes) ...[
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < mediaEstrelas.round() ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${mediaEstrelas.toStringAsFixed(1)} (${avaliacoes.length} avaliações)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ], 
                ],
              ),
              const SizedBox(height: 12),
              if (carregandoAvaliacoes)
                const Center(child: CircularProgressIndicator())
              else if (avaliacoes.isEmpty)
                const Text('Nenhuma avaliação ainda. Seja o primeiro!')
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: avaliacoes.length,
                    itemBuilder: (context, index) {
                      final avaliacao = avaliacoes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  avaliacao['nomeUsuario'] ?? 'Anônimo',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < (avaliacao['estrelas'] ?? 0) ? Icons.star : Icons.star_border,
                                      color: const Color(0xFFFFC107),
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              avaliacao['comentario'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        if (!widget.usuarioLogado) ...[
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
              child: const Text('Avaliar Jogo'),
              onPressed: widget.abrirModalAvaliacao,
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
              onPressed: widget.abrirModalDoacao,
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
Future<bool> enviarAvaliacaoParaBackend(int estrelas, String comentario, String nomeUsuario) async {
  final response = await http.post(
    Uri.parse(avaliacaoApiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "comentario": comentario,
      "estrelas": estrelas,
      "nomeJogo": "Happy Cat Tavern",
      "nomeUsuario": nomeUsuario,
      "dataAvaliacao": DateTime.now().toIso8601String().split('T')[0],
    }),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

// BUSCAR AVALIAÇÕES DO JOGO
Future<List<Map<String, dynamic>>> buscarAvaliacoesJogo(String nomeJogo) async {
  try {
    final response = await http.get(Uri.parse('$avaliacaoApiUrl/jogo/$nomeJogo'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
  } catch (e) {
    print('Erro ao buscar avaliações: $e');
  }
  return [];
}

// BUSCAR MÉDIA DE ESTRELAS
Future<double> buscarMediaEstrelas(String nomeJogo) async {
  try {
    final response = await http.get(Uri.parse('$avaliacaoApiUrl/media/$nomeJogo'));
    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
  } catch (e) {
    print('Erro ao buscar média: $e');
  }
  return 0.0;
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
    if (!widget.usuarioLogado || widget.nomeUsuario == null) return;
    bool sucesso = await enviarAvaliacaoParaBackend(
      estrelasSelecionadas,
      motivoController.text.trim(),
      widget.nomeUsuario!,
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
                                  items: widget.cartoesUsuario.map((cartao) {
                                    final numero = cartao['numC'].toString();
                                    final ultimos4 = numero.length >= 4 ? numero.substring(numero.length - 4) : numero;
                                    return DropdownMenuItem<String>(
                                      value: cartao['id'].toString(),
                                      child: Row(
                                        children: [
                                          Icon(_getCardIcon(cartao['bandeira'] ?? ''), size: 24),
                                          const SizedBox(width: 8),
                                          Text('${cartao['bandeira'] ?? ''} ****$ultimos4'),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: widget.onCartaoSelecionado,
                                  decoration: const InputDecoration(
                                    labelText: 'Cartão para doação',
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

// Função para obter ícone do cartão
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

// MODAL DE CADASTRO DE CARTÃO
class _ModalCadastroCartao extends StatefulWidget {
  final VoidCallback onCartaoCadastrado;
  
  const _ModalCadastroCartao({required this.onCartaoCadastrado});
  
  @override
  State<_ModalCadastroCartao> createState() => _ModalCadastroCartaoState();
}

class _ModalCadastroCartaoState extends State<_ModalCadastroCartao> {
  final _numeroController = TextEditingController();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();
  String _bandeira = 'Visa';
  bool _salvando = false;
  
  Future<void> _salvarCartao() async {
    if (_numeroController.text.isEmpty || _nomeController.text.isEmpty ||
        _validadeController.text.isEmpty || _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }
    
    setState(() => _salvando = true);
    
    try {
      final usuarioData = await getUsuarioLogado();
      final clienteId = usuarioData?['id'] ?? await getClienteId();
      if (clienteId == null) throw Exception('Cliente não encontrado');
      final response = await http.post(
        Uri.parse('${cartaoApiUrl}$clienteId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numC': _numeroController.text,
          'nomeC': _nomeController.text,
          'validadeC': _validadeController.text,
          'cvvC': _cvvController.text,
          'bandeira': _bandeira,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cartão cadastrado com sucesso!')),
        );
        widget.onCartaoCadastrado();
      } else {
        throw Exception('Erro ao cadastrar cartão');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar cartão')),
      );
    } finally {
      setState(() => _salvando = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar Cartão'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(labelText: 'Número do Cartão'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome no Cartão'),
            ),
            TextField(
              controller: _validadeController,
              decoration: const InputDecoration(labelText: 'Validade (MM/AA)'),
            ),
            TextField(
              controller: _cvvController,
              decoration: const InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bandeira,
              items: ['Visa', 'Mastercard', 'Elo'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _bandeira = value!),
              decoration: const InputDecoration(labelText: 'Bandeira'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvando ? null : _salvarCartao,
          child: _salvando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}