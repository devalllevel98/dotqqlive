import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transpate/menu.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> scoreHistory = [];

  @override
  void initState() {
    super.initState();
    loadScoreHistory();
  }

  Future<void> loadScoreHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? scoreKeys = prefs.getKeys().where((key) => key.startsWith('score_')).toList();

    if (scoreKeys != null && scoreKeys.isNotEmpty) {
      scoreHistory = [];
      for (String key in scoreKeys) {
        int score = prefs.getInt(key) ?? 0;
        String timeString = prefs.getString('time_$key') ?? '';
        DateTime time = DateTime.tryParse(timeString) ?? DateTime.now();
        scoreHistory.add({'score': score, 'time': time});
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
 appBar: AppBar(
          title: const Text('Score History',
              style: TextStyle(
                color: Color.fromARGB(255, 239, 236, 236),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          backgroundColor: Color.fromARGB(255, 1, 1, 1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 254, 249, 249)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
            },
          ),
          centerTitle: true,
        ),
      body:
      Stack(
        children: [
          Image.asset(
            'assets/bg.gif',
            fit: BoxFit.cover,
          ),
       scoreHistory.isEmpty
          ? Center(
              child: Text('No scores saved yet.'),
            )
          : ListView.builder(
              itemCount: scoreHistory.length,
              itemBuilder: (context, index) {
                int score = scoreHistory[index]['score'];
                DateTime time = scoreHistory[index]['time'];
                String formattedTime =
                    '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute}:${time.second}';
                return ListTile(
                  title: Text('Score: $score', style: TextStyle(color: Colors.white),),
                  subtitle: Text('Time: $formattedTime', style: TextStyle(color: Colors.white),),
                );
              },
            ),
    
        ],
      )

    );
  }
}
