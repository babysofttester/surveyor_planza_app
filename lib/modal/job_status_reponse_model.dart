class JobStatusResponseModel {
  String? status;
  String? error;
  String? message;

  JobStatusResponseModel({
    this.status,
    this.error,
    this.message,
  });

  JobStatusResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "error": error,
      "message": message,
    };
  }
}