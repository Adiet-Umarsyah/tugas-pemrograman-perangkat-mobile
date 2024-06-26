import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:second/consts.dart';
import 'package:second/models/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TeslaPage extends StatefulWidget {
  const TeslaPage({super.key});

  @override
  State<TeslaPage> createState() => _TeslaPageState();
}

class _TeslaPageState extends State<TeslaPage> {
  final Dio dio = Dio();

  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    _getNews();
  }

  String formatDateTime(String dateTimeString) {
    if (dateTimeString.isEmpty) {
      return '';
    }
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime =
        DateFormat('yyyy-MM-dd\t\tHH:mm:ss').format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tesla'),
              Text(
                'News!',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          onTap: () {
            _launchUrl(Uri.parse(article.url ?? ""));
          },
          leading: SizedBox(
            width: 100,
            child: Image.network(
              article.urlToImage ?? PLACEHOLDER_IMAGE_LINK,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'images/placeholder.png',
                  height: 250,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          title: Text(article.title ?? ""),
          subtitle: Text(formatDateTime(article.publishedAt ?? "")),
        );
      },
    );
  }

  Future<void> _getNews() async {
    try {
      final response = await dio.get(
          'https://newsapi.org/v2/everything?q=tesla&from=2024-05-26&sortBy=publishedAt&apiKey=$NEWS_API_KEY');

      final articlesJson = response.data["articles"] as List;
      setState(() {
        List<Article> newsArticle =
            articlesJson.map((a) => Article.fromJson(a)).toList();
        newsArticle = newsArticle.where((a) => a.title != "[Removed]").toList();
        articles = newsArticle;
      });
    } catch (e) {
      // Handle error
      print('Error fetching news: $e');
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
