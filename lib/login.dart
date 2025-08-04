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
      final response = await http.post(
        Uri.parse("http://localhost:8080/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      if (response.statusCode == 200) {
        final responseMap = jsonDecode(response.body);

        // Salvar dados completos do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final tipoUsuario = responseMap['usuario'] ?? 'Cliente';
        print('Tipo de usuário do backend: $tipoUsuario');
        
        final dadosUsuario = {
          "id": responseMap['id'],
          "nome": responseMap['nome'] ?? '',
          "sobrenome": responseMap['sobrenome'] ?? '',
          "cpf": responseMap['cpf'] ?? '',
          "datanascimento": responseMap['datanascimento'] ?? responseMap['dataNascimento'] ?? '',
          "email": responseMap['email'] ?? email,
          "senha": responseMap['senha'] ?? '',
          "telefone": responseMap['telefone'] ?? '',
          "tipo": tipoUsuario,
        };
        
        print('Dados salvos no SharedPreferences: $dadosUsuario');
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



  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    _searchController.dispose();
    super.dispose();
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
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF90017F),
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Wrap(
                            runSpacing: 24,
                            spacing: 50,
                            children: [
                              SizedBox(
                                width: 350,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
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
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: const [
                                        Icon(Icons.phone, color: Colors.white70, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          "(99) 99999-9999",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        SizedBox(width: 18),
                                        Icon(Icons.email, color: Colors.white70, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          "info@gamelegends.com",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.facebook, color: Colors.white),
                                          onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=61578797307500')),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.alternate_email, color: Colors.white),
                                          onPressed: () => launchUrl(Uri.parse('https://www.instagram.com/game._legends/')),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.business, color: Colors.white),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    InkWell(
                                      onTap: () => Navigator.pushNamed(context, '/privacidade'),
                                      child: const Text(
                                        "Conheça nossa política de privacidade",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF90017F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Text(
                          "© gamelegends.com | Feito pelo time do Game Legends",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
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