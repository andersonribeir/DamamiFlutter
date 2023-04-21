class Login {
   String email;
   String senha;

  Login({required this.email, required this.senha});

  Map toJson()=>{
    'email':email,
    'senha':senha
  };
}