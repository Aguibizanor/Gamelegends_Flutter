import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class PaginaMandarEmail extends StatefulWidget {
  const PaginaMandarEmail({Key? key}) : super(key: key);

  @override
  State<PaginaMandarEmail> createState() => _PaginaMandarEmailState();
}

class _PaginaMandarEmailState extends State<PaginaMandarEmail> {
  bool menuAberto = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _mandarEmail() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/codin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = 'assets/logo.site.tcc.png';
    final viva = 'assets/viva.png';

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF90017F),
        elevation: 0,
        title: Image.asset(logo, height: 38),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: toggleMenu,
          ),
        ],
      ),
      drawer: menuAberto
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF90017F),
                    ),
                    child: Image.asset(logo),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Início'),
                    onTap: () => Navigator.pushNamed(context, '/'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.videogame_asset),
                    title: const Text('Games'),
                    onTap: () => Navigator.pushNamed(context, '/index'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Sobre'),
                    onTap: () => Navigator.pushNamed(context, '/que'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.headset_mic),
                    title: const Text('Suporte'),
                    onTap: () => Navigator.pushNamed(context, '/suporte'),
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar + user panel
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        hintText: "Pesquisar Jogos, Tags ou Criadores",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Login"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    child: const Text("Registre-se"),
                  ),
                ],
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              child: Center(
                child: Container(
                  width: 480,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    children: [
                      const Text(
                        'Redefinir Senha',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF90017F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Para redefinir sua senha, coloque seu Email:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(viva, height: 60),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Digite o email';
                                      }
                                      if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
                                        return 'Email inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF90017F),
                                      ),
                                      onPressed: _mandarEmail,
                                      child: const Text('MANDE EMAIL', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Lembrou a senha? '),
                                      InkWell(
                                        onTap: () => Navigator.pushNamed(context, '/login'),
                                        child: const Text(
                                          'Faça login',
                                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Image.asset(viva, height: 60),
                        ],
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
                  child: Wrap(
                    runSpacing: 24,
                    spacing: 50,
                    children: [
                      // Sobre
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
    );
  }
}