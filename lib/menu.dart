import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transpate/gui.dart';
import 'package:transpate/his.dart';
import 'package:transpate/home_page.dart';
class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bgmenu.gif',
                fit: BoxFit.fill,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 260,),
                Expanded(
                  child: Center(
                    child: GridView.count(
                      crossAxisCount: 2, // Số cột trong grid
                      crossAxisSpacing: 20.0, // Khoảng cách giữa các cột
                      mainAxisSpacing: 20.0, // Khoảng cách giữa các dòng
                      padding: EdgeInsets.all(20.0), // Khoảng cách lề xung quanh grid
                      children: <Widget>[
                        _buildMenuItem(
                          label: 'Play Game',
                          imagePath: 'assets/play.png',
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage(
        centerX: MediaQuery.of(context).size.width / 2,
        centerY: MediaQuery.of(context).size.height * 3 / 5,
      ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          label: 'Guideline',
                          imagePath: 'assets/gui.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Guiline()),
                            );
                          },
                        ),
                        _buildMenuItem(
                          label: 'History Score',
                          imagePath: 'assets/his.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HistoryScreen()),
                            );
                          },
                        ),
                         _buildMenuItem(
                          label: 'Exit Game',
                          imagePath: 'assets/exit.png',
                          onTap: () {
                            exit(0);
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
 
  }

}



  Widget _buildMenuItem({required String label, required String imagePath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0), // Độ cong của viền
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Màu và độ mờ của shadow
              blurRadius: 5, // Độ mờ của shadow
              offset: Offset(0, 2), // Độ dịch chuyển của shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 130,
              height: 130,
            ),
            // SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
