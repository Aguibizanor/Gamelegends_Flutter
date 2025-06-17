import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

        await salvarUsuarioLogado(
          nome: responseMap['nome'] ?? '',
          tipo: responseMap['tipo'] ?? '',
        );

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
                child: SingleChildScrollView(
                  child: Container(
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
                                                    fontSize: 16),
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
                ),
              ),
              // Rodapé igual ao seu
              Container(
                color: Color(0xFF90017F),
                padding: EdgeInsets.symmetric(vertical: 28, horizontal: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Game",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: "Legends",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Color(0xFF05B7E7)),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text("(99) 99999-9999", style: TextStyle(color: Colors.white)),
                                  SizedBox(width: 14),
                                  Icon(Icons.email, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text("info@gamelegends.com", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.facebook, color: Colors.white),
                                  SizedBox(width: 8),
                                  Icon(Icons.camera, color: Colors.white),
                                  SizedBox(width: 8),
                                  Icon(Icons.alternate_email, color: Colors.white),
                                  SizedBox(width: 8),
                                  Icon(Icons.linked_camera, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Links Rápidos",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              SizedBox(height: 8),
                              Text("Eventos", style: TextStyle(color: Colors.white)),
                              Text("Equipe", style: TextStyle(color: Colors.white)),
                              Text("Missão", style: TextStyle(color: Colors.white)),
                              Text("Serviços", style: TextStyle(color: Colors.white)),
                              Text("Afiliados", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.white54),
                    SizedBox(height: 8),
                    Text(
                      "© gamelegends.com | Feito pelo time do Game Legends",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
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