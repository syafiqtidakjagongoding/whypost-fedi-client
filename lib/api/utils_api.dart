import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getToken(String? userid) async {
  String userId = userid ?? 'guest';
  final response = await http.get(
    Uri.parse(
      "https://presign-worker.syafiq-paradisam.my.id/get-token?userId=null"
    ),
  );

  // Parse JSON
  final data = jsonDecode(response.body);
  print(response.body);
  // Ambil properti "token"
  final token = data['token'] as String;
  print("TOKEN:$token");

  return token;
}
