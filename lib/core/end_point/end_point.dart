class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.1.41:5001';
  static const String socketUrl = 'http://192.168.1.41:5001';

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
}