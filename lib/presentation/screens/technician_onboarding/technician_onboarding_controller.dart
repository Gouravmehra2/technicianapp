import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/common_widgets/common_dialog.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'technician_onboarding_model.dart';

class TechnicianOnboardingController extends GetxController {
  final  socketService = SocketService.instance;
  final data = TechnicianOnboardingData();
  final _apiRepo = Get.find<ApiRepo>();

  // ── PageView navigation ───────────────────────────────────────────────────
  // Pages (in order):
  //  0  = Doc Overview
  //  1  = Driving License
  //  2  = Residential Proof
  //  3  = Tax Info
  //  4  = CV/Resume
  //  5  = Background Check
  //  6  = Skills
  //  7  = Experience
  //  8  = Bank Details
  //  9  = Under Review
  final pageController = PageController();
  final currentPage = 0.obs;

  // Which outer steps the user has actually completed (used for step indicator tapping)
  // Step 1 = docs (pages 0–5), Step 2 = skills+exp (6–7), Step 3 = bank (8), Step 4 = review (9)
  int get _highestCompletedStep {
    if (currentPage.value >= 9) return 4;
    if (currentPage.value >= 8) return 3;
    if (currentPage.value >= 6) return 2;
    return 1;
  }

  /// Returns the first page index for a given outer step
  int _firstPageForStep(int step) {
    switch (step) {
      case 1:
        return 0;
      case 2:
        return 6;
      case 3:
        return 8;
      case 4:
        return 9;
      default:
        return 0;
    }
  }

  /// Called when user taps an outer step circle.
  /// Only allows navigation to steps the user has already reached.
  void tryGoToStep(int step) {
    if (step > _highestCompletedStep) {
      AppSnackbar.error('Please complete the previous steps first.');
      return;
    }
    goToPage(_firstPageForStep(step));
  }

  void goToPage(int page) {
    currentPage.value = page;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // Fetch latest verification status whenever the review page is shown
    if (page == 9) fetchMe();
  }

  /// Jump to page 9 directly from the "go back" flow (no animation, no extra fetchMe).
  void jumpToReviewPage() {
    currentPage.value = 9;
    pageController.jumpToPage(9);
  }

  void nextPage() => goToPage(currentPage.value + 1);

  void prevPage() {
    if (currentPage.value > 0) {
      goToPage(currentPage.value - 1);
    } else {
      Get.back();
    }
  }

  // Maps outer step indicator step (1-4) from internal page index
  int get indicatorStep {
    if (currentPage.value <= 5) return 1;
    if (currentPage.value <= 7) return 2;
    if (currentPage.value == 8) return 3;
    return 4;
  }

  // Step 1 (profile — kept for profile editing later, not used in onboarding flow)
  final nameController = TextEditingController(text: 'Gourav Mehra');
  final phoneController = TextEditingController(text: '+91 94639 XXXXX');
  final emailController = TextEditingController(text: 'gouravmehra@gmail.com');
  final gender = 'Male'.obs;
  final dob = '6 Feb 2003'.obs;

  // Step 2 – Skills
  final allSkills = [
    'Electrical',
    'Plumbing',
    'AC Repair',
    'Carpenter',
    'Painting',
    'Cleaning',
    'Appliance Repair',
    'Internet Setup',
  ];
  final selectedSkills = <String>[].obs;
  final experienceLevel = 'Intermediate'.obs;
  final skillSearchQuery = ''.obs;

  // Step 2b – Experience
  final yearsController = TextEditingController();
  final company1Controller = TextEditingController();
  final company2Controller = TextEditingController();
  final certificates = <String>[].obs;
  final portfolioPhotos = <String>[].obs;

  // Step 3 – Bank
  final accountNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final upiController = TextEditingController();
  final cancelledCheque = Rxn<String>();

  // Doc upload state
  final drivingLicenseFront = Rxn<String>();
  final drivingLicenseBack = Rxn<String>();
  final residentialProof = Rxn<String>();
  final w9Doc = Rxn<String>();
  final has1099 = true.obs;
  final doc1099 = Rxn<String>();
  final cvResume = Rxn<String>();
  final backgroundAuthorized = false.obs;
  final drugScreeningDoc = Rxn<String>();

  // Loading state for document upload API call
  final isUploadingDocs = false.obs;
  // Loading states for profile & bank API calls
  final isSubmittingProfile = false.obs;
  final isSubmittingBank = false.obs;

  // Latest verification update payload received from socket
  final verificationUpdateData = Rxn<Map<String, dynamic>>();

  // ── /me profile data (fetched on Review page load + socket updates) ────────
  final verificationStatus = ''.obs;       // "pending" | "rejected" | "approved"
  final verificationNotes = ''.obs;
  final submittedAt = ''.obs;
  final documents = <DocumentItem>[].obs;
  final isFetchingMe = false.obs;

  // New file paths chosen by the user on the rejection re-upload screen
  // keyed by documentId (e.g. 'drivingLicenseFront', 'residentialProof', …)
  final reUploadPaths = <String, String>{}.obs;
  final isReUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToVerificationUpdates();
  }

  /// Subscribes to the `technician:verificationUpdated` socket event.
  /// Prints the incoming payload and stores it in [verificationUpdateData].
  void _listenToVerificationUpdates() {
    socketService.reconnectIfNeeded();
    _registerVerificationListener();
  }

  void _registerVerificationListener() {
    // socket_service.on() automatically removes any previous listener for
    // this event before adding — no stacking, no duplicate calls.
    socketService.on('technician:verificationUpdated', (data) {
      print('[Socket] technician:verificationUpdated received');
      print('[Socket] Data: $data');
      if (data is Map<String, dynamic>) {
        verificationUpdateData.value = data;
        fetchMe();
      } else {
        verificationUpdateData.value = {'raw': data};
      }
    });
  }

  /// Fetches GET /api/technician-auth/me and populates [verificationStatus],
  /// [verificationNotes], [submittedAt], and [documents].
  Future<void> fetchMe() async {
    isFetchingMe.value = true;
    try {
      final response = await _apiRepo.getMeApi();
      final body = response.data as Map<String, dynamic>?;
      if (body == null) return;

      final freshModel = UserModel.fromJson(body);
      final profile = freshModel.user?.technicianProfile;
      if (profile == null) return;

      verificationStatus.value = profile.verificationStatus ?? '';
      verificationNotes.value = profile.verificationNotes ?? '';
      submittedAt.value = profile.submittedAt ?? '';
      documents.value = profile.documents;

      // Keep AuthService cache in sync so splash/routing is always fresh
      final auth = AuthService.to;
      if (auth.token.value != null) {
        await auth.saveSession(
          authToken: auth.token.value!,
          userData: freshModel,
        );
      }

      print('[Me] verificationStatus=${verificationStatus.value}');
      print('[Me] documents=${documents.length}');

      // If admin just approved → navigate to home
      if (verificationStatus.value == 'approved') {
        Get.offAllNamed(AppRoutes.dashboardScreen);
      }
    } catch (e) {
      print('[Me] fetchMe error: $e');
    } finally {
      isFetchingMe.value = false;
    }
  }

  /// Returns `true` if any document in [documents] has status "rejected".
  bool get hasRejectedDocs => documents.any((d) => d.isRejected);

  /// All rejected document IDs from the API list.
  List<String> get rejectedDocumentIds =>
      documents.where((d) => d.isRejected).map((d) => d.documentId).toList();

  /// Pick a new file for a rejected document and store it in [reUploadPaths].
  Future<void> pickReUploadFile(String documentId) async {
    final path = await pickDocument();
    if (path != null) reUploadPaths[documentId] = path;
  }

  /// Submit only the re-uploaded files for rejected documents.
  Future<void> submitReUpload() async {
    // Ensure every rejected doc has a new file selected
    for (final id in rejectedDocumentIds) {
      if (!reUploadPaths.containsKey(id)) {
        AppSnackbar.error('Please upload a new file for every rejected document.');
        return;
      }
    }

    isReUploading.value = true;
    try {
      await _apiRepo.reUploadDocumentsApi(
        drivingLicenseFrontPath: reUploadPaths['drivingLicenseFront'],
        drivingLicenseBackPath: reUploadPaths['drivingLicenseBack'],
        residentialProofPath: reUploadPaths['residentialProof'],
        w9DocPath: reUploadPaths['taxInformationW9'],
        doc1099Path: reUploadPaths['taxInformation1099'],
        cvResumePath: reUploadPaths['cvResume'],
        backgroundVerificationPath: reUploadPaths['backgroundVerification'],
      );

      reUploadPaths.clear();
      AppSnackbar.success('Documents re-submitted for review!');
      await fetchMe();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Re-upload Failed');
    } finally {
      isReUploading.value = false;
    }
  }

  /// Navigate back from the review page to the specific doc page for re-upload.
  /// Maps documentId → the correct page index.
  void goToDocPageForId(String documentId) {
    switch (documentId) {
      case 'drivingLicenseFront':
      case 'drivingLicenseBack':
        goToPage(1);
        break;
      case 'residentialProof':
        goToPage(2);
        break;
      case 'taxInformationW9':
      case 'taxInformation1099':
        goToPage(3);
        break;
      case 'cvResume':
        goToPage(4);
        break;
      case 'backgroundVerification':
        goToPage(5);
        break;
    }
  }

  List<String> get filteredSkills {
    final q = skillSearchQuery.value.toLowerCase();
    if (q.isEmpty) return allSkills;
    return allSkills.where((s) => s.toLowerCase().contains(q)).toList();
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
  }

  Future<void> pickProfileImage() async {
    final file = await CommonDialog.showImagePickerDialog();
    if (file != null) data.profileImagePath = file.path;
  }

  Future<String?> pickDocument() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    return file?.path;
  }

  Future<void> pickAndSet(Rxn<String> target) async {
    final path = await pickDocument();
    if (path != null) target.value = path;
  }

  Future<void> pickPortfolioPhoto() async {
    final path = await pickDocument();
    if (path != null) portfolioPhotos.add(path);
  }

  Future<void> pickCertificate() async {
    final path = await pickDocument();

    if (path != null) certificates.add(path);
  }

  Future<void> removeCertificate(String path) async {
    certificates.remove(path);
  }

  Future<void> removePortfolioPhoto(String path) async {
    portfolioPhotos.remove(path);
  }

  Future<void> pickDate(BuildContext context) async {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final parts = dob.value.split(' ');
    final initial = DateTime(
      int.parse(parts[2]),
      months.indexOf(parts[1]) + 1,
      int.parse(parts[0]),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dob.value = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  bool isDocComplete(String key) => data.docCompleted[key] ?? false;

  void markDocComplete(String key) {
    data.docCompleted[key] = true;
  }

  // ── Per-page upload readiness ─────────────────────────────────────────────

  bool get canProceedDrivingLicense =>
      drivingLicenseFront.value != null && drivingLicenseBack.value != null;

  bool get canProceedResidential => residentialProof.value != null;

  bool get canProceedTaxInfo => w9Doc.value != null && doc1099.value != null;

  bool get canProceedCv => cvResume.value != null;

  bool get canProceedBackground =>
      drugScreeningDoc.value != null && backgroundAuthorized.value;

  /// Called when user taps "Continue →" on the Background Check page (page 5).
  /// Validates all required documents are uploaded, calls the upload API,
  /// then navigates to the Skills page on success.
  Future<void> submitDocuments() async {
    // Validate all required docs are present
    if (drivingLicenseFront.value == null) {
      AppSnackbar.error('Please upload your Driving License (front).');
      return;
    }
    if (drivingLicenseBack.value == null) {
      AppSnackbar.error('Please upload your Driving License (back).');
      return;
    }
    if (residentialProof.value == null) {
      AppSnackbar.error('Please upload your Residential Proof.');
      return;
    }
    if (w9Doc.value == null) {
      AppSnackbar.error('Please upload your W-9 document.');
      return;
    }
    if (cvResume.value == null) {
      AppSnackbar.error('Please upload your CV / Resume.');
      return;
    }
    if (drugScreeningDoc.value == null) {
      AppSnackbar.error('Please upload your Drug Screening document.');
      return;
    }
    if (!backgroundAuthorized.value) {
      AppSnackbar.error(
          'Please authorize the background check before continuing.');
      return;
    }

    isUploadingDocs.value = true;

    try {
      await _apiRepo.uploadOnboardingDocumentsApi(
        drivingLicenseFrontPath: drivingLicenseFront.value!,
        drivingLicenseBackPath: drivingLicenseBack.value!,
        residentialProofPath: residentialProof.value!,
        w9DocPath: w9Doc.value!,
        doc1099Path: doc1099.value,
        cvResumePath: cvResume.value!,
        backgroundVerificationPath: drugScreeningDoc.value!,
      );

      markDocComplete('background_check');
      AppSnackbar.success('Documents uploaded successfully!');
      nextPage();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Upload Failed');
    } finally {
      isUploadingDocs.value = false;
    }
  }

  /// Called when user taps "Next →" on the Experience page (page 7).
  /// Calls POST /api/technician-auth/complete-profile with skills + experience data.
  Future<void> submitSkillsAndExperience() async {
    if (selectedSkills.isEmpty) {
      AppSnackbar.error('Please select at least one skill.');
      return;
    }
    if (yearsController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter your years of experience.');
      return;
    }

    final years = int.tryParse(yearsController.text.trim()) ?? 0;

    isSubmittingProfile.value = true;
    try {
      await _apiRepo.completeProfileApi(
        skills: selectedSkills.toList(),
        experienceLevel: experienceLevel.value,
        yearsOfExperience: years,
        certifications: certificates.toList(),
      );

      // Persist locally
      data.selectedSkills = selectedSkills.toList();
      data.experienceLevel = experienceLevel.value;
      data.yearsOfExperience = yearsController.text.trim();
      data.previousCompany1 = company1Controller.text;
      data.previousCompany2 = company2Controller.text;

      AppSnackbar.success('Profile updated successfully!');
      nextPage();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Update Failed');
    } finally {
      isSubmittingProfile.value = false;
    }
  }

  /// Called when user taps "Next →" on the Bank Details page (page 8).
  /// Calls POST /api/technician-auth/bank-details then navigates to Review page.
  Future<void> submitBankDetails() async {
    if (accountNameController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter the account holder name.');
      return;
    }
    if (bankNameController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter the bank name.');
      return;
    }
    if (accountNumberController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter the account number.');
      return;
    }
    if (ifscController.text.trim().isEmpty) {
      AppSnackbar.error('Please enter the IFSC code.');
      return;
    }

    isSubmittingBank.value = true;
    try {
      await _apiRepo.bankDetailsApi(
        accountHolder: accountNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscController.text.trim(),
        upiId: upiController.text.trim(),
      );

      // Persist locally
      data.accountHolderName = accountNameController.text.trim();
      data.bankName = bankNameController.text.trim();
      data.accountNumber = accountNumberController.text.trim();
      data.ifscCode = ifscController.text.trim();
      data.upiId = upiController.text.trim();

      AppSnackbar.success('Bank details saved successfully!');
      nextPage(); // → page 9 (Under Review) — fetchMe is called by goToPage
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Save Failed');
    } finally {
      isSubmittingBank.value = false;
    }
  }

  // Legacy — kept so nothing breaks; no longer called directly.
  Future<void> submitAll() async => submitBankDetails();

  /// Read the auth token stored by the login/OTP flow.
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  void onClose() {
    socketService.off('technician:verificationUpdated');
    pageController.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    yearsController.dispose();
    company1Controller.dispose();
    company2Controller.dispose();
    accountNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    upiController.dispose();
    super.onClose();
  }
}
