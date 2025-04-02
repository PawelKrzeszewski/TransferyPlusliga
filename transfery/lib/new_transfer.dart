import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfery/color_scheme.dart';
import 'kluby.dart';
import 'pozycje.dart';
import 'statusy.dart';

class NewTransferPage extends StatefulWidget {
  const NewTransferPage({super.key});

  @override
  State<NewTransferPage> createState() => _NewTransferPageState();
}

class _NewTransferPageState extends State<NewTransferPage> {
  List<QueryDocumentSnapshot> existing = [];
  late TextEditingController _controllerName;
  late TextEditingController _controllerSurname;
  late String name;
  late String surname;
  late String position;
  late String team;
  late String status;
  late var transfer;

  @override
  void initState() {
    super.initState();
    name = "";
    surname = "";
    position = "Atakujący";
    team = "Aluron CMC Warta Zawiercie";
    status = "Pewne";
    _controllerName = TextEditingController();
    _controllerSurname = TextEditingController();
  }

  void addToDatabase(String name, String surname, String position, String team, String status){
    // Add a new document with a generated id.
    final data = {"name": name, "surname": surname, "position": position, "team": team, "status": status};
    FirebaseFirestore.instance.collection("transfery").add(data);
    Navigator.pop(context, true);
  }

  Future<bool> alreadyExists(String name, String surname, String position) async{
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transfery')
        .where('name', isEqualTo: name)
        .where('surname', isEqualTo: surname)
        .where('position', isEqualTo: position)
        .where('status', isNotEqualTo: "Błędne")
        .get();
    setState(() {
      existing = snapshot.docs;
    });
    if(existing.isNotEmpty)
    {
      var doc = existing[0]; // Pojedynczy dokument
      transfer = doc.data() as Map<String, dynamic>;
      return true;
    }
    else {return false;}
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerSurname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowy transfer'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: _controllerName,
              onChanged: (String valueName) async {
              name = valueName;
               }, //onSubmitted
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
              }, //onSubmitted
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
                // This is called when the user selects an item.
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
          // This is called when the user selects an item.
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
                // This is called when the user selects an item.
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
                onPressed: () async{
                  if (name != "" && surname != "") {
                    if (await alreadyExists(name, surname, position)){
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Zawodnik już ma istniejące transfery'),
                            content: Text('${transfer['name']} ${transfer['surname']}\n'
                                ' ${transfer['team']} \n ${transfer['status']}'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  addToDatabase(name, surname, position, team, status);
                                  Navigator.pop(context);
                                },
                                child: const Text('Dodaj mimo wszystko'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Anuluj'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else{
                      addToDatabase(name, surname, position, team, status);
                    }
                  } else
                    {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Błąd!'),
                            content: const Text(
                            'Nie podałeś wszystkich wymaganych danych'),
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
                child: const Text("Dodaj plotkę transferową")
            )
          ]
      ),
    );
  }
}
