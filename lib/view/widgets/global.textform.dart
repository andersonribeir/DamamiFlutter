import 'package:flutter/material.dart';
class GlobalTextForm extends StatelessWidget {
  const GlobalTextForm({Key? key, required this.controller, required this.text, required this.textInputType, required this.obscure}) : super(key: key);
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 55,
      padding: const EdgeInsets.only(top: 3,left: 15),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.3),
            blurRadius: 7
          )
        ]

      ),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration:  InputDecoration(
          hintText: text,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(0),
          hintStyle: const TextStyle(
            height: 1
          )
            
        ),
        validator: (value){
          controller.text = value!;
          return controller.text;
        },
      ),
    );
  }
}
