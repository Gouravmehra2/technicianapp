import 'package:get/get.dart';
import 'package:technicianapp/auth/email_login_screen/email_login_binding.dart';
import 'package:technicianapp/auth/email_login_screen/email_login_screen.dart';
import 'package:technicianapp/auth/forgot_password_screen/forgot_password_binding.dart';
import 'package:technicianapp/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:technicianapp/auth/login_screen/login_binding.dart';
import 'package:technicianapp/auth/login_screen/login_screen.dart';
import 'package:technicianapp/auth/otp_screen/otp_binding.dart';
import 'package:technicianapp/auth/otp_screen/otp_screen.dart';
import 'package:technicianapp/auth/sign_up_screen/sign_up_binding.dart';
import 'package:technicianapp/auth/sign_up_screen/sign_up_screen.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/counter_offer_screen.dart';
import 'package:technicianapp/presentation/screens/map_screen/map_binding.dart';
import 'package:technicianapp/presentation/screens/map_screen/map_screen.dart';
import 'package:technicianapp/presentation/screens/dashboard/dasboard_screen.dart';
import 'package:technicianapp/presentation/screens/dashboard/dashboard_binding.dart';
import 'package:technicianapp/presentation/screens/location_detail_screen/location_detail_binding.dart';
import 'package:technicianapp/presentation/screens/location_detail_screen/location_detail_screen.dart';
import 'package:technicianapp/presentation/screens/location_permission_screen/location_permission_bindings.dart';
import 'package:technicianapp/presentation/screens/location_permission_screen/location_permission_screen.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/onboarding_binding.dart';
import 'package:technicianapp/presentation/screens/onboarding_screen/onboarding_screen.dart';
import 'package:technicianapp/presentation/screens/personal_information_screen/personal_information_binding.dart';
import 'package:technicianapp/presentation/screens/personal_information_screen/personal_information_screen.dart';
import 'package:technicianapp/presentation/screens/privacy_policy_screen/privacy_policy_binding.dart';
import 'package:technicianapp/presentation/screens/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:technicianapp/presentation/screens/booking_safety_screen/booking_safety_binding.dart';
import 'package:technicianapp/presentation/screens/booking_safety_screen/booking_safety_screen.dart';
import 'package:technicianapp/presentation/screens/security_screen/security_binding.dart';
import 'package:technicianapp/presentation/screens/security_screen/security_screen.dart';
import 'package:technicianapp/presentation/screens/support_screen/support_binding.dart';
import 'package:technicianapp/presentation/screens/support_screen/support_screen.dart';
import 'package:technicianapp/presentation/screens/support_screen/chat_support_binding.dart';
import 'package:technicianapp/presentation/screens/support_screen/chat_support_screen.dart';
import 'package:technicianapp/presentation/screens/support_screen/call_support_binding.dart';
import 'package:technicianapp/presentation/screens/support_screen/call_support_screen.dart';
import 'package:technicianapp/presentation/screens/support_screen/email_support_binding.dart';
import 'package:technicianapp/presentation/screens/support_screen/email_support_screen.dart';
import 'package:technicianapp/presentation/screens/support_screen/support_thank_you_screen.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_binding.dart';
import 'package:technicianapp/presentation/screens/service_screen/service_screen.dart';
import 'package:technicianapp/presentation/screens/select_location_screen/select_location_binding.dart';
import 'package:technicianapp/presentation/screens/select_location_screen/select_location_screen.dart';
import 'package:technicianapp/presentation/screens/profile_screen/profile_binding.dart';
import 'package:technicianapp/presentation/screens/profile_screen/profile_screen.dart';
import 'package:technicianapp/presentation/screens/splash_screen/splash_binding.dart';
import 'package:technicianapp/presentation/screens/splash_screen/splash_screen.dart';
import 'package:technicianapp/presentation/screens/book_service_screen/book_service_binding.dart';
import 'package:technicianapp/presentation/screens/book_service_screen/book_service_screen.dart';
import 'package:technicianapp/presentation/screens/payment_screen/payment_binding.dart';
import 'package:technicianapp/presentation/screens/payment_screen/payment_screen.dart';
import 'package:technicianapp/presentation/screens/booking_confirmation_screen/booking_confirmation_screen.dart';
import 'package:technicianapp/presentation/screens/booking_status_screen/booking_status_binding.dart';
import 'package:technicianapp/presentation/screens/booking_status_screen/booking_status_screen.dart';
import 'package:technicianapp/presentation/screens/service_review_screen/service_review_binding.dart';
import 'package:technicianapp/presentation/screens/service_review_screen/service_review_screen.dart';
import 'package:technicianapp/presentation/screens/tip_technician_screen/tip_technician_binding.dart';
import 'package:technicianapp/presentation/screens/tip_technician_screen/tip_technician_screen.dart';
import 'package:technicianapp/presentation/screens/notification_screen/notification_binding.dart';
import 'package:technicianapp/presentation/screens/notification_screen/notification_screen.dart';
import 'package:technicianapp/presentation/screens/wallet_screen/wallet_binding.dart';
import 'package:technicianapp/presentation/screens/wallet_screen/wallet_screen.dart';
import 'package:technicianapp/presentation/screens/add_money_screen/add_money_binding.dart';
import 'package:technicianapp/presentation/screens/add_money_screen/add_money_screen.dart';
import 'package:technicianapp/presentation/screens/sos/sos_screen/sos_binding.dart';
import 'package:technicianapp/presentation/screens/sos/sos_screen/sos_screen.dart';
import 'package:technicianapp/presentation/screens/coupon screen/coupon_binding.dart';
import 'package:technicianapp/presentation/screens/coupon screen/coupon_screen.dart';
import 'package:technicianapp/presentation/screens/home_services_screen/home_services_binding.dart';
import 'package:technicianapp/presentation/screens/home_services_screen/home_services_screen.dart';
import 'package:technicianapp/auth/sign_up_detail_screen/sign_up_detail_binding.dart';
import 'package:technicianapp/auth/sign_up_detail_screen/sign_up_detail_screen.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/technician_home_binding.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/technician_home_screen.dart';
import 'package:technicianapp/presentation/screens/notification_settings_screen/notification_settings_binding.dart';
import 'package:technicianapp/presentation/screens/notification_settings_screen/notification_settings_screen.dart';
import 'package:technicianapp/presentation/screens/privacy_security_screen/privacy_security_binding.dart';
import 'package:technicianapp/presentation/screens/privacy_security_screen/privacy_security_screen.dart';
import 'package:technicianapp/presentation/screens/help_support_screen/help_support_binding.dart';
import 'package:technicianapp/presentation/screens/help_support_screen/help_support_screen.dart';
import 'package:technicianapp/presentation/screens/about_screen/about_binding.dart';
import 'package:technicianapp/presentation/screens/about_screen/about_screen.dart';
import 'package:technicianapp/presentation/screens/logout_screen/logout_screen.dart';
import 'package:technicianapp/presentation/screens/delete_account_screen/delete_account_screen.dart';
import 'package:technicianapp/presentation/screens/bank_payout_screen/bank_payout_binding.dart';
import 'package:technicianapp/presentation/screens/bank_payout_screen/bank_payout_screen.dart';
import 'package:technicianapp/presentation/screens/identity_verification_screen/identity_verification_binding.dart';
import 'package:technicianapp/presentation/screens/identity_verification_screen/identity_verification_screen.dart';
import 'package:technicianapp/presentation/screens/professional_info_screen/professional_info_binding.dart';
import 'package:technicianapp/presentation/screens/professional_info_screen/professional_info_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/job_detail_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/navigation_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_binding.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_detail_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_navigation_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_pause_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_cancel_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_cancelled_screen.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_completed_screen.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_binding.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/technician_onboarding_screen.dart';
import 'package:technicianapp/presentation/screens/technician_onboarding/steps/step5_review_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_binding.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_filter_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_detail_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_send_quote_screen.dart';
import 'package:technicianapp/presentation/screens/job_screen/job_quote_sent_screen.dart';

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.onboardingScreen,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.signUpScreen,
      page: () => const SignUpScreen(),
      binding: SignUpBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.otpScreen,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.forgotPasswordScreen,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.emailLoginScreen,
      page: () => const EmailLoginScreen(),
      binding: EmailLoginBinding(),
      transition: Transition.rightToLeftWithFade,
    ),GetPage(
      name: AppRoutes.locationPermissionScreen,
      page: () => const LocationPermissionScreen(),
      binding: LocationPermissionBindings(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.locationDetailScreen,
      page: () => const LocationDetailScreen(),
      binding: LocationDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.dashboardScreen,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.mapScreen,
      page: () => const MapScreen(),
      binding: MapBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.selectLocationScreen,
      page: () => const SelectLocationScreen(),
      binding: SelectLocationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.profileScreen,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.personalInformationScreen,
      page: () => PersonalInformationScreen(),
      binding: PersonalInformationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.privacyPolicyScreen,
      page: () => const PrivacyPolicyScreen(),
      binding: PrivacyPolicyBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.bookingSafetyScreen,
      page: () => const BookingSafetyScreen(),
      binding: BookingSafetyBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.supportScreen,
      page: () => const SupportScreen(),
      binding: SupportBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.chatSupportScreen,
      page: () => const ChatSupportScreen(),
      binding: ChatSupportBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.callSupportScreen,
      page: () => const CallSupportScreen(),
      binding: CallSupportBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.emailSupportScreen,
      page: () => const EmailSupportScreen(),
      binding: EmailSupportBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.supportThankYouScreen,
      page: () => const SupportThankYouScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.serviceScreen,
      page: () => const ServiceScreen(),
      binding: ServiceBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.bookServiceScreen,
      page: () => const BookServiceScreen(),
      binding: BookServiceBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.paymentOptionsScreen,
      page: () => const PaymentScreen(),
      binding: PaymentBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.bookingConfirmationScreen,
      page: () => const BookingConfirmationScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.bookingStatusScreen,
      page: () => const BookingStatusScreen(),
      binding: BookingStatusBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(
      name: AppRoutes.serviceReviewScreen,
      page: () => const ServiceReviewScreen(),
      binding: ServiceReviewBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.tipTechnicianScreen,
      page: () => const TipTechnicianScreen(),
      binding: TipTechnicianBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.notificationScreen,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.securityScreen,
      page: () => const SecurityScreen(),
      binding: SecurityBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.walletScreen,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.addMoneyScreen,
      page: () => const AddMoneyScreen(),
      binding: AddMoneyBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.sosScreen,
      page: () => const SosScreen(),
      binding: SosBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.couponScreen,
      page: () => const CouponScreen(),
      binding: CouponBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.homeServicesScreen,
      page: () => const HomeServicesScreen(),
      binding: HomeServicesBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.signUpDetailScreen,
      page: () => const SignUpDetailScreen(),
      binding: SignUpDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    // Technician onboarding — single screen, all steps inside PageView
    GetPage(
      name: AppRoutes.technicianDocOverviewScreen,
      page: () => const TechnicianOnboardingScreen(),
      binding: TechnicianOnboardingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.technicianUnderReviewScreen,
      page: () => const Step5UnderReviewScreen(),
      binding: TechnicianOnboardingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.technicianAllSetScreen,
      page: () => const AllSetScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.technicianHomeScreen,
      page: () => const TechnicianHomeScreen(),
      binding: TechnicianHomeBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    // Schedule Job screens
    GetPage(
      name: AppRoutes.scheduleJobScreen,
      page: () =>  ScheduleJobScreen(),
      binding: ScheduleJobBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobDetailScreen,
      page: () => ScheduleJobDetailScreen(),
      binding: BindingsBuilder(() => Get.put(ScheduleJobDetailController())),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobNavigationScreen,
      page: () =>  ScheduleJobNavigationScreen(),
      binding: BindingsBuilder(() => Get.put(NavigationController())),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobPauseScreen,
      page: () => const ScheduleJobPauseScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobPauseDetailsScreen,
      page: () => const ScheduleJobPauseDetailsScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobCancelScreen,
      page: () => const ScheduleJobCancelScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobCancelledScreen,
      page: () => const ScheduleJobCancelledScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.scheduleJobCompletedScreen,
      page: () => const ScheduleJobCompletedScreen(),
      transition: Transition.rightToLeftWithFade,
    ),

    // Profile sub-screens
    GetPage(
      name: AppRoutes.notificationSettingsScreen,
      page: () => const NotificationSettingsScreen(),
      binding: NotificationSettingsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.privacySecurityScreen,
      page: () => const PrivacySecurityScreen(),
      binding: PrivacySecurityBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.helpSupportScreen,
      page: () => const HelpSupportScreen(),
      binding: HelpSupportBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.aboutScreen,
      page: () => const AboutScreen(),
      binding: AboutBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.logoutScreen,
      page: () => const LogoutScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.deleteAccountScreen,
      page: () => const DeleteAccountScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.bankPayoutScreen,
      page: () => const BankPayoutScreen(),
      binding: BankPayoutBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.identityVerificationScreen,
      page: () => const IdentityVerificationScreen(),
      binding: IdentityVerificationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.professionalInfoScreen,
      page: () => const ProfessionalInfoScreen(),
      binding: ProfessionalInfoBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    // Job screens
    GetPage(
      name: AppRoutes.jobScreen,
      page: () => JobScreen(),
      binding: JobBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.jobFilterScreen,
      page: () => JobFilterScreen(),
      binding: JobFilterBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.jobDetailScreen,
      page: () => JobDetailScreen(),
      binding: JobDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.jobSendQuoteScreen,
      page: () => JobSendQuoteScreen(),
      binding: JobSendQuoteBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.jobQuoteSentScreen,
      page: () => const JobQuoteSentScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.counterOfferScreen,
      page: () => const CounterOfferScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
