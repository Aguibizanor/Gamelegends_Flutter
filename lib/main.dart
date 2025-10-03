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
import 'essasemana.dart' as essa_semana;
import 'essemes.dart';
import 'hoje.dart';
import 'macOs.dart';
import 'iOs.dart';
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
import 'footer_template.dart';
 
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
        '/iOS': (context) => IOsPage(),
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
  int _mobileCurrentPage = 0;
  PageController? _pageController;
  Map<String, String> formData = {
    'email': "",
    'usuario': ""
  };
 
  @override
  void initState() {
    super.initState();
    _loadCarouselData();
    _loadUser();
    _pageController = PageController(viewportFraction: 0.91, initialPage: _mobileCurrentPage);
  }
 
  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
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
 
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isMobile = MediaQuery.of(context).size.width < 600;
 
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
                  color: const Color(0xFFE6D7FF),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                              color: const Color(0xFFE6D7FF),
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
                            // ----------- CARROSSEL RESPONSIVO -------------
                            Container(
                              color: const Color(0xFFE6D7FF),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1200),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 48,
                                              onPressed: isMobile
                                                  ? (_mobileCurrentPage > 0
                                                      ? () {
                                                          _pageController?.previousPage(
                                                            duration: const Duration(milliseconds: 350),
                                                            curve: Curves.ease,
                                                          );
                                                        }
                                                      : null)
                                                  : _handleLeftClick,
                                              icon: const Icon(Icons.arrow_back_ios),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 350,
                                                child: isMobile
                                                    ? PageView.builder(
                                                        controller: _pageController,
                                                        itemCount: data.length,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            _mobileCurrentPage = index;
                                                          });
                                                        },
                                                        itemBuilder: (context, index) {
                                                          final item = data[index];
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                                            child: _CarouselCard(item: item, onTap: () {
                                                              String route = '/descricao';
                                                              if (item['id'] == 2) route = '/descricao2';
                                                              else if (item['id'] == 3) route = '/descricao3';
                                                              Navigator.pushNamed(context, route);
                                                            }),
                                                          );
                                                        },
                                                      )
                                                    : ListView.builder(
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
                                                              child: _CarouselCard(item: item, onTap: () {
                                                                String route = '/descricao';
                                                                if (item['id'] == 2) route = '/descricao2';
                                                                else if (item['id'] == 3) route = '/descricao3';
                                                                Navigator.pushNamed(context, route);
                                                              }),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ),
                                            IconButton(
                                              iconSize: 48,
                                              onPressed: isMobile
                                                  ? (_mobileCurrentPage < data.length - 1
                                                      ? () {
                                                          _pageController?.nextPage(
                                                            duration: const Duration(milliseconds: 350),
                                                            curve: Curves.ease,
                                                          );
                                                        }
                                                      : null)
                                                  : _handleRightClick,
                                              icon: const Icon(Icons.arrow_forward_ios),
                                            ),
                                          ],
                                        ),
                                        if (isMobile)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(
                                                data.length,
                                                (index) => Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                                  child: CircleAvatar(
                                                    radius: 5,
                                                    backgroundColor: _mobileCurrentPage == index
                                                        ? const Color(0xFF90017F)
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // ----------- FIM CARROSSEL -------------------------
                            const FooterTemplate(),
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
 
class _CarouselCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
 
  const _CarouselCard({required this.item, required this.onTap, Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF90017F),
            width: 1.5,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF90017F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['descricao'] ?? '',
                    style: const TextStyle(
                      fontSize: 13, // Aumentado de 11 para 13
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onTap,
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
  }
}