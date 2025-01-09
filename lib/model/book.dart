class Book {
  int? id;
  String? name;
  String? author;
  String? desc;
  String? imgUrl;
  int? genreId;

  Book({this.id, this.name, this.author, this.desc, this.imgUrl, this.genreId});

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    author = json['author'];
    desc = json['desc'];
    imgUrl = json['img_url'];
    genreId = json['genre_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['author'] = this.author;
    data['desc'] = this.desc;
    data['img_url'] = this.imgUrl;
    data['genre_id'] = this.genreId;
    return data;
  }
}
