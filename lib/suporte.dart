import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';
 
class PaginaSuporte extends StatefulWidget {
  const PaginaSuporte({Key? key}) : super(key: key);
 
  @override
  State<PaginaSuporte> createState() => _PaginaSuporteState();
}
 
class _PaginaSuporteState extends State<PaginaSuporte> {
  bool menuAberto = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> formData = {
    'email': "",
    'usuario': ""
  };
 
  // Simula FAQ
  final List<Map<String, String>> faqData = [
    {
      "question": "Como posso baixar e jogar os jogos disponíveis na plataforma?",
      "answer":
          "Navegue pela nossa biblioteca de jogos, clique no jogo desejado e use o botão 'Download' na página do jogo. Todos os jogos são gratuitos e podem ser baixados diretamente."
    },
    {
      "question": "Como posso publicar meu jogo indie na Game Legends?",
      "answer":
          "Crie uma conta como desenvolvedor, acesse seu perfil e clique em 'Publicar Jogo'. Preencha as informações do seu projeto, faça upload dos arquivos e aguarde a aprovação da nossa equipe."
    },
    {
      "question": "Esqueci minha senha. Como posso recuperá-la?",
      "answer":
          "Clique em 'Esqueci minha senha' na página de login e siga as instruções para redefinir sua senha."
    },
    {
      "question": "Como posso navegar e filtrar os jogos disponíveis no site?",
      "answer":
          "Use a barra lateral esquerda para filtrar jogos por gênero (Terror, Esporte, Aventura, etc.), plataforma (Windows, Mac, Android, iOS), data de postagem (Hoje, Essa semana, Esse mês) ou status de desenvolvimento (Desenvolvido, Desenvolvendo)."
    },
    {
      "question": "Como posso deixar um comentário ou avaliação para um jogo?",
      "answer":
          "Na página de cada jogo, você encontrará uma seção de avaliações onde poderá escrever sua opinião."
    },
  ];
 
  @override
  void initState() {
    super.initState();
    setState(() {
      formData = {
        'email': "",
        'usuario': "",
      };
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
      backgroundColor: const Color(0xFFE6D7FF),
      body: Stack(
        children: [
          Column(
            children: [
              Navbar(
                isMenuOpen: menuAberto,
                onMenuTap: () => setState(() => menuAberto = !menuAberto),
                searchController: _searchController,
              ),
              Expanded(
                child: ListView(
            children: [
              // FAQ Section
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFE6D7FF),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        const Text(
                          "Perguntas Frequentes",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Color(0xFF90017F),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...faqData.map((faq) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ExpansionTile(
                            backgroundColor: const Color(0xFF90017F),
                            collapsedBackgroundColor: const Color(0xFF90017F),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            title: Text(
                              faq["question"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  faq["answer"]!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
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
                              Icons.reddit,
                              [Color(0xFFFF4500), Color(0xFFFF6B35)],
                              () => launchUrl(Uri.parse('https://www.reddit.com/r/Game_Legends_jogos/s/GZVUlKiWg8')),
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
          // Mobile menu overlay
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
 

 
