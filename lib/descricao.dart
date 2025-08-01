import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navbar.dart';
import 'cadastro_cartao.dart';
import 'admin_service.dart';
import 'avaliacao_notifier.dart';

// Imagens e assets
final String logo = 'assets/logo.site.tcc.png';
final String gato1 = 'assets/gato1.png';
final String gato2 = 'assets/gato2.png';
final String gato3 = 'assets/gato3.png';
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



class PaginaDescricao extends StatefulWidget {
  const PaginaDescricao({Key? key}) : super(key: key);

  @override
  State<PaginaDescricao> createState() => _PaginaDescricaoState();
}

class _PaginaDescricaoState extends State<PaginaDescricao> {
  bool menuAberto = false;
  bool modalImagemAberto = false;
  int imagemAtual = 0;
  bool modalAvaliacaoAberto = false;
  bool modalDoacaoAberto = false;

  final List<String> imagens = [gato1, gato2, gato1];
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
      print('=== DEBUG DESCRICAO ===');
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
      print('=== FIM DEBUG DESCRICAO ===');
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                                                    gato3,
                                                    height: 320,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: imagens
                                                      .asMap()
                                                      .entries
                                                      .map((entry) => GestureDetector(
                                                            onTap: () => abrirModalImagem(entry.key),
                                                            child: Container(
                                                              margin: const EdgeInsets.symmetric(horizontal: 6),
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
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Image.asset(
                                              gato3,
                                              height: 220,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: imagens
                                                .asMap()
                                                .entries
                                                .map((entry) => GestureDetector(
                                                      onTap: () => abrirModalImagem(entry.key),
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 6),
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
                      _ModalDoacao(
                        fechar: fecharModalDoacao,
                        nomeUsuario: nomeUsuario,
                        cartoesUsuario: cartoesUsuario,
                        onCadastrarCartao: onCadastrarCartao,
                        cartaoSelecionadoId: cartaoSelecionadoId,
                        onCartaoSelecionado: onCartaoSelecionado,
                        idCliente: idCliente,
                        usuarioLogado: usuarioLogado,
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
    final avaliacoesData = await buscarAvaliacoesJogo("Happy Cat Tavern");
    final media = await buscarMediaEstrelas("Happy Cat Tavern");
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
    print('=== BUILD DESCRICAO E INFO ===');
    print('widget.isAdmin: ${widget.isAdmin}');
    print('widget.modoSelecaoComentarios: ${widget.modoSelecaoComentarios}');
    print('=== FIM BUILD DESCRICAO E INFO ===');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Happy Cat Tavern: Typing Challenge',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Color(0xFF90017F)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Batou quer beber o máximo de milkshakes que puder enquanto os clientes da taverna o animam. Cada palavra é um milkshake para Batou beber. Digite com rapidez e precisão para ganhar pontos e desbloquear conquistas!',
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
              const TextSpan(text: 'Artista: Miyaualit ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Twitter',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ' / '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Etsy',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                ),
              ),
              const TextSpan(text: ')\nProgramador: OnyxHeart ('),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text('Twitter',
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
          child: Column(
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
                  const Spacer(),
                  // BOTÃO DE TESTE TEMPORÁRIO
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      print('=== TESTE FORÇADO ===');
                      print('Forçando isAdmin = true');
                      widget.onToggleModoSelecao();
                    },
                    child: Text('TESTE ADMIN', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  if (widget.isAdmin) ...[
                    if (!widget.modoSelecaoComentarios)
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.red),
                        tooltip: 'Modo Administrador',
                        onPressed: widget.onToggleModoSelecao,
                      )
                    else ...[
                      Text(
                        '${widget.comentariosSelecionados.length} selecionados',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir Selecionados',
                        onPressed: widget.comentariosSelecionados.isEmpty ? null : widget.onExcluirSelecionados,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        tooltip: 'Cancelar',
                        onPressed: widget.onToggleModoSelecao,
                      ),
                    ],
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
                    print('Avaliação ID: $avaliacaoId, Dados: $avaliacao');
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
      "nomeJogo": "Happy Cat Tavern",
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

// MODAL DE DOAÇÃO
class _ModalDoacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final List<Map<String, dynamic>> cartoesUsuario;
  final Function onCadastrarCartao;
  final String? cartaoSelecionadoId;
  final ValueChanged<String?> onCartaoSelecionado;
  final int? idCliente;
  final bool usuarioLogado;
  const _ModalDoacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.cartoesUsuario,
    required this.onCadastrarCartao,
    required this.cartaoSelecionadoId,
    required this.onCartaoSelecionado,
    required this.idCliente,
    required this.usuarioLogado,
  });

  @override
  State<_ModalDoacao> createState() => _ModalDoacaoState();
}

class _ModalDoacaoState extends State<_ModalDoacao> {
  final TextEditingController valorController = TextEditingController();
  bool enviado = false;

  Future<void> enviarDoacao() async {
    double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null ||
        widget.idCliente == null ||
        widget.cartaoSelecionadoId == null ||
        !widget.usuarioLogado) return;
    bool sucesso = await enviarDoacaoParaBackend(
      valor,
      widget.idCliente,
      widget.cartaoSelecionadoId,
    );
    setState(() {
      enviado = sucesso;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
  }

  @override
  void dispose() {
    valorController.dispose();
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
                        "Faça login para doar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : enviado
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.favorite, color: Colors.pink, size: 50),
                          SizedBox(height: 10),
                          Text(
                            "Obrigado pela sua doação!",
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
                            'Bem-vindo, ${widget.nomeUsuario ?? ""}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 12),
                          widget.cartoesUsuario.isEmpty
                              ? Column(
                                  children: [
                                    const Icon(Icons.credit_card_off, size: 48, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    const Text('Nenhum cartão cadastrado.', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF90017F),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => widget.onCadastrarCartao(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Cadastrar Cartão'),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: widget.cartaoSelecionadoId,
                                      items: widget.cartoesUsuario
                                          .map((cartao) {
                                            final numero = cartao['numC']?.toString() ?? '';
                                            final ultimos4 = numero.length >= 4 ? numero.substring(numero.length - 4) : numero;
                                            return DropdownMenuItem(
                                              value: cartao['id'].toString(),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.credit_card, color: Color(0xFF90017F), size: 20),
                                                  const SizedBox(width: 8),
                                                  Text('${cartao['bandeira'] ?? "Cartão"} - **** $ultimos4'),
                                                ],
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: widget.onCartaoSelecionado,
                                      decoration: const InputDecoration(
                                        labelText: "Selecione o cartão para doação",
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.credit_card),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: () => widget.onCadastrarCartao(),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Adicionar outro cartão'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF90017F),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: valorController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Valor da doação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF90017F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: valorController.text.trim().isEmpty ||
                                    widget.cartoesUsuario.isEmpty ||
                                    widget.cartaoSelecionadoId == null
                                ? null
                                : enviarDoacao,
                            child: const Text('Enviar Doação'),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}