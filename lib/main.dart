import 'berita.dart';
import 'favorit.dart';
import 'dart:convert';
import 'color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(
        ChangeNotifierProvider(
          create: (context) => FavoriteNewsProvider(),
          child: const MainApp(),
        ),
      ));
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int selectedIndex = 0;
  late List<Widget> pages;
  String appBarTitle = 'Berita Nih';
  bool isLoading = false;

  final Map<String, String> imagePathsToApis = {
    'assets/images/cnbc.jpg':
        'https://berita-indo-api-next.vercel.app/api/cnbc-news',
    'assets/images/cnn.jpg':
        'https://berita-indo-api-next.vercel.app/api/cnn-news',
    'assets/images/kumparan.jpg':
        'https://berita-indo-api-next.vercel.app/api/kumparan-news',
    'assets/images/okezone.jpg':
        'https://berita-indo-api-next.vercel.app/api/okezone-news',
    'assets/images/republika.jpg':
        'https://berita-indo-api-next.vercel.app/api/republika-news',
    'assets/images/suara.jpg':
        'https://berita-indo-api-next.vercel.app/api/suara-news',
    'assets/images/vice.jpg':
        'https://berita-indo-api-next.vercel.app/api/vice-news',
    'assets/images/voa.jpg':
        'https://berita-indo-api-next.vercel.app/api/voa-news',
  };

  Map<String, Function> apiTransformers = {
    'https://berita-indo-api-next.vercel.app/api/cnbc-news': (data) {
      return {
        'image': data['image']['large'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['contentSnippet'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/cnn-news': (data) {
      return {
        'image': data['image']['large'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['contentSnippet'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/kumparan-news': (data) {
      return {
        'image': data['image']['large'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['description'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/okezone-news': (data) {
      return {
        'image': data['image']['large'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['content'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/republika-news': (data) {
      return {
        'image': data['image']['small'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['description'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/suara-news': (data) {
      return {
        'image': data['image']['large'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['contentSnippet'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/vice-news': (data) {
      return {
        'image': data['image'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': data['content'],
      };
    },
    'https://berita-indo-api-next.vercel.app/api/voa-news': (data) {
      String description = data['description'];
      RegExp regex = RegExp(r'(.*?)\r');
      Match? match = regex.firstMatch(description);
      String filteredDescription = match?.group(1) ?? description;

      return {
        'image': data['image'],
        'isoDate': data['isoDate'],
        'link': data['link'],
        'title': data['title'],
        'contentSnippet': filteredDescription,
      };
    },
  };

  Future<List<dynamic>> fetchNews(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data['data'].map(apiTransformers[url]).toList();
      } else {
        throw Exception('Gagal mendapatkan berita!');
      }
    } else {
      throw Exception('Gagal megambil berita!');
    }
  }

  final List<String> imagePaths = [
    'assets/images/cnbc.jpg',
    'assets/images/cnn.jpg',
    'assets/images/kumparan.jpg',
    'assets/images/okezone.jpg',
    'assets/images/republika.jpg',
    'assets/images/suara.jpg',
    'assets/images/vice.jpg',
    'assets/images/voa.jpg',
  ];

  @override
  void initState() {
    super.initState();

    pages = <Widget>[
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: GridView.builder(
          itemCount: imagePaths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.all(10.0),
              child: Material(
                elevation: 6.0,
                borderRadius: BorderRadius.circular(20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            String? apiUrl =
                                imagePathsToApis[imagePaths[index]];
                            if (apiUrl != null) {
                              setState(() {
                                isLoading = true;
                              });
                              fetchNews(apiUrl).then((news) {
                                setState(() {
                                  pages[1] = BeritaPage(news: news);
                                  selectedIndex = 1;
                                  appBarTitle =
                                      '${getNewsSourceTitle(imagePaths[index])} : Berita Nih';
                                  isLoading = false;
                                });
                              }).catchError((error) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Ada kesalahan saat memuat berita, silahkan coba lagi nanti.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5);
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const BeritaPage(news: []),
      const FavoritePage(),
    ];
  }

  String getNewsSourceTitle(String imagePath) {
    switch (imagePath) {
      case 'assets/images/cnbc.jpg':
        return 'CNBC Indonesia';
      case 'assets/images/cnn.jpg':
        return 'CNN Indonesia';
      case 'assets/images/kumparan.jpg':
        return 'Kumparan';
      case 'assets/images/okezone.jpg':
        return 'Okezone';
      case 'assets/images/republika.jpg':
        return 'Repulika';
      case 'assets/images/suara.jpg':
        return 'Suara';
      case 'assets/images/vice.jpg':
        return 'Vice Indonesia';
      case 'assets/images/voa.jpg':
        return 'VOA Indonesia';
      default:
        return 'Berita Nih';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          fontFamily: GoogleFonts.inter().fontFamily),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          fontFamily: GoogleFonts.inter().fontFamily),
      home: Scaffold(
        appBar: AppBar(
          title: Text(selectedIndex == 1 ? appBarTitle : 'Berita Nih'),
        ),
        body: isLoading
            ? const LinearProgressIndicator()
            : Center(
                child: pages.elementAt(selectedIndex),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_rounded),
              label: 'Berita',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_rounded),
              label: 'Favorit',
            ),
          ],
        ),
      ),
    );
  }
}
