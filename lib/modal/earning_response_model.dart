class EarningResponseModel {
  String? status;
  String? error;
  String? message;
  Data? data;

  EarningResponseModel({this.status, this.error, this.message, this.data});

  EarningResponseModel.fromJson(Map<String, dynamic> json) {
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
  Earnings? earnings;

  Data({this.earnings});

  Data.fromJson(Map<String, dynamic> json) {
    earnings = json['earnings'] != null
        ? new Earnings.fromJson(json['earnings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.earnings != null) {
      data['earnings'] = this.earnings!.toJson();
    }
    return data;
  }
}

class Earnings {
  List<PaidData>? paidData;
  String? totalEarnings;
  List<UnpaidPayments>? unpaidPayments;
  String? totaldues;

  Earnings(
      {this.paidData, this.totalEarnings, this.unpaidPayments, this.totaldues});

  Earnings.fromJson(Map<String, dynamic> json) {
    if (json['paid_data'] != null) {
      paidData = <PaidData>[];
      json['paid_data'].forEach((v) {
        paidData!.add(new PaidData.fromJson(v));
      });
    }
  totalEarnings = json['totalEarnings']?.toString(); 
    if (json['unpaidPayments'] != null) {
      unpaidPayments = <UnpaidPayments>[];
      json['unpaidPayments'].forEach((v) {
        unpaidPayments!.add(new UnpaidPayments.fromJson(v));
      });
    }
  totaldues = json['totaldues']?.toString();
  } 

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.paidData != null) {
      data['paid_data'] = this.paidData!.map((v) => v.toJson()).toList();
    }
    data['totalEarnings'] = this.totalEarnings;
    if (this.unpaidPayments != null) {
      data['unpaidPayments'] =
          this.unpaidPayments!.map((v) => v.toJson()).toList();
    }
    data['totaldues'] = this.totaldues;
    return data;
  }
}

class PaidData {
  String? bookingNo;
  String? projectNo;
  String? amount;
  String? paidAt;

  PaidData({this.bookingNo, this.projectNo, this.amount, this.paidAt});

  PaidData.fromJson(Map<String, dynamic> json) {
    bookingNo = json['booking_no'];
    projectNo = json['project_no'];
    amount = json['amount'];
    paidAt = json['paid_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_no'] = this.bookingNo;
    data['project_no'] = this.projectNo;
    data['amount'] = this.amount;
    data['paid_at'] = this.paidAt;
    return data;
  }
}

class UnpaidPayments {
  String? bookingNo;
  String? projectNo;
  String? amount;

  UnpaidPayments({this.bookingNo, this.projectNo, this.amount});

  UnpaidPayments.fromJson(Map<String, dynamic> json) {
    bookingNo = json['booking_no'];
    projectNo = json['project_no'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_no'] = this.bookingNo;
    data['project_no'] = this.projectNo;
    data['amount'] = this.amount;
    return data;
  }
}
