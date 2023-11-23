import 'package:desafio_tecnico_virtual_bookshelf/model/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({super.key});

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getFavoriteBooks();
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
                        //await startDownload(book.download_url, book.title);
                        //openEpubViewer(filePath!, book.title);
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
