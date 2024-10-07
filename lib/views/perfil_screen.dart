import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/usuario_view_model.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  // Controladores dos TextFields
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaAtualController = TextEditingController();
  TextEditingController novaSenhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Função para carregar dados do usuário sempre que acessar a tela de perfil
  Future<void> _loadUserData() async {
    final userViewModel = Provider.of<UsuarioViewModel>(context, listen: false);
    await userViewModel.carregarDadosAtualizados(); // Recarrega dados do Firestore
    setState(() {
      nomeController.text = userViewModel.currentUser?.displayName ?? '';
      emailController.text = userViewModel.currentUser?.email ?? '';
      _pickedImage = null; // Resetar a imagem selecionada se já tiver sido alterada
    });
  }

  // Método para abrir a galeria ou a câmera
  Future<void> _showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Escolher da Galeria"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tirar uma foto"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          );
        });
  }

  // Método para pegar a imagem da câmera ou da galeria
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    setState(() {
      _pickedImage = image;
    });
  }

  // Método para atualizar os dados do usuário
  Future<void> _updateUserProfile() async {
    final userViewModel = Provider.of<UsuarioViewModel>(context, listen: false);

    // Se o usuário informou uma nova senha, tenta alterar a senha
    if (novaSenhaController.text.isNotEmpty && senhaAtualController.text.isNotEmpty) {
      await userViewModel.atualizarSenha(senhaAtualController.text, novaSenhaController.text);
    }

    // Atualiza nome e imagem
    await userViewModel.editarUsuario(
      userViewModel.currentUser?.uid ?? '',
      nomeController.text,
      newImageFile: _pickedImage != null ? File(_pickedImage!.path) : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );

    Navigator.pop(context, true); // Volta e sinaliza que houve alteração
  }

  // Método para deletar o usuário
  Future<void> _deleteUser() async {
    final userViewModel = Provider.of<UsuarioViewModel>(context, listen: false);
    await userViewModel.deletarUsuario(userViewModel.currentUser?.uid ?? '');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UsuarioViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        iconTheme: const IconThemeData(
          color: Colors.white, // Define a cor dos ícones do AppBar (incluindo a seta de voltar)
        ),
        title: Text(
          "Configuração do Perfil",
          style: GoogleFonts.alata(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path))
                          : NetworkImage(userViewModel.currentUser?.photoURL ??
                          "https://www.designi.com.br/images/preview/10883080.jpg") as ImageProvider,
                      radius: 170,
                    ),
                    Positioned(
                      bottom: 10,
                      right: MediaQuery.of(context).size.width * 0.05, // Centraliza de acordo com a tela
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Forma circular
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFFF5F9F),
                              Color(0xFFC655D7),
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFFF5F9F),
                              blurRadius: 3,
                              spreadRadius: 1,
                              offset: Offset(0, 0), // Sombra para dar efeito de elevação
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            _showImagePickerOptions(context); // Abre a opção para escolha da foto
                          },
                          icon: const Icon(
                            Icons.photo_camera,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: nomeController,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Nome",
                      hintStyle: const TextStyle(
                        fontFamily: 'Alata',
                        fontSize:                      20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xffe5e5e5),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "E-mail",
                      hintStyle: const TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xffe5e5e5),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: senhaAtualController,
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Senha Atual",
                      hintStyle: const TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xffe5e5e5),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: novaSenhaController,
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Nova Senha",
                      hintStyle: const TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xffe5e5e5),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Botão Deletar conta
                  _buildDeleteButton(context, userViewModel),
                  // Botão Editar conta
                  _buildEditButton(context, userViewModel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botão de Deletar conta
  Widget _buildDeleteButton(BuildContext context, UsuarioViewModel userViewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Color(0xffea384d), Color(0xffd31027)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Fundo transparente
          shadowColor: Colors.transparent, // Remove a sombra
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          bool? shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text('Você tem certeza que deseja deletar sua conta?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sim'),
                ),
              ],
            ),
          );
          if (shouldDelete == true) {
            await _deleteUser();
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: userViewModel.isLoading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : const Text(
            "DELETAR",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Alata',
            ),
          ),
        ),
      ),
    );
  }

  // Botão de Editar conta
  Widget _buildEditButton(BuildContext context, UsuarioViewModel userViewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF5F9F),
            Color(0xFFC655D7),
          ],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          await _updateUserProfile();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
          child: userViewModel.isLoading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : const Text(
            "EDITAR",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Alata',
            ),
          ),
        ),
      ),
    );
  }
}

