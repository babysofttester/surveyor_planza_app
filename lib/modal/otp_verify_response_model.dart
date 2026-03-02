class OtpVerifyResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  OtpVerifyResponseModel({this.status, this.error, this.message, this.data});

  OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? token;
  Surveyor? surveyor;

  Data({this.token, this.surveyor});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    surveyor = json['surveyor'] != null
        ? new Surveyor.fromJson(json['surveyor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.surveyor != null) {
      data['surveyor'] = this.surveyor!.toJson();
    }
    return data;
  }
}

class Surveyor {
  String? email;
  String? phone;
  String? name;
  String? username;
  String? role;
  String? status;
  int? isVerified;
  String? fcmToken;
  String? updatedAt;
  String? createdAt;
  int? id;

  Surveyor(
      {this.email,
      this.phone,
      this.name,
      this.username,
      this.role,
      this.status,
      this.isVerified,
      this.fcmToken,
      this.updatedAt,
      this.createdAt,
      this.id});

  Surveyor.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    phone = json['phone'];
    name = json['name'];
    username = json['username'];
    role = json['role'];
    status = json['status'];
    isVerified = json['is_verified'];
    fcmToken = json['fcm_token'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['username'] = this.username;
    data['role'] = this.role;
    data['status'] = this.status;
    data['is_verified'] = this.isVerified;
    data['fcm_token'] = this.fcmToken;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
