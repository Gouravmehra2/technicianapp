// DocumentItem lives in user_model.dart — imported where needed.
// This file contains only the local in-memory form state.

// Local data model — all fields stored in memory until final submit
class TechnicianOnboardingData {
  // Step 1 – Profile
  String fullName = '';
  String phone = '';
  String email = '';
  String gender = 'Male';
  String dob = '';
  String? profileImagePath;

  // Step 2 – Documents overview (tracks per-doc completion)
  Map<String, bool> docCompleted = {
    'driving_license': false,
    'residential_proof': false,
    'tax_info': false,
    'cv_resume': false,
    'background_check': false,
  };

  // Step 2a – Driving License
  String? drivingLicenseFront;
  String? drivingLicenseBack;

  // Step 2b – Residential Proof
  String? residentialProof;

  // Step 2c – Tax Info
  String? w9Document;
  bool? has1099 = true;
  String? doc1099;

  // Step 2d – CV/Resume
  String? cvResume;

  // Step 2e – Background Check
  bool backgroundCheckAuthorized = false;
  String? drugScreeningDoc;

  // Step 3 – Skills
  List<String> selectedSkills = [];
  String experienceLevel = 'Intermediate';

  // Step 3b – Experience
  String yearsOfExperience = '';
  String previousCompany1 = '';
  String previousCompany2 = '';
  List<String> certificates = [];
  List<String> portfolioPhotos = [];

  // Step 4 – Bank
  String accountHolderName = '';
  String bankName = '';
  String accountNumber = '';
  String ifscCode = '';
  String upiId = '';
  String? cancelledCheque;
}
