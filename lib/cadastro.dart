import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'navbar.dart';

class CadastroForm extends StatefulWidget {
  const CadastroForm({super.key});

  @override
  State<CadastroForm> createState() => _CadastroFormState();
}

class _CadastroFormState extends State<CadastroForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'nome': '',
    'sobrenome': '',
    'cpf': '',
    'dataNascimento': '',
    'email': '',
    'telefone': '',
    'senha': '',
    'confirmarSenha': '',
    'usuario': '',
  };
  final TextEditingController _searchController = TextEditingController();
  bool menuAberto = false;

  String _mensagem = '';

  void _handleChange(String key, String value) {
    setState(() {
      _formData[key] = value;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validação de idade mínima (16 anos)
      final hoje = DateTime.now();
      final nascimento = DateTime.tryParse(_formData['dataNascimento'] ?? '');
      if (nascimento != null) {
        int idade = hoje.year - nascimento.year;
        if (hoje.month < nascimento.month ||
            (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
          idade--;
        }
        if (idade < 16) {
          setState(() {
            _mensagem = 'Você deve ter pelo menos 16 anos para se cadastrar.';
          });
          return;
        }
      }

      // Validação das senhas
      if (_formData['senha'] != _formData['confirmarSenha']) {
        setState(() {
          _mensagem = 'As senhas não correspondem!';
        });
        return;
      }

      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@(yahoo|gmail|email)\.com(\.br)?$');
      if (!emailRegex.hasMatch(_formData['email'] ?? '')) {
        setState(() {
          _mensagem = "Formato de email inválido. Use um email válido como yahoo, gmail ou email.";
        });
        return;
      }

      final cadastroData = json.encode({
        ..._formData,
        'datanascimento': _formData['dataNascimento'],
      });

      final cadastroData = json.encode({
        ..._formData,
        'datanascimento': _formData['dataNascimento'],
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/cadastro'),
          headers: {'Content-Type': 'application/json'},
          body: cadastroData,
        );

        if (response.statusCode == 201) {
          setState(() {
            _mensagem = 'Cadastro realizado com sucesso!';
          });

          await salvarUsuarioLogado(
            nome: _formData['nome'] ?? '',
            tipo: _formData['usuario'] ?? '',
          );
        } else {
          final errorResponse = json.decode(response.body);
          setState(() {
            _mensagem = errorResponse['message'] ?? 'Erro no cadastro.';
          });
        }
      } catch (error) {
        setState(() {
          _mensagem = 'Erro ao se conectar ao servidor. Tente novamente.';
        });
      }
    }
  }

  void toggleMenu() => setState(() => menuAberto = !menuAberto);
  void closeMenu() => setState(() => menuAberto = false);

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
                    width: MediaQuery.of(context).size.width > 600 ? 500 : null,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'CRIAR CONTA',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF90017F),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            label: 'Nome',
                            onSaved: (value) => _handleChange('nome', value ?? ''),
                          ),
                          _buildTextFormField(
                            label: 'Sobrenome',
                            onSaved: (value) => _handleChange('sobrenome', value ?? ''),
                          ),
                          _buildTextFormField(
                            label: 'CPF',
                            onSaved: (value) => _handleChange('cpf', value ?? ''),
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                          ),
                          _buildTextFormField(
                            label: 'Data de Nascimento',
                            onSaved: (value) => _handleChange('dataNascimento', value ?? ''),
                            keyboardType: TextInputType.datetime,
                            isDate: true,
                          ),
                          _buildTextFormField(
                            label: 'Email',
                            onSaved: (value) => _handleChange('email', value ?? ''),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextFormField(
                            label: 'Telefone',
                            onSaved: (value) => _handleChange('telefone', value ?? ''),
                            keyboardType: TextInputType.phone,
                            maxLength: 15,
                          ),
                          _buildTextFormField(
                            label: 'Senha',
                            onSaved: (value) => _handleChange('senha', value ?? ''),
                            obscureText: true,
                          ),
                          _buildTextFormField(
                            label: 'Confirmar Senha',
                            onSaved: (value) => _handleChange('confirmarSenha', value ?? ''),
                            obscureText: true,
                          ),
                          _buildDropdownUserType(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                backgroundColor: const Color(0xFF007BFF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'CADASTRE-SE',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          if (_mensagem.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _mensagem,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Já tem uma conta? '),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/login'),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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

  Widget _buildTextFormField({
    required String label,
    required void Function(String?) onSaved,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF90017F),
            ),
          ),
          const SizedBox(height: 5),
          isDate
              ? TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _formData['dataNascimento']),
                  decoration: InputDecoration(
                    hintText: 'aaaa-mm-dd',
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _handleChange('dataNascimento', picked.toIso8601String().split('T')[0]);
                    }
                  },
                  onSaved: onSaved,
                  validator: (value) {
                    if (_formData['dataNascimento'] == null || _formData['dataNascimento']!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                )
              : TextFormField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  onSaved: onSaved,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (label == 'CPF') {
                      String cpf = value.replaceAll(RegExp(r'\D'), '').substring(0, value.length > 11 ? 11 : value.length);
                      if (cpf.length >= 3) cpf = cpf.replaceFirst(RegExp(r'^(\d{3})(\d)'), r'$1.$2');
                      if (cpf.length >= 6) cpf = cpf.replaceFirst(RegExp(r'^(\d{3})\.(\d{3})(\d)'), r'$1.$2.$3');
                      if (cpf.length >= 9) cpf = cpf.replaceFirst(RegExp(r'^(\d{3})\.(\d{3})\.(\d{3})(\d{1,2})'), r'$1.$2.$3-$4');
                      _handleChange('cpf', cpf);
                    } else if (label == 'Telefone') {
                      String telefone = value.replaceAll(RegExp(r'\D'), '').substring(0, value.length > 11 ? 11 : value.length);
                      if (telefone.length >= 2) telefone = telefone.replaceFirst(RegExp(r'^(\d{2})(\d)'), r'($1) $2');
                      if (telefone.length >= 7) telefone = telefone.replaceFirst(RegExp(r'^(\(\d{2}\)\s\d{5})(\d)'), r'$1-$2');
                      _handleChange('telefone', telefone);
                    } else {
                      onSaved(value);
                    }
                  },
                  initialValue: _formData[label.toLowerCase()] ?? '',
                ),
        ],
      ),
    );
  }

  Widget _buildDropdownUserType() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _formData['usuario']!.isEmpty ? null : _formData['usuario'],
        decoration: InputDecoration(
          labelText: 'Tipo de Usuário',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF90017F),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        items: const [
          DropdownMenuItem(value: '', child: Text('Selecione')),
          DropdownMenuItem(value: 'ADM', child: Text('Administrador')),
          DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
          DropdownMenuItem(value: 'Desenvolvedor', child: Text('Desenvolvedor')),
        ],
        onChanged: (value) => _handleChange('usuario', value ?? ''),
        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
        onSaved: (value) => _handleChange('usuario', value ?? ''),
      ),
    );
  }
}