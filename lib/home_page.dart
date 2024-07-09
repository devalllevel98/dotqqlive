import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transpate/game_painter.dart';
import 'package:transpate/gamover.dart';
import 'package:transpate/home_page_bloc.dart';
import 'package:audioplayers/audioplayers.dart';

// Import your game over screen widget

class HomePage extends StatefulWidget {
  final double centerX;
  final double centerY;
  const HomePage({
    super.key,
    required this.centerX,
    required this.centerY,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late HomePageBloc _bloc;
  late DateTime gameOverTime;
  bool _isGameRunning = false;

  @override
  void initState() {
    super.initState();
     audioPlayer = AudioPlayer();
     play('/nen.mp3');
    _bloc = HomePageBloc(
      widget.centerX,
      widget.centerY,
      double.infinity,
      resetGame,
      _showCountdown,
    );
    // Initialize animation controller
    _bloc.controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  // Show countdown
  void _showCountdown(bool show) {
    setState(() {
      _bloc.isCountDown = show;
    });
  }

  // Reset game
  void resetGame() {
    setState(() {
      _bloc.iceBlocks = [];
      _bloc.iceShards = [];
      _bloc.score = 0;
      _bloc.teaHeight = 0;
      _bloc.isColliding = false;
      _bloc.collisionTimer = 0;
      _bloc.angle = 0;
      _bloc.level = 0;
      _bloc.countDown = 3;
      _bloc.iceSpeed = _bloc.speedList[_bloc.level][0];
      _bloc.bubbleSpeed = _bloc.speedList[_bloc.level][1];
    });
  }

  // Start game
  void startGame() {
    _bloc.controller.repeat(); // Repeat animation
    _bloc.controller.addListener(() {
      setState(() {
        _bloc.update(); // Update game state
      });
    });
    // Set timer to generate ice blocks every 500 milliseconds
    _bloc.iceBlockTimer = Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
      if (!_bloc.isCountDown) {
        _bloc.addIceBlock();
      }
    });
  }

  // Stop game
  void stopGame() {
    _bloc.controller.stop(); // Stop animation
    _bloc.iceBlockTimer.cancel(); // Cancel timer
    _showGameOverScreen(); // Show game-over screen
  }

  // Show game-over screen
  void _showGameOverScreen() async {
    // Navigate to game-over screen and pass the score
    int finalScore = _bloc.score;
    await saveScore(finalScore); // Save score locally
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameOverScreen(score: finalScore)),
    );
  }

  // Save score locally using shared_preferences
  Future<void> saveScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_score', score);
  }

  // Toggle game state (start/stop)
  void toggleGame() {
    setState(() {
      if (_isGameRunning) {
        stopGame();
      } else {
        startGame();
      }
      _isGameRunning = !_isGameRunning;
    });
  }

  @override
  void dispose() {
    // Dispose of timer and animation controller
    if (_bloc.iceBlockTimer.isActive) {
      _bloc.iceBlockTimer.cancel();
    }
    _bloc.controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
    Future<void> play(String audioPath) async {
    final response = await audioPlayer.play(AssetSource(audioPath));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
            'assets/bg.gif',
            fit: BoxFit.fill,
          )),
                  GestureDetector(
          onTapDown: (details) {
            if (!_bloc.isCountDown) {
              if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
                _bloc.rotationSpeed = -_bloc.bubbleSpeed; // Click left half, rotate counterclockwise
              } else {
                _bloc.rotationSpeed = _bloc.bubbleSpeed; // Click right half, rotate clockwise
              }
            }
          },
          onTapUp: (details) {
            _bloc.rotationSpeed = 0; // Stop rotation
          },
          child: Stack(
            children: [
              CustomPaint(
                painter: GamePainter(
                  angle: _bloc.angle,
                  radius: _bloc.radius,
                  centerX: _bloc.centerX,
                  centerY: _bloc.centerY,
                  pearlRadius: _bloc.pearlRadius,
                  iceBlocks: _bloc.iceBlocks,
                  iceShards: _bloc.iceShards,
                  teaHeight: _bloc.teaHeight,
                ),
                child: Container(),
              ),
              if (_bloc.isCountDown)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 255, 72).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Countdown ${_bloc.countDown}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Text(
                      'Level ${_bloc.level + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_bloc.score}',
                      style: TextStyle(
                        fontSize: 42,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left:MediaQuery.of(context).size.width / 2-95,
                child:
                 ElevatedButton(
                              child: Text(_isGameRunning ? 'Stop Game' : 'Start Game', 
                              style: TextStyle(
                                color:  Color.fromARGB(255, 255, 255, 255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                              ),),
                          onPressed: toggleGame,
                           style: ButtonStyle(
          
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0), // Điều chỉnh độ cong của border
                              side: BorderSide(color:_isGameRunning ? Colors.red:Color.fromARGB(255, 123, 255, 0), width: 2.0), // Điều chỉnh màu sắc và độ dày của border
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), 
                        ),
                            ),
                  ),
            ],
          ),
        ),
     
          ],
        )

      ),
    );
  }
}
