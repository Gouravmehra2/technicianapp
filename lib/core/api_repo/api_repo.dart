import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:technicianapp/core/dio_client/dio_client.dart';
import 'package:technicianapp/core/end_point/end_point.dart';
import 'package:technicianapp/core/models/chat_detail_model.dart';
import 'package:technicianapp/core/models/technician_models.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

class ApiRepo {
  final DioClient dioClient;

  ApiRepo(this.dioClient);

  Future<Response> loginApi(Map<String, dynamic> data) async {
    try {
      return await dioClient.post(ApiEndpoints.login, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Login with phone number (E.164 format) + password.
  /// Payload: { "phone": "+919999999999", "password": "123456" }
  Future<Response> loginWithPhoneApi({
    required String phone,
    required String password,
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.login,
        data: {'phone': phone, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email + password.
  /// Payload: { "email": "user@example.com", "password": "123456" }
  Future<Response> loginWithEmailApi({
    required String email,
    required String password,
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send OTP.
  ///
  /// Email login/signup  → pass [email], leave [phone] null.
  /// Phone login/signup  → pass [phone] (full E.164 e.g. "+917710567945"), leave [email] null.
  Future<Response> sendOtpApi({String? email, String? phone}) async {
    assert(
      (email != null) ^ (phone != null),
      'Provide exactly one of email or phone.',
    );
    final data = email != null ? {'email': email} : {'phone': phone};
    try {
      return await dioClient.post(ApiEndpoints.sendOtp, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP.
  ///
  /// Email flow  → pass [email], leave [phone] null.
  /// Phone flow  → pass [phone] (full E.164), leave [email] null.
  Future<Response> verifyOtpApi({
    String? email,
    String? phone,
    required String otp,
  }) async {
    assert(
      (email != null) ^ (phone != null),
      'Provide exactly one of email or phone.',
    );
    final data = email != null
        ? {'email': email, 'otp': otp}
        : {'phone': phone, 'otp': otp};
    try {
      return await dioClient.post(ApiEndpoints.verifyOtp, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload a profile photo only (used during sign-up).
  /// Returns the response containing the uploaded file URL.
  Future<Response> uploadProfilePhotoApi(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePhoto': await MultipartFile.fromFile(filePath),
      });
      return await dioClient.post(
        ApiEndpoints.uploadDocuments,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload all onboarding documents in a single multipart request.
  ///
  /// Payload structure expected by /api/technician-auth/upload-documents:
  /// {
  ///   "drivingLicense": { "front": "...", "back": "..." },
  ///   "taxInformation": { "w9Form": "...", "form1099": "..." },
  ///   "residentialProof": "...",
  ///   "cvResume": "...",
  ///   "backgroundVerification": "..."
  /// }
  ///
  /// Multipart field names:
  ///   drivingLicenseFront      → drivingLicense.front
  ///   drivingLicenseBack       → drivingLicense.back
  ///   residentialProof         → residentialProof
  ///   taxInformationW9         → taxInformation.w9Form
  ///   taxInformation1099       → taxInformation.form1099
  ///   cvResume                 → cvResume
  ///   backgroundVerification   → backgroundVerification
  Future<Response> uploadOnboardingDocumentsApi({
    required String drivingLicenseFrontPath,
    required String drivingLicenseBackPath,
    required String residentialProofPath,
    required String w9DocPath,
    String? doc1099Path,
    required String cvResumePath,
    required String backgroundVerificationPath,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'drivingLicenseFront': await MultipartFile.fromFile(
          drivingLicenseFrontPath,
          filename: drivingLicenseFrontPath.split('/').last,
        ),
        'drivingLicenseBack': await MultipartFile.fromFile(
          drivingLicenseBackPath,
          filename: drivingLicenseBackPath.split('/').last,
        ),
        'residentialProof': await MultipartFile.fromFile(
          residentialProofPath,
          filename: residentialProofPath.split('/').last,
        ),
        'taxInformationW9': await MultipartFile.fromFile(
          w9DocPath,
          filename: w9DocPath.split('/').last,
        ),
        'cvResume': await MultipartFile.fromFile(
          cvResumePath,
          filename: cvResumePath.split('/').last,
        ),
        'backgroundVerification': await MultipartFile.fromFile(
          backgroundVerificationPath,
          filename: backgroundVerificationPath.split('/').last,
        ),
      };

      // 1099 is optional
      if (doc1099Path != null && doc1099Path.isNotEmpty) {
        fields['taxInformation1099'] = await MultipartFile.fromFile(
          doc1099Path,
          filename: doc1099Path.split('/').last,
        );
      }

      final formData = FormData.fromMap(fields);
      return await dioClient.post(
        ApiEndpoints.uploadDocuments,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Complete signup — POST /api/technician-auth/complete-signup
  ///
  /// Payload: { email, phone, name, password, confirmPassword }
  Future<Response> registerApi(Map<String, dynamic> data) async {
    try {
      return await dioClient.post(ApiEndpoints.register, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete profile (skills + experience) — POST /api/technician-auth/complete-profile
  ///
  /// Payload:
  /// {
  ///   "skills": ["Plumbing", "Electrical"],
  ///   "experienceLevel": "Intermediate",
  ///   "yearsOfExperience": 4,
  ///   "certifications": ["Plumbing Certificate"]
  /// }
  Future<Response> completeProfileApi({
    required List<String> skills,
    required String experienceLevel,
    required int yearsOfExperience,
    required List<String> certifications,
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.completeProfile,
        data: {
          'skills': skills,
          'experienceLevel': experienceLevel,
          'yearsOfExperience': yearsOfExperience,
          'certifications': certifications,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Save bank details — POST /api/technician-auth/bank-details
  ///
  /// Payload:
  /// {
  ///   "accountHolder": "Rahul Sharma",
  ///   "bankName": "HDFC Bank",
  ///   "accountNumber": "123456789012",
  ///   "ifscCode": "HDFC0001234",
  ///   "upiId": "rahul@upi"
  /// }
  Future<Response> bankDetailsApi({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    try {
      return await dioClient.put(
        ApiEndpoints.bankDetails,
        data: {
          'accountHolder': accountHolder,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
          if (upiId != null && upiId.isNotEmpty) 'upiId': upiId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Keep old name as alias so sign_up_detail_controller continues to compile
  Future<Response> uploadDocumentsApi(String filePath) =>
      uploadProfilePhotoApi(filePath);

  /// Fetch the current technician profile — GET /api/technician-auth/me
  Future<Response> getMeApi() async {
    try {
      return await dioClient.get(ApiEndpoints.me);
    } catch (e) {
      rethrow;
    }
  }

  /// Register or update the device push token on the server.
  ///
  /// Call this:
  ///   • After a successful login
  ///   • When the FCM token is refreshed (`FirebaseService.onTokenUpdated`)
  ///   • On app start if the user is already logged in
  ///
  /// [platform] should be `"android"` or `"ios"`.
  Future<Response> updateFcmTokenApi({
    required String token,
    required String platform,
  }) async {
    try {
      return await dioClient.patch(
        ApiEndpoints.updateFcmToken,
        data: {'fcmToken': token, 'platform': platform},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch technician dashboard — GET /api/technician/dashboard
  Future<DashboardModel> getTechnicianDashboardApi() async {
    try {
      final response = await dioClient.get(ApiEndpoints.technicianDashboard);
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch open jobs for technician — kept for legacy use elsewhere.
  /// Prefer getNewJobsApi() in JobController.
  Future<NewJobsModel> getTechnicianJobsApi() async {
    try {
      final response = await dioClient.get(ApiEndpoints.technicianJobs);
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Re-upload documents after rejection — reuses the same upload endpoint.
  Future<Response> reUploadDocumentsApi({
    String? drivingLicenseFrontPath,
    String? drivingLicenseBackPath,
    String? residentialProofPath,
    String? w9DocPath,
    String? doc1099Path,
    String? cvResumePath,
    String? backgroundVerificationPath,
  }) async {
    try {
      final Map<String, dynamic> fields = {};
      if (drivingLicenseFrontPath != null) {
        fields['drivingLicenseFront'] = await MultipartFile.fromFile(
          drivingLicenseFrontPath,
          filename: drivingLicenseFrontPath.split('/').last,
        );
      }
      if (drivingLicenseBackPath != null) {
        fields['drivingLicenseBack'] = await MultipartFile.fromFile(
          drivingLicenseBackPath,
          filename: drivingLicenseBackPath.split('/').last,
        );
      }
      if (residentialProofPath != null) {
        fields['residentialProof'] = await MultipartFile.fromFile(
          residentialProofPath,
          filename: residentialProofPath.split('/').last,
        );
      }
      if (w9DocPath != null) {
        fields['taxInformationW9'] = await MultipartFile.fromFile(
          w9DocPath,
          filename: w9DocPath.split('/').last,
        );
      }
      if (doc1099Path != null) {
        fields['taxInformation1099'] = await MultipartFile.fromFile(
          doc1099Path,
          filename: doc1099Path.split('/').last,
        );
      }
      if (cvResumePath != null) {
        fields['cvResume'] = await MultipartFile.fromFile(
          cvResumePath,
          filename: cvResumePath.split('/').last,
        );
      }
      if (backgroundVerificationPath != null) {
        fields['backgroundVerification'] = await MultipartFile.fromFile(
          backgroundVerificationPath,
          filename: backgroundVerificationPath.split('/').last,
        );
      }
      final formData = FormData.fromMap(fields);
      return await dioClient.post(
        ApiEndpoints.uploadDocuments,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ── Counter Offer / Charges APIs ─────────────────────────────────────────────

  /// POST /api/technician/jobs/:jobId/request
  ///
  /// Body: { note?, fixedPrice?, charges?: [{label, description, amount}] }
  /// Returns the created TechnicianJobRequest with its `_id` as `requestId`.
  Future<Response> requestJobApi({
    required String jobId,
    String? note,
    int? fixedPrice,
    List<Map<String, dynamic>>? charges,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (note != null && note.isNotEmpty) body['note'] = note;
      if (fixedPrice != null && fixedPrice > 0) body['fixedPrice'] = fixedPrice;
      if (charges != null && charges.isNotEmpty) body['charges'] = charges;
      return await dioClient.post(ApiEndpoints.requestJob(jobId), data: body);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/requests/:requestId/status
  ///
  /// Returns full status: charges grouped by state + invoice + next-action hint.
  Future<RequestStatusModel> getRequestStatusApi(String requestId) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.requestStatus(requestId),
      );
      return RequestStatusModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/technician/requests/:requestId/charges
  ///
  /// Body: { "charges": [{ "label", "description", "amount" }] }
  Future<Response> submitChargesApi({
    required String requestId,
    required List<Map<String, dynamic>> charges,
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.submitCharges(requestId),
        data: {'charges': charges},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH /api/technician/charges/:chargeId/respond
  ///
  /// Body: { "action": "accept" | "counter" | "reject", "note"?: "", "amount"?: 220 }
  /// Per the PDF: for action='counter', additionally send amount.
  Future<Response> respondToChargeApi({
    required String chargeId,
    required String action, // 'accept' | 'counter' | 'reject'
    double? amount, // required when action == 'counter'
    String? note,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'action': action,
        'note': note ?? '',
        if (amount != null) 'amount': amount,
      };
      return await dioClient.patch(
        ApiEndpoints.respondToCharge(chargeId),
        data: body,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/technician/job-requests/:requestId/cancel
  ///
  /// Cancels a pending job request made by the technician.
  /// Returns: { success, message, data: { requestId, jobId, technicianId } }
  Future<Response> cancelJobRequestApi({required String requestId}) async {
    try {
      return await dioClient.patch(ApiEndpoints.cancelJobRequest(requestId));
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/technician/requests/:requestId/counter-offer
  ///
  /// Body: { "amount": 220, "message": "optional message" }
  /// Used when admin has sent a counter and the technician responds with a new amount.
  Future<Response> sendCounterOfferApi({
    required String requestId,
    required double amount,
    String message = '',
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.sendCounterOffer(requestId),
        data: {'amount': amount, 'message': message},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/technician/requests/:requestId/message
  ///
  /// Body: { "message": "<text>" }
  /// Returns the created conversation entry.
  Future<Response> sendMessageApi({
    required String requestId,
    required String message,
  }) async {
    try {
      return await dioClient.post(
        ApiEndpoints.sendMessage(requestId),
        data: {'message': message},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/requests/:requestId/messages
  ///
  /// Returns the full conversation for the request.
  Future<Response> getMessagesApi(String requestId) async {
    try {
      return await dioClient.get(ApiEndpoints.getMessages(requestId));
    } catch (e) {
      rethrow;
    }
  }

  // ── New endpoints ─────────────────────────────────────────────────────────────

  /// GET /api/technician/jobs?filter=new
  ///
  /// Returns new/open jobs available for this technician.
  Future<NewJobsModel> getNewJobsApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'new'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=requested
  ///
  /// Returns jobs that the technician has already sent a request for.
  Future<NewJobsModel> getRequestedJobsApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'requested'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=active
  ///
  /// Returns active (accepted / in-progress) jobs for this technician.
  Future<NewJobsModel> getActiveJobsApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'active'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=completed
  ///
  /// Returns completed jobs for this technician.
  Future<NewJobsModel> getCompletedJobsApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'completed'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=today
  ///
  /// Returns scheduled jobs for today.
  Future<NewJobsModel> getScheduledJobsTodayApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'today'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=tomorrow
  ///
  /// Returns scheduled jobs for tomorrow.
  Future<NewJobsModel> getScheduledJobsTomorrowApi() async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {'filter': 'tomorrow'},
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/jobs?filter=custom&fromDate=YYYY-MM-DD&toDate=YYYY-MM-DD
  ///
  /// Returns scheduled jobs for the full week (today through today+6).
  Future<NewJobsModel> getScheduledJobsWeekApi({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.technicianJobs,
        queryParameters: {
          'filter': 'custom',
          'fromDate': _toDateString(fromDate),
          'toDate': _toDateString(toDate),
        },
      );
      return NewJobsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Formats a [DateTime] as `YYYY-MM-DD` in local time.
  String _toDateString(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// GET /api/technician/metrics
  ///
  /// Returns performance metrics: totalJobsDone, totalEarnings, balance, etc.
  Future<MetricsModel> getMetricsApi() async {
    try {
      final response = await dioClient.get(ApiEndpoints.metrics);
      return MetricsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH /api/technician/jobs/:jobId/start-navigation
  ///
  /// Signals to the backend that the technician has started navigation
  /// to the job location. No request body required.
  Future<void> startNavigationApi(String jobId) async {
    try {
      await dioClient.patch(ApiEndpoints.startNavigation(jobId));
    } catch (e) {
      // Non-blocking — log and continue so navigation still starts even if
      // the API call fails (e.g. offline or temporary network hiccup).
      print('[ApiRepo] startNavigationApi error: $e');
    }
  }

  /// PATCH /api/technician/jobs/:jobId/reached
  ///
  /// Records that the technician has reached the job location.
  Future<MarkReachedModel> markReachedApi(
    String jobId, {
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await dioClient.patch(
        ApiEndpoints.markReached(jobId),
        data: {'lat': lat, 'lng': lng},
      );
      return MarkReachedModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH /api/technician/jobs/:jobId/complete
  ///
  /// Marks the job as completed by the technician.
  /// No request body required. Admin still needs to close and process payment.
  Future<MarkCompletedModel> markCompletedApi(String jobId) async {
    try {
      final response = await dioClient.patch(ApiEndpoints.markCompleted(jobId));
      return MarkCompletedModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/technician/withdraw
  ///
  /// Creates a withdrawal request.
  ///
  /// Payload example:
  /// {
  ///   "amount": 5000,
  ///   "method": "bank",          // "bank" | "upi"
  ///   "details": "HDFC xxxxxx"   // optional note
  /// }
  Future<WithdrawalResponseModel> createWithdrawalApi({
    required int amount,
    required String method,
    String? details,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'amount': amount,
        'method': method,
        if (details != null && details.isNotEmpty) 'details': details,
      };
      final response = await dioClient.post(
        ApiEndpoints.createWithdrawal,
        data: body,
      );
      return WithdrawalResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/withdrawals
  ///
  /// Returns the full withdrawal history for this technician.
  Future<WithdrawalsModel> getWithdrawalsApi() async {
    try {
      final response = await dioClient.get(ApiEndpoints.withdrawals);
      return WithdrawalsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/conversation/:requestId
  ///
  /// Returns the complete conversation history for a specific request.
  Future<ChatDetailModel> getConversationApi(String requestId) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.getConversation(requestId),
      );
      return ChatDetailModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/technician/details/:jobId
  ///
  /// Returns full job details including the technician's request for that job.
  Future<Jobs> getJobDetailApi(String jobId) async {
    try {
      final response = await dioClient.get(ApiEndpoints.jobDetails(jobId));
      return Jobs.fromJson(
        response.data['data']['job'] as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}
