import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/state/instance.dart';
import 'package:mobileapp/state/instanceurl.dart';
import 'package:mobileapp/state/token.dart';

final homeTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final instance = await ref.read(instanceUrlProvider.future);
    final token = await ref.read(tokenProvider.future);

    if (token == null || instance == null) {
      throw Exception("Missing instance or token");
    }
    final resp = await fetchHomeTimeline(instance, token, 20);
    return resp;
  } catch (e) {
    print(e);
    throw e;
  }
});
