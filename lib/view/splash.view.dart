import 'dart:async';
import 'package:damamiflutter/utils/global.images.dart';
import 'package:damamiflutter/view/login.view.dart';
import 'package:flutter/material.dart';


class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Using this for verifying light or dark theme in device - Anderson
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = false;///brightnessValue == Brightness.dark;

      Timer(const Duration(seconds: 2), () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginView())); });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlobalImages.logoimageloading,
            const SizedBox(height: 16), //
            Text('Damami App', style: TextStyle(fontSize: 16,fontFamily: 'Roboto',fontWeight: FontWeight.bold,color: isDark ? Colors.white : Colors.black ),),
          ],
        ),
      ),
    );
  }
}
