import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = "http://localhost:8080";

  // Verificar se o usuário é administrador
  static Future<bool> isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    if (usuarioJson != null) {
      try {
        final usuario = jsonDecode(usuarioJson);
        final tipoUsuario = usuario['tipo'] ?? usuario['usuario'];
        
        // Verificar se é administrador
        final isAdm = tipoUsuario == 'ADM' || 
                     tipoUsuario == 'ADMIN' ||
                     tipoUsuario == 'Administrador' || 
                     tipoUsuario?.toLowerCase() == 'administrador' ||
                     tipoUsuario?.toLowerCase() == 'admin';
        
        return isAdm;
      } catch (e) {
        print('Erro ao decodificar usuário: $e');
        return false;
      }
    }
    return false;
  }

  // Excluir comentário/avaliação
  static Future<bool> excluirComentario(int avaliacaoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/avaliacao/$avaliacaoId'),
        headers: {"Content-Type": "application/json"},
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao excluir comentário: $e');
      return false;
    }
  }

  // Listar todos os comentários de um jogo
  static Future<List<Map<String, dynamic>>> listarComentariosJogo(String nomeJogo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avaliacao/jogo/$nomeJogo'),
        headers: {"Content-Type": "application/json"},
      );
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print('Erro ao listar comentários: $e');
    }
    return [];
  }
}