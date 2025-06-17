import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Função para obter usuário logado do "banco" (SharedPreferences)
Future<Map<String, dynamic>?> getUsuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  final usuarioStr = prefs.getString('usuario');
  if (usuarioStr == null) return null;
  try {
    final usuarioMap = jsonDecode(usuarioStr) as Map<String, dynamic>;
    return usuarioMap;
  } catch (e) {
    // Caso seja só uma string antiga, retorna como tipo
    return {"tipo": usuarioStr};
  }
}

// Para simular cadastro/login (chame após login/cadastro com sucesso)
// Exemplo de uso: await salvarUsuarioLogado(nome: "João", tipo: "Cliente");
Future<void> salvarUsuarioLogado({required String nome, required String tipo}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('usuario', jsonEncode({"nome": nome, "tipo": tipo}));
}

// Para simular logout
Future<void> removerUsuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('usuario');
}

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final bool isMenuOpen;
  final TextEditingController searchController;

  const Navbar({
    Key? key,
    this.onMenuTap,
    this.isMenuOpen = false,
    required this.searchController,
  }) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _NavbarState extends State<Navbar> {
  Map<String, dynamic>? usuarioLogado;
  bool carregandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await getUsuarioLogado();
    if (mounted) {
      setState(() {
        usuarioLogado = usuario;
        carregandoUsuario = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Material(
      elevation: 6,
      color: const Color(0xFF90017F),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/'),
              child: SizedBox(
                height: 45,
                child: Image.asset(
                  'assets/logo.site.tcc.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            if (isWide)
              Expanded(
                child: Row(
                  children: [
                    _NavbarButton(
                      icon: Icons.home,
                      label: 'Início',
                      onTap: () => Navigator.pushNamed(context, '/'),
                    ),
                    _NavbarButton(
                      icon: Icons.videogame_asset,
                      label: 'Games',
                      onTap: () => Navigator.pushNamed(context, '/index'),
                    ),
                    _NavbarButton(
                      icon: Icons.help_outline,
                      label: 'Sobre',
                      onTap: () => Navigator.pushNamed(context, '/que'),
                    ),
                    _NavbarButton(
                      icon: Icons.headset_mic,
                      label: 'Suporte',
                      onTap: () => Navigator.pushNamed(context, '/suporte'),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: widget.searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar Jogos, Tags ou Criadores',
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Color(0xFF90017F)),
                            onPressed: () {},
                          ),
                        ),
                        onSubmitted: (q) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (carregandoUsuario)
                      const SizedBox(
                        width: 90,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      )
                    else if (usuarioLogado != null &&
                        (usuarioLogado!["nome"] != null || usuarioLogado!["tipo"] != null))
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/perfil'),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF780069),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          icon: const Icon(Icons.account_circle, color: Colors.white),
                          label: Text(
                            usuarioLogado!["nome"] != null
                              ? 'perfil (${usuarioLogado!["nome"]})'
                              : 'perfil',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF780069),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: const Text('Login', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF780069),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: const Text('Registre-se', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            if (!isWide)
              Row(
                children: [
                  IconButton(
                    icon: Icon(widget.isMenuOpen ? Icons.close : Icons.menu, color: Colors.white),
                    onPressed: widget.onMenuTap,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Use este widget no corpo do seu Scaffold para mostrar o menu mobile!
class NavbarMobileMenu extends StatefulWidget {
  final VoidCallback closeMenu;
  final TextEditingController searchController;

  const NavbarMobileMenu({
    Key? key,
    required this.closeMenu,
    required this.searchController,
  }) : super(key: key);

  @override
  State<NavbarMobileMenu> createState() => _NavbarMobileMenuState();
}

class _NavbarMobileMenuState extends State<NavbarMobileMenu> {
  Map<String, dynamic>? usuarioLogado;
  bool carregandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await getUsuarioLogado();
    if (mounted) {
      setState(() {
        usuarioLogado = usuario;
        carregandoUsuario = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 70,
      bottom: 0,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.closeMenu,
              child: Container(
                color: Colors.black26,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF90017F),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _NavbarMobileItem(
                        icon: Icons.home,
                        text: 'Início',
                        onTap: () {
                          widget.closeMenu();
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                      _NavbarMobileItem(
                        icon: Icons.videogame_asset,
                        text: 'Games',
                        onTap: () {
                          widget.closeMenu();
                          Navigator.pushNamed(context, '/index');
                        },
                      ),
                      _NavbarMobileItem(
                        icon: Icons.help_outline,
                        text: 'Sobre',
                        onTap: () {
                          widget.closeMenu();
                          Navigator.pushNamed(context, '/que');
                        },
                      ),
                      _NavbarMobileItem(
                        icon: Icons.headset_mic,
                        text: 'Suporte',
                        onTap: () {
                          widget.closeMenu();
                          Navigator.pushNamed(context, '/suporte');
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: TextField(
                          controller: widget.searchController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar Jogos, Tags ou Criadores',
                            hintStyle: const TextStyle(color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search, color: Color(0xFF90017F)),
                              onPressed: () {
                                // Implementar busca
                              },
                            ),
                          ),
                          onSubmitted: (q) {
                            // Implementar busca
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (carregandoUsuario)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                            )
                          else if (usuarioLogado != null &&
                              (usuarioLogado!["nome"] != null || usuarioLogado!["tipo"] != null))
                            TextButton.icon(
                              onPressed: () {
                                widget.closeMenu();
                                Navigator.pushNamed(context, '/perfil');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF780069),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              icon: const Icon(Icons.account_circle, color: Colors.white),
                              label: Text(
                                usuarioLogado!["nome"] != null
                                  ? 'Perfil (${usuarioLogado!["nome"]})'
                                  : 'Perfil',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          else
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    widget.closeMenu();
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF780069),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    widget.closeMenu();
                                    Navigator.pushNamed(context, '/cadastro');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF780069),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: const Text('Registre-se', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF780069),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavbarMobileItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _NavbarMobileItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF780069),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}