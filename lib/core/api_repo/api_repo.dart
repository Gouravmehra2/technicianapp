import 'package:dio/dio.dart';
import 'package:technicianapp/core/dio_client/dio_client.dart';
import 'package:technicianapp/core/end_point/end_point.dart';

class ApiRepo {
  final DioClient dioClient;

  ApiRepo({required this.dioClient});

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
}
