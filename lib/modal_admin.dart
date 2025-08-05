import 'package:flutter/material.dart';
import 'admin_service.dart';
import 'avaliacao_notifier.dart';

// MODAL DE ADMINISTRADOR
class ModalAdmin extends StatefulWidget {
  final VoidCallback fechar;
  final String nomeJogo;
  final VoidCallback onComentarioExcluido;
  
  const ModalAdmin({
    Key? key,
    required this.fechar,
    required this.nomeJogo,
    required this.onComentarioExcluido,
  }) : super(key: key);

  @override
  State<ModalAdmin> createState() => _ModalAdminState();
}

class _ModalAdminState extends State<ModalAdmin> {
  List<Map<String, dynamic>> todosComentarios = [];
  Set<int> comentariosSelecionados = {};
  bool carregando = true;
  bool modoSelecao = false;

  @override
  void initState() {
    super.initState();
    carregarTodosComentarios();
  }

  Future<void> carregarTodosComentarios() async {
    final comentarios = await AdminService.listarComentariosJogo(widget.nomeJogo);
    setState(() {
      todosComentarios = comentarios;
      carregando = false;
    });
  }

  void toggleModoSelecao() {
    setState(() {
      modoSelecao = !modoSelecao;
      if (!modoSelecao) {
        comentariosSelecionados.clear();
      }
    });
  }

  void toggleComentario(int id) {
    setState(() {
      if (comentariosSelecionados.contains(id)) {
        comentariosSelecionados.remove(id);
      } else {
        comentariosSelecionados.add(id);
      }
    });
  }

  void excluirSelecionados() async {
    if (comentariosSelecionados.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: Text("${comentariosSelecionados.length} comentário(s) será(ão) excluído(s). Tem certeza?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              
              bool sucesso = true;
              for (int id in comentariosSelecionados) {
                bool resultado = await AdminService.excluirComentario(id);
                if (!resultado) sucesso = false;
              }
              
              setState(() {
                todosComentarios.removeWhere((comentario) => 
                    comentariosSelecionados.contains(comentario['id']));
                comentariosSelecionados.clear();
                modoSelecao = false;
              });
              
              widget.onComentarioExcluido();
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
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.red, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gerenciar Comentários - ${widget.nomeJogo}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.fechar,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Text(
                      '${todosComentarios.length} comentários encontrados',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    if (modoSelecao) ...[
                      Text(
                        '${comentariosSelecionados.length} selecionados',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Excluir'),
                        onPressed: comentariosSelecionados.isEmpty ? null : excluirSelecionados,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: toggleModoSelecao,
                      ),
                    ] else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Selecionar'),
                        onPressed: todosComentarios.isEmpty ? null : toggleModoSelecao,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: carregando
                      ? const Center(child: CircularProgressIndicator())
                      : todosComentarios.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Nenhum comentário encontrado',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: todosComentarios.length,
                              itemBuilder: (context, index) {
                                final comentario = todosComentarios[index];
                                final id = comentario['id'] ?? 0;
                                final isSelected = comentariosSelecionados.contains(id);
                                
                                return GestureDetector(
                                  onTap: modoSelecao ? () => toggleComentario(id) : null,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.red[50] : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? Colors.red : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (modoSelecao)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: Icon(
                                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: isSelected ? Colors.red : Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    comentario['nomeUsuario'] ?? 'Anônimo',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < (comentario['estrelas'] ?? 0) 
                                                            ? Icons.star 
                                                            : Icons.star_border,
                                                        color: const Color(0xFFFFC107),
                                                        size: 16,
                                                      );
                                                    }),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    comentario['dataAvaliacao'] ?? '',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                comentario['comentario'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
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