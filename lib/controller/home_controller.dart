import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:desafio_tecnico_virtual_bookshelf/model/book_model.dart';

class HomeController extends GetxController {
  late RxList<BookModel> books = <BookModel>[].obs;
  late RxList<BookModel> favoriteBooks = <BookModel>[].obs;
  final dio = Dio();

  getBooks() async {
    try {
      final response =
          await dio.get("https://escribo.com/books.json");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = (response.data);

        books.value =
            responseData.map((data) => BookModel.fromJson(data)).toList();
      }
    } catch (e) {
      print(e);
    }
  }
}
