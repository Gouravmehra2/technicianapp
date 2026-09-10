
class MyRequestsModel {
  final bool success;
  final MyRequestsData? data;

  const MyRequestsModel({required this.success, this.data});

  factory MyRequestsModel.fromJson(Map<String, dynamic> json) {
    return MyRequestsModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? MyRequestsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MyRequestsData {
  final List<MyRequest> requests;

  const MyRequestsData({required this.requests});

  factory MyRequestsData.fromJson(Map<String, dynamic> json) {
    final raw = json['requests'] as List? ?? [];
    return MyRequestsData(
      requests: raw
          .map((e) => MyRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MyRequest {
  final String id;
  final MyRequestJob? job;
  final String status;
  final String? note;
  final int? counterOffer;
  final String? counterOfferFrom;
  final String? adminMessage;
  final List<MyRequestConversationEntry> conversation;
  final String? createdAt;

  const MyRequest({
    required this.id,
    this.job,
    required this.status,
    this.note,
    this.counterOffer,
    this.counterOfferFrom,
    this.adminMessage,
    required this.conversation,
    this.createdAt,
  });

  factory MyRequest.fromJson(Map<String, dynamic> json) {
    final rawConvo = json['conversation'] as List? ?? [];
    return MyRequest(
      id: json['_id'] as String? ?? '',
      job: json['job'] != null
          ? MyRequestJob.fromJson(json['job'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
      counterOffer: json['counterOffer'] as int?,
      counterOfferFrom: json['counterOfferFrom'] as String?,
      adminMessage: json['adminMessage'] as String?,
      conversation: rawConvo
          .map((e) =>
              MyRequestConversationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
    );
  }
}

class MyRequestJob {
  final String id;
  final String title;
  final int? budget;
  final String? status;

  const MyRequestJob({
    required this.id,
    required this.title,
    this.budget,
    this.status,
  });

  factory MyRequestJob.fromJson(Map<String, dynamic> json) {
    return MyRequestJob(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      budget: json['budget'] as int?,
      status: json['status'] as String?,
    );
  }
}

class MyRequestConversationEntry {
  final String sender;
  final String message;
  final int? counterOffer;
  final String? counterOfferFrom;
  final String? createdAt;

  const MyRequestConversationEntry({
    required this.sender,
    required this.message,
    this.counterOffer,
    this.counterOfferFrom,
    this.createdAt,
  });

  factory MyRequestConversationEntry.fromJson(Map<String, dynamic> json) {
    return MyRequestConversationEntry(
      sender: json['sender'] as String? ?? '',
      message: json['message'] as String? ?? '',
      counterOffer: json['counterOffer'] as int?,
      counterOfferFrom: json['counterOfferFrom'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. GET MY JOBS (ACCEPTED)  —  GET /api/technician/myjobs
//    Full models are in lib/presentation/screens/job_screen/my_jobs_model.dart
//    and re-exported above.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// 8. GET METRICS  —  GET /api/technician/metrics
// ─────────────────────────────────────────────────────────────────────────────

class MetricsModel {
  final bool success;
  final MetricsData? data;

  const MetricsModel({required this.success, this.data});

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? MetricsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MetricsData {
  final MetricsInfo metrics;

  const MetricsData({required this.metrics});

  factory MetricsData.fromJson(Map<String, dynamic> json) {
    return MetricsData(
      metrics: MetricsInfo.fromJson(json['metrics'] as Map<String, dynamic>),
    );
  }
}

class MetricsInfo {
  final int totalJobsDone;
  final int totalEarnings;
  final int totalWithdrawn;
  final int availableBalance;
  final int acceptedCount;
  final int pendingCount;
  final int activeJobs;
  final int todaySchedule;
  final int totalRequests;

  const MetricsInfo({
    required this.totalJobsDone,
    required this.totalEarnings,
    required this.totalWithdrawn,
    required this.availableBalance,
    required this.acceptedCount,
    required this.pendingCount,

    required this.activeJobs,
    required this. todaySchedule,
    required this. totalRequests

  });

  factory MetricsInfo.fromJson(Map<String, dynamic> json) {
    return MetricsInfo(
      totalJobsDone: json['totalJobsDone'] as int? ?? 0,
      totalEarnings: json['totalEarnings'] as int? ?? 0,
      totalWithdrawn: json['totalWithdrawn'] as int? ?? 0,
      availableBalance: json['availableBalance'] as int? ?? 0,
      acceptedCount: json['acceptedCount'] as int? ?? 0,
      pendingCount: json['pendingCount'] as int? ?? 0,
      activeJobs: json['activeJobs'] as int? ?? 0,
      todaySchedule: json['todaySchedule'] as int? ?? 0,
      totalRequests: json['totalRequests'] as int? ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 13. POST WITHDRAWAL  —  POST /api/technician/withdraw
// Response model (the request body is passed directly as a Map)
// ─────────────────────────────────────────────────────────────────────────────

class WithdrawalResponseModel {
  final bool success;
  final String? message;
  final WithdrawalItem? data;

  const WithdrawalResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory WithdrawalResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return WithdrawalResponseModel(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: dataRaw != null
          ? WithdrawalItem.fromJson(dataRaw as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 14. GET WITHDRAWALS  —  GET /api/technician/withdrawals
// ─────────────────────────────────────────────────────────────────────────────

class WithdrawalsModel {
  final bool success;
  final WithdrawalsData? data;

  const WithdrawalsModel({required this.success, this.data});

  factory WithdrawalsModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalsModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? WithdrawalsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WithdrawalsData {
  final List<WithdrawalItem> withdrawals;

  const WithdrawalsData({required this.withdrawals});

  factory WithdrawalsData.fromJson(Map<String, dynamic> json) {
    final raw = json['withdrawals'] as List? ?? [];
    return WithdrawalsData(
      withdrawals: raw
          .map((e) => WithdrawalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WithdrawalItem {
  final String id;
  final int amount;
  final String status; // pending | completed | rejected
  final String? method;
  final String? details;
  final String? createdAt;

  const WithdrawalItem({
    required this.id,
    required this.amount,
    required this.status,
    this.method,
    this.details,
    this.createdAt,
  });

  factory WithdrawalItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalItem(
      id: json['_id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      method: json['method'] as String?,
      details: json['details'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. GET CONVERSATION  —  GET /api/technician/conversation/:requestId
// ─────────────────────────────────────────────────────────────────────────────

class ConversationModel {
  final bool success;
  final ConversationData? data;

  const ConversationModel({required this.success, this.data});

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      success: json['success'] == true,
      data: json['data'] != null
          ? ConversationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ConversationData {
  final String requestId;
  final List<ConversationEntry> conversation;

  const ConversationData({
    required this.requestId,
    required this.conversation,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    final raw = json['conversation'] as List? ?? [];
    return ConversationData(
      requestId: json['requestId'] as String? ?? '',
      conversation: raw
          .map((e) => ConversationEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ConversationEntry {
  final String sender; // 'technician' | 'admin'
  final String message;
  final int? counterOffer;
  final String? counterOfferFrom;
  final String? createdAt;

  const ConversationEntry({
    required this.sender,
    required this.message,
    this.counterOffer,
    this.counterOfferFrom,
    this.createdAt,
  });

  factory ConversationEntry.fromJson(Map<String, dynamic> json) {
    return ConversationEntry(
      sender: json['sender'] as String? ?? '',
      message: json['message'] as String? ?? '',
      counterOffer: json['counterOffer'] as int?,
      counterOfferFrom: json['counterOfferFrom'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. PATCH MARK REACHED  —  PATCH /api/technician/jobs/:jobId/reached
// ─────────────────────────────────────────────────────────────────────────────

class MarkReachedModel {
  final bool success;
  final String? message;
  final MarkReachedData? data;

  const MarkReachedModel({required this.success, this.message, this.data});

  factory MarkReachedModel.fromJson(Map<String, dynamic> json) {
    return MarkReachedModel(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null
          ? MarkReachedData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MarkReachedData {
  final String? reachedAt;
  final String? jobStartedAt;
  final String? status; // 'in-progress'

  const MarkReachedData({this.reachedAt, this.jobStartedAt, this.status});

  factory MarkReachedData.fromJson(Map<String, dynamic> json) {
    return MarkReachedData(
      reachedAt: json['reachedAt'] as String?,
      jobStartedAt: json['jobStartedAt'] as String?,
      status: json['status'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. PATCH MARK COMPLETED  —  PATCH /api/technician/jobs/:jobId/complete
// ─────────────────────────────────────────────────────────────────────────────

class MarkCompletedModel {
  final bool success;
  final String? message;
  final MarkCompletedData? data;

  const MarkCompletedModel({required this.success, this.message, this.data});

  factory MarkCompletedModel.fromJson(Map<String, dynamic> json) {
    return MarkCompletedModel(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null
          ? MarkCompletedData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MarkCompletedData {
  final String? jobCompletedAt;
  final int? jobDurationMinutes;
  final String? reachedAt;

  const MarkCompletedData({
    this.jobCompletedAt,
    this.jobDurationMinutes,
    this.reachedAt,
  });

  factory MarkCompletedData.fromJson(Map<String, dynamic> json) {
    return MarkCompletedData(
      jobCompletedAt: json['jobCompletedAt'] as String?,
      jobDurationMinutes: json['jobDurationMinutes'] as int?,
      reachedAt: json['reachedAt'] as String?,
    );
  }
}
