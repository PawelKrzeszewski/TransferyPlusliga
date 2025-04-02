import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

void launchArticle(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Nie można otworzyć: $url";
  }
}

Future<List<Map<String, String>>> fetchArticles(List<String> keywords) async {
  final url = Uri.parse("https://siatka.org");
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Nie udało się pobrać strony");
  }

  // Parsowanie HTML
  final document = html.parse(response.body);
  List<Map<String, String>> filteredArticles = [];

  // Pobranie artykułów z sekcji th-labels
  List<dom.Element> labelArticles = document.querySelectorAll(".th-labels a");

  for (var article in labelArticles) {
    String title = article.text.trim();
    String? link = article.attributes["href"];

    if (link != null) {
      if (keywords.any((word) => title.toLowerCase().contains(word.toLowerCase()))) {
        filteredArticles.add({"title": title, "link": link});
      }
    }
  }

  List<dom.Element> h3Articles = document.querySelectorAll("h3 > a");

  for (var article in h3Articles) {
    String title = article.text.trim();
    String? link = article.attributes["href"];

    if (link != null) {
      if (keywords.any((word) => title.toLowerCase().contains(word.toLowerCase()))) {
        filteredArticles.add({"title": title, "link": link});
      }
    }
  }

  return filteredArticles;
}



class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Map<String, String>>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = fetchArticles(["transfer", "transfery", "nowy",
      "ruchy kadrowe", "przechodzi", "odchodzi", "zatrudnia","zatrudniają",
    "odszedł", "przyszedł", "podpisał", "kontrakt", "kontrakty", "zmieni",
    "zmienia", "zmienił", "celownik", "na celowniku", "wzmocnienie",
    "przyjdzie", "odejdzie", "zatrudni", "zainteresowanie", "zainsteresowany",
    "prowadzi rozmowy", "rozmowy", "rozmawiają", "rozmawia"]);  // Słowa kluczowe
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Artykuły Siatka.org')
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Brak artykułów"));
          }

          final articles = snapshot.data!;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article["title"]!),
                subtitle: Text(article["link"]!),
                onTap: () {
                  // Otwórz link w przeglądarce
                  launchArticle(article["link"]!);
                },
              );
            },
          );
        },
      ),
    );
  }
}
