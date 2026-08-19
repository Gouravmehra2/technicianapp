import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class NewJobsModel {
  bool? success;
  Data? data;

  NewJobsModel({this.success, this.data});

  NewJobsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Jobs>? jobs;

  Data({this.jobs});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['jobs'] != null) {
      jobs = <Jobs>[];
      json['jobs'].forEach((v) {
        jobs!.add(new Jobs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.jobs != null) {
      data['jobs'] = this.jobs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Jobs {
  AssignedTechnician? assignedTechnician;
  String? sId;
  String? title;
  String? category;
  String? location;
  int? budget;
  String? description;
  List<Null>? requirements;
  String? postedBy;
  String? status;
  Null? assignedRequest;
  String? estimatedTime;
  Null? reachedAt;
  Null? jobStartedAt;
  Null? jobCompletedAt;
  Null? jobDurationMinutes;
  int? finalPrice;
  Null? completedAt;
  String? visibleTo;
  String? deadline;
  String? scheduledDate;
  List<String>? preferredSkills;
  List<RescheduleHistory>? rescheduleHistory;
  List<Conversation>? conversation;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? serviceDate;

  Jobs(
      {this.assignedTechnician,
        this.sId,
        this.title,
        this.category,
        this.location,
        this.budget,
        this.description,
        this.requirements,
        this.postedBy,
        this.status,
        this.assignedRequest,
        this.estimatedTime,
        this.reachedAt,
        this.jobStartedAt,
        this.jobCompletedAt,
        this.jobDurationMinutes,
        this.finalPrice,
        this.completedAt,
        this.visibleTo,
        this.deadline,
        this.scheduledDate,
        this.preferredSkills,
        this.rescheduleHistory,
        this.conversation,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.serviceDate});

  Jobs.fromJson(Map<String, dynamic> json) {
    assignedTechnician = json['assignedTechnician'] != null
        ? new AssignedTechnician.fromJson(json['assignedTechnician'])
        : null;
    sId = json['_id'];
    title = json['title'];
    category = json['category'];
    location = json['location'];
    budget = json['budget'];
    description = json['description'];
    // if (json['requirements'] != null) {
    //   requirements = <Null>[];
    //   json['requirements'].forEach((v) {
    //     requirements!.add(new Null.fromJson(v));
    //   });
    // }
    postedBy = json['postedBy'];
    status = json['status'];
    assignedRequest = json['assignedRequest'];
    estimatedTime = json['estimatedTime'];
    reachedAt = json['reachedAt'];
    jobStartedAt = json['jobStartedAt'];
    jobCompletedAt = json['jobCompletedAt'];
    jobDurationMinutes = json['jobDurationMinutes'];
    finalPrice = json['finalPrice'];
    completedAt = json['completedAt'];
    visibleTo = json['visibleTo'];
    deadline = json['deadline'];
    scheduledDate = json['scheduledDate'];
    preferredSkills = json['preferredSkills'].cast<String>();
    if (json['rescheduleHistory'] != null) {
      rescheduleHistory = <RescheduleHistory>[];
      json['rescheduleHistory'].forEach((v) {
        rescheduleHistory!.add(new RescheduleHistory.fromJson(v));
      });
    }
    if (json['conversation'] != null) {
      conversation = <Conversation>[];
      json['conversation'].forEach((v) {
        conversation!.add(new Conversation.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    serviceDate = json['serviceDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.assignedTechnician != null) {
      data['assignedTechnician'] = this.assignedTechnician!.toJson();
    }
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['category'] = this.category;
    data['location'] = this.location;
    data['budget'] = this.budget;
    data['description'] = this.description;
    // if (this.requirements != null) {
    //   data['requirements'] = this.requirements!.map((v) => v?.toJson()).toList();
    // }
    data['postedBy'] = this.postedBy;
    data['status'] = this.status;
    data['assignedRequest'] = this.assignedRequest;
    data['estimatedTime'] = this.estimatedTime;
    data['reachedAt'] = this.reachedAt;
    data['jobStartedAt'] = this.jobStartedAt;
    data['jobCompletedAt'] = this.jobCompletedAt;
    data['jobDurationMinutes'] = this.jobDurationMinutes;
    data['finalPrice'] = this.finalPrice;
    data['completedAt'] = this.completedAt;
    data['visibleTo'] = this.visibleTo;
    data['deadline'] = this.deadline;
    data['scheduledDate'] = this.scheduledDate;
    data['preferredSkills'] = this.preferredSkills;
    if (this.rescheduleHistory != null) {
      data['rescheduleHistory'] =
          this.rescheduleHistory!.map((v) => v.toJson()).toList();
    }
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['serviceDate'] = this.serviceDate;
    return data;
  }
}

class AssignedTechnician {
  Null? nId;
  String? name;
  String? email;
  String? phone;

  AssignedTechnician({this.nId, this.name, this.email, this.phone});

  AssignedTechnician.fromJson(Map<String, dynamic> json) {
    nId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.nId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class RescheduleHistory {
  Null? previousDate;
  String? newDate;
  String? reason;
  String? rescheduledAt;
  String? sId;

  RescheduleHistory(
      {this.previousDate,
        this.newDate,
        this.reason,
        this.rescheduledAt,
        this.sId});

  RescheduleHistory.fromJson(Map<String, dynamic> json) {
    previousDate = json['previousDate'];
    newDate = json['newDate'];
    reason = json['reason'];
    rescheduledAt = json['rescheduledAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['previousDate'] = this.previousDate;
    data['newDate'] = this.newDate;
    data['reason'] = this.reason;
    data['rescheduledAt'] = this.rescheduledAt;
    data['_id'] = this.sId;
    return data;
  }
}

class Conversation {
  String? sender;
  String? message;
  String? createdAt;
  String? sId;

  Conversation({this.sender, this.message, this.createdAt, this.sId});

  Conversation.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    message = json['message'];
    createdAt = json['createdAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender'] = this.sender;
    data['message'] = this.message;
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
    return data;
  }
}

class ScheduleJob {
  final String time;
  final String duration;
  final String title;
  final String jobId;
  final String distance;
  final String status; // 'IN PROGRESS' | 'UPCOMING'

  const ScheduleJob({
    required this.time,
    required this.duration,
    required this.title,
    required this.jobId,
    required this.distance,
    required this.status,
  });

  ScheduledJobModel toScheduledJobModel() {
    return ScheduledJobModel(
      time: time,
      duration: duration,
      title: title,
      jobId: jobId,
      distance: distance,
      status: status == 'IN PROGRESS'
          ? JobStatus.inProgress
          : JobStatus.upcoming,
    );
  }
}

class NewJob {
  final String id;
  final String title;
  final String distance;
  final String sector;
  final String requestedFor;
  final String estimatedPay;
  /// The technician request ID (from TechnicianJobRequest._id).
  /// Null when navigating from an open job that has no request yet.
  final String? requestId;

  const NewJob({
    required this.id,
    required this.title,
    required this.distance,
    required this.sector,
    required this.requestedFor,
    required this.estimatedPay,
    this.requestId,
  });
}
