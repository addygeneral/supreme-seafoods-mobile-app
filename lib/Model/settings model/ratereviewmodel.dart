class Ratereviewmodel {
  int? status;
  String? message;
  List<Data>? data;
  dynamic checkReviewExist;

  Ratereviewmodel(
      {this.status, this.message, this.data, this.checkReviewExist});

  Ratereviewmodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    checkReviewExist = json['check_review_exist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['check_review_exist'] = this.checkReviewExist;
    return data;
  }
}

class Data {
  int? id;
  dynamic ratting;
  String? comment;
  String? date;
  dynamic userId;
  String? name;
  String? profileImage;

  Data(
      {this.id,
      this.ratting,
      this.comment,
      this.date,
      this.userId,
      this.name,
      this.profileImage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ratting = json['ratting'];
    comment = json['comment'];
    date = json['date'];
    userId = json['user_id'];
    name = json['name'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ratting'] = this.ratting;
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
