import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:transpate/ice_block_model.dart';

class HomePageBloc {
  double angle = 0;
  double radius = 100;
  double centerX;
  double centerY;
  double pearlRadius = 15;
  double rotationSpeed = 0;
  List<IceBlock> iceBlocks = [];
  List<IceShard> iceShards = [];
  int score = 0;
  double teaHeight = 0;
  double maxTeaHeight;
  bool isColliding = false;
  int collisionTimer = 0;
  late Timer iceBlockTimer;
  late AnimationController controller;
  final Function resetGame;
  final Function showCountdown;
  int level = 0;
  late double iceSpeed = 5.0;
  late double bubbleSpeed = 0.075;
  int countDown = 3;
  bool isCountDown = false;

  HomePageBloc(
    this.centerX,
    this.centerY,
    this.maxTeaHeight,
    this.resetGame,
    this.showCountdown,
  );

  void update() {
    if (isColliding) {
      collisionTimer++;
      updateIceShards();
      if (collisionTimer >= 120) {
        gameOver(); // Gọi phương thức gameOver khi va chạm
      }
    } else {
      angle += rotationSpeed;
      final x1 = centerX + cos(angle) * radius;
      final y1 = centerY + sin(angle) * radius;
      final x2 = centerX + cos(angle + pi) * radius;
      final y2 = centerY + sin(angle + pi) * radius;

      for (int i = iceBlocks.length - 1; i >= 0; i--) {
        final block = iceBlocks[i];
        block.y += iceSpeed;
        
        if (checkCollision(x1, y1, block) || checkCollision(x2, y2, block)) {
          isColliding = true;
          createIceShatter(block.x, block.y, block.width, block.height);
          iceBlocks.removeAt(i);
          gameOver(); // Gọi phương thức gameOver khi va chạm
        } else if (block.y > centerY * 2) {
          iceBlocks.removeAt(i);
        }
      }

      if (!isCountDown) {
        teaHeight = min(maxTeaHeight, teaHeight + 0.6);
      }
      score = teaHeight.toInt();

      if (level == 0 && score >= 500 && !isCountDown) {
        showLevelUp(0);
      } else if (level == 1 && score >= 1000 && !isCountDown) {
        showLevelUp(1);
      } else if (level == 2 && score >= 1500 && !isCountDown) {
        showLevelUp(2);
      } else if (level == 3 && score >= 2000 && !isCountDown) {
        showLevelUp(3);
      } else if (level == 4 && score >= 3000 && !isCountDown) {
        showLevelUp(4);
      }
    }
  }

  void showLevelUp(int index) {
    isCountDown = true;
    showCountdown(true);
    iceBlocks = [];
    angle = 0;
    rotationSpeed = 0;
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      countDown--;
      showCountdown(true);
      if (countDown < 1) {
        isCountDown = false;
        showCountdown(false);
        timer.cancel();
        level = index + 1;
        levelUp();
        countDown = 3;
      }
    });
  }

  void gameOver() {
    controller.stop();
    iceBlockTimer.cancel();
    // No navigation needed here, it will be handled in HomePage widget
  }

  bool checkCollision(double pearlX, double pearlY, IceBlock block) {
    double closestX = pearlX.clamp(block.x, block.x + block.width);
    double closestY = pearlY.clamp(block.y, block.y + block.height);

    double distanceX = pearlX - closestX;
    double distanceY = pearlY - closestY;

    return (distanceX * distanceX + distanceY * distanceY) <
        (pearlRadius * pearlRadius);
  }

  void addIceBlock() {
    if (!isColliding && iceBlocks.length < 5) {
      final isLeft = Random().nextBool();
      final iceWidth = centerX * 0.9;
      final leftIceX = centerX / 2 - iceWidth / 2;
      final rightIceX = centerX * 1.5 - iceWidth / 2;
      iceBlocks.add(IceBlock(
        x: isLeft ? leftIceX : rightIceX,
        y: -20,
        width: iceWidth,
        height: 30,
      ));
    }
  }

  void createIceShatter(double x, double y, double width, double height) {
    for (int i = 0; i < 50; i++) {
      iceShards.add(IceShard(
        x: x + Random().nextDouble() * width,
        y: y + Random().nextDouble() * height,
        vx: (Random().nextDouble() - 0.5) * 5,
        vy: (Random().nextDouble() - 0.5) * 5,
        size: Random().nextDouble() * 4 + 1,
        opacity: 1,
      ));
    }
  }

  void updateIceShards() {
    for (int i = iceShards.length - 1; i >= 0; i--) {
      final shard = iceShards[i];
      shard.x += shard.vx;
      shard.y += shard.vy;
      shard.opacity -= 0.02;
      if (shard.opacity <= 0) {
        iceShards.removeAt(i);
      }
    }
  }

  void levelUp() {
    iceSpeed = speedList[level][0];
    bubbleSpeed = speedList[level][1];
  }

  List<List<double>> speedList = [
    [5.0, 0.075],
    [7.0, 0.085],
    [9.5, 0.09],
    [12.0, 0.12],
    [15.0, 0.14],
  ];
}
