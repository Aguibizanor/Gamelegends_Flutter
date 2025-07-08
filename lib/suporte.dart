import 'package:flutter/material.dart';
import 'navbar.dart';
 
class PaginaSuporte extends StatefulWidget {
  const PaginaSuporte({Key? key}) : super(key: key);
 
  @override
  State<PaginaSuporte> createState() => _PaginaSuporteState();
}
 
class _PaginaSuporteState extends State<PaginaSuporte> {
  bool menuAberto = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> formData = {
    'email': "",
    'usuario': ""
  };
 
  // Simula FAQ
  final List<Map<String, String>> faqData = [
    {
      "question": "Como posso visualizar ou alterar minhas configurações de conta?",
      "answer":
          "Clique no ícone de perfil no canto superior direito e selecione 'Configurações da Conta' para visualizar ou editar suas informações pessoais e preferências."
    },
    {
      "question": "Onde posso encontrar o histórico das doações nos projetos?",
      "answer":
          "Vá para 'Minha Conta' e selecione 'Histórico de Compras' para ver todas as suas transações anteriores."
    },
    {
      "question": "Esqueci minha senha. Como posso recuperá-la?",
      "answer":
          "Clique em 'Esqueci minha senha' na página de login e siga as instruções para redefinir sua senha."
    },
    {
      "question": "Como posso encontrar as últimas notícias e atualizações sobre os jogos?",
      "answer":
          "Acesse a seção de notícias no menu principal para ver as últimas novidades sobre os projetos e lançamentos."
    },
    {
      "question": "Como posso deixar um comentário ou avaliação para um jogo?",
      "answer":
          "Na página de cada jogo, você encontrará uma seção de avaliações onde poderá escrever sua opinião."
    },
  ];
 
  @override
  void initState() {
    super.initState();
    setState(() {
      formData = {
        'email': "",
        'usuario': "",
      };
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
 
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      appBar: Navbar(
        isMenuOpen: menuAberto,
        onMenuTap: () => setState(() => menuAberto = !menuAberto),
        searchController: _searchController,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              // FAQ Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
                color: Colors.white,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          "Perguntas Frequentes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Color(0xFF90017F),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...faqData.map((faq) => FAQItem(
                              question: faq["question"]!,
                              answer: faq["answer"]!,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer ajustado conforme a imagem
              Container(
                color: const Color(0xFF90017F),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // GameLegends
                        const Text(
                          "GameLegends",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                       
                        // Descrição
                        const Text(
                          "Game Legends é uma plataforma dedicada a jogos indie, fornecendo uma maneira fácil para desenvolvedores distribuírem seus jogos e para jogadores descobrirem novas experiências.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                       
                        // Contatos
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "(99) 99999-9999",
                              style: TextStyle(color: Colors.white70),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.email, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "info@gamelegends.com",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                       
                        // Divisor
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                        ),
                        const SizedBox(height: 24),
                       
                        // Links Rápidos
                        const Text(
                          "Links Rápidos",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                       
                        Column(
                          children: [
                            "Eventos",
                            "Equipe",
                            "Missão",
                            "Serviços",
                            "Afiliados"
                          ].map((txt) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              txt,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Rodapé inferior
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
          // Mobile menu overlay
          if (!isWide && menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }
}
 
// Widget FAQItem
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
 
  const FAQItem({super.key, required this.question, required this.answer});
 
  @override
  State<FAQItem> createState() => _FAQItemState();
}
 
class _FAQItemState extends State<FAQItem> {
  bool isOpen = false;
 
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isOpen ? 3 : 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => setState(() {
          isOpen = !isOpen;
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                    widget.question,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 17),
                  )),
                  Icon(isOpen ? Icons.remove : Icons.add),
                ],
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
 