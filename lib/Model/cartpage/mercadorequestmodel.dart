class mercadopagomodel {
  dynamic status;
  dynamic message;
  dynamic redirecturl;
  dynamic successurl;
  dynamic failureurl;

  mercadopagomodel(
      {this.status,
        this.message,
        this.redirecturl,
        this.successurl,
        this.failureurl});

  mercadopagomodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    redirecturl = json['redirecturl'];
    successurl = json['successurl'];
    failureurl = json['failureurl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['redirecturl'] = this.redirecturl;
    data['successurl'] = this.successurl;
    data['failureurl'] = this.failureurl;
    return data;
  }
}