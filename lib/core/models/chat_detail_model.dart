class ChatDetailModel {
  bool? success;
  Data? data;

  ChatDetailModel({this.success, this.data});

  ChatDetailModel.fromJson(Map<String, dynamic> json) {
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
  Job? job;
  Request? request;
  List<Conversation>? conversation;
  List<Charges>? charges;

  Data({this.job, this.request, this.conversation, this.charges});

  Data.fromJson(Map<String, dynamic> json) {
    job = json['job'] != null ? new Job.fromJson(json['job']) : null;
    request =
    json['request'] != null ? new Request.fromJson(json['request']) : null;
    if (json['conversation'] != null) {
      conversation = <Conversation>[];
      json['conversation'].forEach((v) {
        conversation!.add(new Conversation.fromJson(v));
      });
    }
    if (json['charges'] != null) {
      charges = <Charges>[];
      json['charges'].forEach((v) {
        charges!.add(new Charges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.job != null) {
      data['job'] = this.job!.toJson();
    }
    if (this.request != null) {
      data['request'] = this.request!.toJson();
    }
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    if (this.charges != null) {
      data['charges'] = this.charges!.map((v) => v.toJson()).toList();
    }
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
  var assignedRequest;
  String? estimatedTime;
  var reachedAt;
  var jobStartedAt;
  var jobCompletedAt;
  var jobDurationMinutes;
  int? finalPrice;
  var completedAt;
  String? visibleTo;
  String? serviceDate;
  var scheduledDate;
  List<String>? preferredSkills;
  List<Null>? rescheduleHistory;
  List<Conversation>? conversation;
  String? createdAt;
  String? updatedAt;
  int? iV;

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
        this.serviceDate,
        this.scheduledDate,
        this.preferredSkills,
        this.rescheduleHistory,
        this.conversation,
        this.createdAt,
        this.updatedAt,
        this.iV});

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
    serviceDate = json['serviceDate'];
    scheduledDate = json['scheduledDate'];
    preferredSkills = json['preferredSkills'].cast<String>();
    // if (json['rescheduleHistory'] != null) {
    //   rescheduleHistory = <Null>[];
    //   json['rescheduleHistory'].forEach((v) {
    //     rescheduleHistory!.add(new Null.fromJson(v));
    //   });
    // }
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
    data['serviceDate'] = this.serviceDate;
    data['scheduledDate'] = this.scheduledDate;
    data['preferredSkills'] = this.preferredSkills;
    // if (this.rescheduleHistory != null) {
    //   data['rescheduleHistory'] =
    //       this.rescheduleHistory!.map((v) => v.toJson()).toList();
    // }
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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

class Request {
  String? sId;
  String? status;
  String? note;
  int? bidAmount;
  int? counterOffer;
  String? counterOfferFrom;
  String? adminMessage;
  String? createdAt;
  String? updatedAt;
  Null? completedAt;

  Request(
      {this.sId,
        this.status,
        this.note,
        this.bidAmount,
        this.counterOffer,
        this.counterOfferFrom,
        this.adminMessage,
        this.createdAt,
        this.updatedAt,
        this.completedAt});

  Request.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    note = json['note'];
    bidAmount = json['bidAmount'];
    counterOffer = json['counterOffer'];
    counterOfferFrom = json['counterOfferFrom'];
    adminMessage = json['adminMessage'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['status'] = this.status;
    data['note'] = this.note;
    data['bidAmount'] = this.bidAmount;
    data['counterOffer'] = this.counterOffer;
    data['counterOfferFrom'] = this.counterOfferFrom;
    data['adminMessage'] = this.adminMessage;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['completedAt'] = this.completedAt;
    return data;
  }
}

class Conversation {
  String? sender;
  String? message;
  int? counterOffer;
  String? counterOfferFrom;
  String? createdAt;
  String? sId;

  Conversation(
      {this.sender,
        this.message,
        this.counterOffer,
        this.counterOfferFrom,
        this.createdAt,
        this.sId});

  Conversation.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    message = json['message'];
    counterOffer = json['counterOffer'];
    counterOfferFrom = json['counterOfferFrom'];
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

class Charges {
  String? sId;
  String? job;
  String? request;
  String? technician;
  String? label;
  String? description;
  int? requestedAmount;
  String? status;
  Null? adminCounterAmount;
  String? adminNote;
  String? technicianResponseNote;
  Null? agreedAmount;
  String? submittedAt;
  String? reviewedAt;
  String? resolvedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Charges(
      {this.sId,
        this.job,
        this.request,
        this.technician,
        this.label,
        this.description,
        this.requestedAmount,
        this.status,
        this.adminCounterAmount,
        this.adminNote,
        this.technicianResponseNote,
        this.agreedAmount,
        this.submittedAt,
        this.reviewedAt,
        this.resolvedAt,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Charges.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    job = json['job'];
    request = json['request'];
    technician = json['technician'];
    label = json['label'];
    description = json['description'];
    requestedAmount = json['requestedAmount'];
    status = json['status'];
    adminCounterAmount = json['adminCounterAmount'];
    adminNote = json['adminNote'];
    technicianResponseNote = json['technicianResponseNote'];
    agreedAmount = json['agreedAmount'];
    submittedAt = json['submittedAt'];
    reviewedAt = json['reviewedAt'];
    resolvedAt = json['resolvedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['job'] = this.job;
    data['request'] = this.request;
    data['technician'] = this.technician;
    data['label'] = this.label;
    data['description'] = this.description;
    data['requestedAmount'] = this.requestedAmount;
    data['status'] = this.status;
    data['adminCounterAmount'] = this.adminCounterAmount;
    data['adminNote'] = this.adminNote;
    data['technicianResponseNote'] = this.technicianResponseNote;
    data['agreedAmount'] = this.agreedAmount;
    data['submittedAt'] = this.submittedAt;
    data['reviewedAt'] = this.reviewedAt;
    data['resolvedAt'] = this.resolvedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
