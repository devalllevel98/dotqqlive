import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOverScreen extends StatelessWidget {
  final int score;

  const GameOverScreen({Key? key, required this.score}) : super(key: key);

  Future<void> saveScoreAndTime(int score, DateTime gameOverTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentKey = prefs.getInt('score_counter') ?? 0;
    String scoreKey = 'score_$currentKey';
    String timeKey = 'time_$currentKey';

    await prefs.setInt(scoreKey, score);
    await prefs.setString(timeKey, gameOverTime.toIso8601String());

    // Increment score counter
    await prefs.setInt('score_counter', currentKey + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bg.gif',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Your Score:',
                  style: TextStyle(fontSize: 24,color: Colors.white ),
                ),
                Text(
                  '$score',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    DateTime gameOverTime = DateTime.now();
                    saveScoreAndTime(score, gameOverTime);  // Save score and time locally
                    Navigator.pop(context); // Close game over screen
                  },
                  child: Text('Back to menu'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

