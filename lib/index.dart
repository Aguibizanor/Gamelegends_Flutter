import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'jogo_detalhes.dart';

class IndexPrincipal extends StatefulWidget {
  const IndexPrincipal({Key? key}) : super(key: key);

  @override
  State<IndexPrincipal> createState() => _IndexPrincipalState();
}

class _IndexPrincipalState extends State<IndexPrincipal> {
  final TextEditingController _searchController = TextEditingController();
  bool menuAberto = false;
  bool isMobileOpen = false;

  Map<String, String> formData = {
    'email': "",
    'usuario': "" // "Cliente" ou "Desenvolvedor"
  };

  // Controle dos filtros
  Map<String, bool> isOpen = {
    'genero': true,
    'plataformas': true,
    'postagem': true,
    'status': true,
  };

  List<dynamic> projetos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjetos();
    _loadUser();
  }

  Future<void> _fetchProjetos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/projetos'));
      if (response.statusCode == 200) {
        setState(() {
          projetos = json.decode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // ignore: avoid_print
        print('Erro ao carregar projetos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      // ignore: avoid_print
      print('Erro ao carregar projetos: $e');
    }
  }

  void _loadUser() {
    // Simulação, adapte para SharedPreferences, Provider, etc
    // Exemplo: final usuarioData = ...;
    setState(() {
      formData = {
        'email': "",
        'usuario': "",
      };
    });
  }

  void toggleList(String section) {
    setState(() {
      isOpen[section] = !(isOpen[section] ?? false);
    });
  }

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
  }

  void toggleMobileMenu() {
    setState(() {
      isMobileOpen = !isMobileOpen;
    });
  }

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity( 0.4),
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

  String getProjetoImagem(dynamic projeto) {
    // Sempre retorna o endpoint que serve o byte[] convertido em imagem
    return 'http://localhost:8080/projetos/${projeto['id']}/foto';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),

      body: Stack(
        children: [
          Column(
            children: [
              Navbar(
                searchController: _searchController,
                isMenuOpen: menuAberto,
                onMenuTap: toggleMenu,
              ),
              Expanded(
                child: Stack(
                  children: [
          // Conteúdo principal
          Container(
            margin: EdgeInsets.only(left: isWide ? 260 : 0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Botão hamburguer mobile lateral
                  if (!isWide)
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: Icon(isMobileOpen ? Icons.chevron_left : Icons.chevron_right),
                        onPressed: toggleMobileMenu,
                      ),
                    ),
                  // Lista de projetos/jogos
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(10),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 4 : 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: projetos.length,
                            itemBuilder: (context, index) {
                              final projeto = projetos[index];
                              return _GameCard(
                                nome: projeto['nomeProjeto'] ?? '',
                                imageUrl: getProjetoImagem(projeto),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JogoDetalhes(jogoId: projeto['id'].toString()),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 50),
                  // ======= RODAPÉ COLORIDO =========
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF90017F),
                      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            children: [
                              // Logo com efeito brilhante
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFB19CD9), Colors.white],
                                ).createShader(bounds),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Game",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: "Legends"),
                                    ],
                                  ),
                                  style: GoogleFonts.blackOpsOne(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              // Descrição com sombra colorida
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "🎮 Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências! 🚀",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    height: 1.6,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity( 0.3),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 35),
                              
                              // Informações de contato com círculos coloridos
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
                              
                              // Redes sociais com círculos animados
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
                                    () => launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=61578797307500')),
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
                                    () => launchUrl(Uri.parse('https://www.instagram.com/game._legends/')),
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
                              
                              // Link de privacidade estilizado
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
                                        color: Colors.black.withOpacity( 0.2),
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
                              
                              // Copyright com emojis
                              Text(
                                "© Game Legends ✨ | Feito com 💜 pelo nosso time incrível!",
                                style: TextStyle(
                                  color: Colors.white.withOpacity( 0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
          // Sidebar sobreposta
          if (isWide)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 260,
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  children: [
                    _buildSection(
                      "Gênero",
                      "genero",
                      [
                        _buildFilterLink(context, "Terror", Icons.sports_esports, "/terror"),
                        _buildFilterLink(context, "Esporte", Icons.sports_esports, "/esporte"),
                        _buildFilterLink(context, "Aventura", Icons.sports_esports, "/aventura"),
                        _buildFilterLink(context, "Educacional", Icons.sports_esports, "/educacional"),
                        _buildFilterLink(context, "Sobrevivência", Icons.sports_esports, "/sobrevivencia"),
                        _buildFilterLink(context, "Jogo de cartas", Icons.sports_esports, "/cartas"),
                      ],
                    ),
                    _buildSection(
                      "Plataformas",
                      "plataformas",
                      [
                        _buildFilterLink(context, "Windows", Icons.desktop_windows, "/windows"),
                        _buildFilterLink(context, "Mac OS", Icons.laptop_mac, "/macOs"),
                        _buildFilterLink(context, "Android", Icons.android, "/android"),
                        _buildFilterLink(context, "iOS", Icons.phone_iphone, "/iOS"),
                      ],
                    ),
                    _buildSection(
                      "Postagem",
                      "postagem",
                      [
                        _buildFilterLink(context, "Hoje", Icons.access_time, "/hoje"),
                        _buildFilterLink(context, "Essa semana", Icons.access_time, "/essaSemana"),
                        _buildFilterLink(context, "Esse mês", Icons.access_time, "/esseMes"),
                      ],
                    ),
                    _buildSection(
                      "Status",
                      "status",
                      [
                        _buildFilterLink(context, "Desenvolvido", Icons.flash_on, "/desenvolvido"),
                        _buildFilterLink(context, "Desenvolvendo", Icons.play_arrow, "/desenvolvendo"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // Sidebar mobile sobreposta
          if (isMobileOpen && !isWide)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  children: [
                    _buildSection(
                      "Gênero",
                      "genero",
                      [
                        _buildFilterLink(context, "Terror", Icons.sports_esports, "/terror"),
                        _buildFilterLink(context, "Esporte", Icons.sports_esports, "/esporte"),
                        _buildFilterLink(context, "Aventura", Icons.sports_esports, "/aventura"),
                        _buildFilterLink(context, "Educacional", Icons.sports_esports, "/educacional"),
                        _buildFilterLink(context, "Sobrevivência", Icons.sports_esports, "/sobrevivencia"),
                        _buildFilterLink(context, "Jogo de cartas", Icons.sports_esports, "/cartas"),
                      ],
                    ),
                    _buildSection(
                      "Plataformas",
                      "plataformas",
                      [
                        _buildFilterLink(context, "Windows", Icons.desktop_windows, "/windows"),
                        _buildFilterLink(context, "Mac OS", Icons.laptop_mac, "/macOs"),
                        _buildFilterLink(context, "Android", Icons.android, "/android"),
                        _buildFilterLink(context, "iOS", Icons.phone_iphone, "/iOS"),
                      ],
                    ),
                    _buildSection(
                      "Postagem",
                      "postagem",
                      [
                        _buildFilterLink(context, "Hoje", Icons.access_time, "/hoje"),
                        _buildFilterLink(context, "Essa semana", Icons.access_time, "/essaSemana"),
                        _buildFilterLink(context, "Esse mês", Icons.access_time, "/esseMes"),
                      ],
                    ),
                    _buildSection(
                      "Status",
                      "status",
                      [
                        _buildFilterLink(context, "Desenvolvido", Icons.flash_on, "/desenvolvido"),
                        _buildFilterLink(context, "Desenvolvendo", Icons.play_arrow, "/desenvolvendo"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
                  ],
                ),
              ),
            ],
          ),
          // Menu mobile overlay do topo
          if (!isWide && menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String key, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: GestureDetector(
            onTap: () => toggleList(key),
            child: Row(
              children: [
                Icon(
                  isOpen[key]! ? Icons.expand_more : Icons.chevron_right,
                  size: 20,
                  color: const Color(0xFF90017F),
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF90017F)),
                ),
              ],
            ),
          ),
        ),
        if (isOpen[key]!)
          ...children.map((w) => Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 8),
                child: w,
              )),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFilterLink(BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String nome;
  final String imageUrl;
  final VoidCallback onTap;

  const _GameCard({
    required this.nome,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Text("sem imagem", style: TextStyle(color: Colors.black38)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Center(
                child: Text(
                  nome,
                  style: const TextStyle(
                    color: Color(0xFF90017F),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
