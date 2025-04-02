import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfery/edit_transfer.dart';
import 'new_transfer.dart';

class TeamTransfersPage extends StatefulWidget {
  final String team;

  const TeamTransfersPage({required this.team, Key? key}) : super(key: key);

  @override
  _TeamTransfersPageState createState() => _TeamTransfersPageState();
}

class _TeamTransfersPageState extends State<TeamTransfersPage> {
  List<QueryDocumentSnapshot> transfers = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getDataFromFirestore();
  }

  Future<void> _getDataFromFirestore() async {
    try {
      // Pobranie danych z kolekcji 'transfery'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transfery')
          .where('team', isEqualTo: widget.team)
          .orderBy('position')
          .get()
          .timeout(const Duration(seconds: 10));
      setState(() {
        transfers = snapshot.docs;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Nie pobrano danych";
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team),
        actions: [
          IconButton(
            onPressed: () async {
              bool? update = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewTransferPage(),
                ),
              );
              if (update == true) {
                _getDataFromFirestore();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: transfers.isEmpty
          ? (errorMessage != null
          ? const Center(
        child: Text(
            "Nie udało się pobrać danych z bazy. Sprawdź połączenie z "
                "internetem bądź skontaktuj się z autorem aplikacji"),// Pokazuje tekst na wypadek nie wczytania transferów
      )
          : const Center(
        child: CircularProgressIndicator(),
      ))
          : ListView.builder(
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          var doc = transfers[index]; // Pojedynczy dokument
          var transfer = doc.data() as Map<String, dynamic>; // Pobierz dane
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 15),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: Text(
                '${transfer['name']} ${transfer['surname']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                    color: transfer['status'] == "Błędne" ? Colors.red :
                    transfer['status'] == "Potwierdzone" ? Colors.green : Colors.black
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Rola: ${transfer['position']}'),
                  Text('Status: ${transfer['status']}'),
                ],
              ),
              onTap: () async {
                bool? update = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTransferPage(
                      documentId: doc.id, // Przekazanie ID dokumentu
                    ),
                  ),
                );
                if (update == true) {
                  _getDataFromFirestore();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
