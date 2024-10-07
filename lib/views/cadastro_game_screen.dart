import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';

class CadastroGameScreen extends StatefulWidget {
  const CadastroGameScreen({super.key});

  @override
  State<CadastroGameScreen> createState() => _CadastroGameScreenState();
}

class _CadastroGameScreenState extends State<CadastroGameScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para os campos do formulário
  TextEditingController nomeController = TextEditingController();
  TextEditingController sobreController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController downloadsController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  // Para armazenar a imagem do jogo
  File? _imageFile;
  File? _thumbFile;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isUploadingImage = false; // Flag para indicar upload
  String? lancamentoOuDestaqueSelecionado; // Variável para armazenar a escolha entre "Lançamento" ou "Destaque"

  // Método para escolher imagem
  Future<void> _pickImage(bool isThumb) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (isThumb) {
          _thumbFile = File(pickedFile.path);
        } else {
          _imageFile = File(pickedFile.path);
        }
      }
    });
  }

  // Método para salvar o game no Firestore
  Future<void> _saveGame() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Cria ID único para o game
        String gameId = const Uuid().v4();

        // Upload de imagens para o Firebase Storage
        String? imageUrl;
        String? thumbUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToStorage(gameId, _imageFile!, "image");
        }
        if (_thumbFile != null) {
          thumbUrl = await _uploadImageToStorage(gameId, _thumbFile!, "thumb");
        }

        // Criação do objeto Game
        Game newGame = Game(
          id: gameId,
          nome: nomeController.text.trim(),
          sobre: sobreController.text.trim(),
          img: imageUrl,
          thumb: thumbUrl,
          rating: double.parse(ratingController.text.trim()),
          downloads: double.parse(downloadsController.text.trim()),
          categoria: categoriaController.text.trim(),
          lancamentoOuDestaque: lancamentoOuDestaqueSelecionado,
          link: linkController.text.trim(),
        );

        // Salvar no Firestore
        await FirebaseFirestore.instance
            .collection('games')
            .doc(gameId)
            .set(newGame.toMap());

        // Exibe mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game cadastrado com sucesso!')),
        );

        // Retorna true para a tela anterior
        Navigator.pop(context, true); // Passa true indicando que houve uma atualização
      } catch (e) {
        print("Erro ao cadastrar o game: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar o game. Tente novamente.')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Método para upload de imagem para o Firebase Storage
  Future<String> _uploadImageToStorage(String gameId, File image, String type) async {
    try {
      Reference storageRef =
      FirebaseStorage.instance.ref().child('games/$gameId/$type');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erro ao enviar imagem: $e");
      throw e;
    }
  }

  // Método para limpar o formulário
  void _clearForm() {
    nomeController.clear();
    sobreController.clear();
    ratingController.clear();
    downloadsController.clear();
    categoriaController.clear();
    lancamentoOuDestaqueSelecionado = null;
    linkController.clear();
    _imageFile = null;
    _thumbFile = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Novo Game"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo para o nome do game
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome do Game"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do game é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para a descrição (sobre) do game
              TextFormField(
                controller: sobreController,
                decoration: const InputDecoration(labelText: "Sobre o Game"),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição do game é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: linkController,
                decoration: const InputDecoration(labelText: "Link da Página do Jogo"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O link é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para rating
              TextFormField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: "Avaliação (Rating)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A avaliação é obrigatória';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor numérico válido para a avaliação';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para downloads
              TextFormField(
                controller: downloadsController,
                decoration: const InputDecoration(labelText: "Número de Downloads"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O número de downloads é obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor numérico válido para downloads';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para categoria
              TextFormField(
                controller: categoriaController,
                decoration: const InputDecoration(labelText: "Categoria"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A categoria é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para selecionar Lançamento ou Destaque
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selecione o tipo do game:"),
                  RadioListTile<String>(
                    title: const Text('Lançamento'),
                    value: 'Lançamento',
                    groupValue: lancamentoOuDestaqueSelecionado,
                    onChanged: (String? value) {
                      setState(() {
                        lancamentoOuDestaqueSelecionado = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Destaque'),
                    value: 'Destaque',
                    groupValue: lancamentoOuDestaqueSelecionado,
                    onChanged: (String? value) {
                      setState(() {
                        lancamentoOuDestaqueSelecionado = value;
                      });
                    },
                  ),
                ],
              ),

              // Upload de imagem principal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _imageFile != null
                      ? Image.file(
                    _imageFile!,
                    width: 100,
                    height: 100,
                  )
                      : const Text("Nenhuma imagem selecionada"),
                  ElevatedButton(
                    onPressed: () => _pickImage(false),
                    child: const Text("Selecionar Imagem"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Upload de thumbnail
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _thumbFile != null
                      ? Image.file(
                    _thumbFile!,
                    width: 100,
                    height: 100,
                  )
                      : const Text("Nenhuma thumbnail selecionada"),
                  ElevatedButton(
                    onPressed: () => _pickImage(true),
                    child: const Text("Selecionar Thumbnail"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botão para salvar o game
              ElevatedButton(
                onPressed: _saveGame,
                child: const Text("Cadastrar Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}