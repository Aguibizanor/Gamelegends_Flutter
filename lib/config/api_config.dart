import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Para emulador use 10.0.2.2, para dispositivo físico use IP da máquina
      return 'http://10.0.2.2:8080';
      // Se não funcionar, troque por: 'http://192.168.1.XXX:8080'
    } else {
      return 'http://localhost:8080';
    }
  }
  
  // URLs específicas
  static String get cadastroUrl => '$baseUrl/cadastro';
  static String get loginUrl => '$baseUrl/login';
  static String get cadCartaoUrl => '$baseUrl/cadcartao';
  static String get avaliacaoUrl => '$baseUrl/avaliacao';
  static String get doacaoUrl => '$baseUrl/doacao';
  static String get projetosUrl => '$baseUrl/projetos';
  static String get comentariosUrl => '$baseUrl/comentarios';
  static String get clienteUrl => '$baseUrl/cliente';
  static String get redefinirSenhaUrl => '$baseUrl/redefinir-senha';
  
  // Função para obter URL de foto do projeto
  static String getProjetoFotoUrl(int projetoId) => '$projetosUrl/$projetoId/foto';
}