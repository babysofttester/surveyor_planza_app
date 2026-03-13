class LoginResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  LoginResponseModel({this.status, this.error, this.message, this.data});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null
        ? Data.fromJson(json['data'])
        : null;
   // data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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
  int? isVerified;
  int? isRejected;
  int? isPending;
  int? isNotCompleted;

  Data(
      {this.token,
      this.surveyor,
      this.isVerified,
      this.isRejected,
      this.isPending,
      this.isNotCompleted});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    surveyor = json['surveyor'] != null
        ? new Surveyor.fromJson(json['surveyor'])
        : null;
    isVerified = json['is_verified'];
    isRejected = json['is_rejected'];
    isPending = json['is_pending'];
    isNotCompleted = json['is_notCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    if (this.surveyor != null) {
      data['surveyor'] = this.surveyor!.toJson();
    }
    data['is_verified'] = this.isVerified;
    data['is_rejected'] = this.isRejected;
    data['is_pending'] = this.isPending;
    data['is_notCompleted']= this.isNotCompleted;
    return data;
  }
}

class Surveyor {
  int? id;
  String? name;
  String? username;
  String? email;
  String? phone;
  String? role;
  String? avatar;
  Null? facebookId;
  Null? googleId;
  Null? appleId;
  String? loginType;
  int? isActive;
  String? status;
  int? isVerified;
  int? isFeatured;
  String? verifiedAt;
  String? fcmToken;
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;

  Surveyor(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.phone,
      this.role,
      this.avatar,
      this.facebookId,
      this.googleId,
      this.appleId,
      this.loginType,
      this.isActive,
      this.status,
      this.isVerified,
      this.isFeatured,
      this.verifiedAt,
      this.fcmToken,
      this.deletedAt,
      this.createdAt,
      this.updatedAt});

  Surveyor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    phone = json['phone'];
    role = json['role'];
    avatar = json['avatar'];
    facebookId = json['facebook_id'];
    googleId = json['google_id'];
    appleId = json['apple_id'];
    loginType = json['login_type'];
    isActive = json['is_active'];
    status = json['status'];
    isVerified = json['is_verified'];
    isFeatured = json['is_featured'];
    verifiedAt = json['verified_at'];
    fcmToken = json['fcm_token'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['role'] = this.role;
    data['avatar'] = this.avatar;
    data['facebook_id'] = this.facebookId;
    data['google_id'] = this.googleId;
    data['apple_id'] = this.appleId;
    data['login_type'] = this.loginType;
    data['is_active'] = this.isActive;
    data['status'] = this.status;
    data['is_verified'] = this.isVerified;
    data['is_featured'] = this.isFeatured;
    data['verified_at'] = this.verifiedAt;
    data['fcm_token'] = this.fcmToken;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
