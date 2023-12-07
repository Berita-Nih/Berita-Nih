import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class News {
  final String image;
  final String date;
  final String title;
  final String link;

  News({
    required this.image,
    required this.date,
    required this.title,
    required this.link,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is News &&
        other.image == image &&
        other.date == date &&
        other.title == title &&
        other.link == link;
  }

  @override
  int get hashCode {
    return image.hashCode ^ date.hashCode ^ title.hashCode ^ link.hashCode;
  }

  News.fromJson(Map<String, dynamic> json)
      : image = json['image'],
        date = json['date'],
        title = json['title'],
        link = json['link'];

  Map<String, dynamic> toJson() => {
        'image': image,
        'date': date,
        'title': title,
        'link': link,
      };
}

class FavoriteNewsProvider extends ChangeNotifier {
  List<News> favNews = [];
  List<News> get favoriteNews => favNews;

  FavoriteNewsProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favNewsData = prefs.getStringList('favoriteNews');
    if (favNewsData != null) {
      favNews =
          favNewsData.map((item) => News.fromJson(json.decode(item))).toList();
      notifyListeners();
    }
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favNewsData =
        favNews.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('favoriteNews', favNewsData);
  }

  void addNews(News news) {
    favNews.add(news);
    saveFavorites();
    notifyListeners();
  }

  void removeNews(News news) {
    favNews.remove(news);
    saveFavorites();
    notifyListeners();
  }

  bool isFavorite(News news) {
    return favNews.contains(news);
  }
}

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Nih'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

class BeritaPage extends StatefulWidget {
  final List<dynamic> news;

  const BeritaPage({Key? key, required this.news}) : super(key: key);

  @override
  BeritaPageState createState() => BeritaPageState();
}

class BeritaPageState extends State<BeritaPage> {
  List<bool> favoriteStatus = [];

  @override
  void initState() {
    super.initState();
    favoriteStatus = List<bool>.filled(widget.news.length, false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.news.isEmpty) {
      return const Center(
        child: Text('Pilih sumber berita dulu pada Beranda.'),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.news.length,
                itemBuilder: (context, index) {
                  var news = News(
                    image: widget.news[index]['image'],
                    date: widget.news[index]['isoDate'],
                    title: widget.news[index]['title'],
                    link: widget.news[index]['link'],
                  );
                  return Container(
                    margin: const EdgeInsets.only(top: 12.0),
                    child: Card(
                      elevation: 4.0,
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: Image.network(
                              widget.news[index]['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${DateFormat('EEEE, dd MMM yyyy HH:mm', 'id_ID').format(DateTime.parse(widget.news[index]['isoDate']))} WIB",
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Provider.of<FavoriteNewsProvider>(
                                                    context)
                                                .isFavorite(news)
                                            ? const Icon(Icons.favorite_rounded,
                                                color: Colors.red, size: 32.0)
                                            : const Icon(
                                                Icons.favorite_outline_rounded,
                                                size: 32.0),
                                        onPressed: () {
                                          if (Provider.of<FavoriteNewsProvider>(
                                                  context,
                                                  listen: false)
                                              .isFavorite(news)) {
                                            Provider.of<FavoriteNewsProvider>(
                                                    context,
                                                    listen: false)
                                                .removeNews(news);
                                          } else {
                                            Provider.of<FavoriteNewsProvider>(
                                                    context,
                                                    listen: false)
                                                .addNews(news);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext bc) {
                                                return Wrap(
                                                  children: <Widget>[
                                                    ListTile(
                                                      leading: const Icon(Icons
                                                          .open_in_new_rounded),
                                                      title: const Text(
                                                          'Buka disini...'),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                WebViewPage(
                                                                    url: widget.news[
                                                                            index]
                                                                        [
                                                                        'link']),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons
                                                          .open_in_browser_rounded),
                                                      title: const Text(
                                                          'Buka di Browser...'),
                                                      onTap: () {
                                                        launchUrl(
                                                            Uri.parse(widget
                                                                    .news[index]
                                                                ['link']),
                                                            mode: LaunchMode
                                                                .externalApplication);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text(
                                          widget.news[index]['title'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.news[index]['contentSnippet'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
