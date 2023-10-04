// ignore_for_file: camel_case_types, prefer_collection_literals

class promocodemodel {
  dynamic status;
  dynamic message;
  List<Data>? data;

  promocodemodel({this.status, this.message, this.data});

  promocodemodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  dynamic offerName;
  dynamic offerCode;
  dynamic offerType;
  dynamic offerAmount;
  dynamic minAmount;
  dynamic perUser;
  dynamic usageType;
  dynamic usageLimit;
  dynamic startDate;
  dynamic expireDate;
  dynamic description;

  Data(
      {this.offerName,
        this.offerCode,
        this.offerType,
        this.offerAmount,
        this.minAmount,
        this.perUser,
        this.usageType,
        this.usageLimit,
        this.startDate,
        this.expireDate,
        this.description});

  Data.fromJson(Map<String, dynamic> json) {
    offerName = json['offer_name'];
    offerCode = json['offer_code'];
    offerType = json['offer_type'];
    offerAmount = json['offer_amount'];
    minAmount = json['min_amount'];
    perUser = json['per_user'];
    usageType = json['usage_type'];
    usageLimit = json['usage_limit'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['offer_name'] = this.offerName;
    data['offer_code'] = this.offerCode;
    data['offer_type'] = this.offerType;
    data['offer_amount'] = this.offerAmount;
    data['min_amount'] = this.minAmount;
    data['per_user'] = this.perUser;
    data['usage_type'] = this.usageType;
    data['usage_limit'] = this.usageLimit;
    data['start_date'] = this.startDate;
    data['expire_date'] = this.expireDate;
    data['description'] = this.description;
    return data;
  }
}
