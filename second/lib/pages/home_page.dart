import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second/consts.dart';
import 'package:second/models/article.dart';
import 'package:second/models/category_model.dart';
import 'package:second/models/slider_model.dart';
import 'package:second/pages/technology_page.dart';
import 'package:second/pages/trending_page.dart';
import 'package:second/service/category_data.dart';
import 'package:second/service/category_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio dio = Dio();
  List<CategoryModel> categories = [];
  List<SliderModel> sliders = [];
  List<Article> articles = [];
  int activeIndex = 0;

  @override
  void initState() {
    categories = getCategories();
    super.initState();
    _getNews();
  }

  void _initializeSliders() {
    sliders = articles
        .where((article) =>
            article.urlToImage != null &&
            (article.urlToImage!.endsWith('.jpg') ||
                article.urlToImage!.endsWith('.jpeg') ||
                article.urlToImage!.endsWith('.png')))
        .take(5)
        .map((article) {
      return SliderModel(
        image: article.urlToImage,
        name: article.title,
        url: article.url,
        publishedAt: article.publishedAt,
      );
    }).toList();
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
              Text('News'),
              Text(
                'App',
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildCategoryUi(),
              const SizedBox(
                height: 30.0,
              ),
              _breakingNewsBar(),
              const SizedBox(
                height: 30.0,
              ),
              _buildSliderUI(),
              const SizedBox(
                height: 30.0,
              ),
              Center(
                child: buildIndicator(),
              ),
              const SizedBox(
                height: 30.0,
              ),
              _techNewsBar(),
              const SizedBox(
                height: 30.0,
              ),
              _buildTechUI(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getNews() async {
    final response = await dio.get(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$NEWS_API_KEY');

    final articlesJson = response.data["articles"] as List;
    setState(() {
      List<Article> newsArticle =
          articlesJson.map((a) => Article.fromJson(a)).toList();
      newsArticle = newsArticle.where((a) => a.title != "[Removed]").toList();
      articles = newsArticle;
      _initializeSliders(); // Initialize sliders after fetching articles
    });
  }

  Widget _breakingNewsBar() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Breaking News!',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrendingPage()),
              );
            },
            child: const Text(
              'View All!',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _techNewsBar() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Technology News!',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TechnologyPage()),
              );
            },
            child: const Text(
              'View All!',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderUI() {
    if (sliders.isEmpty) {
      return Center(child: Text("No articles available."));
    }

    return CarouselSlider.builder(
      itemCount: sliders.length,
      itemBuilder: (context, index, realIndex) {
        final slider = sliders[index];
        return buildImage(slider);
      },
      options: CarouselOptions(
        height: 273.0,
        autoPlay: true,
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        onPageChanged: (index, reason) {
          setState(() {
            activeIndex = index;
          });
        },
      ),
    );
  }

  Widget buildImage(SliderModel slider) {
    return GestureDetector(
      onTap: () {
        _launchUrl(Uri.parse(slider.url ?? ""));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            children: [
              Image.network(
                slider.image ?? PLACEHOLDER_IMAGE_LINK,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    PLACEHOLDER_IMAGE_LINK,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
              SizedBox(height: 10),
              Text(
                slider.name ?? "",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(sliders.length, (index) {
        return Container(
          width: 15.0,
          height: 15.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activeIndex == index ? Colors.blue : Colors.grey,
          ),
        );
      }).reversed.toList(),
    );
  }

  Widget _buildTechUI() {
    final filteredArticles = articles
        .where((article) =>
            article.urlToImage != null &&
            (article.urlToImage!.endsWith('.jpg') ||
                article.urlToImage!.endsWith('.jpeg') ||
                article.urlToImage!.endsWith('.png')))
        .take(20)
        .toList();

    if (filteredArticles.isEmpty) {
      return Center(child: Text("No articles available."));
    }

    return Container(
      height: 300.0,
      child: ListView.builder(
        itemCount: filteredArticles.length,
        itemBuilder: (context, index) {
          final article = filteredArticles[index];
          return ListTile(
            onTap: () {
              _launchUrl(Uri.parse(article.url ?? ""));
            },
            leading: Image.network(
              article.urlToImage ?? PLACEHOLDER_IMAGE_LINK,
              height: 250,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  PLACEHOLDER_IMAGE_LINK,
                  height: 250,
                  width: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
            title: Text(article.title ?? ""),
            subtitle: Text(formatDateTime(article.publishedAt ?? "")),
          );
        },
      ),
    );
  }

  Widget _buildCategoryUi() {
    return Container(
      margin: const EdgeInsets.only(left: 10.0),
      height: 70,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryTile(
              image: categories[index].image,
              categoryName: categories[index].categoryName,
              categoryUrl: categories[index].categoryUrl);
        },
      ),
    );
  }
}
