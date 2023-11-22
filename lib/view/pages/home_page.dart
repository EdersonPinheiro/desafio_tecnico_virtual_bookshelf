import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../../controller/home_controller.dart';
import 'favoritas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  String? filePath = null;
  late bool loading;
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    controller.getBooks();
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

  openEpubViewer(String epubPath, String bookTitle) {
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

    if (File(filePath!).existsSync()) {
      VocsyEpub.open(
        epubPath,
        lastLocation: EpubLocator.fromJson({
          "bookId": "1",
          "href": "/path/to/book/page.xhtml",
          "created": 1622116345,
          "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
        }),
      );
    } else {
      startDownload(filePath!, bookTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Virtual Bookshelf'),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Books'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Obx(() => GridView.builder(
                    itemCount: controller.books.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: IconButton(
                                  icon: Icon(
                                    controller.books[index].marker
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      controller.books[index].marker =
                                          !controller.books[index].marker;
                                    });
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await startDownload(
                                    controller.books[index].download_url,
                                    controller.books[index].title);
                                openEpubViewer(
                                    filePath!, controller.books[index].title);
                              },
                              child: Image.network(
                                controller.books[index].cover_url,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                controller.books[index].title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(controller.books[index].author),
                          ],
                        ),
                      );
                    },
                  )),
              FavoritasPage(),
            ],
          ),
        ),
      ),
    );
  }
}
