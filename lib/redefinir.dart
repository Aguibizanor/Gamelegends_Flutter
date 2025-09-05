import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'redefinir_senha_service.dart';
import 'navbar.dart';

class PaginaRedefinirSenha extends StatefulWidget {
  const PaginaRedefinirSenha({Key? key}) : super(key: key);

  @override
  State<PaginaRedefinirSenha> createState() => _PaginaRedefinirSenhaState();
}

class _PaginaRedefinirSenhaState extends State<PaginaRedefinirSenha> {
  bool menuAberto = false;
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _searchController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
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

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Validação adicional da senha
      if (_senhaController.text.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ A senha deve ter exatamente 6 caracteres'),
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
        bool sucesso = await RedefinirSenhaService.redefinirSenha(_senhaController.text);
        
        Navigator.pop(context); // Fechar loading
        
        if (sucesso) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text("Sucesso!"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Senha redefinida com sucesso!"),
                  SizedBox(height: 8),
                  Text(
                    RedefinirSenhaService.isEmailReal
                      ? "📧 Email real: ${RedefinirSenhaService.emailAtual}"
                      : "💾 Email cadastrado: ${RedefinirSenhaService.emailAtual}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("FAZER LOGIN"),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro ao redefinir senha'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao redefinir senha: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
                                      'assets/mario.png',
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
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Nova Senha",
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
                                        Text(
                                          'Agora você pode definir uma nova senha:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 24),
                                        TextFormField(
                                          controller: _senhaController,
                                          obscureText: _obscurePassword,
                                          maxLength: 6,
                                          decoration: InputDecoration(
                                            labelText: "Nova Senha",
                                            border: OutlineInputBorder(),
                                            hintText: "Digite sua nova senha",
                                            prefixIcon: Icon(Icons.lock),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                              ),
                                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Digite a nova senha';
                                            }
                                            if (value.length != 6) {
                                              return 'Senha deve ter exatamente 6 caracteres';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        TextFormField(
                                          controller: _confirmarSenhaController,
                                          obscureText: _obscureConfirmPassword,
                                          maxLength: 6,
                                          decoration: InputDecoration(
                                            labelText: "Confirmar Senha",
                                            border: OutlineInputBorder(),
                                            hintText: "Confirme sua nova senha",
                                            prefixIcon: Icon(Icons.lock_outline),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                              ),
                                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Confirme a senha';
                                            }
                                            if (value != _senhaController.text) {
                                              return 'As senhas não coincidem';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _onSubmit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF90017F),
                                              padding: EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                            ),
                                            child: Text(
                                              "REDEFINIR SENHA",
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
                                              onPressed: () => Navigator.pushNamed(context, '/codin'),
                                              child: Text(
                                                "← Voltar",
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pushNamed(context, '/login'),
                                              child: Text(
                                                "Fazer login",
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (MediaQuery.of(context).size.width > 700)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Image.asset(
                                      'assets/mario.png',
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
