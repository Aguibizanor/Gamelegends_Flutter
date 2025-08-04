import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';

// Lista dos jogos para a categoria "iOS" (agora com usuário, descrição e comentários!)
// Removido o campo "pai"
final _iosGames = [
  {
    "img": "assets/morticia.png",
    "name": "Mortician's Tale",
    "user": "tanatofã",
    "description": "Uma experiência única sobre o universo do luto e funerária.",
    "comments": [
      "Bem diferente do que eu esperava.",
      "Trilha sonora relaxante.",
      "História sensível e bonita."
    ]
  },
  {
    "img": "assets/city.png",
    "name": "CityGlitch",
    "user": "cityzen",
    "description": "Resolva puzzles em cidades bugadas e misteriosas.",
    "comments": [
      "Desafio crescente!",
      "Visual minimalista show.",
      "Ótimo passatempo."
    ]
  },
  {
    "img": "assets/gladia.png",
    "name": "Gladiabots",
    "user": "botmaster",
    "description": "Programe robôs para batalhas automáticas táticas.",
    "comments": [
      "Curti automatizar batalhas.",
      "Requer bastante lógica.",
      "Viciante pra quem gosta de estratégia."
    ]
  },
  {
    "img": "assets/ceu.png",
    "name": "Até a borda do Céu",
    "user": "dreamer",
    "description": "Uma aventura poética para desafiar sua imaginação.",
    "comments": [
      "Lindo visual.",
      "Poético e emocionante.",
      "Trilha sonora perfeita."
    ]
  },
  {
    "img": "assets/sixit.png",
    "name": "Sixit",
    "user": "seisvezes",
    "description": "Você só tem seis movimentos para salvar o mundo!",
    "comments": [
      "Mecânica diferente.",
      "Ótimo para quem gosta de puzzle.",
      "Desafiador e divertido."
    ]
  },
  {
    "img": "assets/imost.png",
    "name": "Inmost",
    "user": "profundezas",
    "description": "Aventure-se em um mundo sombrio e cheio de mistérios.",
    "comments": [
      "Clima sombrio top!",
      "Narrativa excelente.",
      "Recomendo para fãs de suspense."
    ]
  },
];

class IosPage extends StatefulWidget {
  const IosPage({Key? key}) : super(key: key);

  @override
  State<IosPage> createState() => _IosPageState();
}

class _IosPageState extends State<IosPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool menuAberto = false;
  bool isMobileOpen = false;
  Map<String, bool> isOpen = {
    'genero': true,
    'plataformas': true,
    'postagem': true,
    'status': true,
  };

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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final sideBarOpen = isWide || isMobileOpen;

    return Scaffold(
      body: Column(
        children: [
          Navbar(
            searchController: _searchController,
            isMenuOpen: menuAberto,
            onMenuTap: toggleMenu,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra lateral
                if (sideBarOpen)
                  SizedBox(
                    width: 260,
                    child: Drawer(
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
                    ),
                  ),
                
                // Botão hamburguer mobile lateral
                if (!isWide && !sideBarOpen)
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: toggleMobileMenu,
                  ),
                
                if (!isWide && sideBarOpen)
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: toggleMobileMenu,
                  ),
                
                // Lista dos jogos do iOS
                Expanded(
                  child: Container(
                    color: const Color(0xFFE9E9E9),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      children: [
                        // Lista de jogos
                        ..._iosGames.map((game) => _IosGameCard(
                          img: (game.containsKey('img') && game['img'] != null) ? game['img'] as String : '',
                          name: (game.containsKey('name') && game['name'] != null) ? game['name'] as String : '',
                          user: (game.containsKey('user') && game['user'] != null) ? game['user'] as String : '',
                          comments: (game['comments'] is List) ? List<String>.from(game['comments'] as List) : [],
                          description: (game.containsKey('description') && game['description'] != null) ? game['description'] as String : '',
                          onTap: () {},
                          sidebarOpen: sideBarOpen,
                        )),
                        
                        // Espaço antes do footer
                        const SizedBox(height: 30),
                        
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
                                  // Sobre a plataforma
                                  SizedBox(
                                    width: 350,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(
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
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Menu mobile overlay do topo (hambúrguer)
      endDrawer: !isWide && menuAberto
          ? NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            )
          : null,
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

// Card customizado para iOS, estilo terror.dart, sem pai
class _IosGameCard extends StatelessWidget {
  final String img;
  final String name;
  final String user;
  final List<String> comments;
  final String description;
  final VoidCallback onTap;
  final bool sidebarOpen;

  const _IosGameCard({
    required this.img,
    required this.name,
    required this.user,
    required this.comments,
    required this.description,
    required this.onTap,
    required this.sidebarOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (sidebarOpen) {
      return Center(
        child: Card(
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    img,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      width: 180,
                      height: 180,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text("sem imagem", style: TextStyle(color: Colors.black38)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF90017F),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do jogo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                img,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text("sem imagem", style: TextStyle(color: Colors.black38)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Título, descrição, botão
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF90017F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF3E78C9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF90017F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: onTap,
                    child: const Text(
                      "ver detalhes",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // Usuário e comentários (igual ao terror.dart, sem pai)
            if (user.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 18, top: 2),
                constraints: const BoxConstraints(
                  maxWidth: 160,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle, size: 22, color: Color(0xFF90017F)),
                        const SizedBox(width: 6),
                        Text(
                          user,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF90017F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    for (final comment in comments)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          comment,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}