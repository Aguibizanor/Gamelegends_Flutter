import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navbar.dart';
import 'cadastro_cartao.dart';
import 'modal_doacao_novo.dart';
import 'modal_pix_novo.dart';

// Endpoints do backend
const String projetosApiUrl = "http://localhost:8080/projetos";
const String avaliacaoApiUrl = "http://localhost:8080/avaliacao";
const String doacaoApiUrl = "http://localhost:8080/doacao";
const String comentariosApiUrl = "http://localhost:8080/comentarios";

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
        'usuario': usuario['usuario'],
        'isAdmin': usuario['usuario'] == 'ADM',
      };
    } catch (e) {
      return null;
    }
  }
  return null;
}

class JogoDetalhes extends StatefulWidget {
  final String jogoId;
  
  const JogoDetalhes({Key? key, required this.jogoId}) : super(key: key);

  @override
  State<JogoDetalhes> createState() => _JogoDetalhesState();
}

class _JogoDetalhesState extends State<JogoDetalhes> {
  bool menuAberto = false;
  bool modalImagemAberto = false;
  bool modalAvaliacaoAberto = false;
  bool modalDoacaoAberto = false;
  bool modalPixAberto = false;
  
  final TextEditingController _searchController = TextEditingController();
  
  // Dados do jogo
  Map<String, dynamic>? jogoData;
  bool carregandoJogo = true;
  
  // Dados do usuário
  bool usuarioLogado = false;
  String? nomeUsuario;
  String? tipoUsuario;
  bool isAdmin = false;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;
  
  // Modal admin
  bool modalAdminAberto = false;
  
  // Avaliações
  List<Map<String, dynamic>> avaliacoes = [];
  double mediaEstrelas = 0.0;
  bool carregandoAvaliacoes = true;
  
  // Comentários
  List<Map<String, dynamic>> comentarios = [];
  bool carregandoComentarios = true;

  @override
  void initState() {
    super.initState();
    buscarDadosJogo();
    buscarDadosUsuario();
    carregarComentarios();
  }

  Future<void> buscarDadosJogo() async {
    try {
      final response = await http.get(Uri.parse('$projetosApiUrl'));
      if (response.statusCode == 200) {
        final List<dynamic> projetos = jsonDecode(response.body);
        final jogo = projetos.firstWhere(
          (p) => p['id'].toString() == widget.jogoId,
          orElse: () => null,
        );
        
        if (jogo != null) {
          setState(() {
            jogoData = jogo;
            carregandoJogo = false;
          });
          await carregarAvaliacoes();
          await carregarComentarios();
        } else {
          setState(() {
            carregandoJogo = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        carregandoJogo = false;
      });
    }
  }

  Future<void> buscarDadosUsuario() async {
    final usuarioData = await getUsuarioLogado();
    
    if (usuarioData != null && usuarioData['nome'] != null) {
      setState(() {
        usuarioLogado = true;
        nomeUsuario = usuarioData['nome'];
        tipoUsuario = usuarioData['usuario'];
        isAdmin = usuarioData['isAdmin'] ?? false;
      });
    }
  }

  Future<void> carregarAvaliacoes() async {
    if (jogoData == null || jogoData!['nomeProjeto'] == null) {
      setState(() {
        avaliacoes = [];
        mediaEstrelas = 0.0;
        carregandoAvaliacoes = false;
      });
      return;
    }
    
    final avaliacoesData = await buscarAvaliacoesJogo(jogoData!['nomeProjeto']);
    final media = await buscarMediaEstrelas(jogoData!['nomeProjeto']);
    setState(() {
      avaliacoes = avaliacoesData ?? [];
      mediaEstrelas = media;
      carregandoAvaliacoes = false;
    });
  }

  Future<List<Map<String, dynamic>>> buscarAvaliacoesJogo(String nomeJogo) async {
    try {
      final response = await http.get(Uri.parse('$avaliacaoApiUrl/jogo/$nomeJogo'));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          final decodedData = jsonDecode(responseBody);
          if (decodedData is List) {
            return List<Map<String, dynamic>>.from(decodedData);
          }
        }
      }
    } catch (e) {
      print('Erro ao buscar avaliações: $e');
    }
    return [];
  }

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

  Future<void> carregarComentarios() async {
    if (jogoData == null || jogoData!['nomeProjeto'] == null) {
      setState(() {
        comentarios = [];
        carregandoComentarios = false;
      });
      return;
    }
    
    try {
      final response = await http.get(Uri.parse('$comentariosApiUrl/jogo/${jogoData!['nomeProjeto']}'));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          final decodedData = jsonDecode(responseBody);
          if (decodedData is List) {
            setState(() {
              comentarios = List<Map<String, dynamic>>.from(decodedData);
              carregandoComentarios = false;
            });
          } else {
            setState(() {
              comentarios = [];
              carregandoComentarios = false;
            });
          }
        } else {
          setState(() {
            comentarios = [];
            carregandoComentarios = false;
          });
        }
      } else {
        setState(() {
          comentarios = [];
          carregandoComentarios = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar comentários: $e');
      setState(() {
        comentarios = [];
        carregandoComentarios = false;
      });
    }
  }

  Future<void> excluirComentario(int comentarioId) async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas administradores podem excluir comentários'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (comentarioId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do comentário inválido')),
      );
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$comentariosApiUrl/$comentarioId'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          comentarios.removeWhere((c) => (c['id'] ?? 0) == comentarioId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir comentário (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao excluir comentário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir comentário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> excluirAvaliacao(int avaliacaoId) async {
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas administradores podem excluir avaliações'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (avaliacaoId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID da avaliação inválido')),
      );
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$avaliacaoApiUrl/$avaliacaoId'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          avaliacoes.removeWhere((a) => (a['id'] ?? 0) == avaliacaoId);
        });
        await carregarAvaliacoes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir avaliação (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao excluir avaliação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir avaliação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleMenu() {
    setState(() {
      menuAberto = !menuAberto;
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

  void abrirModalAdmin() {
    setState(() {
      modalAdminAberto = true;
    });
  }

  void fecharModalAdmin() {
    setState(() {
      modalAdminAberto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    if (carregandoJogo) {
      return Scaffold(
        body: Column(
          children: [
            Navbar(
              isMenuOpen: menuAberto,
              onMenuTap: toggleMenu,
              searchController: _searchController,
            ),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    if (jogoData == null) {
      return Scaffold(
        body: Column(
          children: [
            Navbar(
              isMenuOpen: menuAberto,
              onMenuTap: toggleMenu,
              searchController: _searchController,
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Jogo não encontrado',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                        child: Stack(
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 900),
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: _buildImagemJogo(),
                                          ),
                                          const SizedBox(width: 40),
                                          Expanded(
                                            flex: 7,
                                            child: _buildInfoJogo(),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _buildImagemJogo(),
                                          const SizedBox(height: 24),
                                          _buildInfoJogo(),
                                        ],
                                      ),
                              ),
                            ),

                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 24.0, bottom: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.arrow_back, size: 46, color: Color(0xFF90017F)),
                          ),
                        ),
                      ),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (menuAberto)
            NavbarMobileMenu(
              closeMenu: () => setState(() => menuAberto = false),
              searchController: _searchController,
            ),
          if (modalAvaliacaoAberto)
            _ModalAvaliacao(
              fechar: fecharModalAvaliacao,
              nomeUsuario: nomeUsuario,
              usuarioLogado: usuarioLogado,
              nomeJogo: jogoData!['nomeProjeto'],
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
          if (modalAdminAberto)
            _ModalAdmin(
              fechar: fecharModalAdmin,
              nomeJogo: jogoData!['nomeProjeto'],
              onAvaliacaoExcluida: carregarAvaliacoes,
            ),
        ],
      ),
    );
  }

  Widget _buildImagemJogo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: jogoData!['foto'] != null
                ? Image.network(
                    '$projetosApiUrl/${jogoData!['id']}/foto',
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              jogoData!['nomeProjeto'] ?? 'Jogo',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videogame_asset, size: 80, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        jogoData!['nomeProjeto'] ?? 'Jogo',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoJogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jogoData!['nomeProjeto'] ?? 'Nome não disponível',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Color(0xFF90017F),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          jogoData!['descricao'] ?? 'Descrição não disponível',
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        const SizedBox(height: 18),
        _buildDetalhesJogo(),
        const SizedBox(height: 20),
        _buildSecaoAvaliacoes(),
        const SizedBox(height: 20),
        _buildSecaoComentarios(),
        const SizedBox(height: 20),
        if (!usuarioLogado) ...[
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
              onPressed: usuarioLogado ? abrirModalAvaliacao : null,
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
              onPressed: usuarioLogado ? abrirModalDoacao : null,
            ),
            if (isAdmin) ...[
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Admin'),
                onPressed: abrirModalAdmin,
              ),
            ]
          ]
        ),
      ],
    );
  }

  Widget _buildDetalhesJogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 8),
        Text('Gênero: ${jogoData!['genero'] ?? 'Não informado'}'),
        Text('Tecnologias: ${jogoData!['tecnologias'] ?? 'Não informado'}'),
        Text('Data de Início: ${jogoData!['dataInicio'] ?? 'Não informado'}'),
        if (jogoData!['statusProjeto'] != null)
          Text('Status: ${jogoData!['statusProjeto']}'),
      ],
    );
  }

  Widget _buildSecaoAvaliacoes() {
    return Container(
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
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Stack(
                    children: [
                      Column(
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
                      if (isAdmin)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () {
                                final id = avaliacao['id'];
                                if (id != null && id is int && id > 0) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Excluir Avaliação'),
                                      content: const Text('Tem certeza que deseja excluir esta avaliação?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            excluirAvaliacao(id);
                                          },
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ID da avaliação inválido'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Excluir avaliação',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSecaoComentarios() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comentários',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF90017F),
            ),
          ),
          const SizedBox(height: 12),
          if (carregandoComentarios)
            const Center(child: CircularProgressIndicator())
          else if (comentarios.isEmpty)
            const Text('Nenhum comentário ainda.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comentarios.length,
              itemBuilder: (context, index) {
                if (index >= comentarios.length) return const SizedBox();
                final comentario = comentarios[index];
                if (comentario == null) return const SizedBox();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comentario['usuario']?.toString() ?? 'Usuário',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF90017F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comentario['texto']?.toString() ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comentario['data']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (isAdmin)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () {
                                final id = comentario['id'];
                                if (id != null && id is int && id > 0) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Excluir Comentário'),
                                      content: const Text('Tem certeza que deseja excluir este comentário?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            excluirComentario(id);
                                          },
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ID do comentário inválido'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Excluir comentário',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
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
                        color: Colors.black.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
            color: colors.first.withOpacity(0.4),
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
}

// Modal de Avaliação
class _ModalAvaliacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final bool usuarioLogado;
  final String nomeJogo;

  const _ModalAvaliacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.usuarioLogado,
    required this.nomeJogo,
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
    
    final response = await http.post(
      Uri.parse(avaliacaoApiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "comentario": motivoController.text.trim(),
        "estrelas": estrelasSelecionadas,
        "nomeJogo": widget.nomeJogo,
        "nomeUsuario": widget.nomeUsuario!,
        "dataAvaliacao": DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    
    setState(() {
      enviado = response.statusCode == 200 || response.statusCode == 201;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
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
            child: enviado
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
                      Text(
                        'Avalie ${widget.nomeJogo}',
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
                              color: const Color(0xFFFFC107),
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
                          labelText: 'Deixe seu comentário',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.feedback_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: estrelasSelecionadas == 0 || motivoController.text.trim().isEmpty
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

// Modal de Doação
class _ModalDoacao extends StatefulWidget {
  final VoidCallback fechar;
  final String? nomeUsuario;
  final bool usuarioLogado;
  final VoidCallback abrirPix;

  const _ModalDoacao({
    required this.fechar,
    required this.nomeUsuario,
    required this.usuarioLogado,
    required this.abrirPix,
  });

  @override
  State<_ModalDoacao> createState() => _ModalDoacaoState();
}

class _ModalDoacaoState extends State<_ModalDoacao> {
  final TextEditingController valorController = TextEditingController();
  bool enviado = false;
  List<Map<String, dynamic>> cartoesUsuario = [];
  String? cartaoSelecionadoId;
  bool carregandoCartoes = true;
  bool mostrarCartao = false;
  bool mostrarPix = false;

  @override
  void initState() {
    super.initState();
    _carregarCartoes();
  }

  Future<void> _carregarCartoes() async {
    if (!widget.usuarioLogado) {
      setState(() => carregandoCartoes = false);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioStr = prefs.getString('usuario');
      if (usuarioStr != null) {
        final usuarioData = jsonDecode(usuarioStr) as Map<String, dynamic>;
        final clienteId = usuarioData['id'];
        
        if (clienteId != null) {
          final response = await http.get(Uri.parse('http://localhost:8080/cadcartao/cliente/$clienteId'));
          if (response.statusCode == 200) {
            final cartoes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
            setState(() {
              cartoesUsuario = cartoes;
              cartaoSelecionadoId = cartoes.isNotEmpty ? cartoes.first['id'].toString() : null;
              carregandoCartoes = false;
            });
          } else {
            setState(() => carregandoCartoes = false);
          }
        } else {
          setState(() => carregandoCartoes = false);
        }
      } else {
        setState(() => carregandoCartoes = false);
      }
    } catch (e) {
      setState(() => carregandoCartoes = false);
    }
  }

  Future<void> enviarDoacao() async {
    double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null || cartaoSelecionadoId == null || !widget.usuarioLogado) return;
    
    // Simular envio de doação
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      enviado = true;
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
                          carregandoCartoes
                              ? const Center(child: CircularProgressIndicator())
                              : cartoesUsuario.isEmpty
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
                                          onPressed: () async {
                                            final resultado = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const CadastroCartaoScreen(),
                                              ),
                                            );
                                            if (resultado == true) {
                                              await _carregarCartoes();
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Cadastrar Cartão'),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: cartaoSelecionadoId,
                                          items: cartoesUsuario
                                              .map<DropdownMenuItem<String>>((cartao) {
                                                final numero = cartao['numC']?.toString() ?? '';
                                                final ultimos4 = numero.length >= 4 ? numero.substring(numero.length - 4) : numero;
                                                return DropdownMenuItem<String>(
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
                                          onChanged: (value) {
                                            setState(() {
                                              cartaoSelecionadoId = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: "Selecione o cartão para doação",
                                            border: OutlineInputBorder(),
                                            prefixIcon: Icon(Icons.credit_card),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: () async {
                                            final resultado = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const CadastroCartaoScreen(),
                                              ),
                                            );
                                            if (resultado == true) {
                                              await _carregarCartoes();
                                            }
                                          },
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
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF90017F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: valorController.text.trim().isEmpty ||
                                          cartoesUsuario.isEmpty ||
                                          cartaoSelecionadoId == null ||
                                          carregandoCartoes
                                      ? null
                                      : enviarDoacao,
                                  child: const Text('Pagar com Cartão'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF32BCAD),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: valorController.text.trim().isEmpty
                                      ? null
                                      : () {
                                          widget.fechar();
                                          widget.abrirPix();
                                        },
                                  icon: const Icon(Icons.qr_code, size: 20),
                                  label: const Text('PIX'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

// Modal de Administração
class _ModalAdmin extends StatefulWidget {
  final VoidCallback fechar;
  final String nomeJogo;
  final VoidCallback onAvaliacaoExcluida;

  const _ModalAdmin({
    required this.fechar,
    required this.nomeJogo,
    required this.onAvaliacaoExcluida,
  });

  @override
  State<_ModalAdmin> createState() => _ModalAdminState();
}

class _ModalAdminState extends State<_ModalAdmin> {
  List<Map<String, dynamic>> avaliacoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final response = await http.get(Uri.parse('$avaliacaoApiUrl/jogo/${widget.nomeJogo}'));
      if (response.statusCode == 200) {
        setState(() {
          avaliacoes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
      }
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<void> _excluirAvaliacao(int avaliacaoId) async {
    try {
      final response = await http.delete(Uri.parse('$avaliacaoApiUrl/$avaliacaoId'));
      if (response.statusCode == 200) {
        setState(() {
          avaliacoes.removeWhere((av) => av['id'] == avaliacaoId);
        });
        widget.onAvaliacaoExcluida();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir avaliação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 600,
            height: 500,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF90017F),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Gerenciar Comentários',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.fechar,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator())
                      : avaliacoes.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum comentário encontrado',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: avaliacoes.length,
                              itemBuilder: (context, index) {
                                final avaliacao = avaliacoes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    avaliacao['nomeUsuario'] ?? 'Anônimo',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < (avaliacao['estrelas'] ?? 0)
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: const Color(0xFFFFC107),
                                                        size: 16,
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Excluir Comentário'),
                                                    content: const Text(
                                                        'Tem certeza que deseja excluir este comentário?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(ctx);
                                                          _excluirAvaliacao(avaliacao['id']);
                                                        },
                                                        child: const Text(
                                                          'Excluir',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Excluir comentário',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          avaliacao['comentario'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Data: ${avaliacao['dataAvaliacao'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modal PIX
class _ModalPix extends StatefulWidget {
  final VoidCallback fechar;

  const _ModalPix({
    required this.fechar,
  });

  @override
  State<_ModalPix> createState() => _ModalPixState();
}

class _ModalPixState extends State<_ModalPix> {
  final TextEditingController valorController = TextEditingController();
  String? pixCode;
  bool carregandoPix = false;
  bool pixGerado = false;
  bool pagamentoConfirmado = false;

  Future<void> gerarPix() async {
    double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));
    if (valor == null) return;

    setState(() {
      carregandoPix = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$doacaoApiUrl/pix'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "valor": (valor * 100).toInt(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pixCode = data['pixCode'];
          pixGerado = true;
          carregandoPix = false;
        });
      } else {
        setState(() {
          carregandoPix = false;
        });
      }
    } catch (e) {
      setState(() {
        carregandoPix = false;
      });
    }
  }

  void confirmarPagamento() {
    setState(() {
      pagamentoConfirmado = true;
    });
    Future.delayed(const Duration(seconds: 2), widget.fechar);
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
            child: pagamentoConfirmado
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 60),
                      SizedBox(height: 16),
                      Text(
                        "Obrigado por doar!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Sua doação foi processada com sucesso.",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.qr_code, color: Color(0xFF32BCAD), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Doação via PIX',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.fechar,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!pixGerado) ...[
                        TextField(
                          controller: valorController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Valor da doação (R\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF32BCAD),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: carregandoPix || valorController.text.trim().isEmpty
                                ? null
                                : gerarPix,
                            icon: carregandoPix
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.qr_code),
                            label: Text(carregandoPix ? 'Gerando PIX...' : 'Gerar Código PIX'),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code, size: 80, color: Colors.black54),
                                      SizedBox(height: 8),
                                      Text(
                                        'QR Code PIX',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Escaneie o QR Code com seu app do banco',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Valor: R\$ ${valorController.text}',
                                style: const TextStyle(fontSize: 16, color: Color(0xFF32BCAD)),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Código PIX:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pixCode ?? '',
                                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    pixGerado = false;
                                    pixCode = null;
                                  });
                                },
                                child: const Text('Voltar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: confirmarPagamento,
                                child: const Text('Já Paguei'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
