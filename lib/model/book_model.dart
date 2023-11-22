class BookModel {
  final int id;
  final String title;
  final String author;
  final String cover_url;
  final String download_url;
  bool marker;

  BookModel(
      {required this.id,
      required this.title,
      required this.author,
      required this.cover_url,
      required this.download_url,
      this.marker = false});

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
      id: json["id"] as int,
      title: json["title"],
      author: json["author"],
      cover_url: json["cover_url"],
      download_url: json["download_url"]);
}
