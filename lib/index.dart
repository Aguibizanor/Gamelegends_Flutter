import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  String getProjetoImagem(dynamic projeto) {
    // Sempre retorna o endpoint que serve o byte[] convertido em imagem
    return 'http://localhost:8080/projetos/${projeto['id']}/foto';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: Navbar(
        searchController: _searchController,
        isMenuOpen: menuAberto,
        onMenuTap: toggleMenu,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Barra lateral e jogos
              Expanded(
                child: Row(
                  children: [
                    // Barra lateral
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isWide || isMobileOpen ? 260 : 0,
                      child: isWide || isMobileOpen
                          ? Drawer(
                              elevation: 0,
                              child: Container(
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
                            )
                          : null,
                    ),
                    // Botão hamburguer mobile lateral
                    if (!isWide)
                      Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(isMobileOpen ? Icons.chevron_left : Icons.chevron_right),
                          onPressed: toggleMobileMenu,
                        ),
                      ),
                    // Lista de projetos/jogos
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : GridView.builder(
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
                                      Navigator.pushNamed(context, '/Descricao/${projeto['id']}');
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                color: const Color(0xFF90017F),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Wrap(
                      runSpacing: 24,
                      spacing: 50,
                      children: [
                        // Sobre
                        SizedBox(
                          width: 350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text.rich(
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
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: const [
                                  Icon(Icons.phone, color: Colors.white70, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    "(99) 99999-9999",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  SizedBox(width: 18),
                                  Icon(Icons.email, color: Colors.white70, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    "info@gamelegends.com",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.facebook, color: Colors.white),
                                    onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=61578797307500')),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.alternate_email, color: Colors.white),
                                    onPressed: () => launchUrl(Uri.parse('https://www.instagram.com/game._legends/')),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.business, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, '/privacidade'),
                                child: const Text(
                                  "Conheça nossa política de privacidade",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF90017F),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    "© gamelegends.com | Feito pelo time do Game Legends",
                    style: TextStyle(color: Colors.white70),
                  ),
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