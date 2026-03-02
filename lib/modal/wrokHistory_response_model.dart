
class WorkHistoryResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  WorkHistoryResponseModel({this.status, this.error, this.message, this.data});

  WorkHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<Works>? works;

  Data({this.works});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Works'] != null) {
      works = <Works>[];
      json['Works'].forEach((v) {
        works!.add(Works.fromJson(v));
      });
    }
  }
}

class Works {
  int? projectId;
  String? bookingNo;
  double? amount;       
  double? rating;       
  String? comment;
  String? completedAt;

  Works({
    this.projectId,
    this.bookingNo,
    this.amount,
    this.rating,
    this.comment,
    this.completedAt,
  });

  Works.fromJson(Map<String, dynamic> json) {
    projectId = int.tryParse(json['project_id']?.toString() ?? '');

    bookingNo = json['booking_no'];

    
    amount = double.tryParse(json['amount']?.toString() ?? '0');

    
    rating = double.tryParse(json['rating']?.toString() ?? '');

    comment = json['comment'];
    completedAt = json['completed_at'];
  }
}