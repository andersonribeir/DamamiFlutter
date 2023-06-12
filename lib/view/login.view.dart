import 'package:damamiflutter/services/ApiService.dart';
import 'package:damamiflutter/utils/global.colors.dart';
import 'package:damamiflutter/utils/global.images.dart';
import 'package:damamiflutter/view/mainpage.view.dart';

import 'package:damamiflutter/view/widgets/global.textform.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = false;

  Future<bool> verificaLogin(String login, String senha) async {
    ApiService api = ApiService();
    return await api.LoginUser(login, senha);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Container(
                  alignment: Alignment.center,
                  child: GlobalImages.logoimageLogin,
                ),
                const SizedBox(height: 50,),
                Column(
                  children: [
                    Text(
                      'Entre com sua conta Damami',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30,),
                    GlobalTextForm(
                      controller: loginController,
                      text: 'Login',
                      textInputType: TextInputType.text,
                      obscure: false,
                    ),
                    const SizedBox(height: 20,),
                    GlobalTextForm(
                      controller: senhaController,
                      text: 'Senha',
                      textInputType: TextInputType.visiblePassword,
                      obscure: true,
                    ),
                    const SizedBox(height: 40,),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (loginController.text.trim() == "" || senhaController.text.trim() == "") {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Dados não inseridos."),
                                content: Text("Por favor, insira os dados para acesso ao sistema."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Ok"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            isLoading = true;
                          });

                          if (await verificaLogin(loginController.text, senhaController.text)) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Dados Inválidos"),
                                  content: Text("Login e/ou senha incorretos. Por favor, insira dados válidos de acesso."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }

                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(GlobalColors.mainColor),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        minimumSize: MaterialStateProperty.all<Size>(Size(MediaQuery.of(context).size.width - 85, 55)),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        "Login",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
                      ),
                    ),
                    const SizedBox(height: 100,),
                    Text(
                      'DAMAMI',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        fontFamily: 'Dogma',
                        color: GlobalColors.mainColor,
                      ),
                    ),
                    const SizedBox(height: 35,),
                    Text(
                      'Sistema de Controle de Produção de Bananas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
