import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UsuarioViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância de autenticação Firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Instância do Firestore para salvar dados
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false; // Controla o estado de carregamento
  String? errorMessage; // Armazena a mensagem de erro, se houver
  User? currentUser = FirebaseAuth.instance.currentUser; // Usuário logado atual

  //Método para selecionar imagem da galeria ou tirar foto
  Future<File?> pickImage({required bool fromCamera}) async{
    try{
      final pickedFile = await _picker.pickImage(
        source: fromCamera? ImageSource.camera : ImageSource.gallery,
      );
      if(pickedFile != null){
        return File(pickedFile.path);
      }
      return null;
    }catch (e){
      errorMessage = "Erro ao selecionar imagem.";
      notifyListeners();
      return null;
    }
  }

  // Método para cadastrar um novo usuário com imagem opcional
  Future<void> registerUser(String name, String email, String password, {File? imageFile}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners(); // Atualiza o estado da View para exibir o carregamento

      // Cria o usuário no Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obter o UID do usuário recém-criado
      String userId = userCredential.user!.uid;

      // URL da imagem no Firebase Storage
      String? imageUrl;

      if (imageFile != null) {
        // Carregar a imagem para o Firebase Storage
        imageUrl = await _uploadImageToStorage(userId, imageFile);
      }

      // Salvar o nome do usuário no Firestore
      await _db.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'img': imageUrl, // URL da imagem ou null
      });

      isLoading = false;
      notifyListeners(); // Finaliza o estado de carregamento e notifica a View
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = _handleAuthError(e); // Trata o erro e define a mensagem de erro
      notifyListeners(); // Notifica a View sobre o erro
    } catch (e) {
      isLoading = false;
      errorMessage = "Ocorreu um erro inesperado. Tente novamente."; // Para erros genéricos
      notifyListeners(); // Notifica a View sobre o erro
    }
  }

  //Método auxiliar para enviar a imagem para o Firebase Storage
  Future<String?> _uploadImageToStorage(String userId, File imageFile) async{
    try{
      //Define o caminho da imagem no Storage
      Reference ref = _storage.ref().child('user_images/$userId');
      UploadTask uploadTask = ref.putFile(imageFile);

      //Espera o upload terminar
      TaskSnapshot snapshot = await uploadTask;

      //Pega a URL da Imagem
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    }catch (e){
      errorMessage = "Erro ao enviar imagem para o Firebase Storage.";
      notifyListeners();
      return null;
    }
  }

  // Função que retorna uma mensagem de erro mais amigável com base no FirebaseAuthException
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'O e-mail já está cadastrado. Por favor, use outro e-mail.';
      case 'invalid-email':
        return 'O e-mail informado é inválido. Verifique e tente novamente.';
      case 'weak-password':
        return 'A senha é muito fraca. Por favor, use uma senha mais forte.';
      case 'operation-not-allowed':
        return 'Cadastro de e-mail e senha desativado. Contate o suporte.';
      default:
        return 'Erro ao tentar cadastrar. Por favor, tente novamente.';
    }
  }


  // Método para editar o nome e imagem do usuário no Firestore
  Future<void> editarUsuario(String userId, String newName,  {File? newImageFile}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners(); // Atualiza o estado da View

      //upload da nova imagem, se fornecida
      String? newImageUrl;
      if(newImageFile != null){
        newImageUrl = await _uploadImageToStorage(userId, newImageFile);
      }

      // Atualiza o nome e imagem (caso fornecida) do usuário no Firestore
      await _db.collection('users').doc(userId).update({
        'name': newName,
        if(newImageUrl != null) 'img': newImageUrl, //Atualiza a imagem se fornecida
      });

      // Atualiza o nome e imagem do usuário no Firebase Authentication
      await currentUser?.updateDisplayName(newName);
      if (newImageUrl != null) {
        await currentUser?.updatePhotoURL(newImageUrl);
      }

      isLoading = false;
      notifyListeners(); // Finaliza o estado de carregamento e notifica a View
    } catch (e) {
      isLoading = false;
      errorMessage = "Erro ao editar o usuário. Tente novamente.";
      notifyListeners(); // Notifica a View sobre o erro
    }
  }

  // Método para atualizar a senha do usuário
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Reautentica o usuário com a senha atual
      User? currentUser = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser?.email ?? '',
        password: senhaAtual,
      );

      await currentUser?.reauthenticateWithCredential(credential);

      // Atualiza a senha
      await currentUser?.updatePassword(novaSenha);

      isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = _handleAuthError(e);
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = "Erro ao atualizar a senha. Tente novamente.";
      notifyListeners();
    }
  }

  // Método para carregar os dados atualizados do Firestore
  Future<void> carregarDadosAtualizados() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Recarrega os dados do Firestore
        final userData = await _db.collection('users').doc(user.uid).get();
        final userInfo = userData.data();

        // Atualiza os dados do usuário com as informações do Firestore
        if (userInfo != null) {
          currentUser = _auth.currentUser;
          await currentUser?.updateDisplayName(userInfo['name']);
          await currentUser?.updatePhotoURL(userInfo['img']);
          notifyListeners(); // Notifica a UI sobre os novos dados carregados
        }
      }
    } catch (e) {
      errorMessage = "Erro ao carregar dados atualizados do usuário.";
      notifyListeners();
    }
  }

  // Método para deletar o usuário e seus arquivos do Firebase Storage e Firestore
  Future<void> deletarUsuario(String userId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners(); // Atualiza o estado da View

      // Excluir arquivos do Firebase Storage associados ao usuário
      Reference storageRef = _storage.ref().child('user_images/$userId');
      await storageRef.delete();  // Exclui a imagem do perfil do Storage

      // Excluir o usuário do Firestore
      await _db.collection('users').doc(userId).delete();

      // Excluir o usuário do Firebase Authentication
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
      }

      isLoading = false;
      notifyListeners(); // Finaliza o estado de carregamento e notifica a View
    } catch (e) {
      isLoading = false;
      errorMessage = "Erro ao deletar o usuário. Tente novamente.";
      notifyListeners(); // Notifica a View sobre o erro
    }
  }
}
