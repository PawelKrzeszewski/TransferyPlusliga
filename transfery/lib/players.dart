import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_transfer.dart';
import 'edit_transfer.dart';

class PlayersPage extends StatefulWidget {
  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  List<QueryDocumentSnapshot> transfers = [];
  String filter = "";
  final TextEditingController _controller = TextEditingController();

  Widget appBarTitle = const Text("Zawodnicy");
  Icon actionIcon = const Icon(Icons.search);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Wywołaj odświeżanie z debounce
      _onSearchChanged();
    });
    _getDataFromFirestore();
  }

  void _onSearchChanged() {
      setState(() {
        filter = _controller.text;
      });
      _getDataFromFirestore(); // Wywołaj odświeżenie listy
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getDataFromFirestore() async {
    try {
      Query query = FirebaseFirestore.instance.collection('transfery');

      // Dodaj filtr do zapytania
      if (filter.isNotEmpty) {
        query = query.where('surname', isGreaterThanOrEqualTo: filter).where('surname', isLessThanOrEqualTo: '$filter\uf8ff');
      }

      QuerySnapshot snapshot = await query.orderBy('surname').get();
      setState(() {
        transfers = snapshot.docs;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (actionIcon.icon == Icons.search) {
                  actionIcon = const Icon(Icons.close);
                  appBarTitle = TextField(
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Szukaj",
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                    textCapitalization: TextCapitalization.words,
                    controller: _controller,
                  );
                } else {
                  actionIcon = const Icon(Icons.search);
                  appBarTitle = const Text("Zawodnicy");
                  _controller.clear();
                  filter = "";
                  _getDataFromFirestore(); // Przywróć pełną listę
                }
              });
            },
          ),
          IconButton(
            onPressed: () async {
              bool update = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewTransferPage(),
                ),
              );
              if (update) {
                _getDataFromFirestore();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: transfers.isEmpty
          ? const Center(child: CircularProgressIndicator())  // Pokazuje loading
          : ListView.builder(
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          var doc = transfers[index];
          var transfer = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                    Text('Zespół: ${transfer['team']}'),
                    Text('Status: ${transfer['status']}'),
                  ],
                ),
                onTap: () async{
                  bool update = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditTransferPage(
                        documentId: doc.id),
                    ), // Navigate to TeamTransfers
                  );
                  if (update) {
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
