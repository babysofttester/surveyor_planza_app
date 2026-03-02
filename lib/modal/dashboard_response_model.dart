class DashboardResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  DashboardResponseModel({this.status, this.error, this.message, this.data});

  DashboardResponseModel.fromJson(Map<String, dynamic> json) {
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
  List<JobRequest>? jobRequest;

  Data({this.jobRequest});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['job_request'] != null) {
      jobRequest = <JobRequest>[];
      json['job_request'].forEach((v) {
        jobRequest!.add(new JobRequest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.jobRequest != null) {
      data['job_request'] = this.jobRequest!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class JobRequest {
  int? requestId;
  int? projectId;
  String? bookingNo;
  String? status;
  int? earningAmount;
  String? state;
  String? city;
  int? isAccept;
  String? acceptedAt;

  JobRequest(
      {this.requestId,
      this.projectId,
      this.bookingNo,
      this.status,
      this.earningAmount,
      this.state,
      this.city,
      this.isAccept, 
      this.acceptedAt});

  JobRequest.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    projectId = json['project_id'];
    bookingNo = json['booking_no'];
    status = json['status'];
    earningAmount = json['earning_amount'];
    state = json['state'];
    city = json['city'];
    isAccept = json['is_accept'];
    acceptedAt = json['accepted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = this.requestId;
    data['project_id'] = this.projectId;
    data['booking_no'] = this.bookingNo;
    data['status'] = this.status;
    data['earning_amount'] = this.earningAmount;
    data['state'] = this.state;
    data['city'] = this.city;
    data['is_accept'] = this.isAccept;
    data['accepted_at'] = this.acceptedAt;
    return data;
  }
}
