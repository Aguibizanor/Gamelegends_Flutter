import 'package:flutter/material.dart';

class AvaliacaoNotifier extends ChangeNotifier {
  static final AvaliacaoNotifier _instance = AvaliacaoNotifier._internal();
  factory AvaliacaoNotifier() => _instance;
  AvaliacaoNotifier._internal();

  void notificarAtualizacao() {
    notifyListeners();
  }
}
