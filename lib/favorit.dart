import 'berita.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteNewsProvider>(
      builder: (context, favoriteNewsProvider, child) {
        if (favoriteNewsProvider.favoriteNews.isEmpty) {
          return const Center(
            child: Text('Belum ada berita Favorit.'),
          );
        } else {
          return ListView.builder(
            itemCount: favoriteNewsProvider.favoriteNews.length,
            itemBuilder: (BuildContext context, int index) {
              var news = favoriteNewsProvider.favoriteNews[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Card(
                  elevation: 2.0,
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          news.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Icon(
                              Icons.error_outline_rounded,
                              size: 100,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${DateFormat('EEEE, dd MMM yyyy HH:mm', 'id_ID').format(DateTime.parse(news.date))} WIB",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 4.0),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return Wrap(
                                        children: <Widget>[
                                          ListTile(
                                            leading: const Icon(
                                                Icons.open_in_new_rounded),
                                            title: const Text('Buka disini...'),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WebViewPage(
                                                          url: news.link),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                                Icons.open_in_browser_rounded),
                                            title: const Text(
                                                'Buka di Browser...'),
                                            onTap: () {
                                              launchUrl(Uri.parse(news.link),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete_forever_rounded,
                                            ),
                                            title: const Text(
                                                'Hapus dari Favorit'),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Konfirmasi'),
                                                    content: const Text(
                                                        'Hapus berita favorit?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Batalkan'),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop(false);
                                                        },
                                                      ),
                                                      TextButton(
                                                        child:
                                                            const Text('Hapus'),
                                                        onPressed: () async {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop(true);
                                                          var favoriteNewsProvider =
                                                              Provider.of<
                                                                      FavoriteNewsProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          favoriteNewsProvider
                                                              .removeNews(news);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  news.title.length > 64
                                      ? '${news.title.substring(0, 64)}...'
                                      : news.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
