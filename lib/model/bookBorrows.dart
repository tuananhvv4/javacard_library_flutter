import 'package:intl/intl.dart';

class BookBorrows {
  int? id;
  int? userId;
  int? bookId;
  int? duration;
  DateTime? createdAt;
  DateTime? returnDate;

  BookBorrows(
      {this.id,
      this.userId,
      this.bookId,
      this.duration,
      this.createdAt,
      this.returnDate});

  BookBorrows.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bookId = json['book_id'];
    duration = json['duration'];
    createdAt =
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    returnDate = json['return_date'] != null
        ? DateTime.parse(json['return_date'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['book_id'] = this.bookId;
    data['duration'] = this.duration;
    data['created_at'] = this.createdAt?.toIso8601String();
    data['return_date'] = this.returnDate?.toIso8601String();
    return data;
  }

  // Phương thức tính ngày hết hạn
  DateTime? getExpirationDate() {
    if (createdAt != null && duration != null) {
      return createdAt!.add(Duration(days: duration!));
    }
    return null; // Nếu thiếu dữ liệu
  }

  //Kiểm tra đã quá hạn trả hay chưa
  bool isExpired() {
    DateTime? expirationDate = getExpirationDate();
    if (expirationDate != null) {
      return expirationDate
          .isBefore(DateTime.now()); // Trả về true nếu đã hết hạn
    }
    return false; // Nếu chưa hết hạn
  }
}
