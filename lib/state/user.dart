import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/state/credentials.dart';

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final cred = await CredentialsRepository.loadCredentials();

  return fetchCurrentUser(cred.instanceUrl!, cred.accToken!);
});

final selectedUserProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  identifier,
) async {
  final cred = await CredentialsRepository.loadCredentials();

  if (identifier.startsWith("@")) {
    final clean = identifier.startsWith("@")
        ? identifier.substring(1)
        : identifier;

    // Split ke username dan host
    final parts = clean.split('@');

    if (parts.length >= 2) {
      final username = parts[0];
      final host =
          "https://${parts.sublist(1).join('@')}"; // kalau host ada @ di dalam
      print('Username: $username');
      print('Host: $host');
      if (host == cred.instanceUrl!) {
        return fetchUserByAcct("@$username", host, cred.accToken!);
      }
    } else {
      // fallback / error
      print('Invalid identifier: $identifier');
    }
  }

  return fetchUserById(identifier, cred.instanceUrl!, cred.accToken!);
});
