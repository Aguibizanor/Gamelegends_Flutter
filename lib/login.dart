import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';

class PaginaLogin extends StatefulWidget {
  @override
  _PaginaLoginState createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? errorMessage;
  String? successMessage;
  bool loading = false;
  bool menuAberto = false;

  void handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@(yahoo|gmail|email)\.com(\.br)?$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        errorMessage =
            "Formato de email inválido. Use um email válido como yahoo, gmail ou email.";
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      print('🔐 Tentando login com email: $email');
      final response = await http.post(
        Uri.parse("http://localhost:8080/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );
      
      print('📡 Status da resposta: ${response.statusCode}');
      print('📄 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final responseMap = jsonDecode(response.body);

        // Salvar dados completos do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        
        final dadosUsuario = {
          "id": responseMap['id'],
          "nome": responseMap['nome'] ?? '',
          "sobrenome": responseMap['sobrenome'] ?? '',
          "cpf": responseMap['cpf'] ?? '',
          "datanascimento": responseMap['datanascimento'] ?? '',
          "email": responseMap['email'] ?? email,
          "senha": responseMap['senha'] ?? '',
          "telefone": responseMap['telefone'] ?? '',
          "usuario": responseMap['usuario'] ?? 'Cliente',
        };
        
        await prefs.setString('usuario', jsonEncode(dadosUsuario));

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Sucesso"),
            content: Text("Login realizado com sucesso!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        );
      } else {
        setState(() {
          errorMessage = "Email ou senha incorretos.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Email ou senha incorretos.";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
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

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['showMessage'] == true) {
      emailController.text = args['email'] ?? '';
      senhaController.text = args['senha'] ?? '';
      successMessage = 'Email e senha salvos com sucesso!';
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
                                      'assets/stardew.png',
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
                                        "Login",
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
                                      SizedBox(height: 24),
                                      TextField(
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: "Email",
                                          border: OutlineInputBorder(),
                                          hintText: "Ex: exemplo@yahoo.com",
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: senhaController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: "Senha",
                                          border: OutlineInputBorder(),
                                          hintText: "Senha",
                                        ),
                                      ),
                                      if (successMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            successMessage!,
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      if (errorMessage != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(
                                            errorMessage!,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      SizedBox(height: 16),
                                      loading
                                          ? CircularProgressIndicator(
                                              color: Color(0xFF90017F),
                                            )
                                          : SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: loading
                                                    ? null
                                                    : () => handleLogin(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF90017F),
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                ),
                                                child: Text(
                                                  "LOGIN",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushNamed(context, '/cadastro'),
                                        child: Text(
                                          "Ainda não tem conta? Cadastre-se",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushNamed(context, '/mandaremail'),
                                        child: Text(
                                          "Esqueceu a senha? Redefinir senha",
                                          style: TextStyle(color: Colors.blue),
                                        ),
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
                                      'assets/stardew.png',
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
