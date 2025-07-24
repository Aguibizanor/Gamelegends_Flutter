import 'package:flutter/material.dart';
import 'navbar.dart';

// Lista dos jogos para a categoria Aventura (agora com usuário, descrição e comentários!)
// Removido o campo "pai"
final _aventuraGames = [
  {
    "img": "assets/laranja.png",
    "name": "Coop Catacombs",
    "user": "catacombcoop",
    "description": "Explore catacumbas em cooperação com amigos e resolva enigmas.",
    "comments": [
      "Adorei jogar em dupla!",
      "Cenários bem criativos.",
      "Desafios inteligentes."
    ]
  },
  {
    "img": "assets/limao.png",
    "name": "Hero's Hour",
    "user": "herohourfan",
    "description": "Comande heróis em batalhas em tempo real e conquiste territórios.",
    "comments": [
      "Muito estratégico.",
      "Gráficos estilosos.",
      "Lembra jogos clássicos."
    ]
  },
  {
    "img": "assets/jaca.png",
    "name": "The Vale",
    "user": "valeexplorer",
    "description": "Uma aventura sensorial intensa em um mundo medieval.",
    "comments": [
      "Narrativa imersiva.",
      "Ótimo para deficientes visuais.",
      "Trilha sonora marcante."
    ]
  },
  {
    "img": "assets/goiaba.png",
    "name": "Bug Fables",
    "user": "buglover",
    "description": "Acompanhe insetos carismáticos em uma jornada épica.",
    "comments": [
      "Personagens cativantes.",
      "Puzzles divertidos.",
      "História envolvente."
    ]
  },
  {
    "img": "assets/framboesa.png",
    "name": "Billie Bust up",
    "user": "billieplayer",
    "description": "Enfrente desafios musicais em uma aventura animada.",
    "comments": [
      "Músicas incríveis!",
      "Visual colorido.",
      "Muito divertido."
    ]
  },
  {
    "img": "assets/damasco.png",
    "name": "Endless Blue",
    "user": "bluesailor",
    "description": "Navegue mares misteriosos e descubra segredos profundos.",
    "comments": [
      "Atmosfera relaxante.",
      "Mundo aberto interessante.",
      "Recomendo para quem gosta de exploração."
    ]
  },
];

class AventuraPage extends StatefulWidget {
  const AventuraPage({Key? key}) : super(key: key);

  @override
  State<AventuraPage> createState() => _AventuraPageState();
}

class _AventuraPageState extends State<AventuraPage> {
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
                
                // Lista dos jogos de aventura
                Expanded(
                  child: Container(
                    color: const Color(0xFFE9E9E9),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      children: [
                        // Lista de jogos
                        ..._aventuraGames.map((game) => _AventuraGameCard(
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
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // GameLegends
                                  const Text(
                                    "GameLegends",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Descrição
                                  const Text(
                                    "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Contatos
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone, color: Colors.white70, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        "(99) 99999-9999",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(Icons.email, color: Colors.white70, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        "info@gamelegends.com",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Divisor
                                  Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                    margin: const EdgeInsets.symmetric(horizontal: 40),
                                  ),
                                  const SizedBox(height: 24),

                                  // Links Rápidos
                                  const Text(
                                    "Links Rápidos",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  Column(
                                    children: [
                                      "Eventos",
                                      "Equipe",
                                      "Missão",
                                      "Serviços",
                                      "Afiliados"
                                    ].map((txt) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        txt,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Rodapé inferior
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

// Card customizado para Aventura, estilo desenvolvendo.dart
class _AventuraGameCard extends StatelessWidget {
  final String img;
  final String name;
  final String user;
  final List<String> comments;
  final String description;
  final VoidCallback onTap;
  final bool sidebarOpen;

  const _AventuraGameCard({
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