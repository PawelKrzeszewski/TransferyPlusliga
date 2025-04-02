import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'teams.dart';
import 'players.dart';
import 'news.dart';
import 'main.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<QueryDocumentSnapshot> transfers = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    listenToTransfery();
  }

  //Dispose of listenToTransfery?
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfery Plusligi"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamsPage()), // Navigate to TeamTransfers
                );
              },
              child: const Text('Drużyny'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayersPage(),
                  ),
                );
              },
              child: const Text('Zawodnicy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsPage()),
                );
              },
              child: const Text('Wiadomości'),
            ),
          ],
        ),
      ),
    );
  }
}
