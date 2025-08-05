import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';

class PaginaSobre extends StatefulWidget {
  const PaginaSobre({Key? key}) : super(key: key);

  @override
  State<PaginaSobre> createState() => _PaginaSobreState();
}

class _PaginaSobreState extends State<PaginaSobre> {
  bool menuAberto = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> formData = {
    'email': "",
    'usuario': "", // "Cliente" ou "Desenvolvedor"
  };

  @override
  void initState() {
    super.initState();
    // Aqui você pode integrar com o seu sistema de autenticação real se quiser.
  }

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
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
                child: ListView(
            children: [
              // Header visual (equivalente ao background com Pessoas.png)
              Container(
                height: 320,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/Pessoas.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
                  child: Text(
                    'Quem Somos',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black38,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ) ??
                        const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
              ),

              // Seções principais
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // QUEM SOMOS
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'QUEM SOMOS?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: Color(0xFF90017F),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Somos a Game Legends, uma plataforma de jogos dedicada a promover a inclusão e o apoio aos desenvolvedores independentes, especialmente aqueles que estão começando a produzir seus primeiros jogos. Nosso objetivo é criar um ecossistema de jogos mais saudável, criativo e inclusivo, onde gamers e desenvolvedores possam se unir e colaborar.',
                                style: TextStyle(fontSize: 17, color: Colors.black87, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        // O QUE FAZEMOS
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'O QUE FAZEMOS?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: Color(0xFF90017F),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nós oferecemos uma plataforma onde desenvolvedores de jogos podem receber apoio financeiro diretamente de jogadores através de doações. Utilizamos tecnologias avançadas, como sistemas de pagamento integrados e inteligência artificial, para facilitar transações e personalizar recomendações de jogos. Isso não só ajuda a financiar e lançar novos jogos, mas também promove a diversidade e a inovação na indústria de games. Além disso, criamos uma comunidade onde jogadores podem se conectar com desenvolvedores, trocar ideias e contribuir para o sucesso de novos projetos.',
                                style: TextStyle(fontSize: 17, color: Colors.black87, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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
              ),
            ],
          ),
              ),
            ],
          ),
          // Menu mobile overlay
          if (!isWide && menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }
}