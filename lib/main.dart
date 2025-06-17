import 'package:flutter/material.dart';
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
import 'essaSemana.dart';
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
        '/essaSemana': (context) => EssasemanaPage(),
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
        // Exemplo extra:
        // '/descricao': (context) => const TelaDescricao(),
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
    'usuario': "" // "Cliente" ou "Desenvolvedor"
  };

  @override
  void initState() {
    super.initState();
    _loadCarouselData();
    _loadUser();
  }

  Future<void> _loadCarouselData() async {
    // Dados dos jogos integrados conforme solicitado, com caminhos corretos!
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
          "name": "Coop  Catacombs: Roguelike",
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: Navbar(
        isMenuOpen: menuAberto,
        onMenuTap: () => setState(() => menuAberto = !menuAberto),
        searchController: _searchController,
      ),
      backgroundColor: const Color(0xFFE9E9E9),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // Intro Section
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
                              // Texto Intro
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EXPLORE O \nMUNDO\nDOS JOGOS',
                                        style: TextStyle(
                                          fontSize: 46,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF90017F),
                                          height: 1.05,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      const Text(
                                        'Venha conhecer \nnossa plataforma \nonde você poderá\nencontrar jogos\nda nossa comunidade.',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black87,
                                          height: 1.3,
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
                                          Navigator.pushNamed(context, '/');
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
                              // Imagem
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
                    // Carrossel Section
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
                                icon: Image.asset('assets/left.png', height: 40),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 320,
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                                                  color: Colors.black.withOpacity(isFocused ? 0.18 : 0.09),
                                                  blurRadius: isFocused ? 24 : 10,
                                                  spreadRadius: isFocused ? 5 : 2,
                                                ),
                                              ],
                                              border: Border.all(
                                                color: isFocused
                                                    ? const Color(0xFF90017F)
                                                    : Colors.transparent,
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
                                                    errorBuilder: (c, o, s) =>
                                                        const FlutterLogo(size: 100),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      AnimatedDefaultTextStyle(
                                                        duration: const Duration(milliseconds: 180),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: isFocused ? 20 : 18,
                                                          color: const Color(0xFF90017F),
                                                        ),
                                                        child: Text(item['name'] ?? ''),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      AnimatedDefaultTextStyle(
                                                        duration: const Duration(milliseconds: 180),
                                                        style: TextStyle(
                                                          fontSize: isFocused ? 12 : 12,
                                                          color: Colors.black87,
                                                        ),
                                                        child: Text(item['descricao'] ?? ''),
                                                      ),
 
                                                      const SizedBox(height: 10),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.pushNamed(context, '/descricao');
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 16, vertical: 6),
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
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                              SizedBox(width: 8),
                                                              Icon(Icons.arrow_circle_right_outlined,
                                                                  color: Colors.white, size: 20),
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
                              ),
                              IconButton(
                                iconSize: 48,
                                onPressed: _handleRightClick,
                                icon: Image.asset('assets/right.png', height: 40),
                              ),
                            ],
                          ),
                        ),
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
                          child: Column(
                            children: [
                              const Text(
                                "GameLegends",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
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