import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = "http://localhost:8080";

  // Verificar se o usuário é administrador
  static Future<bool> isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    
    print('=== DEBUG ADMIN SERVICE ===');
    print('usuarioJson: $usuarioJson');
    
    if (usuarioJson != null) {
      try {
        final usuario = jsonDecode(usuarioJson);
        final tipoUsuario = usuario['tipo'] ?? usuario['usuario'];
        print('Tipo de usuário encontrado: $tipoUsuario');
        print('Dados completos do usuário: $usuario');
        final isAdm = tipoUsuario == 'ADM' || tipoUsuario == 'Administrador' || tipoUsuario?.toLowerCase() == 'administrador';
        print('É administrador? $isAdm');
        print('=== FIM DEBUG ADMIN SERVICE ===');
        return isAdm;
      } catch (e) {
        print('Erro ao decodificar usuário: $e');
        return false;
      }
    }
    print('Nenhum usuário logado');
    return false;
  }

  // Excluir comentário/avaliação
  static Future<bool> excluirComentario(int avaliacaoId) async {
    try {
      print('Tentando excluir avaliação ID: $avaliacaoId');
      final response = await http.delete(
        Uri.parse('$baseUrl/avaliacao/$avaliacaoId'),
        headers: {"Content-Type": "application/json"},
      );
      print('Status da resposta: ${response.statusCode}');
      print('Corpo da resposta: ${response.body}');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao excluir comentário: $e');
      return false;
    }
  }
}