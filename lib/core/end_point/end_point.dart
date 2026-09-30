class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.1.24:5001';
  static const String socketUrl = 'http://192.168.1.24:5001';

  //Live Url
  // static const String baseUrl = 'http://52.52.223.128:5001';
  // static const String socketUrl = 'http://52.52.223.128:5001';

  // =========================
  // Auth
  // =========================

  static const String login = '/api/technician-auth/login';
  static const String logout = '/api/auth/logout';
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
  static const String serviceTypes = '/api/service-types';

  /// GET /api/technician/requests
  static const String myRequests = '/api/technician/requests';

  /// GET /api/technician/myjobs

  /// GET /api/technician/metrics
  static const String metrics = '/api/technician/metrics';

  /// POST /api/technician/withdraw
  static const String createWithdrawal = '/api/technician/withdraw';

  /// GET /api/technician/withdrawals
  static const String withdrawals = '/api/technician/withdrawals';

  /// PATCH /api/technician/jobs/:jobId/start-navigation
  static String startNavigation(String jobId) {
    return '/api/technician/jobs/$jobId/start-navigation';
  }

  /// PATCH /api/technician/jobs/:jobId/reached
  static String markReached(String jobId) {
    return '/api/technician/jobs/$jobId/reached';
  }

  /// PATCH /api/technician/jobs/:jobId/complete
  static String markCompleted(String jobId) {
    return '/api/technician/jobs/$jobId/complete';
  }

  /// PATCH /api/technician/jobs/:jobId/tasks/:taskIndex/complete
  static String completeTask(String jobId, int taskIndex) {
    return '/api/technician/jobs/$jobId/tasks/$taskIndex/complete';
  }

  /// GET /api/technician/conversation/:requestId
  static String getConversation(String requestId) {
    return '/api/technician/details/$requestId';
  }

  /// GET /api/technician/details/:jobId
  static String jobDetails(String jobId) {
    return '/api/technician/details/$jobId';
  }

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

  /// POST /api/technician/job-requests/:requestId/cancel
  static String cancelJobRequest(String requestId) {
    return '/api/technician/job-requests/$requestId/cancel';
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

  /// POST /api/technician/requests/:requestId/message
  /// Body: { "message": "<text>" }
  static String sendMessage(String requestId) {
    return '/api/technician/requests/$requestId/message';
  }

  /// GET  /api/technician/requests/:requestId/messages
  static String getMessages(String requestId) {
    return '/api/technician/requests/$requestId/messages';
  }

  // =========================
  // Chat support
  // =========================

  static String chatMessages(String technicianId) {
    return '/api/chat/conversations/$technicianId/messages';
  }

  static String chatRead(String technicianId) {
    return '/api/chat/conversations/$technicianId/read';
  }

  /// POST /api/technician/requests/:requestId/counter-offer
  /// Body: { "amount": 220, "message": "optional message" }
  static String sendCounterOffer(String requestId) {
    return '/api/technician/requests/$requestId/counter-offer';
  }

  /// PATCH /api/technician/requests/:requestId/respond
  static String respondToRequest(String requestId) {
    return '/api/technician/requests/$requestId/respond';
  }

  // =========================
  // Routes
  // =========================

  /// POST /api/routes/directions
  /// Body: { "origin": { "lat", "lng" }, "destination": { "lat", "lng" } }
  static const String directions = '/api/routes/directions';
}
