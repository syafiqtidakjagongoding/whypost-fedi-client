import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/relationship_api.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/sharedpreferences/credentials.dart';

final relationshipProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
      final cred = await CredentialsRepository.loadCredentials();
      if (cred.instanceUrl == null || cred.accToken == null) {
        throw Exception("Error");
      }

      return fetchRelationshipById(userId, cred.instanceUrl!, cred.accToken!);
    });

final followUserProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, userId) async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.instanceUrl == null || cred.accToken == null) {
      throw Exception("Error");
    }

    return await followUser(
      instanceUrl: cred.instanceUrl!,
      token: cred.accToken!,
      userId: userId,
    );
  },
);


final unfollowUserProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, userId) async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.instanceUrl == null || cred.accToken == null) {
      throw Exception("Error");
    }

    return await unfollowUser(
      instanceUrl: cred.instanceUrl!,
      token: cred.accToken!,
      userId: userId,
    );
  },
);
