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
  Coordinates? coordinates;
  Pay? pay;
  AssignedTechnician? assignedTechnician;
  ReachedStatus? reachedStatus;
  ReachedStatus? completedStatus;
  WorkType? workType;
  WorkType? additionalWorkType;
  SubType? serviceType;
  JobDate? jobDate;
  String? city;
  String? state;
  String? zipCode;
  String? sId;
  String? title;
  String? location;
  String? description;
  List<String>? requirements;
  String? postedBy;
  String? status;
  String? assignedRequest;
  var reachedAt;
  var jobStartedAt;
  var jobCompletedAt;
  var jobDurationMinutes;
  int? finalPrice;
  var completedAt;
  String? scheduledDate;
  String? visibleTo;
  List<String>? preferredSkills;
  List<dynamic>? requestedBy;
  List<Tasks>? tasks;
  List<RescheduleHistory>? rescheduleHistory;
  List<Conversation>? conversation;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? requestId;
  String? requestStatus;

  // Fields used across job screens but absent from the original model
  num? budget;
  String? estimatedTime;
  String? serviceDate;
  Schedule? schedule;

  Jobs({
    this.coordinates,
    this.pay,
    this.assignedTechnician,
    this.reachedStatus,
    this.completedStatus,
    this.workType,
    this.additionalWorkType,
    this.serviceType,
    this.jobDate,
    this.city,
    this.state,
    this.zipCode,
    this.sId,
    this.title,
    this.location,
    this.description,
    this.requirements,
    this.postedBy,
    this.status,
    this.assignedRequest,
    this.reachedAt,
    this.jobStartedAt,
    this.jobCompletedAt,
    this.jobDurationMinutes,
    this.finalPrice,
    this.completedAt,
    this.scheduledDate,
    this.visibleTo,
    this.preferredSkills,
    this.requestedBy,
    this.tasks,
    this.rescheduleHistory,
    this.conversation,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.requestId,
    this.requestStatus,
    this.budget,
    this.estimatedTime,
    this.serviceDate,
    this.schedule,
  });

  Jobs.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'] != null
        ? new Coordinates.fromJson(json['coordinates'])
        : null;
    pay = json['pay'] != null ? new Pay.fromJson(json['pay']) : null;
    assignedTechnician = json['assignedTechnician'] != null
        ? new AssignedTechnician.fromJson(json['assignedTechnician'])
        : null;
    reachedStatus = json['reachedStatus'] != null
        ? new ReachedStatus.fromJson(json['reachedStatus'])
        : null;
    completedStatus = json['completedStatus'] != null
        ? new ReachedStatus.fromJson(json['completedStatus'])
        : null;
    workType = json['workType'] != null
        ? new WorkType.fromJson(json['workType'])
        : null;
    additionalWorkType = json['additionalWorkType'] != null
        ? new WorkType.fromJson(json['additionalWorkType'])
        : null;
    serviceType = json['serviceType'] != null
        ? new SubType.fromJson(json['serviceType'])
        : null;
    jobDate = json['jobDate'] != null
        ? new JobDate.fromJson(json['jobDate'])
        : null;
    city = json['city'];
    state = json['state'];
    zipCode = json['zipCode'];
    sId = json['_id'];
    title = json['title'];
    location = json['location'];
    description = json['description'];
    requirements = json['requirements'].cast<String>();
    postedBy = json['postedBy'];
    status = json['status'];
    assignedRequest = json['assignedRequest'];
    reachedAt = json['reachedAt'];
    jobStartedAt = json['jobStartedAt'];
    jobCompletedAt = json['jobCompletedAt'];
    jobDurationMinutes = json['jobDurationMinutes'];
    finalPrice = json['finalPrice'];
    completedAt = json['completedAt'];
    scheduledDate = json['scheduledDate'];
    visibleTo = json['visibleTo'];
    preferredSkills = json['preferredSkills'].cast<String>();
    requestedBy = json['requestedBy'];
    if (json['tasks'] != null) {
      tasks = <Tasks>[];
      json['tasks'].forEach((v) {
        tasks!.add(new Tasks.fromJson(v));
      });
    }
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
    requestId = json['requestId'];
    requestStatus = json['requestStatus'];
    budget = json['budget'];
    estimatedTime = json['estimatedTime'];
    serviceDate = json['serviceDate'];
    schedule = json['schedule'] != null
        ? Schedule.fromJson(json['schedule'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.coordinates != null) {
      data['coordinates'] = this.coordinates!.toJson();
    }
    if (this.pay != null) {
      data['pay'] = this.pay!.toJson();
    }
    if (this.assignedTechnician != null) {
      data['assignedTechnician'] = this.assignedTechnician!.toJson();
    }
    if (this.reachedStatus != null) {
      data['reachedStatus'] = this.reachedStatus!.toJson();
    }
    if (this.completedStatus != null) {
      data['completedStatus'] = this.completedStatus!.toJson();
    }
    if (this.workType != null) {
      data['workType'] = this.workType!.toJson();
    }
    if (this.additionalWorkType != null) {
      data['additionalWorkType'] = this.additionalWorkType!.toJson();
    }
    if (this.serviceType != null) {
      data['serviceType'] = this.serviceType!.toJson();
    }
    if (this.jobDate != null) {
      data['jobDate'] = this.jobDate!.toJson();
    }
    data['city'] = this.city;
    data['state'] = this.state;
    data['zipCode'] = this.zipCode;
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['location'] = this.location;
    data['description'] = this.description;
    data['requirements'] = this.requirements;
    data['postedBy'] = this.postedBy;
    data['status'] = this.status;
    data['assignedRequest'] = this.assignedRequest;
    data['reachedAt'] = this.reachedAt;
    data['jobStartedAt'] = this.jobStartedAt;
    data['jobCompletedAt'] = this.jobCompletedAt;
    data['jobDurationMinutes'] = this.jobDurationMinutes;
    data['finalPrice'] = this.finalPrice;
    data['completedAt'] = this.completedAt;
    data['scheduledDate'] = this.scheduledDate;
    data['visibleTo'] = this.visibleTo;
    data['preferredSkills'] = this.preferredSkills;
    data['requestedBy'] = this.requestedBy;
    if (this.tasks != null) {
      data['tasks'] = this.tasks!.map((v) => v.toJson()).toList();
    }
    if (this.rescheduleHistory != null) {
      data['rescheduleHistory'] = this.rescheduleHistory!
          .map((v) => v.toJson())
          .toList();
    }
    if (this.conversation != null) {
      data['conversation'] = this.conversation!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['requestId'] = this.requestId;
    data['requestStatus'] = this.requestStatus;
    data['budget'] = this.budget;
    data['estimatedTime'] = this.estimatedTime;
    data['serviceDate'] = this.serviceDate;
    if (this.schedule != null) {
      data['schedule'] = this.schedule!.toJson();
    }
    return data;
  }
}

class Coordinates {
  double? lat;
  double? lng;

  Coordinates({this.lat, this.lng});

  Coordinates.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class Pay {
  String? type;
  int? fixedAmount;
  int? hourlyRate;
  int? maxHours;
  int? perDeviceRate;
  int? maxDevices;
  int? blendedFixedAmount;
  int? blendedFixedHours;
  int? blendedHourlyRate;
  int? blendedMaxAddlHours;
  String? approxHours;

  Pay({
    this.type,
    this.fixedAmount,
    this.hourlyRate,
    this.maxHours,
    this.perDeviceRate,
    this.maxDevices,
    this.blendedFixedAmount,
    this.blendedFixedHours,
    this.blendedHourlyRate,
    this.blendedMaxAddlHours,
    this.approxHours,
  });

  Pay.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    fixedAmount = json['fixedAmount'];
    hourlyRate = json['hourlyRate'];
    maxHours = json['maxHours'];
    perDeviceRate = json['perDeviceRate'];
    maxDevices = json['maxDevices'];
    blendedFixedAmount = json['blendedFixedAmount'];
    blendedFixedHours = json['blendedFixedHours'];
    blendedHourlyRate = json['blendedHourlyRate'];
    blendedMaxAddlHours = json['blendedMaxAddlHours'];
    approxHours = json['approxHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['fixedAmount'] = this.fixedAmount;
    data['hourlyRate'] = this.hourlyRate;
    data['maxHours'] = this.maxHours;
    data['perDeviceRate'] = this.perDeviceRate;
    data['maxDevices'] = this.maxDevices;
    data['blendedFixedAmount'] = this.blendedFixedAmount;
    data['blendedFixedHours'] = this.blendedFixedHours;
    data['blendedHourlyRate'] = this.blendedHourlyRate;
    data['blendedMaxAddlHours'] = this.blendedMaxAddlHours;
    data['approxHours'] = this.approxHours;
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

class ReachedStatus {
  var at;
  var lat;
  var lng;
  var distanceMeters;

  ReachedStatus({this.at, this.lat, this.lng, this.distanceMeters});

  ReachedStatus.fromJson(Map<String, dynamic> json) {
    at = json['at'];
    lat = json['lat'];
    lng = json['lng'];
    distanceMeters = json['distanceMeters'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['at'] = this.at;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['distanceMeters'] = this.distanceMeters;
    return data;
  }
}

class WorkType {
  SubType? subType;
  String? sId;
  String? name;

  WorkType({this.subType, this.sId, this.name});

  WorkType.fromJson(Map<String, dynamic> json) {
    subType = json['subType'] != null
        ? new SubType.fromJson(json['subType'])
        : null;
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.subType != null) {
      data['subType'] = this.subType!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class SubType {
  String? sId;
  String? name;

  SubType({this.sId, this.name});

  SubType.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class JobDate {
  String? from;
  String? to;

  JobDate({this.from, this.to});

  JobDate.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}

class Tasks {
  String? title;
  String? group;
  int? order;
  bool? isDone;
  var checkedAt;
  var technicianLat;
  var technicianLng;
  var distanceMeters;
  String? sId;

  // ── Requirement flags coming from the API ─────────────────────────────────
  bool? requiresNote;
  bool? requiresImage;
  bool? requiresSignature;
  String? requirementReason;
  String? completionNote;
  String? completionImage;
  String? signature;

  Tasks({
    this.title,
    this.group,
    this.order,
    this.isDone,
    this.checkedAt,
    this.technicianLat,
    this.technicianLng,
    this.distanceMeters,
    this.sId,
    this.requiresNote,
    this.requiresImage,
    this.requiresSignature,
    this.requirementReason,
    this.completionNote,
    this.completionImage,
    this.signature,
  });

  Tasks.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    group = json['group'];
    order = json['order'];
    isDone = json['isDone'];
    checkedAt = json['checkedAt'];
    technicianLat = json['technicianLat'];
    technicianLng = json['technicianLng'];
    distanceMeters = json['distanceMeters'];
    sId = json['_id'];
    requiresNote = json['requiresNote'] as bool?;
    requiresImage = json['requiresImage'] as bool?;
    requiresSignature = json['requiresSignature'] as bool?;
    requirementReason = json['requirementReason'] as String?;
    completionNote = _readString(json, const [
      'completionNote',
      'note',
      'additionalNote',
    ]);
    completionImage = _readMediaUrl(json, const [
      'completionImage',
      'image',
      'imageUrl',
    ]);
    signature = _readMediaUrl(json, const ['signature', 'signatureUrl']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['group'] = this.group;
    data['order'] = this.order;
    data['isDone'] = this.isDone;
    data['checkedAt'] = this.checkedAt;
    data['technicianLat'] = this.technicianLat;
    data['technicianLng'] = this.technicianLng;
    data['distanceMeters'] = this.distanceMeters;
    data['_id'] = this.sId;
    data['requiresNote'] = this.requiresNote;
    data['requiresImage'] = this.requiresImage;
    data['requiresSignature'] = this.requiresSignature;
    data['requirementReason'] = this.requirementReason;
    data['completionNote'] = this.completionNote;
    data['completionImage'] = this.completionImage;
    data['signature'] = this.signature;
    return data;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static String? _readMediaUrl(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
      if (value is Map) {
        for (final nestedKey in const ['url', 'uri', 'path', 'secure_url']) {
          final nested = value[nestedKey];
          if (nested is String && nested.trim().isNotEmpty) return nested;
        }
      }
    }
    return null;
  }
}

class RescheduleHistory {
  String? previousDate;
  String? newDate;
  String? reason;
  String? rescheduledAt;
  String? sId;

  RescheduleHistory({
    this.previousDate,
    this.newDate,
    this.reason,
    this.rescheduledAt,
    this.sId,
  });

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

class Schedule {
  String? type;
  String? hardStartTime;
  String? betweenDateFrom;
  String? betweenDateTo;
  String? betweenTimeFrom;
  String? betweenTimeTo;
  String? arriveAfterTime;
  String? arriveBeforeTime;

  Schedule({
    this.type,
    this.hardStartTime,
    this.betweenDateFrom,
    this.betweenDateTo,
    this.betweenTimeFrom,
    this.betweenTimeTo,
    this.arriveAfterTime,
    this.arriveBeforeTime,
  });

  Schedule.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    hardStartTime = json['hardStartTime'];
    betweenDateFrom = json['betweenDateFrom'];
    betweenDateTo = json['betweenDateTo'];
    betweenTimeFrom = json['betweenTimeFrom'];
    betweenTimeTo = json['betweenTimeTo'];
    arriveAfterTime = json['arriveAfterTime'];
    arriveBeforeTime = json['arriveBeforeTime'];
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'hardStartTime': hardStartTime,
      'betweenDateFrom': betweenDateFrom,
      'betweenDateTo': betweenDateTo,
      'betweenTimeFrom': betweenTimeFrom,
      'betweenTimeTo': betweenTimeTo,
      'arriveAfterTime': arriveAfterTime,
      'arriveBeforeTime': arriveBeforeTime,
    };
  }
}
