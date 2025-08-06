import 'package:flutter/material.dart';

class PaginaRedefinirSenha extends StatefulWidget {
  const PaginaRedefinirSenha({Key? key}) : super(key: key);

  @override
  State<PaginaRedefinirSenha> createState() => _PaginaRedefinirSenhaState();
}

class _PaginaRedefinirSenhaState extends State<PaginaRedefinirSenha> {
  bool menuAberto = false;

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
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
    // Substitua pelos seus assets ou use AssetImage se estiver em assets
    final logo = 'assets/logo.site.tcc.png';
    final mario = 'assets/mario.png';
    final esquerda = 'assets/esquerda.png';

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
                  width: 600,
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
                        'Pronto! Agora coloque sua senha nova:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(mario, height: 60),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _RedefinirSenhaForm(),
                          ),
                          const SizedBox(width: 16),
                          Image.asset(mario, height: 60),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/codin'),
                          child: Image.asset(esquerda, height: 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Game",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "Legends"),
                            ],
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "🎮 Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências! 🚀",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.6,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
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
                            () {},
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
                            () {},
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
    );
  }
}

class _RedefinirSenhaForm extends StatefulWidget {
  @override
  State<_RedefinirSenhaForm> createState() => _RedefinirSenhaFormState();
}

class _RedefinirSenhaFormState extends State<_RedefinirSenhaForm> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Aqui você pode fazer a lógica de redefinição de senha
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Senha
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Senha:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextFormField(
            controller: _senhaController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Digite a senha' : null,
          ),
          const SizedBox(height: 12),
          // Confirme senha
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Confirme senha:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextFormField(
            controller: _confirmarSenhaController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirme a senha';
              if (value != _senhaController.text) return 'As senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90017F),
              ),
              onPressed: _onSubmit,
              child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
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
    );
  }
}