import 'package:flutter/material.dart';

import 'navbar.dart';
import 'footer_template.dart';

class PrivacidadePage extends StatefulWidget {
  const PrivacidadePage({Key? key}) : super(key: key);

  @override
  State<PrivacidadePage> createState() => _PrivacidadePageState();
}

class _PrivacidadePageState extends State<PrivacidadePage> {
  final TextEditingController _searchController = TextEditingController();
  bool menuAberto = false;

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
  }



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

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
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Política de Privacidade",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF90017F),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Esta Política de Privacidade descreve como o Game Legends coleta, usa e protege suas informações pessoais.",
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildSection("1. Informações que Coletamos", 
                                    "Coletamos informações que você nos fornece diretamente, como nome, email e dados de perfil quando você se cadastra em nossa plataforma."),
                                  _buildSection("2. Como Usamos suas Informações", 
                                    "Utilizamos suas informações para fornecer nossos serviços, melhorar a experiência do usuário e comunicar atualizações importantes."),
                                  _buildSection("3. Compartilhamento de Informações", 
                                    "Não vendemos, alugamos ou compartilhamos suas informações pessoais com terceiros sem seu consentimento explícito."),
                                  _buildSection("4. Segurança dos Dados", 
                                    "Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações contra acesso não autorizado."),
                                  _buildSection("5. Seus Direitos", 
                                    "Você tem o direito de acessar, corrigir ou excluir suas informações pessoais a qualquer momento."),
                                  _buildSection("6. Contato", 
                                    "Para questões sobre esta política, entre em contato conosco através do email: info@gamelegends.com"),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Última atualização: Janeiro de 2024",
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const FooterTemplate(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isWide && menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF90017F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
