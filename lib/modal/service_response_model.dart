class SupportResponseModel {
  String? status;
  String? error;
  String? message;
  List<dynamic>? data;

  SupportResponseModel({
    this.status,
    this.error,
    this.message,
    this.data,
  });

  SupportResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'error': error,
      'message': message,
      'data': data,
    };
  }
}