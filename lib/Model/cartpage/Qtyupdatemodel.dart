// ignore_for_file: file_names, prefer_collection_literals
class QTYupdatemodel {
  dynamic status;
  dynamic message;
  dynamic deliveryCharge;

  QTYupdatemodel({this.status, this.message, this.deliveryCharge});

  QTYupdatemodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    deliveryCharge = json['delivery_charge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['delivery_charge'] = this.deliveryCharge;
    return data;
  }
}
