import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfery/color_scheme.dart';
import 'kluby.dart';
import 'pozycje.dart';
import 'statusy.dart';

class EditTransferPage extends StatefulWidget {
  final String documentId;

  const EditTransferPage({required this.documentId, Key? key}) : super(key: key);

  @override
  State<EditTransferPage> createState() => _EditTransferPageState();
}

class _EditTransferPageState extends State<EditTransferPage> {
  late TextEditingController _controllerName;
  late TextEditingController _controllerSurname;
  late String name;
  late String surname;
  late String position;
  late String team;
  late String status;
  bool isLoading = true; // Flaga ładowania

  @override
  void initState() {
    super.initState();

    _controllerName = TextEditingController();
    _controllerSurname = TextEditingController();

    // Pobieranie danych dokumentu
    FirebaseFirestore.instance
        .collection('transfery')
        .doc(widget.documentId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _controllerName.text = data['name'];
          _controllerSurname.text = data['surname'];
          name = data['name'];
          surname = data['surname'];
          position = data['position'];
          team = data['team'];
          status = data['status'];
          isLoading = false; // Wyłączenie ładowania po wczytaniu danych
        });
      }
    });
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerSurname.dispose();
    super.dispose();
  }

  void updateDatabase(String name, String surname, String position, String team, String status) {
    final data = {"name": name, "surname": surname, "position": position, "team": team, "status": status};
    FirebaseFirestore.instance
        .collection('transfery')
        .doc(widget.documentId)
        .update(data)
        .then((_) {
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj transfer'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Wyświetlenie wskaźnika ładowania
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: _controllerName,
              onChanged: (String valueName) async {
                name = valueName;
              },
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Imię',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controllerSurname,
              onChanged: (String valueSurname) async {
                surname = valueSurname;
              },
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nazwisko',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: position,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: TextStyle(color: Colors.grey.shade800),
              underline: Container(
                height: 2,
                color: myColorScheme.primary,
              ),
              onChanged: (String? valuePos) {
                setState(() {
                  position = valuePos!;
                });
              },
              items: pozycje.map<DropdownMenuItem<String>>((String valuePos) {
                return DropdownMenuItem<String>(
                  value: valuePos,
                  child: Text(valuePos),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: team,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: TextStyle(color: Colors.grey.shade800),
              underline: Container(
                height: 2,
                color: myColorScheme.primary,
              ),
              onChanged: (String? value3) {
                setState(() {
                  team = value3!;
                });
              },
              items: kluby.map<DropdownMenuItem<String>>((String value3) {
                return DropdownMenuItem<String>(
                  value: value3,
                  child: Text(value3),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: status,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: TextStyle(color: Colors.grey.shade800),
              underline: Container(
                height: 2,
                color: myColorScheme.primary,
              ),
              onChanged: (String? value4) {
                setState(() {
                  status = value4!;
                });
              },
              items: statusy.map<DropdownMenuItem<String>>((String value4) {
                return DropdownMenuItem<String>(
                  value: value4,
                  child: Text(value4),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (name != "" && surname != "" && status != "") {
                  updateDatabase(name, surname, position, team, status);
                } else {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Błąd!'),
                        content: const Text('Nie podałeś wszystkich wymaganych danych'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}
