import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mind_quest/providers/quest_provider.dart';
import 'package:mini_mind_quest/widgets/ad_bar_widget.dart';
import 'package:mini_mind_quest/widgets/animated_quest_card.dart';
import 'package:mini_mind_quest/widgets/top_app_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);

    return Scaffold(
      appBar: const TopAppBar(title: 'Mini Mind Quest'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF59D), // soft yellow
              Color(0xFF81D4FA), // sky blue
              Color(0xFFF48FB1), // playful pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  itemCount: questProvider.quests.length,
                  itemBuilder: (_, index) {
                    final quest = questProvider.quests[index];
                    return AnimatedQuestCard(quest: quest, index: index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBarWidget(),
    );
  }
}
