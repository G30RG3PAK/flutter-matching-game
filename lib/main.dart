import 'package:flutter/material.dart';
import 'package:flutter_match_animal_game/game_page.dart';
import 'package:flutter_match_animal_game/my_application.dart';

void main() {
  MyApplication.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match Animal Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(title: 'Match Animal Game'),
    );
  }
}
