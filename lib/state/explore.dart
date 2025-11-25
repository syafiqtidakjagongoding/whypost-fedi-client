import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/explore_api.dart';
import 'package:mobileapp/state/credentials.dart';

class SuggestedPeopleNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return [];
    }

    return await fetchSuggestedPeople(cred.instanceUrl!, cred.accToken!);
  }
}

final suggestedPeopleProvider =
    AsyncNotifierProvider<SuggestedPeopleNotifier, List<dynamic>>(
  () => SuggestedPeopleNotifier(),
);


final searchQueryProvider = StateProvider<String>((ref) => "");

class SearchResultsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final query = ref.watch(searchQueryProvider);

    if (query.trim().isEmpty) {
      return {
        "accounts": [],
        "statuses": [],
        "hashtags": [],
      };
    }

    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return {};
    }

    return await searchAny(
      cred.instanceUrl!,
      cred.accToken!,
      query,
    );
  }
}

final searchResultsProvider = AsyncNotifierProvider<SearchResultsNotifier, Map<String, dynamic>>(
  () => SearchResultsNotifier(),
);
