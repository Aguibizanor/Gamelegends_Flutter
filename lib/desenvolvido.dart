import 'package:flutter/material.dart';
import 'navbar.dart';

// Lista dos jogos para a categoria "Desenvolvido" (agora com usuário, descrição e comentários!)
final _desenvolvidoGames = [
  {
    "img": "assets/galho.png",
    "name": "Inmost",
    "user": "educador",
    "description": "Explore temas profundos e aprendizagem emocional nesse puzzle.",
    "comments": [
      "Muito educativo!",
      "Desperta empatia.",
      "Recomendo para escolas."
    ]
  },
  {
    "img": "assets/gladiator.png",
    "name": "Gladiator",
    "user": "ludus",
    "description": "Aprenda história enquanto batalha como um verdadeiro gladiador.",
    "comments": [
      "Aprendi sobre Roma.",
      "Jogo de ação e conhecimento.",
      "Legal para aula de história."
    ]
  },
  {
    "img": "assets/pombo.png",
    "name": "Subida de Pomba",
    "user": "pombinhu",
    "description": "Ajude a pomba a superar obstáculos e aprender geografia urbana.",
    "comments": [
      "Geografia divertida.",
      "Muito criativo!",
      "Aprendi brincando."
    ]
  },
  {
    "img": "assets/img06.png",
    "name": "Face Down",
    "user": "psicoplay",
    "description": "Reflexão sobre bullying e saúde mental em formato de game.",
    "comments": [
      "Importante para jovens.",
      "Traz reflexão real.",
      "Didático e sensível."
    ]
  },
  {
    "img": "assets/salada.png",
    "name": "They Are Here",
    "user": "aliensensei",
    "description": "Aprenda lógica e resolução de problemas com aliens.",
    "comments": [
      "Puzzles inteligentes.",
      "Didático e divertido.",
      "Bons desafios."
    ]
  },
  {
    "img": "assets/mirror.png",
    "name": "Pocket Mirror",
    "user": "espelhoso",
    "description": "Trabalhe autoconhecimento com narrativa interativa e puzzles.",
    "comments": [
      "Narrativa envolvente.",
      "Ótimo para autoconhecimento.",
      "Recomendo para projetos escolares."
    ]
  },
];

class DesenvolvidoPage extends StatefulWidget {
  const DesenvolvidoPage({Key? key}) : super(key: key);

  @override
  State<DesenvolvidoPage> createState() => _DesenvolvidoPageState();
}

class _DesenvolvidoPageState extends State<DesenvolvidoPage> {
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
                    
                    // Lista dos jogos desenvolvidos
                    Expanded(
                      child: Container(
                        color: const Color(0xFFE9E9E9),
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          children: [
                            // Lista de jogos
                            ..._desenvolvidoGames.map((game) => _DesenvolvidoGameCard(
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
                              width: double.infinity,
                              color: const Color(0xFF90017F),
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
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.alternate_email, color: Colors.white),
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.business, color: Colors.white),
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Links rápidos
                                      SizedBox(
                                        width: 220,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Links Rápidos",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                            const SizedBox(height: 10),
                                            ...[
                                              "Eventos",
                                              "Equipe",
                                              "Missão",
                                              "Serviços",
                                              "Afiliados"
                                            ].map((txt) => Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: InkWell(
                                                    onTap: () {},
                                                    child: Text(
                                                      txt,
                                                      style: const TextStyle(
                                                          color: Colors.white70, fontSize: 15),
                                                    ),
                                                  ),
                                                )),
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

// Card customizado para Desenvolvido
class _DesenvolvidoGameCard extends StatelessWidget {
  final String img;
  final String name;
  final String user;
  final List<String> comments;
  final String description;
  final VoidCallback onTap;
  final bool sidebarOpen;

  const _DesenvolvidoGameCard({
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