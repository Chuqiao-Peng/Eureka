import 'package:flutter/material.dart';

final List<Map> newsList = [
  {'title': 'News 1', 'content': 'This is the content for news 1.'},
  {'title': 'News 2', 'content': 'This is the content for news 2.'},
  {'title': 'News 3', 'content': 'This is the content for news 3.'},
  {'title': 'News 2', 'content': 'This is the content for news 2.'},
  {'title': 'News 2', 'content': 'This is the content for news 2.'},
  {'title': 'News 2', 'content': 'This is the content for news 2.'},
  {'title': 'News 2', 'content': 'This is the content for news 2.'},
];

class NewsPage extends StatefulWidget {
  final int index;
  const NewsPage({super.key, required this.index});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ],
            ),
            Text(newsList[widget.index]['title']),
            Text(newsList[widget.index]['content']),
          ],
        ),
      ),
    );
  }
}
