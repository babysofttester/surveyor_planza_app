class KycResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  KycResponseModel({this.status, this.error, this.message, this.data});

  KycResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? kycStatus;

  Data({this.kycStatus});

  Data.fromJson(Map<String, dynamic> json) {
    kycStatus = json['kyc_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kyc_status'] = this.kycStatus;
    return data;
  }
}
