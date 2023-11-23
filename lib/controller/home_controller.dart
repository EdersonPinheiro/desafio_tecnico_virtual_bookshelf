import 'package:desafio_tecnico_virtual_bookshelf/db/book_storage.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:desafio_tecnico_virtual_bookshelf/model/book_model.dart';

class HomeController extends GetxController {
  final BookStorage dbHelper = BookStorage.instance;
  late RxList<BookModel> books = <BookModel>[].obs;
  late RxList<BookModel> favoriteBooks = <BookModel>[].obs;
  final dio = Dio();

  void toggleFavorite(BookModel book) async {
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      final existingBook = books[index];
      if (existingBook.marker) {
        await dbHelper.insertFavoriteBook(book);
        favoriteBooks.add(existingBook);
        //existingBook.marker = !existingBook.marker;
      } else {
        await dbHelper.deleteFavoriteBook(book.id);
        favoriteBooks.removeWhere((fav) => fav.id == book.id);
      }
    }
  }

   void getFavoriteBooks() async {
    final favBooks = await dbHelper.getFavoriteBooks();
    favoriteBooks.assignAll(favBooks);
  }

  getBooks() async {
    try {
      final response = await dio.get("https://escribo.com/books.json");

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
