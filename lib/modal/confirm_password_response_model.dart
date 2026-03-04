class ConfirmPasswordResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  ConfirmPasswordResponseModel(
      {this.status, this.error, this.message, this.data});

  ConfirmPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userId;

  Data({this.userId});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    return data;
  }
}
