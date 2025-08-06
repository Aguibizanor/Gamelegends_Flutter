import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';
import 'suporte.dart';
import 'login.dart';
import 'cadastro.dart';
import 'sobre.dart';
import 'index.dart';
import 'android.dart';
import 'aventura.dart';
import 'cartas.dart';
import 'desenvolvendo.dart';
import 'desenvolvido.dart';
import 'educacional.dart';
import 'esporte.dart';
import 'essaSemana.dart' as essa_semana;
import 'esseMes.dart';
import 'hoje.dart';
import 'macOs.dart';
import 'iOS.dart';
import 'sobrevivencia.dart';
import 'terror.dart';
import 'windows.dart';
import 'codin.dart';
import 'mandaremail.dart';
import 'redefinir.dart';
import 'perfil.dart';
import 'descricao.dart';
import 'descricao2.dart';
import 'descricao3.dart';
import 'privacidade.dart';
import 'cartoes_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPrincipal(),
        '/index': (context) => const IndexPrincipal(),
        '/que': (context) => PaginaSobre(),
        '/suporte': (context) => PaginaSuporte(),
        '/login': (context) => PaginaLogin(),
        '/cadastro': (context) => CadastroForm(),
        '/android': (context) => AndroidPage(),
        '/cartas': (context) => CartasPage(),
        '/aventura': (context) => AventuraPage(),
        '/desenvolvendo': (context) => DesenvolvendoPage(),
        '/desenvolvido': (context) => DesenvolvidoPage(),
        '/essaSemana': (context) => essa_semana.EssaSemanaPage(),
        '/educacional': (context) => EducacionalPage(),
        '/esporte': (context) => EsportePage(),
        '/esseMes': (context) => EsseMesPage(),
        '/hoje': (context) => HojePage(),
        '/iOS': (context) => IosPage(),
        '/macOs': (context) => MacOsPage(),
        '/sobrevivencia': (context) => SobrevivenciaPage(),
        '/terror': (context) => TerrorPage(),
        '/windows': (context) => WindowsPage(),
        '/mandaremail': (context) => PaginaMandarEmail(),
        '/codin': (context) => PaginaCodin(),
        '/redefinir': (context) => PaginaRedefinirSenha(),
        '/perfil': (context) => PaginaPerfil(),
        '/descricao': (context) => PaginaDescricao(),
        '/descricao2': (context) => PaginaDescricao2(),
        '/descricao3': (context) => PaginaDescricao3(),
        '/privacidade': (context) => PrivacidadePage(),
        '/cartoes': (context) => CartoesPage(),
      },
    );
  }
}

class MainPrincipal extends StatefulWidget {
  const MainPrincipal({Key? key}) : super(key: key);

  @override
  State<MainPrincipal> createState() => _MainPrincipalState();
}

class _MainPrincipalState extends State<MainPrincipal> {
  final ScrollController _carouselController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> data = [];
  bool isLoading = true;
  bool menuAberto = false;
  int? focusedIndex;
  Map<String, String> formData = {
    'email': "",
    'usuario': ""
  };

  @override
  void initState() {
    super.initState();
    _loadCarouselData();
    _loadUser();
  }

  Future<void> _loadCarouselData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      data = [
        {
          "id": 1,
          "name": "Happy Cat Tavern",
          "descricao": "Ajude Batou a beber o máximo de milkshakes que puder enquanto os clientes da taverna o animam.",
          "imagem": "assets/happy.png",
        },
        {
          "id": 2,
          "name": "Coop Catacombs: Roguelike",
          "descricao": "Nas masmorras, acompanhando em todos os momentos e poderá presenciar os rastros de outros aventureiros.",
          "imagem": "assets/catacombs.png",
        },
        {
          "id": 3,
          "name": "Subida de Pombo",
          "descricao": "Cuide do seu próprio pombo enquanto ele luta contra inimigos cada vez mais fortes e, no final, enfrente o lendário Deus Pombo.",
          "imagem": "assets/pombo.png",
        }
      ];
      isLoading = false;
    });
  }

  void _loadUser() {
    setState(() {
      formData = {
        'email': "",
        'usuario': "",
      };
    });
  }

  void _handleLeftClick() {
    _carouselController.animateTo(
      _carouselController.offset - 300,
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  void _handleRightClick() {
    _carouselController.animateTo(
      _carouselController.offset + 300,
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
    );
  }

  void _handleMouseEnter(int index) {
    setState(() {
      focusedIndex = index;
    });
  }

  void _handleMouseLeave() {
    setState(() {
      focusedIndex = null;
    });
  }

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.4),
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
                onMenuTap: () => setState(() => menuAberto = !menuAberto),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFE9E9E9),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                              color: Colors.white,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'EXPLORE O MUNDO DOS JOGOS',
                                                style: TextStyle(
                                                  fontSize: isWide ? 46 : 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF90017F),
                                                  height: isWide ? 1.05 : 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              Text(
                                                'Venha conhecer nossa plataforma onde você poderá encontrar jogos da nossa comunidade.',
                                                style: TextStyle(
                                                  fontSize: isWide ? 20 : 16,
                                                  color: Colors.black87,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 28),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF90017F),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                  textStyle: const TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(context, '/terror');
                                                },
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('Conheça'),
                                                    SizedBox(width: 10),
                                                    Icon(Icons.arrow_circle_right_outlined, size: 24),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Image.asset(
                                            'assets/shadowdograu.png',
                                            height: 380,
                                            fit: BoxFit.contain,
                                            errorBuilder: (c, o, s) => const FlutterLogo(size: 220),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1200),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 48,
                                        onPressed: _handleLeftClick,
                                        icon: const Icon(Icons.arrow_back_ios),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 350,
                                          child: ListView.builder(
                                            controller: _carouselController,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: data.length,
                                            itemBuilder: (context, index) {
                                              final item = data[index];
                                              final isFocused = index == focusedIndex;
                                              return MouseRegion(
                                                onEnter: (_) => _handleMouseEnter(index),
                                                onExit: (_) => _handleMouseLeave(),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 180),
                                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                                  width: isFocused ? 280 : 240,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: isFocused ? 0.18 : 0.09),
                                                        blurRadius: isFocused ? 24 : 10,
                                                        spreadRadius: isFocused ? 5 : 2,
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: isFocused ? const Color(0xFF90017F) : Colors.transparent,
                                                      width: isFocused ? 2.4 : 1,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Image.asset(
                                                          item['imagem'] ?? '',
                                                          height: 120,
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (c, o, s) => const FlutterLogo(size: 100),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              item['name'] ?? '',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: isFocused ? 18 : 16,
                                                                color: const Color(0xFF90017F),
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 6),
                                                            Text(
                                                              item['descricao'] ?? '',
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                color: Colors.black87,
                                                              ),
                                                              maxLines: 3,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 10),
                                                            GestureDetector(
                                                              onTap: () {
                                                                String route = '/descricao';
                                                                if (item['id'] == 2) {
                                                                  route = '/descricao2';
                                                                } else if (item['id'] == 3) {
                                                                  route = '/descricao3';
                                                                }
                                                                Navigator.pushNamed(context, route);
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFF007BFF),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: const Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text(
                                                                      'Veja Mais',
                                                                      style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 8),
                                                                    Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 20),
                                                                  ],
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
                                            },
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 48,
                                        onPressed: _handleRightClick,
                                        icon: const Icon(Icons.arrow_forward_ios),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                                                color: Colors.black.withValues(alpha: 0.3),
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
                                                color: Colors.black.withValues(alpha: 0.2),
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
                                          color: Colors.white.withValues(alpha: 0.9),
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
}