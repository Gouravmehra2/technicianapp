class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.1.6:5001';
  static const String socketUrl = 'http://192.168.1.6:5001';

  // =========================
  // Auth
  // =========================

  static const String login = '/api/technician-auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // =========================
  // Technician Auth
  // =========================

  static const String sendOtp = '/api/technician-auth/send-otp';
  static const String verifyOtp = '/api/technician-auth/verify-otp';
  static const String register = '/api/technician-auth/complete-signup';
  static const String uploadDocuments = '/api/technician-auth/upload-documents';
  static const String completeProfile = '/api/technician-auth/complete-profile';
  static const String bankDetails = '/api/technician-auth/bank-details';
  static const String me = '/api/technician-auth/me';

  // =========================
  // FCM / Device Token
  // =========================

  /// PATCH /api/technician-auth/fcm-token
  /// Body: { "fcmToken": "<token>", "platform": "android" | "ios" }
  static const String updateFcmToken = '/api/technician-auth/fcm-token';

  // =========================
  // User
  // =========================

  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/account';

  // =========================
  // Home
  // =========================

  static const String home = '/home';

  // =========================
  // Technician
  // =========================

  static const String technicianDashboard = '/api/technician/dashboard';
  static const String technicianJobs = '/api/technician/jobs';

  // =========================
  // Services
  // =========================

  static const String services = '/services';

  // =========================
  // Booking
  // =========================

  static const String bookings = '/bookings';

  static String bookingDetails(String id) {
    return '/bookings/$id';
  }

  static String cancelBooking(String id) {
    return '/bookings/$id/cancel';
  }

  // =========================
  // Counter Offer / Charges
  // =========================

  /// POST /api/technician/jobs/:jobId/request
  /// Body: { note?, fixedPrice?, charges?: [{label, description, amount}] }
  static String requestJob(String jobId) {
    return '/api/technician/jobs/$jobId/request';
  }

  /// GET  /api/technician/requests/:requestId/status
  static String requestStatus(String requestId) {
    return '/api/technician/requests/$requestId/status';
  }

  /// POST /api/technician/requests/:requestId/charges
  static String submitCharges(String requestId) {
    return '/api/technician/requests/$requestId/charges';
  }

  /// GET  /api/technician/requests/:requestId/charges
  static String getMyCharges(String requestId) {
    return '/api/technician/requests/$requestId/charges';
  }

  /// PATCH /api/technician/charges/:chargeId/respond
  static String respondToCharge(String chargeId) {
    return '/api/technician/charges/$chargeId/respond';
  }

  /// GET  /api/technician/requests/:requestId/invoice
  static String getTechnicianInvoice(String requestId) {
    return '/api/technician/requests/$requestId/invoice';
  }
}