import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_store/views/cadastro_game_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game.dart';

class GameDetalheScreen extends StatelessWidget {
  final Game game; // Recebe o objeto Game que será exibido

  const GameDetalheScreen({Key? key, required this.game}) : super(key: key);

  // Função para abrir o link no navegador
  void launchURL(String url) async {
    Uri uri = Uri.parse(url); // Converte a string em um objeto Uri
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Define a cor dos ícones do AppBar (incluindo a seta de voltar)
        ),
        title: const Text(
          'Detalhes do Jogo',
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontFamily: 'Alata'),
        ),
        backgroundColor: const Color(0xFF161616),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              // Navega para a tela de edição do game
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CadastroGameScreen(game: game),
                ),
              );
              if (updated == true) {
                Navigator.pop(context, true); // Passa true para a GameListScreen indicando atualização
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Função para deletar o jogo
              _deleteGame(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do jogo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  game.img != null && game.img!.isNotEmpty
                      ? game.img!
                      : "https://www.designi.com.br/images/preview/10883080.jpg", // Imagem padrão
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),

              // Nome do Jogo
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F), // Fundo retangular com cor
                    borderRadius: BorderRadius.circular(15), // Bordas arredondadas
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFFF5F9F),
                          Color(0xFFC655D7),
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn, // Aplica o gradiente ao texto
                    child: Text(
                      game.nome ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Mantém a cor original do texto
                        fontFamily: 'Alata',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Informações sobre o jogo: Rating, Downloads, Categoria
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard('Rating', "${game.rating?.toStringAsFixed(1)}★"),
                  _buildInfoCard('Downloads', "${game.downloads?.toStringAsFixed(0)}+"),
                  _buildInfoCard('Categoria', game.categoria ?? ''),
                ],
              ),
              const SizedBox(height: 16),

              // Seção de "Sobre"
              const Text(
                "Sobre",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Alata',
                ),
              ),
              const SizedBox(height: 8),

              Text(
                game.sobre ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Alata',
                ),
              ),
              const SizedBox(height: 24),

              // Botão "Saiba mais"
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFF5F9F),
                        Color(0xFFC655D7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.transparent, // Deixa o fundo do ElevatedButton transparente
                      shadowColor: Colors.transparent, // Remove sombra para não interferir no gradiente
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (game.link != null && game.link!.isNotEmpty) {
                        launchURL(game.link!); // Agora funcionando corretamente com Uri
                      } else {
                        // Mostra uma mensagem de erro se o link estiver ausente
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link do jogo não disponível')),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Saiba mais",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Alata',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
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

  // Widget para criar os cards de informações (Rating, Downloads, Categoria)
  Widget _buildInfoCard(String title, String info) {
    // Define o ícone baseado no título
    IconData iconData;
    switch (title) {
      case 'Rating':
        iconData = Icons.star; // Ícone de estrela para rating
        break;
      case 'Downloads':
        iconData = Icons.download; // Ícone de download
        break;
      case 'Categoria':
        iconData = Icons.grid_view_rounded; // Ícone de grid view para categorias
        break;
      default:
        iconData = Icons.info; // Ícone padrão caso necessário
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Ícone com gradiente
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF5F9F),
                  Color(0xFFC655D7),
                ],
              ).createShader(bounds);
            },
            child: Icon(
              iconData,
              size: 30, // Define o tamanho do ícone
              color: Colors.white, // A cor é controlada pelo ShaderMask
            ),
          ),
          const SizedBox(height: 8),

          // Título do card (ex: Rating, Downloads, Categoria)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Alata',
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),

          // Informações (valor do rating, downloads, categoria)
          Text(
            info,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Alata',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Método para deletar o jogo
  void _deleteGame(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('games')
          .doc(game.id)
          .delete();
      Navigator.pop(context); // Volta à tela anterior após deletar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jogo deletado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao deletar o jogo.')),
      );
    }
  }
}
