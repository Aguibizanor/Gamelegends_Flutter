import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navbar.dart';
import 'cadastro_cartao.dart';
import 'modal_doacao_novo.dart';
import 'modal_pix_novo.dart';
import 'admin_service.dart';
import 'avaliacao_notifier.dart';
import 'modal_admin.dart';

// Imagens e assets
final String logo = 'assets/logo.site.tcc.png';
final String coopdescricao1 = 'assets/catacombs.png';
final String coopdescricao2 = 'assets/coopdescricao2.png';
final String coopdescricao3 = 'assets/coopdescricao3.png';
final String esquerda = 'assets/esquerda.png';

// Endpoints do backend Spring Boot
const String avaliacaoApiUrl = "http://localhost:8080/avaliacao";
const String doacaoApiUrl = "http://localhost:8080/doacao";
const String cartaoApiUrl = "http://localhost:8080/cadcartao/cliente/";

// Função para buscar cartões do cliente
Future<List<Map<String, dynamic>>> buscarCartoesCliente(int clienteId) async {
  try {
    final url = '$cartaoApiUrl$clienteId';
    print('Buscando cartões na URL: $url');
    
    final response = await http.get(Uri.parse(url));
    print('Status da resposta: ${response.statusCode}');
    print('Corpo da resposta: ${response.body}');
    
    if (response.statusCode == 200) {
      final cartoes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      print('Cartões decodificados: $cartoes');
      return cartoes;
    }
  } catch (e) {
    print('Erro ao buscar cartões: $e');
  }
  return [];
}
const String clienteApiUrl = "http://localhost:8080/cliente/";

// Função para buscar o id do cliente do storage
Future<int?> getClienteId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usuarioJson = prefs.getString('usuario');
  
  if (usuarioJson != null) {
    try {
      final usuario = jsonDecode(usuarioJson);
      return usuario['id']?.toInt();
    } catch (e) {
      print('Erro ao obter ID do cliente: $e');
    }
  }
  return null;
}

// Função para buscar dados do usuário logado
Future<Map<String, dynamic>?> getUsuarioLogado() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usuarioJson = prefs.getString('usuario');
  
  if (usuarioJson != null) {
    try {
      final usuario = jsonDecode(usuarioJson);
      return {
        'nome': usuario['nome'],
        'email': usuario['email'],
        'tipo': usuario['tipo'],
      };
    } catch (e) {
      return null;
    }
  }
  return null;
}

class PaginaDescricao2 extends StatefulWidget {
  const PaginaDescricao2({Key? key}) : super(key: key);

  @override
  State<PaginaDescricao2> createState() => _PaginaDescricao2State();
}

class _PaginaDescricao2State extends State<PaginaDescricao2> {
  bool menuAberto = false;
  bool modalImagemAberto = false;
  int imagemAtual = 0;
  bool modalAvaliacaoAberto = false;
  bool modalDoacaoAberto = false;
  bool modalPixAberto = false;

  final List<String> imagens = ['assets/coopdescricao1.png', coopdescricao2, coopdescricao3];
  final TextEditingController _searchController = TextEditingController();

  // Dados do usuário
  bool usuarioLogado = false;
  int? idCliente;
  String? nomeUsuario;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;
  
  // Controle de administrador
  bool isAdmin = false;
  bool modoSelecaoComentarios = false;
  Set<int> comentariosSelecionados = {};
  bool modalAdminAberto = false;

  @override
  void initState() {
    super.initState();
    buscarDadosUsuario();
  }

  Future<void> buscarDadosUsuario() async {
    final usuarioData = await getUsuarioLogado();
    if (usuarioData != null && usuarioData['nome'] != null) {
      final clienteId = await getClienteId();
      print('Cliente ID encontrado: $clienteId');
      
      List<Map<String, dynamic>> cartoes = [];
      
      if (clienteId != null) {
        cartoes = await buscarCartoesCliente(clienteId);
        print('Cartões encontrados: ${cartoes.length}');
        print('Cartões: $cartoes');
      }
      
      final adminStatus = await AdminService.isAdmin();
      print('=== DEBUG DESCRICAO2 ===');
      print('Status de admin retornado: $adminStatus');
      print('Dados do usuário: $usuarioData');
      
      setState(() {
        usuarioLogado = true;
        nomeUsuario = usuarioData['nome'];
        idCliente = clienteId;
        cartoesUsuario = cartoes;
        cartaoSelecionadoId = cartoes.isNotEmpty ? cartoes.first['id'].toString() : null;
        isAdmin = adminStatus;
      });
      print('isAdmin definido no setState como: $isAdmin');
      print('=== FIM DEBUG DESCRICAO2 ===');
    } else {
      setState(() {
        usuarioLogado = false;
        nomeUsuario = null;
        idCliente = null;
        cartoesUsuario = [];
        cartaoSelecionadoId = null;
        isAdmin = false;
        modoSelecaoComentarios = false;
        comentariosSelecionados.clear();
      });
    }
  }

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
    });
  }

  void abrirModalImagem(int index) {
    setState(() {
      imagemAtual = index;
      modalImagemAberto = true;
    });
  }

  void fecharModalImagem() {
    setState(() {
      modalImagemAberto = false;
    });
  }

  void imagemAnterior() {
    setState(() {
      imagemAtual = (imagemAtual - 1 + imagens.length) % imagens.length;
    });
  }

  void proximaImagem() {
    setState(() {
      imagemAtual = (imagemAtual + 1) % imagens.length;
    });
  }

  void abrirModalAvaliacao() {
    setState(() {
      modalAvaliacaoAberto = true;
    });
  }

  void fecharModalAvaliacao() {
    setState(() {
      modalAvaliacaoAberto = false;
    });
  }

  void abrirModalDoacao() {
    setState(() {
      modalDoacaoAberto = true;
    });
  }

  void fecharModalDoacao() {
    setState(() {
      modalDoacaoAberto = false;
    });
  }

  void abrirModalPix() {
    setState(() {
      modalPixAberto = true;
    });
  }

  void fecharModalPix() {
    setState(() {
      modalPixAberto = false;
    });
  }

  void onCadastrarCartao() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroCartaoScreen()),
    );
    if (resultado == true) {
      await buscarDadosUsuario();
    }
  }

  void onCartaoSelecionado(String? id) {
    setState(() {
      cartaoSelecionadoId = id;
    });
  }
  
  void toggleModoSelecaoComentarios() {
    setState(() {
      modoSelecaoComentarios = !modoSelecaoComentarios;
      if (!modoSelecaoComentarios) {
        comentariosSelecionados.clear();
      }
    });
  }
  
  void abrirModalAdmin() {
    setState(() {
      modalAdminAberto = true;
    });
  }
  
  void fecharModalAdmin() {
    setState(() {
      modalAdminAberto = false;
      modoSelecaoComentarios = false;
      comentariosSelecionados.clear();
    });
  }
  
  void toggleComentarioSelecionado(int avaliacaoId) {
    setState(() {
      if (comentariosSelecionados.contains(avaliacaoId)) {
        comentariosSelecionados.remove(avaliacaoId);
      } else {
        comentariosSelecionados.add(avaliacaoId);
      }
    });
  }
  
  void excluirComentariosSelecionados() {
    if (comentariosSelecionados.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirmar Exclusão"),
        content: Text("${comentariosSelecionados.length} comentário(s) será(ão) excluído(s). Tem certeza?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              bool sucesso = true;
              print('Comentários selecionados para exclusão: $comentariosSelecionados');
              for (int id in comentariosSelecionados) {
                print('Excluindo comentário ID: $id');
                bool resultado = await AdminService.excluirComentario(id);
                print('Resultado da exclusão ID $id: $resultado');
                if (!resultado) sucesso = false;
              }
              
              setState(() {
                comentariosSelecionados.clear();
                modoSelecaoComentarios = false;
              });
              
              // Notificar atualização das avaliações
              AvaliacaoNotifier().notificarAtualizacao();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(sucesso ? "Comentários excluídos com sucesso!" : "Erro ao excluir alguns comentários"),
                  backgroundColor: sucesso ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulSocialButton(IconData icon, List<Color> colors, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha:  0.4),
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
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: const Color(0xFFE6D7FF),
      body: Stack(
        children: [
          Column(
            children: [
              Navbar(
                isMenuOpen: menuAberto,
                onMenuTap: toggleMenu,
                searchController: _searchController,
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 900),
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Image.asset(
                                                    coopdescricao1,
                                                    height: 320,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: Wrap(
                                                    alignment: WrapAlignment.center,
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: imagens
                                                        .asMap()
                                                        .entries
                                                        .map((entry) => GestureDetector(
                                                              onTap: () => abrirModalImagem(entry.key),
                                                              child: Container(
                                                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  child: Image.asset(
                                                                    entry.value,
                                                                    height: 56,
                                                                    width: 56,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                          Expanded(
                                            flex: 7,
                                            child: _DescricaoEInfo(
                                              abrirModalAvaliacao: usuarioLogado ? abrirModalAvaliacao : null,
                                              abrirModalDoacao: usuarioLogado ? abrirModalDoacao : null,
                                              usuarioLogado: usuarioLogado,
                                              onAvaliacaoEnviada: () => setState(() {}),
                                              isAdmin: isAdmin,
                                              modoSelecaoComentarios: modoSelecaoComentarios,
                                              comentariosSelecionados: comentariosSelecionados,
                                              onToggleModoSelecao: toggleModoSelecaoComentarios,
                                              onToggleComentario: toggleComentarioSelecionado,
                                              onExcluirSelecionados: excluirComentariosSelecionados,
                                              onRecarregarAvaliacoes: () => setState(() {}),
                                              abrirModalAdmin: abrirModalAdmin,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Image.asset(
                                             coopdescricao1,
                                              height: 220,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Center(
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: imagens
                                                  .asMap()
                                                  .entries
                                                  .map((entry) => GestureDetector(
                                                        onTap: () => abrirModalImagem(entry.key),
                                                        child: Container(
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Image.asset(
                                                              entry.value,
                                                              height: 44,
                                                              width: 44,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          _DescricaoEInfo(
                                            abrirModalAvaliacao: usuarioLogado ? abrirModalAvaliacao : null,
                                            abrirModalDoacao: usuarioLogado ? abrirModalDoacao : null,
                                            usuarioLogado: usuarioLogado,
                                            onAvaliacaoEnviada: () => setState(() {}),
                                            isAdmin: isAdmin,
                                            modoSelecaoComentarios: modoSelecaoComentarios,
                                            comentariosSelecionados: comentariosSelecionados,
                                            onToggleModoSelecao: toggleModoSelecaoComentarios,
                                            onToggleComentario: toggleComentarioSelecionado,
                                            onExcluirSelecionados: excluirComentariosSelecionados,
                                            onRecarregarAvaliacoes: () => setState(() {}),
                                            abrirModalAdmin: abrirModalAdmin,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 24.0, bottom: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(esquerda, height: 46),
                              ),
                            ),
                          ),
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
                                              color: Colors.black.withValues(alpha:  0.3),
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
                                              color: Colors.black.withValues(alpha:  0.2),
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
                                        color: Colors.white.withValues(alpha:  0.9),
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
                    if (modalImagemAberto)
                      _ModalImagem(
                        imagem: imagens[imagemAtual],
                        fechar: fecharModalImagem,
                        proxima: proximaImagem,
                        anterior: imagemAnterior,
                      ),
                    if (modalAvaliacaoAberto)
                      _ModalAvaliacao(
                        fechar: fecharModalAvaliacao,
                        nomeUsuario: nomeUsuario,
                        idCliente: idCliente,
                        usuarioLogado: usuarioLogado,
                      ),
                    if (modalDoacaoAberto)
                      ModalDoacaoNovo(
                        fechar: fecharModalDoacao,
                        nomeUsuario: nomeUsuario,
                        usuarioLogado: usuarioLogado,
                        abrirPix: abrirModalPix,
                      ),
                    if (modalPixAberto)
                      ModalPixNovo(
                        fechar: fecharModalPix,
                      ),
                    if (modalAdminAberto && isAdmin)
                      ModalAdmin(
                        fechar: fecharModalAdmin,
                        nomeJogo: "Coop Catacombs: Roguelike",
                        onComentarioExcluido: () => setState(() {}),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
        ],
      ),
    );
  }
}

class _DescricaoEInfo extends StatefulWidget {
  final VoidCallback? abrirModalAvaliacao;
  final VoidCallback? abrirModalDoacao;
  final bool usuarioLogado;
  final VoidCallback? onAvaliacaoEnviada;
  final bool isAdmin;
  final bool modoSelecaoComentarios;
  final Set<int> comentariosSelecionados;
  final VoidCallback onToggleModoSelecao;
  final Function(int) onToggleComentario;
  final VoidCallback onExcluirSelecionados;
  final VoidCallback? onRecarregarAvaliacoes;
  final VoidCallback abrirModalAdmin;

  const _DescricaoEInfo({
    required this.abrirModalAvaliacao,
    required this.abrirModalDoacao,
    required this.usuarioLogado,
    this.onAvaliacaoEnviada,
    required this.isAdmin,
    required this.modoSelecaoComentarios,
    required this.comentariosSelecionados,
    required this.onToggleModoSelecao,
    required this.onToggleComentario,
    required this.onExcluirSelecionados,
    this.onRecarregarAvaliacoes,
    required this.abrirModalAdmin,
  });

  @override
  State<_DescricaoEInfo> createState() => _DescricaoEInfoState();
}

class _DescricaoEInfoState extends State<_DescricaoEInfo> {
  List<Map<String, dynamic>> avaliacoes = [];
  double mediaEstrelas = 0.0;
  bool carregandoAvaliacoes = true;

  @override
  void initState() {
    super.initState();
    carregarAvaliacoes();
    AvaliacaoNotifier().addListener(recarregarAvaliacoes);
  }
  
  @override
  void dispose() {
    AvaliacaoNotifier().removeListener(recarregarAvaliacoes);
    super.dispose();
  }

  Future<void> carregarAvaliacoes() async {
    final avaliacoesData = await buscarAvaliacoesJogo("Coop Catacombs: Roguelike");
    final media = await buscarMediaEstrelas("Coop Catacombs: Roguelike");
    setState(() {
      avaliacoes = avaliacoesData;
      mediaEstrelas = media;
      carregandoAvaliacoes = false;
    });
  }
  
  void recarregarAvaliacoes() {
    setState(() {
      carregandoAvaliacoes = true;
    });
    carregarAvaliacoes();
  }

  @override
  Widget build(BuildContext context) {
    print('=== BUILD DESCRICAO2 E INFO ===');
    print('widget.isAdmin: ${widget.isAdmin}');
    print('widget.modoSelecaoComentarios: ${widget.modoSelecaoComentarios}');
    print('=== FIM BUILD DESCRICAO2 E INFO ===');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coop Catacombs: Roguelike',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFF90017F)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Explore masmorras perigosas em cooperativo! Nas catacumbas sombrias, você e seus aliados enfrentarão desafios únicos a cada descida. Colete tesouros, derrote monstros e descubra os segredos enterrados nas profundezas. Cada aventura é diferente com elementos roguelike que garantem rejogabilidade infinita.',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        const Text(
          'Créditos:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: 'Desenvolvedor: DungeonMaster Studios ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.reddit.com/r/Game_Legends_jogos/s/GZVUlKiWg8')),
                  child: const Text('Twitter',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ' / '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.reddit.com/r/Game_Legends_jogos/s/GZVUlKiWg8')),
                  child: const Text('Steam',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ')\\nArtista: CryptArt ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.reddit.com/r/Game_Legends_jogos/s/GZVUlKiWg8')),
                  child: const Text('Portfolio',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ')'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Seção de Avaliações
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Avaliações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      if (!carregandoAvaliacoes) ...[
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < mediaEstrelas.round() ? Icons.star : Icons.star_border,
                              color: const Color(0xFFFFC107),
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${mediaEstrelas.toStringAsFixed(1)} (${avaliacoes.length} avaliações)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (carregandoAvaliacoes)
                    const Center(child: CircularProgressIndicator())
                  else if (avaliacoes.isEmpty)
                    const Text('Nenhuma avaliação ainda. Seja o primeiro!')
                  else
                    Column(
                      children: avaliacoes.take(3).map((avaliacao) {
                        final avaliacaoId = avaliacao['id'] ?? 0;
                        final isSelected = widget.comentariosSelecionados.contains(avaliacaoId);
                        
                        return GestureDetector(
                          onTap: widget.modoSelecaoComentarios ? () => widget.onToggleComentario(avaliacaoId) : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red[50] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (widget.modoSelecaoComentarios)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: isSelected ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            avaliacao['nomeUsuario'] ?? 'Anônimo',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < (avaliacao['estrelas'] ?? 0) ? Icons.star : Icons.star_border,
                                                color: const Color(0xFFFFC107),
                                                size: 16,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        avaliacao['comentario'] ?? '',
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              // Botão de Administrador no canto inferior direito
              if (widget.isAdmin)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: widget.modoSelecaoComentarios
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${widget.comentariosSelecionados.length} selecionados',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                                tooltip: 'Excluir Selecionados',
                                onPressed: widget.comentariosSelecionados.isEmpty ? null : widget.onExcluirSelecionados,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                tooltip: 'Cancelar',
                                onPressed: widget.onToggleModoSelecao,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                            tooltip: 'Gerenciar Comentários (Admin)',
                            onPressed: widget.abrirModalAdmin,
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          ),
                        ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        if (!widget.usuarioLogado) ...[
          const Text(
            "Você precisa estar logado para avaliar ou doar.",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05B7E7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Avaliar Jogo'),
              onPressed: widget.abrirModalAvaliacao,
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90017F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Doações'),
              onPressed: widget.abrirModalDoacao,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModalImagem extends StatelessWidget {
  final String imagem;
  final VoidCallback fechar;
  final VoidCallback proxima;
  final VoidCallback anterior;

  const _ModalImagem({
    required this.imagem,
    required this.fechar,
    required this.proxima,
    required this.anterior,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(imagem, height: 320),
              ),
            ),
            Positioned(
              left: 30,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                onPressed: anterior,
              ),
            ),
            Positioned(
              right: 30,
              top: MediaQuery.of(context).size.height / 2 - 25,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                onPressed: proxima,
              ),
            ),
            Positioned(
              right: 30,
              top: 50,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 36),
                onPressed: fechar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ENVIO DE AVALIAÇÃO
Future<bool> enviarAvaliacaoParaBackend(int estrelas, String comentario, String nomeUsuario) async {
  final response = await http.post(
    Uri.parse(avaliacaoApiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "comentario": comentario,
      "estrelas": estrelas,
      "nomeJogo": "Coop Catacombs: Roguelike",
      "nomeUsuario": nomeUsuario,
      "dataAvaliacao": DateTime.now().toIso8601String().split('T')[0],
    }),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

// BUSCAR AVALIAÇÕES DO JOGO
Future<List<Map<String, dynamic>>> buscarAvaliacoesJogo(String nomeJogo) async {
  try {
    final response = await http.get(Uri.parse('$avaliacaoApiUrl/jogo/$nomeJogo'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
  } catch (e) {
    print('Erro ao buscar avaliações: $e');
  }
  return [];
}

// BUSCAR MÉDIA DE ESTRELAS
Future<double> buscarMediaEstrelas(String nomeJogo) async {
  try {
    final response = await http.get(Uri.parse('$avaliacaoApiUrl/media/$nomeJogo'));
    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
  } catch (e) {
    print('Erro ao buscar média: $e');
  }
  return 0.0;
}

// ENVIO DE DOAÇÃO
Future<bool> enviarDoacaoParaBackend(double valor, int? idCliente, String? cartaoId) async {
  if (idCliente == null || cartaoId == null) return false;
  final response = await http.post(
    Uri.parse(doacaoApiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "valor": valor.toInt(),
      "fk_Cliente_ID": idCliente,
      "cartaoId": cartaoId,
    }),
  );
  return response.statusCode == 200 || response.statusCode == 201;
}

// MODAL DE AVALIAÇÃO
class _ModalAvaliacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final int? idCliente;
  final bool usuarioLogado;
  const _ModalAvaliacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.idCliente,
    required this.usuarioLogado,
  });

  @override
  State<_ModalAvaliacao> createState() => _ModalAvaliacaoState();
}

class _ModalAvaliacaoState extends State<_ModalAvaliacao> {
  int estrelasSelecionadas = 0;
  bool enviado = false;
  final TextEditingController motivoController = TextEditingController();

  Future<void> enviarAvaliacao() async {
    if (!widget.usuarioLogado || widget.nomeUsuario == null) return;
    bool sucesso = await enviarAvaliacaoParaBackend(
      estrelasSelecionadas,
      motivoController.text.trim(),
      widget.nomeUsuario!,
    );
    setState(() {
      enviado = sucesso;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
  }

  @override
  void dispose() {
    motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: !widget.usuarioLogado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        "Faça login para avaliar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : enviado
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 50),
                          SizedBox(height: 10),
                          Text(
                            "Obrigado pela sua avaliação!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: widget.fechar,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Avalie o jogo como ${widget.nomeUsuario ?? ""}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < estrelasSelecionadas ? Icons.star : Icons.star_border,
                                  color: Color(0xFFFFC107),
                                  size: 36,
                                ),
                                onPressed: () => setState(() {
                                  estrelasSelecionadas = index + 1;
                                }),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: motivoController,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Deixe seu comentário ou motivo da avaliação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.feedback_outlined),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: estrelasSelecionadas == 0 ||
                                    motivoController.text.trim().isEmpty
                                ? null
                                : enviarAvaliacao,
                            child: const Text('Enviar Avaliação'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}


