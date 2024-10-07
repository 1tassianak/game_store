import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_store/views/cadastro_game_screen.dart';
import 'package:game_store/views/perfil_screen.dart';

import '../models/game.dart';
import 'game_detalhe_screen.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  User? user; // Variável para armazenar o usuário logado
  String? userImageUrl; // Variável para armazenar a URL da imagem do usuário
  String? userName; // Variável para armazenar o nome do usuário

  //Games
  List<Game> lancamentos = [];
  List<Game> destaques = [];

  @override
  void initState() {
    super.initState();
    checkUserStatus(); // Verifica o estado de autenticação
    loadGames();
  }

  // Método para verificar se o usuário está logado
  void checkUserStatus() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Se não houver usuário autenticado, redireciona para a tela de login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    } else {
      // Se o usuário estiver logado, carrega os dados
      getCurrentUser();
    }
  }

  // Método para obter o usuário logado e sua imagem do Firestore
  Future<void> getCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Obtém o documento do usuário no Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          user = currentUser;
          userImageUrl = userDoc['img'] ?? null;
          userName = userDoc['name'] ?? 'Nome do Usuário'; // Atualiza o nome do usuário a partir do Firestore
        });
      } else {
        print('Documento de usuário não existe no Firestore');
      }
    }
  }

  // Método para carregar os jogos (Lançamentos e Jogos em Destaque)
  Future<void> loadGames() async {
    QuerySnapshot lancamentosSnapshot = await FirebaseFirestore.instance
        .collection('games')
        .where('lancamentoOuDestaque', isEqualTo: 'Lançamento')
        .get();
    QuerySnapshot destaquesSnapshot = await FirebaseFirestore.instance
        .collection('games')
        .where('lancamentoOuDestaque', isEqualTo: 'Destaque')
        .get();

    setState(() {
      lancamentos = lancamentosSnapshot.docs
          .map((doc) => Game.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      destaques = destaquesSnapshot.docs
          .map((doc) => Game.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView( // Permite rolar o conteúdo do Drawer
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName ?? "Nome do Usuário"),
                accountEmail: Text(user?.email ?? "email@usuario.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userImageUrl ?? "https://www.designi.com.br/images/preview/10883080.jpg",
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Configurar Perfil"),
                onTap: () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PerfilScreen(),
                    ),
                  );

                  if (updated == true) {
                    // Atualiza os dados do usuário quando voltar
                    await getCurrentUser();
                    setState(() {});
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut(); // Realiza o logoff do Firebase

                  // Redireciona para a tela de login
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                          (Route<dynamic> route) => false);
                },
              ),

              ListTile(
                leading: Icon(Icons.gamepad),
                title: Text("Cadastrar Game"),
                onTap: () async {
                  // Ao voltar da tela de cadastro, verifica se foi passado true
                  bool? newGameAdded = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CadastroGameScreen(),
                    ),
                  );

                  // Se um novo game foi adicionado, recarrega a lista de jogos
                  if (newGameAdded == true) {
                    await loadGames(); // Recarrega os jogos se houver novos
                    setState(() {}); // Atualiza a tela
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Seção de Lançamentos
              Text("Lançamentos",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alata',
                ),
              ),
              SizedBox(
                height: 16,
              ),
              lancamentos.isNotEmpty
              ? CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: lancamentos.map((game){
                  return GestureDetector(
                    onTap: () async {
                      bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetalheScreen(game: game),
                        ),
                      );
                      if (updated == true) {
                        await loadGames();
                        setState(() {});
                      }
                    },
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          game.img ?? '',
                          fit: BoxFit.cover,
                          width: 300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ) : Center(
                child: CircularProgressIndicator(),
              ),
              
              SizedBox(
                height: 30,
              ),
              
              //Seção de Jogos em Destaque
              Text("Jogos em Destaque",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alata',
                ),
              ),

              SizedBox(
                height: 16,
              ),
              
              destaques.isNotEmpty
              ? ListView.builder(
                shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: destaques.length,
                  itemBuilder: (context, index){
                    Game game = destaques[index];
                    return GestureDetector(
                      onTap: () async {
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameDetalheScreen(game: game),
                          ),
                        );
                        if (updated == true) {
                          await loadGames();
                          setState(() {});
                        }
                      },
                      child: Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              game.thumb ?? '',
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(game.nome ?? ''),
                          subtitle: Text("${game.rating?.toStringAsFixed(1)}★"),
                        ),
                      ),
                    );
                  }
              ): Center(
                child: CircularProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
