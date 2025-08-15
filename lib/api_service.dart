import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  
  static Future<Map<String, dynamic>?> buscarUsuario(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cadastro/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }
  
  static Future<bool> atualizarUsuario(int id, Map<String, dynamic> dados) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cadastro/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }
  
  static Future<List<Map<String, dynamic>>> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Erro ao listar usuários: $e');
      return [];
    }
  }
  
  static Future<bool> excluirUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cadastro/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao excluir usuário: $e');
      return false;
    }
  }
  
  static Future<Map<String, dynamic>?> cadastrarUsuario(Map<String, dynamic> dados) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> fazerLogin(String email, String senha) async {
    try {
      final usuarios = await listarUsuarios();
      for (var usuario in usuarios) {
        if (usuario['email'] == email && usuario['senha'] == senha) {
          return usuario;
        }
      }
      return null;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return null;
    }
  }
}
