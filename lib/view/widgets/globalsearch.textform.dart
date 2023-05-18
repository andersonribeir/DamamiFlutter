import 'package:flutter/material.dart';
class GlobalSearchTextForm extends StatelessWidget {
   GlobalSearchTextForm({Key? key, required this.controller, required this.text, required this.textInputType, required this.obscure,required this.focusNode}) : super(key: key);
  final TextEditingController controller;
  final String text;
  FocusNode focusNode = FocusNode();
  final TextInputType textInputType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 30,

      width: 65,
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.only(top: 3,left: 15),
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
        focusNode: focusNode,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration:  InputDecoration(
            hintText: text,
            border: InputBorder.none,
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
