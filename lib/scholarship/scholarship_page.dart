import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

import '../browser/browser_page.dart';

void main() {
  runApp(Scholarship());
}

class Scholarship extends StatelessWidget {
  const Scholarship({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Article> articles = [];
  @override
  void initState() {
    super.initState();

    getWebsiteData();
  }

  Future getWebsiteData() async {
    final url = Uri.parse(
        'https://www.dcescholarship.kerala.gov.in/he_ma/he_maindx.php');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll('div > div.vertical-tab > ul > li > a')
        .map((e) => e.innerHtml.trim())
        .toList();

    print('Count: ${titles.length}');

    setState(() {
      articles = List.generate(
        titles.length,
        (index) => Article(
            url: 'https://www.dcescholarship.kerala.gov.in/he_ma/he_maindx.php',
            title: titles[index]),
      );
    });

    for (final title in titles) {
      debugPrint(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Scholarships'),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                article.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            enabled: true,
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                 Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BrowserApp(value: "https://www.dcescholarship.kerala.gov.in/he_ma/he_maindx.php",)));
              },
            ),
          );
        },
      ),
    );
  }
}

class Article {
  final String url;
  final String title;

  const Article({required this.url, required this.title});
}