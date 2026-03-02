class WorkResponseModel {
  String? status;
  String? error;
  String? message;

  WorkResponseModel({this.status, this.error, this.message});

  WorkResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'error': error,
      'message': message,
    };
  }
}