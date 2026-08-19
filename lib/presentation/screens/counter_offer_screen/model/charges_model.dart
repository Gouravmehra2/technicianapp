/// Models for the GET /api/technician/requests/:requestId/status response.
/// Maps to the backend `getMyRequestStatus` controller output.

// ─────────────────────────────────────────────────────────────────────────────
// Top-level response
// ─────────────────────────────────────────────────────────────────────────────

class RequestStatusModel {
  final bool success;
  final RequestStatusData data;

  const RequestStatusModel({required this.success, required this.data});

  factory RequestStatusModel.fromJson(Map<String, dynamic> json) {
    return RequestStatusModel(
      success: json['success'] == true,
      data: RequestStatusData.fromJson(
          json['data'] as Map<String, dynamic>),
    );
  }
}

class RequestStatusData {
  final RequestOverview request;
  final JobSummary? job;
  final InvoiceModel? invoice;
  final ChargesBreakdown charges;
  final ChargesSummary summary;
  final String? nextAction;

  const RequestStatusData({
    required this.request,
    this.job,
    this.invoice,
    required this.charges,
    required this.summary,
    this.nextAction,
  });

  factory RequestStatusData.fromJson(Map<String, dynamic> json) {
    return RequestStatusData(
      request: RequestOverview.fromJson(
          json['request'] as Map<String, dynamic>),
      job: json['job'] != null
          ? JobSummary.fromJson(json['job'] as Map<String, dynamic>)
          : null,
      invoice: json['invoice'] != null
          ? InvoiceModel.fromJson(json['invoice'] as Map<String, dynamic>)
          : null,
      charges: ChargesBreakdown.fromJson(
          json['charges'] as Map<String, dynamic>),
      summary: ChargesSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      nextAction: json['nextAction'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request overview
// ─────────────────────────────────────────────────────────────────────────────

class RequestOverview {
  final String id;
  final String status;
  final String chargesStatus;
  final String? note;
  final String? adminMessage;
  final double? agreedFixedCharge;
  final double? agreedAdditionalTotal;
  final double? agreedTotal;
  final String? createdAt;

  const RequestOverview({
    required this.id,
    required this.status,
    required this.chargesStatus,
    this.note,
    this.adminMessage,
    this.agreedFixedCharge,
    this.agreedAdditionalTotal,
    this.agreedTotal,
    this.createdAt,
  });

  factory RequestOverview.fromJson(Map<String, dynamic> json) {
    return RequestOverview(
      id: json['_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      chargesStatus: json['chargesStatus'] as String? ?? 'none',
      note: json['note'] as String?,
      adminMessage: json['adminMessage'] as String?,
      agreedFixedCharge: _toDouble(json['agreedFixedCharge']),
      agreedAdditionalTotal: _toDouble(json['agreedAdditionalTotal']),
      agreedTotal: _toDouble(json['agreedTotal']),
      createdAt: json['createdAt'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job summary (nested inside status response)
// ─────────────────────────────────────────────────────────────────────────────

class JobSummary {
  final String id;
  final String title;
  final String location;
  final double budget;
  final String category;

  const JobSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.budget,
    required this.category,
  });

  factory JobSummary.fromJson(Map<String, dynamic> json) {
    return JobSummary(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      budget: _toDouble(json['budget']) ?? 0,
      category: json['category'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single charge item
// ─────────────────────────────────────────────────────────────────────────────

class ChargeItem {
  final String id;
  final String label;
  final String description;
  final double requestedAmount;
  final double? adminCounterAmount;
  final String? adminNote;
  final double? agreedAmount;
  final String status; // pending | accepted | rejected | countered
  final bool needsYourResponse;
  final String? submittedAt;
  final String? reviewedAt;
  final String? resolvedAt;

  const ChargeItem({
    required this.id,
    required this.label,
    required this.description,
    required this.requestedAmount,
    this.adminCounterAmount,
    this.adminNote,
    this.agreedAmount,
    required this.status,
    required this.needsYourResponse,
    this.submittedAt,
    this.reviewedAt,
    this.resolvedAt,
  });

  factory ChargeItem.fromJson(Map<String, dynamic> json) {
    return ChargeItem(
      id: json['_id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requestedAmount: _toDouble(json['requestedAmount']) ?? 0,
      adminCounterAmount: _toDouble(json['adminCounterAmount']),
      adminNote: json['adminNote'] as String?,
      agreedAmount: _toDouble(json['agreedAmount']),
      status: json['status'] as String? ?? 'pending',
      needsYourResponse: json['needsYourResponse'] == true,
      submittedAt: json['submittedAt'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Charges breakdown (grouped by state)
// ─────────────────────────────────────────────────────────────────────────────

class ChargesBreakdown {
  final List<ChargeItem> pendingAdminReview;
  final List<ChargeItem> awaitingYourReply;
  final List<ChargeItem> accepted;
  final List<ChargeItem> rejected;
  final List<ChargeItem> all;

  const ChargesBreakdown({
    required this.pendingAdminReview,
    required this.awaitingYourReply,
    required this.accepted,
    required this.rejected,
    required this.all,
  });

  factory ChargesBreakdown.fromJson(Map<String, dynamic> json) {
    return ChargesBreakdown(
      pendingAdminReview: _parseList(json['pendingAdminReview']),
      awaitingYourReply: _parseList(json['awaitingYourReply']),
      accepted: _parseList(json['accepted']),
      rejected: _parseList(json['rejected']),
      all: _parseList(json['all']),
    );
  }

  static List<ChargeItem> _parseList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List).map((e) => ChargeItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Charges summary counts
// ─────────────────────────────────────────────────────────────────────────────

class ChargesSummary {
  final int totalCharges;
  final int pendingAdminReview;
  final int awaitingYourReply;
  final int accepted;
  final int rejected;
  final bool allResolved;

  const ChargesSummary({
    required this.totalCharges,
    required this.pendingAdminReview,
    required this.awaitingYourReply,
    required this.accepted,
    required this.rejected,
    required this.allResolved,
  });

  factory ChargesSummary.fromJson(Map<String, dynamic> json) {
    return ChargesSummary(
      totalCharges: json['totalCharges'] as int? ?? 0,
      pendingAdminReview: json['pendingAdminReview'] as int? ?? 0,
      awaitingYourReply: json['awaitingYourReply'] as int? ?? 0,
      accepted: json['accepted'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      allResolved: json['allResolved'] == true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice model
// ─────────────────────────────────────────────────────────────────────────────

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final double fixedJobCharge;
  final List<InvoiceLineItem> additionalCharges;
  final double subtotalAdditional;
  final double totalAmount;
  final String status; // draft | finalised | paid
  final String? paidAt;
  final String? finalisedAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.fixedJobCharge,
    required this.additionalCharges,
    required this.subtotalAdditional,
    required this.totalAmount,
    required this.status,
    this.paidAt,
    this.finalisedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['_id'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      fixedJobCharge: _toDouble(json['fixedJobCharge']) ?? 0,
      additionalCharges: (json['additionalCharges'] as List? ?? [])
          .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotalAdditional: _toDouble(json['subtotalAdditional']) ?? 0,
      totalAmount: _toDouble(json['totalAmount']) ?? 0,
      status: json['status'] as String? ?? 'draft',
      paidAt: json['paidAt'] as String?,
      finalisedAt: json['finalisedAt'] as String?,
    );
  }
}

class InvoiceLineItem {
  final String label;
  final String description;
  final double agreedAmount;

  const InvoiceLineItem({
    required this.label,
    required this.description,
    required this.agreedAmount,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      agreedAmount: _toDouble(json['agreedAmount']) ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}
