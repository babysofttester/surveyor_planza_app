class EditProfileResponseModel {
  String? status;
  String? error;
  String? message;
  List<Data>? data;

  EditProfileResponseModel({this.status, this.error, this.message, this.data});

  EditProfileResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error']?.toString();  // ✅ bool → String karo
    message = json['message'];
    // data = [] list bhi problem hai — API "data": [] bhejta hai (empty array)
    // forEach crash karega agar Data.fromJson expect kare
    if (json['data'] != null && json['data'] is List && (json['data'] as List).isNotEmpty) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['status'] = status;
    dataMap['error'] = error;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class Data {
  String? name;
  String? email;

  Data({this.name, this.email});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}