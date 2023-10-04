class loginrequiredmodel {
  dynamic status;
  dynamic message;
  dynamic sessionId;
  dynamic isLoginRequired;

  loginrequiredmodel(
      {this.status, this.message, this.sessionId, this.isLoginRequired});

  loginrequiredmodel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    sessionId = json['session_id'];
    isLoginRequired = json['is_login_required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['session_id'] = this.sessionId;
    data['is_login_required'] = this.isLoginRequired;
    return data;
  }
}