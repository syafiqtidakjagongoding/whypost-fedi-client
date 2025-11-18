import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchUserById(
  String id,
  String instanceUrl,
  String token,
) async {
  final url = Uri.parse('$instanceUrl/api/v1/accounts/$id');

  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    print('Error fetch user: ${res.body}');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchCurrentUser(
  String instanceUrl,
  String token,
) async {
  final url = Uri.parse('$instanceUrl/api/v1/accounts/verify_credentials');

  final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});

  if (res.statusCode == 200) {
    final user = jsonDecode(res.body);
    print(user);
    return user;
  } else {
    print('Error fetching current user: ${res.statusCode} - ${res.body}');
    return null;
  }
}
