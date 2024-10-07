import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_store/models/game.dart';

class GameViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Instância do Firestore
  bool isLoading = false; // Controla o estado de carregamento
  String? errorMessage; // Armazena a mensagem de erro, se houver

  List<Game> games = []; // Armazena a lista de jogos

  // Método para carregar a lista de games do Firestore
  Future<void> carregarGames() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      QuerySnapshot snapshot = await _db.collection('games').get();

      // Mapeia os documentos para objetos Game e atualiza a lista
      games = snapshot.docs.map((doc) {
        return Game.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao carregar os jogos. Tente novamente.';
      notifyListeners();
    }
  }

  // Método para adicionar um novo game ao Firestore
  Future<void> adicionarGame(Game game) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      DocumentReference docRef = _db.collection('games').doc();
      game.id = docRef.id; // Define o ID gerado automaticamente
      await docRef.set(game.toMap());

      // Adiciona o game à lista local
      games.add(game);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao adicionar o jogo. Tente novamente.';
      notifyListeners();
    }
  }

  // Método para atualizar um game existente no Firestore
  Future<void> atualizarGame(Game game) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (game.id != null) {
        await _db.collection('games').doc(game.id).update(game.toMap());

        // Atualiza o game na lista local
        int index = games.indexWhere((g) => g.id == game.id);
        if (index != -1) {
          games[index] = game;
        }
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao atualizar o jogo. Tente novamente.';
      notifyListeners();
    }
  }

  // Método para deletar um game do Firestore
  Future<void> deletarGame(String gameId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _db.collection('games').doc(gameId).delete();

      // Remove o game da lista local
      games.removeWhere((game) => game.id == gameId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao deletar o jogo. Tente novamente.';
      notifyListeners();
    }
  }

  // Método para buscar um game específico pelo ID
  Future<Game?> buscarGamePorId(String gameId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      DocumentSnapshot doc = await _db.collection('games').doc(gameId).get();
      if (doc.exists) {
        return Game.fromMap(doc.data() as Map<String, dynamic>);
      }

      isLoading = false;
      return null;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Erro ao buscar o jogo. Tente novamente.';
      notifyListeners();
      return null;
    }
  }
}
