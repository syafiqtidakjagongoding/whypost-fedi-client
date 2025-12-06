import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/api/explore_api.dart';
import 'package:mobileapp/sharedpreferences/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrendingTagsNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return [];
    }

    return await fetchTrendingTags(cred.instanceUrl!, cred.accToken!);
  }
}



final trendingTagsProvider =
    AsyncNotifierProvider<TrendingTagsNotifier, List<dynamic>>(
  () => TrendingTagsNotifier(),
);

class TrendingStatusesNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return [];
    }

    return await fetchTrendingTags(cred.instanceUrl!, cred.accToken!);
  }
}



final trendingStatusesProvider =
    AsyncNotifierProvider<TrendingStatusesNotifier, List<dynamic>>(
  () => TrendingStatusesNotifier(),
);


class TrendingLinksNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return [];
    }

    return await fetchTrendingLinks(cred.instanceUrl!, cred.accToken!);
  }
}

final trendingLinksProvider =
    AsyncNotifierProvider<TrendingLinksNotifier, List<dynamic>>(
  () => TrendingLinksNotifier(),
);
  