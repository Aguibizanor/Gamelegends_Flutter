import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'redefinir_senha_service.dart';
import 'navbar.dart';
 
class PaginaCodin extends StatefulWidget {
  const PaginaCodin({Key? key}) : super(key: key);
 
  @override
  State<PaginaCodin> createState() => _PaginaCodinState();
}
 
class _PaginaCodinState extends State<PaginaCodin> {
  bool menuAberto = false;
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final _searchController = TextEditingController();
 
  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }
 
  void toggleMenu() => setState(() => menuAberto = !menuAberto);
  void closeMenu() => setState(() => menuAberto = false);
 
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
 
  void _gerarNovoCodigo() async {
    if (RedefinirSenhaService.emailAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Email não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
 
    try {
      await RedefinirSenhaService.enviarCodigo(RedefinirSenhaService.emailAtual!);
      Navigator.pop(context);
     
      // Limpar campos
      for (var controller in _codeControllers) {
        controller.clear();
      }
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Novo código gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao gerar novo código: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 
  void _confirmar() async {
    String codigo = _codeControllers.map((c) => c.text).join();
   
    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Digite o código completo de 6 dígitos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
   
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
   
    try {
      bool valido = await RedefinirSenhaService.verificarCodigo(codigo);
     
      Navigator.pop(context); // Fechar loading
     
      if (valido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Código verificado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(context, '/redefinir');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Código inválido ou expirado'),
            backgroundColor: Colors.red,
          ),
        );
        // Limpar campos
        for (var controller in _codeControllers) {
          controller.clear();
        }
      }
    } catch (e) {
      Navigator.pop(context); // Fechar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
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
                child: Container(
                  color: const Color(0xFFE6D7FF),
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 8),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 700),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (MediaQuery.of(context).size.width > 700)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Image.asset(
                                      'assets/sonic.png',
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Verificar Código",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [
                                                Color(0xFF90017F),
                                                Color(0xFF05B7E7)
                                              ],
                                            ).createShader(
                                              Rect.fromLTWH(0, 0, 200, 70)),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Column(
                                        children: [
                                          Text(
                                            'Digite o código de 6 dígitos:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: RedefinirSenhaService.isEmailReal
                                                ? Colors.green.shade50
                                                : Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: RedefinirSenhaService.isEmailReal
                                                  ? Colors.green.shade200
                                                  : Colors.blue.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  RedefinirSenhaService.isEmailReal
                                                    ? Icons.email
                                                    : Icons.storage,
                                                  color: RedefinirSenhaService.isEmailReal
                                                    ? Colors.green
                                                    : Colors.blue,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    RedefinirSenhaService.isEmailReal
                                                      ? 'Verifique sua caixa de entrada: ${RedefinirSenhaService.emailAtual}'
                                                      : 'Código salvo no banco para: ${RedefinirSenhaService.emailAtual}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: RedefinirSenhaService.isEmailReal
                                                        ? Colors.green.shade700
                                                        : Colors.blue.shade700,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 32),
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF90017F).withOpacity(0.05),
                                              Color(0xFF05B7E7).withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Color(0xFF90017F).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Código de Verificação',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF90017F),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(6, (i) {
                                                return Container(
                                                  width: 35,
                                                  height: 45,
                                                  margin: EdgeInsets.symmetric(horizontal: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xFF90017F).withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    controller: _codeControllers[i],
                                                    maxLength: 1,
                                                    textAlign: TextAlign.center,
                                                    keyboardType: TextInputType.number,
                                                    style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF90017F),
                                                    ),
                                                    decoration: InputDecoration(
                                                      counterText: '',
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFF90017F).withOpacity(0.3),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: BorderSide(
                                                          color: Color(0xFF90017F).withOpacity(0.3),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(
                                                          color: Color(0xFF90017F),
                                                          width: 2.5,
                                                        ),
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                                    ),
                                                    onChanged: (value) {
                                                      if (value.length == 1 && i < 5) {
                                                        FocusScope.of(context).nextFocus();
                                                      }
                                                      if (value.isEmpty && i > 0) {
                                                        FocusScope.of(context).previousFocus();
                                                      }
                                                    },
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _confirmar,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF90017F),
                                            padding: EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                          ),
                                          child: Text(
                                            "VERIFICAR CÓDIGO",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pushNamed(context, '/mandaremail'),
                                            child: Text(
                                              "← Voltar",
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _gerarNovoCodigo,
                                            child: Text(
                                              "Gerar novo código",
                                              style: TextStyle(color: Colors.orange),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (MediaQuery.of(context).size.width > 700)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Image.asset(
                                      'assets/sonic.png',
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                                        color: Colors.black.withOpacity(0.3),
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
                                    () => launchUrl(Uri.parse('https://www.reddit.com/r/Game_Legends_jogos/s/GZVUlKiWg8')),
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
              ),
            ],
          ),
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: closeMenu,
              searchController: _searchController,
            ),
        ],
      ),
    );
  }
}
 
