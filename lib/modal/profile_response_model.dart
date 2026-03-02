class ProfileResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  ProfileResponseModel({this.status, this.error, this.message, this.data});

  ProfileResponseModel.fromJson(Map<String, dynamic> json) {
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
  Surveyor? surveyor;

  Data({this.surveyor});

  Data.fromJson(Map<String, dynamic> json) {
    surveyor = json['surveyor'] != null
        ? new Surveyor.fromJson(json['surveyor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.surveyor != null) {
      data['surveyor'] = this.surveyor!.toJson();
    }
    return data;
  }
}

class Surveyor {
  String? name;
  String? email;
  String? phone;
  String? state;
  String? city;
  String? currentLat;
  String? currentLng;
  String? avatar;

  Surveyor(
      {this.name,
      this.email,
      this.phone,
      this.state,
      this.city,
      this.currentLat,
      this.currentLng,
      this.avatar});

  Surveyor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    state = json['state'];
    city = json['city'];
    currentLat = json['current_lat'];
    currentLng = json['current_lng'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['state'] = this.state;
    data['city'] = this.city;
    data['current_lat'] = this.currentLat;
    data['current_lng'] = this.currentLng;
    data['avatar'] = this.avatar;
    return data;
  }
}
