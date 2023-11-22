import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import 'favoritas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.getBooks();
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
                              onTap: () async {},
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
