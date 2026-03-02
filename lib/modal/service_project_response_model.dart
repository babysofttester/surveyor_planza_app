class SupportProjectResponseModel {
  String? status;
  String? error;
  String? message;
  SupportProjectData? data;

  SupportProjectResponseModel({this.status, this.error, this.message, this.data});

  SupportProjectResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    error = json['error'];
    message = json['message'];
    data = json['data'] != null
        ? SupportProjectData.fromJson(json['data'])
        : null;
  }
}

class SupportProjectData {
  List<ProjectItem>? result;

  SupportProjectData({this.result});

  SupportProjectData.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = (json['result'] as List)
          .map((e) => ProjectItem.fromJson(e))
          .toList();
    }
  }
}

class ProjectItem {
  int? projectId;
  String? jobId;
  String? projectStatus;

  ProjectItem({this.projectId, this.jobId, this.projectStatus});

  ProjectItem.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'];
    jobId = json['job_id'];
    projectStatus = json['project_status'];
  }
}