import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/state/credentials.dart';

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
   final cred = await CredentialsRepository.loadCredentials();
  
  print(cred.accToken);
  return fetchCurrentUser(cred.instanceUrl!, cred.accToken!);
});

final selectedUserProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
   final cred = await CredentialsRepository.loadCredentials();
  

  return fetchUserById(id, cred.instanceUrl!, cred.accToken!);
});
