class StatusResponseModel {
  String? status;
  String? error;
  String? message;
  List<dynamic>? data;

  StatusResponseModel({this.status, this.error, this.message, this.data});

  StatusResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "error": error,
      "message": message,
      "data": data,
    };
  }
}
