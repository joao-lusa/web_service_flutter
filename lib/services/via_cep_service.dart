import 'package:web_service/models/result_cep.dart';
import 'package:dio/dio.dart';

var dio = Dio();

class ViaCepService {
  static Future<ResultCep> fetchCep({String? cep}) async {
    final Uri uri = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    final response = await dio.getUri(uri);
    if (response.statusCode == 200) {
      if (response.data.toString()[1] == "e") {
        throw Exception(
            'CEP não encontrado, verifique se o CEP informado esta correto');
      } else {
        return ResultCep.fromMap(response.data);
      }
    } else {
      throw Exception('Requisição inválida!');
    }
  }
}
