class SupportProjectResponseModel {
  String? status;
  String? error;
  String? message;
  ProjectData? data;

  SupportProjectResponseModel({this.status, this.error, this.message, this.data});

  SupportProjectResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? ProjectData.fromJson(json['data']) : null;
  }
}

class ProjectData {
  List<dynamic>? result;

  ProjectData({this.result});

  ProjectData.fromJson(Map<String, dynamic> json) {
    result = json['result'];
  }
}