import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/usuario_view_model.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  //Método para abrir a galeria ou a câmera
  Future<void> _showImagePickerOptions(BuildContext context) async{
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Escolher da Galeria"),
                onTap: () async{
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Tirar uma foto"),
                onTap: () async{
                  Navigator.of(context).pop();
                  await _pickImage(ImageSource.camera);
                },
              )
            ],
          );
        }
    );
  }

  //Método para pegar a imagem da câmera ou da galeria
  Future<void> _pickImage(ImageSource source) async{
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
        print("Imagem selecionada: ${_pickedImage!.path}"); // Log para verificar a imagem
      } else {
        print("Nenhuma imagem selecionada.");
      }
    } catch (e) {
      print("Erro ao pegar a imagem: $e"); // Log para erros
    }
  }

  // Controladores dos TextFields
  TextEditingController nome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Acessa o UsuarioViewModel através do Provider
    final userViewModel = Provider.of<UsuarioViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SafeArea(
                child: SizedBox.shrink(), // Não exibe nada no SafeArea
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "CADASTRO",
                  style: GoogleFonts.alata(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : NetworkImage(
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
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF5F9F),
                              blurRadius: 3,
                              spreadRadius: 1,
                              offset: Offset(0, 0), // Sombra para dar efeito de elevação
                            ),
                          ],
                        ),
                        child: IconButton(
                            onPressed: (){
                              _showImagePickerOptions(context); //Abre a opção para escolha da foto
                            },
                            icon: Icon(Icons.photo_camera,
                              size: 50,
                              color: Colors.black,
                            ),

                        ),
                      ),
                    )
                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: nome,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Nome",
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
                    controller: email,
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
                    controller: senha,
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'Alata',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Senha",
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
              Container(
                margin: const EdgeInsets.only(top: 26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Mesma borda arredondada do botão
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
                    backgroundColor: Colors.transparent, // Fundo transparente
                    shadowColor: Colors.transparent, // Remove a sombra
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    // Desativa o botão se estiver carregando
                    if (!userViewModel.isLoading) {
                      await userViewModel.registerUser(
                        nome.text,
                        email.text,
                        senha.text,
                        imageFile: _pickedImage != null ? File(_pickedImage!.path) : null, // Passa a imagem selecionada
                      );

                      if (userViewModel.errorMessage != null) {
                        // Exibe a mensagem de erro no SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userViewModel.errorMessage!),
                          ),
                        );
                      } else {
                        // Sucesso: Exibe uma mensagem de sucesso
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuário cadastrado com sucesso!'),
                          ),
                        );
                        // Volta automaticamente para a tela de login
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: userViewModel.isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "CADASTRAR",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Alata',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
