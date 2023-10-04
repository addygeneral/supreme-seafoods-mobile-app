class toyyibpaymodel {
  dynamic status;
  dynamic message;
  dynamic redirecturl;
  dynamic successurl;
  dynamic failureurl;
  dynamic billcode;

  toyyibpaymodel(
      {this.status,
        this.message,
        this.redirecturl,
        this.successurl,
        this.failureurl,
        this.billcode});

  toyyibpaymodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    redirecturl = json['redirecturl'];
    successurl = json['successurl'];
    failureurl = json['failureurl'];
    billcode = json['billcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['redirecturl'] = this.redirecturl;
    data['successurl'] = this.successurl;
    data['failureurl'] = this.failureurl;
    data['billcode'] = this.billcode;
    return data;
  }
}