import 'dart:io';

import 'package:desafio_tecnico_virtual_bookshelf/model/book_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../../controller/home_controller.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({super.key});

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  final HomeController controller = Get.put(HomeController());
   String filePath = '';
  late bool loading;
  Dio dio = Dio();
  
  @override
  void initState() {
    super.initState();
    controller.getFavoriteBooks();
  }

  startDownload(String bookUrl, String bookTitle) async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir!.path + '/${bookTitle}.epub';
    File file = File(path);

    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        bookUrl,
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            loading = true;
          });
        },
      ).whenComplete(() {
        setState(() {
          loading = false;
          filePath = path;
        });
      });
    } else {
      setState(() {
        loading = false;
        filePath = path;
      });
    }
  }

  openEpubViewer(String epubPath) {
    try {
      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "book",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: false,
      );

      VocsyEpub.locatorStream.listen((locator) {
        print('LOCATOR: $locator');
      });

      VocsyEpub.open(
        epubPath,
        lastLocation: EpubLocator.fromJson({
          "bookId": "1",
          "href": "/path/to/book/page.xhtml",
          "created": 1622116345,
          "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => GridView.builder(
            itemCount: controller.favoriteBooks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              BookModel book = controller.favoriteBooks[index];
              return Card(
                elevation: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await startDownload(book.download_url, book.title);
                        openEpubViewer(filePath);
                      },
                      child: Image.network(
                        book.cover_url,
                        height: 120,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        book.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(book.author),
                  ],
                ),
              );
            },
          )),
    );
  }
}
