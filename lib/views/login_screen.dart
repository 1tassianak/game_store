import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_store/views/cadastro_usuario_screen.dart';
import 'package:game_store/views/game_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Controladores dos TextFields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variáveis de controle de estado
  bool _isLoading = false;
  String? _errorMessage;

  // Função para realizar login com Firebase
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpa mensagem de erro
    });

    try {
      // Faz login com email e senha
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o login for bem-sucedido, navega para a tela de lista de jogos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Captura erros de autenticação
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Usuário não encontrado.';
            break;
          case 'wrong-password':
            _errorMessage = 'Senha incorreta.';
            break;
          case 'invalid-email':
            _errorMessage = 'Formato de e-mail inválido.';
            break;
          default:
            _errorMessage = 'Ocorreu um erro. Tente novamente.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false; // Remove o indicador de carregamento
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161616),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SafeArea(
                child: SizedBox.shrink(), // Não exibe nada no SafeArea
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text("GAME STORE",
                  style: GoogleFonts.alata(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 36
                    )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Image.asset("img/bggame.png"),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 16
                    ),
                    decoration: InputDecoration(
                        hintText: "E-mail",
                        hintStyle: TextStyle(
                          fontFamily: 'Alata',  // Aplicar também a fonte no hintText
                          fontSize: 20,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                            )
                        ),
                        filled: true,
                        fillColor: Color(0xffe5e5e5)
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                        fontFamily: 'Alata',
                        fontSize: 16
                    ),
                    decoration: InputDecoration(
                        hintText: "Senha",
                        hintStyle: TextStyle(
                          fontFamily: 'Alata',  // Aplicar também a fonte no hintText
                          fontSize: 20,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none
                            )
                        ),
                        filled: true,
                        fillColor: Color(0xffe5e5e5)
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) // Exibe mensagem de erro se houver
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              Container(
                margin: EdgeInsets.only(top:26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Mesma borda arredondada do botão
                  gradient: LinearGradient(
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
                        backgroundColor: Colors.transparent, // Deixa o fundo do botão transparente
                        shadowColor: Colors.transparent, // Remove a sombra para que não interfira no gradiente
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        )
                    ),
                    onPressed: _isLoading ? null : _login, // Desativa o botão se estiver carregando
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "LOGIN",
                          style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Alata'),
                        ),
                    ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                child: Text("Não possui cadastro? Clique aqui.",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Alata',
                  ),
                ),
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroUsuarioScreen(),
                      )
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
