class DashboardModel {
  bool? success;
  DashboardData? data;

  DashboardModel({this.success, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new DashboardData.fromJson(json['data']) : null;
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

class DashboardData {
  Technician? technician;
  List<Requests>? requests;
  List<Withdrawals>? withdrawals;

  DashboardData({this.technician, this.requests, this.withdrawals});

  DashboardData.fromJson(Map<String, dynamic> json) {
    technician = json['technician'] != null
        ? new Technician.fromJson(json['technician'])
        : null;
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(new Requests.fromJson(v));
      });
    }
    if (json['withdrawals'] != null) {
      withdrawals = <Withdrawals>[];
      json['withdrawals'].forEach((v) {
        withdrawals!.add(new Withdrawals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.technician != null) {
      data['technician'] = this.technician!.toJson();
    }
    if (this.requests != null) {
      data['requests'] = this.requests!.map((v) => v.toJson()).toList();
    }
    if (this.withdrawals != null) {
      data['withdrawals'] = this.withdrawals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Technician {
  String? name;
  String? email;
  String? phone;
  List<String>? skills;
  String? experienceLevel;
  int? totalJobsDone;
  int? totalEarnings;
  int? totalWithdrawn;
  int? availableBalance;
  bool? profileCompleted;

  Technician(
      {this.name,
        this.email,
        this.phone,
        this.skills,
        this.experienceLevel,
        this.totalJobsDone,
        this.totalEarnings,
        this.totalWithdrawn,
        this.availableBalance,
        this.profileCompleted});

  Technician.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    skills = json['skills'].cast<String>();
    experienceLevel = json['experienceLevel'];
    totalJobsDone = json['totalJobsDone'];
    totalEarnings = json['totalEarnings'];
    totalWithdrawn = json['totalWithdrawn'];
    availableBalance = json['availableBalance'];
    profileCompleted = json['profileCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['skills'] = this.skills;
    data['experienceLevel'] = this.experienceLevel;
    data['totalJobsDone'] = this.totalJobsDone;
    data['totalEarnings'] = this.totalEarnings;
    data['totalWithdrawn'] = this.totalWithdrawn;
    data['availableBalance'] = this.availableBalance;
    data['profileCompleted'] = this.profileCompleted;
    return data;
  }
}

class Requests {
  String? sId;
  Job? job;
  String? technician;
  String? note;
  String? status;
  String? adminMessage;
  String? counterOfferFrom;
  int? counterOffer;
  String? completedAt;
  String? paymentStatus;
  int? amountEarned;
  List<Conversation>? conversation;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Requests(
      {this.sId,
        this.job,
        this.technician,
        this.note,
        this.status,
        this.adminMessage,
        this.counterOfferFrom,
        this.counterOffer,
        this.completedAt,
        this.paymentStatus,
        this.amountEarned,
        this.conversation,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Requests.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    job = json['job'] != null ? new Job.fromJson(json['job']) : null;
    technician = json['technician'];
    note = json['note'];
    status = json['status'];
    adminMessage = json['adminMessage'];
    counterOfferFrom = json['counterOfferFrom'];
    counterOffer = json['counterOffer'];
    completedAt = json['completedAt'];
    paymentStatus = json['paymentStatus'];
    amountEarned = json['amountEarned'];
    if (json['conversation'] != null) {
      conversation = <Conversation>[];
      json['conversation'].forEach((v) {
        conversation!.add(new Conversation.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.job != null) {
      data['job'] = this.job!.toJson();
    }
    data['technician'] = this.technician;
    data['note'] = this.note;
    data['status'] = this.status;
    data['adminMessage'] = this.adminMessage;
    data['counterOfferFrom'] = this.counterOfferFrom;
    data['counterOffer'] = this.counterOffer;
    data['completedAt'] = this.completedAt;
    data['paymentStatus'] = this.paymentStatus;
    data['amountEarned'] = this.amountEarned;
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Job {
  AssignedTechnician? assignedTechnician;
  String? sId;
  String? title;
  String? category;
  String? location;
  int? budget;
  String? description;
  List<String>? requirements;
  String? postedBy;
  String? status;
  String? assignedRequest;
  String? estimatedTime;
  String? reachedAt;
  String? jobStartedAt;
  String? jobCompletedAt;
  int? jobDurationMinutes;
  int? finalPrice;
  String? completedAt;
  String? visibleTo;
  String? deadline;
  List<String>? preferredSkills;
  List<Conversation>? conversation;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<RescheduleHistory>? rescheduleHistory;
  String? scheduledDate;
  String? serviceDate;

  Job(
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
        this.preferredSkills,
        this.conversation,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.rescheduleHistory,
        this.scheduledDate,
        this.serviceDate});

  Job.fromJson(Map<String, dynamic> json) {
    assignedTechnician = json['assignedTechnician'] != null
        ? new AssignedTechnician.fromJson(json['assignedTechnician'])
        : null;
    sId = json['_id'];
    title = json['title'];
    category = json['category'];
    location = json['location'];
    budget = json['budget'];
    description = json['description'];
    requirements = json['requirements'].cast<String>();
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
    preferredSkills = json['preferredSkills'].cast<String>();
    if (json['conversation'] != null) {
      conversation = <Conversation>[];
      json['conversation'].forEach((v) {
        conversation!.add(new Conversation.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['rescheduleHistory'] != null) {
      rescheduleHistory = <RescheduleHistory>[];
      json['rescheduleHistory'].forEach((v) {
        rescheduleHistory!.add(new RescheduleHistory.fromJson(v));
      });
    }
    scheduledDate = json['scheduledDate'];
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
    data['requirements'] = this.requirements;
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
    data['preferredSkills'] = this.preferredSkills;
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.rescheduleHistory != null) {
      data['rescheduleHistory'] =
          this.rescheduleHistory!.map((v) => v.toJson()).toList();
    }
    data['scheduledDate'] = this.scheduledDate;
    data['serviceDate'] = this.serviceDate;
    return data;
  }
}

class AssignedTechnician {
  String? sId;
  String? name;
  String? email;
  String? phone;

  AssignedTechnician({this.sId, this.name, this.email, this.phone});

  AssignedTechnician.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Conversation {
  String? sender;
  String? message;
  /// The counter offer amount attached to this conversation entry (may be 0).
  int? counterOffer;
  /// Who sent the counter offer in this entry ('technician' | 'admin' | '').
  String? counterOfferFrom;
  String? createdAt;
  String? sId;

  Conversation({
    this.sender,
    this.message,
    this.counterOffer,
    this.counterOfferFrom,
    this.createdAt,
    this.sId,
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    message = json['message'];
    counterOffer = json['counterOffer'] as int?;
    counterOfferFrom = json['counterOfferFrom'] as String?;
    createdAt = json['createdAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender'] = this.sender;
    data['message'] = this.message;
    data['counterOffer'] = this.counterOffer;
    data['counterOfferFrom'] = this.counterOfferFrom;
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
    return data;
  }
}

class RescheduleHistory {
  String? previousDate;
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


class Withdrawals {
  String? sId;
  String? technician;
  int? amount;
  String? status;
  String? method;
  String? details;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Withdrawals(
      {this.sId,
        this.technician,
        this.amount,
        this.status,
        this.method,
        this.details,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Withdrawals.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    technician = json['technician'];
    amount = json['amount'];
    status = json['status'];
    method = json['method'];
    details = json['details'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['technician'] = this.technician;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['method'] = this.method;
    data['details'] = this.details;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
