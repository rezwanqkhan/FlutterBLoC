import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Unscramble',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WordGameScreen(),
    );
  }
}

class WordGameScreen extends StatefulWidget {
  @override
  _WordGameScreenState createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  final List<String> words = ['flutter', 'dart', 'widget', 'state', 'build'];
  late String currentWord;
  late String scrambledWord;
  String userGuess = '';
  String message = '';
  int score = 0;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    currentWord = words[Random().nextInt(words.length)];
    scrambledWord = _scrambleWord(currentWord);
    userGuess = '';
    message = '';
    setState(() {});
  }

  String _scrambleWord(String word) {
    List<String> characters = word.split('');
    characters.shuffle();
    return characters.join();
  }

  void _checkAnswer() {
    if (userGuess.toLowerCase() == currentWord) {
      setState(() {
        message = 'Correct!';
        score++;
      });
      Future.delayed(Duration(seconds: 1), _newGame);
    } else {
      setState(() {
        message = 'Try again!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Unscramble'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Unscramble the word:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              scrambledWord,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Container(
              width: 200,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    userGuess = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter your guess',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Check'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
