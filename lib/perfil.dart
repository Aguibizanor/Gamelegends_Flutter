import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// O model Java possui: id, nome, sobrenome, cpf, datanascimento, email, senha, telefone, usuario

class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({Key? key}) : super(key: key);

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  Map<String, dynamic> formData = {
    "id": null,
    "nome": "",
    "sobrenome": "",
    "cpf": "",
    "datanascimento": "",
    "email": "",
    "telefone": "",
    "usuario": "",
    "senha": ""
  };
  bool loading = true;
  bool modalVisible = false;
  bool menuAberto = false;

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  // PEGAR ID DO CLIENTE LOGADO
  Future<int?> getClienteId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('clienteId');
  }

  // API: USAR /cadastro/{id} e /cadastro
  Future<Map<String, dynamic>?> getUsuarioBanco(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:8080/cadastro/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> updateUsuarioBanco(Map<String, dynamic> usuario) async {
    await http.put(
      Uri.parse('http://localhost:8080/cadastro/${usuario["id"]}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario),
    );
  }

  Future<void> deleteUsuarioBanco(int id) async {
    await http.delete(
      Uri.parse('http://localhost:8080/cadastro/$id'),
    );
  }

  // CARREGAR PERFIL LOGADO
  Future<void> _loadPerfil() async {
    try {
      final id = await getClienteId();
      if (id == null) {
        setState(() { loading = false; });
        if (mounted) Navigator.pushReplacementNamed(context, '/Login');
        return;
      }
      final usuarioData = await getUsuarioBanco(id);
      if (usuarioData != null) {
        setState(() {
          formData = {
            "id": usuarioData["id"],
            "nome": usuarioData["nome"] ?? "",
            "sobrenome": usuarioData["sobrenome"] ?? "",
            "cpf": usuarioData["cpf"] ?? "",
            "datanascimento": usuarioData["datanascimento"] ?? usuarioData["dataNascimento"] ?? "",
            "email": usuarioData["email"] ?? "",
            "telefone": usuarioData["telefone"] ?? "",
            "usuario": usuarioData["usuario"] ?? "",
            "senha": usuarioData["senha"] ?? "",
          };
          loading = false;
        });
      } else {
        setState(() { loading = false; });
        if (mounted) Navigator.pushReplacementNamed(context, '/Login');
      }
    } catch (e) {
      setState(() { loading = false; });
      if (mounted) Navigator.pushReplacementNamed(context, '/Login');
    }
  }

  Future<void> _handleDelete() async {
    final idUsuario = formData["id"];
    if (idUsuario == null) {
      _showDialog("Erro: ID do usuário não encontrado.");
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja excluir seu perfil?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Excluir")),
        ],
      ),
    );
    if (result == true) {
      await deleteUsuarioBanco(idUsuario);
      _showDialog("Perfil deletado com sucesso!", onClose: () {
        Navigator.pushReplacementNamed(context, '/Login');
      });
    }
  }

  void _handleEdit() {
    setState(() {
      modalVisible = true;
    });
  }

  Future<void> _handleSave(Map<String, dynamic> updatedData) async {
    final newUser = {
      ...formData,
      ...updatedData,
    };
    await updateUsuarioBanco(newUser);
    setState(() {
      formData = newUser;
      modalVisible = false;
    });
    _showDialog("Perfil atualizado com sucesso!");
  }

  void _toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
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
    final logo = 'assets/logo.site.tcc.png';
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF90017F),
        elevation: 0,
        title: Image.asset(logo, height: 38),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _toggleMenu,
          ),
        ],
      ),
      drawer: Drawer(
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
              onTap: () => Navigator.pushReplacementNamed(context, '/Index'),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Games'),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Sobre'),
              onTap: () => Navigator.pushReplacementNamed(context, '/Que'),
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Suporte'),
              onTap: () => Navigator.pushReplacementNamed(context, '/Suporte'),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        formData["usuario"] != null && formData["usuario"] != ""
                            ? TextButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/Perfil?tipo=${formData["usuario"]}'),
                                icon: const Icon(Icons.account_circle),
                                label: Text("Perfil (${formData["usuario"]})"),
                              )
                            : Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/Login'),
                                    child: const Text("Login"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/Cadastro'),
                                    child: const Text("Registre-se"),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  // Perfil Info
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 0),
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
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF90017F),
                              child: const Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                            const SizedBox(height: 24),
                            PerfilInfo(formData: formData),
                            const SizedBox(height: 22),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90017F)),
                              onPressed: _handleEdit,
                              child: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
                            ),
                            if (formData["usuario"] == "Desenvolvedor")
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/Criar'),
                                  child: const Text("+ Criar Novo Jogo"),
                                ),
                              ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: _handleDelete,
                              child: const Text("Excluir Perfil", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Modal
                  if (modalVisible)
                    PerfilModal(
                      formData: formData,
                      onClose: () => setState(() => modalVisible = false),
                      onSave: _handleSave,
                    ),
                  // Footer
                  Container(
                    color: const Color(0xFF90017F),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
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
                                fontSize: 26,
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
                        "© 2025 Game Legends. Todos os direitos reservados.",
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          const TextSpan(text: "ID: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["id"]?.toString() ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Nome: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["nome"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Sobrenome: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["sobrenome"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "CPF: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["cpf"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Data de Nascimento: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: dataNasc),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Email: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["email"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Telefone: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["telefone"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Tipo de Usuário: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["usuario"] ?? ""),
        ])),
        Text.rich(TextSpan(children: [
          const TextSpan(text: "Senha: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: formData["senha"] ?? ""),
        ])),
      ],
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
  late TextEditingController idCtrl;
  late TextEditingController nomeCtrl;
  late TextEditingController sobrenomeCtrl;
  late TextEditingController cpfCtrl;
  late TextEditingController dataNascCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefoneCtrl;
  late TextEditingController usuarioCtrl;
  late TextEditingController senhaCtrl;

  @override
  void initState() {
    super.initState();
    idCtrl = TextEditingController(text: widget.formData["id"]?.toString() ?? "");
    nomeCtrl = TextEditingController(text: widget.formData["nome"]);
    sobrenomeCtrl = TextEditingController(text: widget.formData["sobrenome"]);
    cpfCtrl = TextEditingController(text: widget.formData["cpf"]);
    dataNascCtrl = TextEditingController(text: widget.formData["datanascimento"] ?? "");
    emailCtrl = TextEditingController(text: widget.formData["email"]);
    telefoneCtrl = TextEditingController(text: widget.formData["telefone"]);
    usuarioCtrl = TextEditingController(text: widget.formData["usuario"]);
    senhaCtrl = TextEditingController(text: widget.formData["senha"]);
  }

  @override
  void dispose() {
    idCtrl.dispose();
    nomeCtrl.dispose();
    sobrenomeCtrl.dispose();
    cpfCtrl.dispose();
    dataNascCtrl.dispose();
    emailCtrl.dispose();
    telefoneCtrl.dispose();
    usuarioCtrl.dispose();
    senhaCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final idText = idCtrl.text.trim();
    final dataNascimento = dataNascCtrl.text.trim();
    if (idText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("O campo ID é obrigatório."),
      ));
      return;
    }
    try {
      if (dataNascimento.isEmpty) throw "A data de nascimento é obrigatória";
      DateFormat('yyyy-MM-dd').parseStrict(dataNascimento);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("A data de nascimento é obrigatória e deve estar no formato AAAA-MM-DD."),
      ));
      return;
    }
    widget.onSave({
      "id": int.tryParse(idText) ?? idText,
      "nome": nomeCtrl.text,
      "sobrenome": sobrenomeCtrl.text,
      "cpf": cpfCtrl.text,
      "datanascimento": dataNascCtrl.text,
      "email": emailCtrl.text,
      "telefone": telefoneCtrl.text,
      "usuario": usuarioCtrl.text,
      "senha": senhaCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Modal overlay
        Positioned.fill(
          child: Container(
            color: Colors.black54,
          ),
        ),
        Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Editar Perfil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 16),
                  _inputField("ID", idCtrl, keyboardType: TextInputType.number, enabled: false),
                  _inputField("Nome", nomeCtrl),
                  _inputField("Sobrenome", sobrenomeCtrl),
                  _inputField("CPF", cpfCtrl),
                  _dateField("Data de Nascimento", dataNascCtrl),
                  _inputField("Email", emailCtrl, keyboardType: TextInputType.emailAddress),
                  _inputField("Telefone", telefoneCtrl),
                  _inputField("Tipo de Usuário", usuarioCtrl),
                  _inputField("Senha", senhaCtrl, obscureText: true),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90017F)),
                        onPressed: _handleSubmit,
                        child: const Text("Salvar", style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: widget.onClose,
                        child: const Text("Cancelar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {TextInputType keyboardType = TextInputType.text, bool enabled = true, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
      ),
    );
  }

  Widget _dateField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
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