import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';
 
Future<Map<String, dynamic>?> getUsuarioLogado() async {
  final prefs = await SharedPreferences.getInstance();
  final usuarioStr = prefs.getString('usuario');
  if (usuarioStr == null) return null;
  try {
    final usuarioMap = jsonDecode(usuarioStr) as Map<String, dynamic>;
    return usuarioMap;
  } catch (e) {
    return {"nome": usuarioStr};
  }
}
 
class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({Key? key}) : super(key: key);
 
  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}
 
class _PaginaPerfilState extends State<PaginaPerfil> {
  Map<String, dynamic> formData = {
    "nome": "",
    "sobrenome": "",
    "cpf": "",
    "datanascimento": "",
    "email": "",
    "senha": "",
    "telefone": "",
    "foto": "assets/foto.png",
  };
  bool loading = true;
  bool modalVisible = false;
  bool menuAberto = false;
  final TextEditingController _searchController = TextEditingController();
 
  final List<String> _fotosExemplo = [
    'assets/foto.png',
    'assets/gato1.png',
    'assets/gato2.png',
    'assets/gato3.png',
    'assets/mario.png',
    'assets/sonic.png',
  ];
 
  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }
 
  Future<void> _loadPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioStr = prefs.getString('usuario');
   
    if (usuarioStr == null) {
      setState(() => loading = false);
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
   
    try {
      final usuarioData = jsonDecode(usuarioStr) as Map<String, dynamic>;
      setState(() {
        formData = {
          "nome": usuarioData["nome"] ?? "",
          "sobrenome": usuarioData["sobrenome"] ?? "",
          "cpf": usuarioData["cpf"] ?? "",
          "datanascimento": usuarioData["datanascimento"] ?? usuarioData["dataNascimento"] ?? "",
          "email": usuarioData["email"] ?? "",
          "senha": usuarioData["senha"] ?? "",
          "telefone": usuarioData["telefone"] ?? "",
          "foto": usuarioData["foto"] ?? "assets/foto.png",
        };
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }
 
  Future<void> _selecionarFotoComputador() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleção de arquivos não disponível. Use as fotos de exemplo.')),
    );
  }
 
  Future<void> _salvarFoto(String caminhoFoto) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioData = {...formData, "foto": caminhoFoto};
    setState(() {
      formData = usuarioData;
    });
    await prefs.setString('usuario', jsonEncode(usuarioData));
    _showDialog("Foto alterada com sucesso!");
  }
 
  void _mostrarSeletorFoto() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Escolher Foto de Perfil"),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFF90017F)),
                title: const Text("Escolher dos Arquivos do Computador"),
                onTap: () {
                  Navigator.pop(ctx);
                  _selecionarFotoComputador();
                },
              ),
              const Divider(),
              const Text("Ou escolha uma das fotos de exemplo:"),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _fotosExemplo.length,
                  itemBuilder: (context, index) {
                    final foto = _fotosExemplo[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _salvarFoto(foto);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: formData["foto"] == foto ? const Color(0xFF90017F) : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(foto),
                          onBackgroundImageError: (exception, stackTrace) {},
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }
 
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }
 
  void _handleEdit() {
    setState(() {
      modalVisible = true;
    });
  }
 
  Future<void> _handleSave(Map<String, dynamic> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usuarioData = {...formData, ...updatedData};
    setState(() {
      formData = usuarioData;
      modalVisible = false;
    });
    await prefs.setString('usuario', jsonEncode(usuarioData));
    _showDialog("Perfil atualizado com sucesso!");
  }
 
  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    _showDialog("Logout realizado com sucesso!", onClose: () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }
 
  Future<void> _handleDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Perfil"),
        content: const Text("Tem certeza que deseja excluir seu perfil? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('usuario');
              _showDialog("Perfil excluído com sucesso!", onClose: () {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
 
  void _toggleMenu() {
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
            color: colors.first.withOpacity( 0.4),
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
    _searchController.dispose();
    super.dispose();
  }
 
  void _showDialog(String msg, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onClose != null) onClose();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: Navbar(
        onMenuTap: _toggleMenu,
        isMenuOpen: menuAberto,
        searchController: _searchController,
      ),
      body: Stack(
        children: [
          loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                        child: Center(
                          child: Container(
                            width: 520,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFF90017F), const Color(0xFF90017F).withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.white,
                                              backgroundImage: _getImageProvider(formData["foto"] ?? 'assets/foto.png'),
                                              onBackgroundImageError: (exception, stackTrace) {},
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: _mostrarSeletorFoto,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: const Color(0xFF90017F), width: 2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Color(0xFF90017F),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "${formData["nome"] ?? ""} ${formData["sobrenome"] ?? ""}".trim(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.email, color: Colors.white, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              formData["email"] ?? "",
                                              style: const TextStyle(color: Colors.white, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      PerfilInfo(formData: formData),
                                      const SizedBox(height: 32),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF90017F),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 3,
                                              ),
                                              onPressed: _handleEdit,
                                              icon: const Icon(Icons.edit, color: Colors.white),
                                              label: const Text("Editar Perfil", style: TextStyle(color: Colors.white, fontSize: 16)),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 3,
                                              ),
                                              onPressed: () => Navigator.pushNamed(context, '/cartoes'),
                                              icon: const Icon(Icons.credit_card, color: Colors.white),
                                              label: const Text("Meus Cartões", style: TextStyle(color: Colors.white, fontSize: 16)),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.orange,
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  onPressed: _handleLogout,
                                                  icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                                                  label: const Text("Logout", style: TextStyle(color: Colors.white)),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  onPressed: _handleDelete,
                                                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                                                  label: const Text("Excluir", style: TextStyle(color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
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
                                // Logo com efeito brilhante
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
                                
                                // Descrição com sombra colorida
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
                                          color: Colors.black.withOpacity( 0.3),
                                          offset: const Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 35),
                                
                                // Informações de contato com círculos coloridos
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
                                
                                // Redes sociais com círculos animados
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
                                      Icons.camera_alt,
                                      [Color(0xFFB19CD9), Color(0xFFD1C4E9)],
                                      () {},
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
                                      () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                
                                // Link de privacidade estilizado
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
                                          color: Colors.black.withOpacity( 0.2),
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
                                
                                // Copyright com emojis
                                Text(
                                  "© Game Legends ✨ | Feito com 💜 pelo nosso time incrível!",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity( 0.9),
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
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
          if (modalVisible)
            PerfilModal(
              formData: formData,
              onClose: () => setState(() => modalVisible = false),
              onSave: _handleSave,
            ),
        ],
      ),
    );
  }
}
 
class PerfilInfo extends StatelessWidget {
  final Map<String, dynamic> formData;
  const PerfilInfo({required this.formData});
 
  @override
  Widget build(BuildContext context) {
    String dataNasc = "";
    if (formData["datanascimento"] != null && formData["datanascimento"] != "") {
      try {
        dataNasc = DateFormat('dd/MM/yyyy').format(DateTime.parse(formData["datanascimento"]));
      } catch (_) {
        dataNasc = formData["datanascimento"].toString();
      }
    }
   
    return Column(
      children: [
        _buildInfoCard(Icons.badge, "Nome Completo", "${formData["nome"] ?? ""} ${formData["sobrenome"] ?? ""}".trim()),
        _buildInfoCard(Icons.credit_card, "CPF", formData["cpf"] ?? ""),
        _buildInfoCard(Icons.cake, "Data de Nascimento", dataNasc),
        _buildInfoCard(Icons.phone, "Telefone", formData["telefone"] ?? ""),
        _buildInfoCard(Icons.lock, "Senha", "••••••••"),
        if (formData["usuario"] != null && formData["usuario"].toString().isNotEmpty)
          _buildInfoCard(Icons.account_circle, "Usuário", formData["usuario"] ?? ""),
      ],
    );
  }
 
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF90017F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF90017F), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Não informado" : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
class PerfilModal extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;
 
  const PerfilModal({
    required this.formData,
    required this.onClose,
    required this.onSave,
  });
 
  @override
  State<PerfilModal> createState() => _PerfilModalState();
}
 
class _PerfilModalState extends State<PerfilModal> {
  late TextEditingController nomeCtrl;
  late TextEditingController sobrenomeCtrl;
  late TextEditingController cpfCtrl;
  late TextEditingController dataNascCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController senhaCtrl;
  late TextEditingController telefoneCtrl;
 
  @override
  void initState() {
    super.initState();
    nomeCtrl = TextEditingController(text: widget.formData["nome"]);
    sobrenomeCtrl = TextEditingController(text: widget.formData["sobrenome"]);
    cpfCtrl = TextEditingController(text: widget.formData["cpf"]);
    dataNascCtrl = TextEditingController(text: widget.formData["datanascimento"] ?? "");
    emailCtrl = TextEditingController(text: widget.formData["email"]);
    senhaCtrl = TextEditingController(text: widget.formData["senha"]);
    telefoneCtrl = TextEditingController(text: widget.formData["telefone"]);
  }
 
  @override
  void dispose() {
    nomeCtrl.dispose();
    sobrenomeCtrl.dispose();
    cpfCtrl.dispose();
    dataNascCtrl.dispose();
    emailCtrl.dispose();
    senhaCtrl.dispose();
    telefoneCtrl.dispose();
    super.dispose();
  }
 
  void _handleSubmit() {
    final dataNascimento = dataNascCtrl.text.trim();
    if (dataNascimento.isEmpty || DateTime.tryParse(dataNascimento) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("A data de nascimento é obrigatória e deve estar no formato AAAA-MM-DD."),
      ));
      return;
    }
    widget.onSave({
      "nome": nomeCtrl.text,
      "sobrenome": sobrenomeCtrl.text,
      "cpf": cpfCtrl.text,
      "datanascimento": dataNascCtrl.text,
      "email": emailCtrl.text,
      "senha": senhaCtrl.text,
      "telefone": telefoneCtrl.text,
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black54,
          ),
        ),
        Center(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF90017F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        "Editar Perfil",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _inputField("Nome", nomeCtrl, Icons.person),
                        _inputField("Sobrenome", sobrenomeCtrl, Icons.person_outline),
                        _inputField("CPF", cpfCtrl, Icons.credit_card),
                        _dateField("Data de Nascimento", dataNascCtrl),
                        _inputField("Email", emailCtrl, Icons.email, keyboardType: TextInputType.emailAddress),
                        _inputField("Senha", senhaCtrl, Icons.lock, obscureText: true),
                        _inputField("Telefone", telefoneCtrl, Icons.phone),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF90017F),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: _handleSubmit,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text("Salvar Alterações", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
 
  Widget _inputField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF90017F)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF90017F), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
      ),
    );
  }
 
  Widget _dateField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.cake, color: Color(0xFF90017F)),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF90017F)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF90017F), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: "AAAA-MM-DD",
        ),
        keyboardType: TextInputType.datetime,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: ctrl.text.isNotEmpty
                ? DateTime.tryParse(ctrl.text) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            helpText: label,
          );
          if (picked != null) {
            ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
            setState(() {});
          }
        },
      ),
    );
  }
}
 
