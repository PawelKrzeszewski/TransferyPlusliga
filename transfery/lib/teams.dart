import 'package:flutter/material.dart';
import 'package:transfery/team_transfers.dart';
import 'kluby.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<Map<String, dynamic>> transfers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zespoły'),
      ),
      body: ListView.builder(
        itemCount: kluby.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamTransfersPage(team: kluby[index])), // Navigate to CategorySelectionPage
              );
            },
            child: Text(kluby[index]),
          );
        },
      ),
    );
  }
}
