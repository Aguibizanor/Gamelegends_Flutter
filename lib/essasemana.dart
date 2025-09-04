import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';

// Lista dos jogos para a categoria "Essa Semana" (agora com usuário, descrição e comentários!)
// Removido o campo "pai"
final _essaSemanaGames = [
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

class EssaSemanaPage extends StatefulWidget {
  const EssaSemanaPage({Key? key}) : super(key: key);

  @override
  State<EssaSemanaPage> createState() => _EssaSemanaPageState();
}

class _EssaSemanaPageState extends State<EssaSemanaPage> {
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

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha:  0.4),
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

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
            child: Stack(
              children: [
                // Conteúdo principal sempre visível
                Container(
                  color: const Color(0xFFE6D7FF),
                  margin: EdgeInsets.only(left: isWide ? 260 : 0),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    children: [
                      // Lista de jogos
                      ..._essaSemanaGames.map((game) => _EssaSemanaGameCard(
                        img: (game.containsKey('img') && game['img'] != null) ? game['img'] as String : '',
                        name: (game.containsKey('name') && game['name'] != null) ? game['name'] as String : '',
                        user: (game.containsKey('user') && game['user'] != null) ? game['user'] as String : '',
                        comments: (game['comments'] is List) ? List<String>.from(game['comments'] as List) : [],
                        description: (game.containsKey('description') && game['description'] != null) ? game['description'] as String : '',
                        onTap: () {},
                        sidebarOpen: false,
                      )),
                      
                      const SizedBox(height: 30),
                      
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
                                                color: Colors.black.withValues(alpha:  0.3),
                                                offset: const Offset(2, 2),
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
                                                color: Colors.black.withValues(alpha:  0.2),
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
                                          color: Colors.white.withValues(alpha:  0.9),
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
                // Seta destacada
                if (!isWide)
                  Positioned(
                    top: 20,
                    left: isMobileOpen ? 270 : 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF90017F),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:  0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isMobileOpen ? Icons.chevron_left : Icons.chevron_right,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: toggleMobileMenu,
                      ),
                    ),
                  ),
                // Sidebar sobreposta para mobile
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
                            color: Colors.black.withValues(alpha:  0.3),
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
                // Sidebar fixa para desktop
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

// Card customizado para Essa Semana
class _EssaSemanaGameCard extends StatelessWidget {
  final String img;
  final String name;
  final String user;
  final List<String> comments;
  final String description;
  final VoidCallback onTap;
  final bool sidebarOpen;

  const _EssaSemanaGameCard({
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
    final isWide = MediaQuery.of(context).size.width > 600;
    
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
    
    // Layout para mobile (horizontal com comentários na direita)
    if (!isWide) {
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
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Text("sem imagem", style: TextStyle(color: Colors.black38, fontSize: 10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Título, descrição, botão
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF90017F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF3E78C9),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              // Usuário e comentários na direita
              if (user.isNotEmpty)
                Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_circle, size: 16, color: Color(0xFF90017F)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF90017F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (comments.isNotEmpty) const SizedBox(height: 6),
                      if (comments.isNotEmpty)
                        ...comments.take(4).map((comment) => Container(
                          margin: const EdgeInsets.only(bottom: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            comment,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    // Layout para desktop (horizontal)
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
            // Usuário e comentários
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
