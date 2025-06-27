import 'package:flutter/material.dart';
import 'navbar.dart';

// Lista dos jogos para a categoria Cartas (agora com usuário, descrição e comentários!)
// Removido o campo "pai"
final _cartasGames = [
  {
    "img": "assets/Img01.png",
    "name": "Gamblers",
    "user": "apostador",
    "description": "Jogo de cartas com apostas e estratégias arriscadas.",
    "comments": [
      "Ganhei várias rodadas!",
      "Jogo emocionante.",
      "Viciante!"
    ]
  },
  {
    "img": "assets/Img02.png",
    "name": "Pocket Crystal League",
    "user": "crystalboy",
    "description": "Monte seu deck e desafie rivais em batalhas de cartas.",
    "comments": [
      "Deck building ótimo.",
      "Visual incrível.",
      "Recomendo para fãs de TCG."
    ]
  },
  {
    "img": "assets/Img03.png",
    "name": "Dungeon Drafters",
    "user": "drafter",
    "description": "Explore masmorras e use cartas para vencer inimigos.",
    "comments": [
      "Mistura legal de dungeon crawler e cartas.",
      "Adorei as mecânicas.",
      "Muito estratégico."
    ]
  },
  {
    "img": "assets/Img04.png",
    "name": "Beecarbonize",
    "user": "beeeco",
    "description": "Salve o planeta usando cartas de ações ambientais.",
    "comments": [
      "Sustentável e divertido!",
      "Aprendi sobre ecologia.",
      "Sensacional."
    ]
  },
  {
    "img": "assets/Img05.png",
    "name": "Tuggowar",
    "user": "tugplayer",
    "description": "Uma disputa de força e cartas em batalhas rápidas.",
    "comments": [
      "Joguei com amigos.",
      "Rápido e divertido.",
      "Boa para partidas curtas."
    ]
  },
  {
    "img": "assets/Img06.png",
    "name": "Face Down",
    "user": "mascarado",
    "description": "Descubra quem está por trás das máscaras neste jogo social.",
    "comments": [
      "Ótimo para festas.",
      "Mistura de blefe e sorte.",
      "Quero expansão!"
    ]
  },
];

class CartasPage extends StatefulWidget {
  const CartasPage({Key? key}) : super(key: key);

  @override
  State<CartasPage> createState() => _CartasPageState();
}

class _CartasPageState extends State<CartasPage> {
  final TextEditingController _searchController = TextEditingController();
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
                    // Lista dos jogos de cartas (com comentários, usuário, sem pai)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _cartasGames.length,
                          itemBuilder: (context, index) {
                            final game = _cartasGames[index];
                            return _CartasGameCard(
                              img: (game.containsKey('img') && game['img'] != null) ? game['img'] as String : '',
                              name: (game.containsKey('name') && game['name'] != null) ? game['name'] as String : '',
                              user: (game.containsKey('user') && game['user'] != null) ? game['user'] as String : '',
                              comments: (game['comments'] is List) ? List<String>.from(game['comments'] as List) : [],
                              description: (game.containsKey('description') && game['description'] != null) ? game['description'] as String : '',
                              onTap: () {
                                // Navegue para a descrição se desejar
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // === Footer IDÊNTICO AO SUPORTE ===
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
              // Rodapé inferior idêntico
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

// Card customizado para Cartas, estilo terror.dart, sem pai
class _CartasGameCard extends StatelessWidget {
  final String img;
  final String name;
  final String user;
  final List<String> comments;
  final String description;
  final VoidCallback onTap;

  const _CartasGameCard({
    required this.img,
    required this.name,
    required this.user,
    required this.comments,
    required this.description,
    required this.onTap,
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