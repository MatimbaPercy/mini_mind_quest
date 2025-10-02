import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mini_mind_quest/helpers/adHelper.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/ad_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  AdHelper().initialize(); // <-- initialize Google Mobile Ads
  runApp(const MiniMindQuestApp());
}

class MiniMindQuestApp extends StatelessWidget {
  const MiniMindQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()..loadQuests()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MaterialApp(
        title: 'MiniMind Quest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: HomeScreen(),
      ),
    );
  }
}
