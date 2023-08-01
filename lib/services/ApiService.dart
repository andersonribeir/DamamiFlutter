import 'dart:convert';
import 'dart:io';

import 'package:damamiflutter/models/Login.dart';
import 'package:damamiflutter/utils/global.configs.dart';


class ApiService{

  Future<String> LoginUser(String loginInput, String senhaInput) async {
    Login login =  Login(email: loginInput,senha: senhaInput);
    var body = login.toJson();

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await httpClient.postUrl(Uri.parse("${Configs.urlApi}api/Pessoa/Login"));
    request.headers.set('Content-Type', 'application/json');
    String jsonBody = json.encode(body);

    request.write(jsonBody);

    HttpClientResponse response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      String responseText = await response.transform(utf8.decoder).join();

      //Converte a string JSON em um objeto Dart (Map<String, dynamic>).
      Map<String, dynamic> jsonData = jsonDecode(responseText);

      int userId = jsonData['user_Id'];
      return userId.toString();
    }else{
      return "Erro";
    }

  }
  Future<String> GetChart(String chart,String unidade, String anoInicial,String anoFinal) async {

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("${Configs.urlApi}api/Chart/GetChartData/${chart}/${unidade}/${anoInicial}/${anoFinal}"));

    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == HttpStatus.ok) {
      return responseBody;
    }else{
      return "";
    }
  }

  Future<String> GetUnidades(String uid) async {

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("${Configs.urlApi}api/Chart/GetUnidades/$uid"));

    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == HttpStatus.ok) {
      return responseBody;
    }else{
      return "";
    }
  }
  Future<String> GetChartDecimal(String chart,String unidade, String anoInicial,String anoFinal) async {

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("${Configs.urlApi}api/Chart/GetChartDataDecimal/${chart}/${unidade}/${anoInicial}/${anoFinal}"));

    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == HttpStatus.ok) {
      return responseBody;
    }else{
      return "";
    }
  }
}