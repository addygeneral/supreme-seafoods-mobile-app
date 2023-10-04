class paymentoptionModel {
  dynamic status;
  dynamic message;
  dynamic totalWallet;
  List<Paymentmethods>? paymentmethods;

  paymentoptionModel(
      {this.status, this.message, this.totalWallet, this.paymentmethods});

  paymentoptionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    totalWallet = json['total_wallet'];
    if (json['paymentmethods'] != null) {
      paymentmethods = <Paymentmethods>[];
      json['paymentmethods'].forEach((v) {
        paymentmethods!.add(new Paymentmethods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total_wallet'] = this.totalWallet;
    if (this.paymentmethods != null) {
      data['paymentmethods'] =
          this.paymentmethods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Paymentmethods {
  dynamic id;
  dynamic environment;
  String? paymentName;
  String? currency;
  String? publicKey;
  String? secretKey;
  String? encryptionKey;
  String? image;

  Paymentmethods(
      {this.id,
      this.environment,
      this.paymentName,
      this.currency,
      this.publicKey,
      this.secretKey,
      this.encryptionKey,
      this.image});

  Paymentmethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    environment = json['environment'];
    paymentName = json['payment_name'];
    currency = json['currency'];
    publicKey = json['public_key'];
    secretKey = json['secret_key'];
    encryptionKey = json['encryption_key'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['environment'] = this.environment;
    data['payment_name'] = this.paymentName;
    data['currency'] = this.currency;
    data['public_key'] = this.publicKey;
    data['secret_key'] = this.secretKey;
    data['encryption_key'] = this.encryptionKey;
    data['image'] = this.image;
    return data;
  }
}
