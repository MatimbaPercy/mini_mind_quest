import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final supabase = Supabase.instance.client;

  Future<void> logImpression(String adType, String userId) async {
    await supabase.from('ad_impressions').insert({
      'user_id': userId,
      'ad_type': adType,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logQuestCompletion(String questId, String userId) async {
    await supabase.from('quest_logs').insert({
      'user_id': userId,
      'quest_id': questId,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }
}
