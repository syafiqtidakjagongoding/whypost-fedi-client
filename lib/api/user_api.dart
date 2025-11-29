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

Future<Map<String, dynamic>?> fetchUserByAcct(
  String acct, // ganti dari id ke acct
  String instanceUrl,
  String token,
) async {
  final url = Uri.parse(
    'https://$instanceUrl/api/v1/accounts/lookup',
  ).replace(queryParameters: {'acct': acct}); // <-- query param
  print("prin $url");
  final res = await http.get(url, headers: {"Authorization": "Bearer $token"});

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  } else {
    print('Error fetch user: ${res.statusCode} ${res.body}');
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
    return user;
  } else {
    print('Error fetching current user: ${res.statusCode} - ${res.body}');
    return null;
  }
}

Future<Map<String, dynamic>?> followUser({
  required String instanceUrl,
  required String token,
  required String userId,
  bool reblogs = true,
  bool notify = false,
}) async {
  final url = Uri.parse('$instanceUrl/api/v1/accounts/$userId/follow');

  final res = await http.post(
    url,
    headers: {'Authorization': 'Bearer $token'},
    body: {'reblogs': reblogs.toString(), 'notify': notify.toString()},
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    print('Error following user: ${res.statusCode} - ${res.body}');
    return null;
  }
}

/// Unfollow user by ID
Future<Map<String, dynamic>?> unfollowUser({
  required String instanceUrl,
  required String token,
  required String userId,
}) async {
  final url = Uri.parse('$instanceUrl/api/v1/accounts/$userId/unfollow');

  final res = await http.post(url, headers: {'Authorization': 'Bearer $token'});

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    print('Error unfollowing user: ${res.statusCode} - ${res.body}');
    return null;
  }
}
