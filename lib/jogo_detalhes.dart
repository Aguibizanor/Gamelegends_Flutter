import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';

// Endpoints do backend
const String projetosApiUrl = "http://localhost:8080/projetos";
const String avaliacaoApiUrl = "http://localhost:8080/avaliacao";
const String doacaoApiUrl = "http://localhost:8080/doacao";

// Função para buscar dados do usuário logado
Future<Map<String, dynamic>?> getUsuarioLogado() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usuarioJson = prefs.getString('usuario');
  
  if (usuarioJson != null) {
    try {
      final usuario = jsonDecode(usuarioJson);
      return {
        'nome': usuario['nome'],
        'email': usuario['email'],
        'tipo': usuario['tipo'],
      };
    } catch (e) {
      return null;
    }
  }
  return null;
}

class JogoDetalhes extends StatefulWidget {
  final String jogoId;
  
  const JogoDetalhes({Key? key, required this.jogoId}) : super(key: key);

  @override
  State<JogoDetalhes> createState() => _JogoDetalhesState();
}

class _JogoDetalhesState extends State<JogoDetalhes> {
  bool menuAberto = false;
  bool modalImagemAberto = false;
  bool modalAvaliacaoAberto = false;
  bool modalDoacaoAberto = false;
  
  final TextEditingController _searchController = TextEditingController();
  
  // Dados do jogo
  Map<String, dynamic>? jogoData;
  bool carregandoJogo = true;
  
  // Dados do usuário
  bool usuarioLogado = false;
  String? nomeUsuario;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;
  
  // Avaliações
  List<Map<String, dynamic>> avaliacoes = [];
  double mediaEstrelas = 0.0;
  bool carregandoAvaliacoes = true;

  @override
  void initState() {
    super.initState();
    buscarDadosJogo();
    buscarDadosUsuario();
  }

  Future<void> buscarDadosJogo() async {
    try {
      final response = await http.get(Uri.parse('$projetosApiUrl'));
      if (response.statusCode == 200) {
        final List<dynamic> projetos = jsonDecode(response.body);
        final jogo = projetos.firstWhere(
          (p) => p['id'].toString() == widget.jogoId,
          orElse: () => null,
        );
        
        if (jogo != null) {
          setState(() {
            jogoData = jogo;
            carregandoJogo = false;
          });
          await carregarAvaliacoes();
        } else {
          setState(() {
            carregandoJogo = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        carregandoJogo = false;
      });
    }
  }

  Future<void> buscarDadosUsuario() async {
    final usuarioData = await getUsuarioLogado();
    if (usuarioData != null && usuarioData['nome'] != null) {
      setState(() {
        usuarioLogado = true;
        nomeUsuario = usuarioData['nome'];
      });
    }
  }

  Future<void> carregarAvaliacoes() async {
    if (jogoData == null) return;
    
    final avaliacoesData = await buscarAvaliacoesJogo(jogoData!['nomeProjeto']);
    final media = await buscarMediaEstrelas(jogoData!['nomeProjeto']);
    setState(() {
      avaliacoes = avaliacoesData;
      mediaEstrelas = media;
      carregandoAvaliacoes = false;
    });
  }

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

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    if (carregandoJogo) {
      return Scaffold(
        body: Column(
          children: [
            Navbar(
              isMenuOpen: menuAberto,
              onMenuTap: toggleMenu,
              searchController: _searchController,
            ),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    if (jogoData == null) {
      return Scaffold(
        body: Column(
          children: [
            Navbar(
              isMenuOpen: menuAberto,
              onMenuTap: toggleMenu,
              searchController: _searchController,
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Jogo não encontrado',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                child: SingleChildScrollView(
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
                                        child: _buildImagemJogo(),
                                      ),
                                      const SizedBox(width: 40),
                                      Expanded(
                                        flex: 7,
                                        child: _buildInfoJogo(),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildImagemJogo(),
                                      const SizedBox(height: 24),
                                      _buildInfoJogo(),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 24.0, bottom: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.arrow_back, size: 46, color: Color(0xFF90017F)),
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
          if (modalAvaliacaoAberto)
            _ModalAvaliacao(
              fechar: fecharModalAvaliacao,
              nomeUsuario: nomeUsuario,
              usuarioLogado: usuarioLogado,
              nomeJogo: jogoData!['nomeProjeto'],
            ),
          if (modalDoacaoAberto)
            _ModalDoacao(
              fechar: fecharModalDoacao,
              nomeUsuario: nomeUsuario,
              usuarioLogado: usuarioLogado,
            ),
        ],
      ),
    );
  }

  Widget _buildImagemJogo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: jogoData!['foto'] != null
                ? Image.network(
                    '$projetosApiUrl/${jogoData!['id']}/foto',
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              jogoData!['nomeProjeto'] ?? 'Jogo',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        jogoData!['nomeProjeto'] ?? 'Jogo',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoJogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jogoData!['nomeProjeto'] ?? 'Nome não disponível',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Color(0xFF90017F),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          jogoData!['descricao'] ?? 'Descrição não disponível',
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        _buildDetalhesJogo(),
        const SizedBox(height: 20),
        _buildSecaoAvaliacoes(),
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
              child: const Text('Avaliar Jogo'),
              onPressed: usuarioLogado ? abrirModalAvaliacao : null,
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
              onPressed: usuarioLogado ? abrirModalDoacao : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetalhesJogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 8),
        Text('Gênero: ${jogoData!['genero'] ?? 'Não informado'}'),
        Text('Tecnologias: ${jogoData!['tecnologias'] ?? 'Não informado'}'),
        Text('Data de Início: ${jogoData!['dataInicio'] ?? 'Não informado'}'),
        if (jogoData!['statusProjeto'] != null)
          Text('Status: ${jogoData!['statusProjeto']}'),
      ],
    );
  }

  Widget _buildSecaoAvaliacoes() {
    return Container(
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
            Column(
              children: avaliacoes.take(3).map((avaliacao) {
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
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF90017F),
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFB19CD9), Colors.white],
                ).createShader(bounds),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Game",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "Legends"),
                    ],
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "🎮 Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências! 🚀",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.6,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 35),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 40,
                runSpacing: 20,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF007BFF)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "(99) 99999-9999",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.email, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "info@gamelegends.com",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text(
                "🌟 Siga-nos nas Redes Sociais 🌟",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorfulSocialButton(
                    Icons.facebook,
                    [Color(0xFF1877F2), Color(0xFF42A5F5)],
                    () {},
                  ),
                  const SizedBox(width: 20),
                  _buildColorfulSocialButton(
                    Icons.camera_alt,
                    [Color(0xFFB19CD9), Color(0xFFD1C4E9)],
                    () {},
                  ),
                  const SizedBox(width: 20),
                  _buildColorfulSocialButton(
                    Icons.alternate_email,
                    [Color(0xFFE91E63), Color(0xFFFF6B9D)],
                    () {},
                  ),
                  const SizedBox(width: 20),
                  _buildColorfulSocialButton(
                    Icons.business,
                    [Color(0xFF0077B5), Color(0xFF00A0DC)],
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/privacidade'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A0DAD), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Política de Privacidade",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "© Game Legends ✨ | Feito com 💜 pelo nosso time incrível!",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
        splashRadius: 30,
      ),
    );
  }
}

// Modal de Avaliação
class _ModalAvaliacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final bool usuarioLogado;
  final String nomeJogo;

  const _ModalAvaliacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.usuarioLogado,
    required this.nomeJogo,
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
    
    final response = await http.post(
      Uri.parse(avaliacaoApiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "comentario": motivoController.text.trim(),
        "estrelas": estrelasSelecionadas,
        "nomeJogo": widget.nomeJogo,
        "nomeUsuario": widget.nomeUsuario!,
        "dataAvaliacao": DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    
    setState(() {
      enviado = response.statusCode == 200 || response.statusCode == 201;
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
                      Text(
                        'Avalie ${widget.nomeJogo}',
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
                              color: const Color(0xFFFFC107),
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
                          labelText: 'Deixe seu comentário',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.feedback_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: estrelasSelecionadas == 0 || motivoController.text.trim().isEmpty
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

// Modal de Doação (simplificado)
class _ModalDoacao extends StatelessWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final bool usuarioLogado;

  const _ModalDoacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.usuarioLogado,
  });

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: fechar,
                  ),
                ),
                const Icon(Icons.favorite, color: Colors.pink, size: 50),
                const SizedBox(height: 10),
                const Text(
                  "Funcionalidade de doação em desenvolvimento!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}