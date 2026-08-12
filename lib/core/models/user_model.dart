/// Full API response model for /api/technician-auth/me and login endpoints.
///
/// Structure:
/// {
///   "success": true,
///   "token": "...",          ← present on login, absent on /me
///   "data": { "user": { … } }
/// }

// ─────────────────────────────────────────────────────────────────────────────
// Top-level wrapper
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final bool success;
  final String? token;
  final UserData? data;

  const UserModel({
    required this.success,
    this.token,
    this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        success: json['success'] as bool? ?? false,
        token: json['token']?.toString(),
        data: json['data'] != null
            ? UserData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        if (token != null) 'token': token,
        if (data != null) 'data': data!.toJson(),
      };

  // ── Convenience getters used across the app ───────────────────────────────

  /// The nested User object (null-safe shortcut).
  User? get user => data?.user;

  /// Display name.
  String get name => user?.name ?? '';

  /// Verification status from the technician profile.
  String get verificationStatus =>
      user?.technicianProfile?.verificationStatus ?? '';

  /// True when the technician has been approved to accept jobs.
  bool get isTechnicianApproved =>
      verificationStatus.toLowerCase() == 'approved';

  /// True when docs submitted but still under admin review.
  bool get isTechnicianPending =>
      verificationStatus.toLowerCase() == 'pending';

  /// True when some docs were rejected and need re-upload.
  bool get isTechnicianRejected =>
      verificationStatus.toLowerCase() == 'rejected';

  /// True when no docs have been submitted yet (fresh account).
  bool get hasNotStartedOnboarding =>
      verificationStatus.isEmpty ||
      verificationStatus.toLowerCase() == 'not-started';

  /// True when docs have been submitted but are still under review
  /// (pending, rejected, or any other non-approved / non-empty status).
  bool get hasSubmittedDocs => !hasNotStartedOnboarding;
}

// ─────────────────────────────────────────────────────────────────────────────
// data wrapper
// ─────────────────────────────────────────────────────────────────────────────

class UserData {
  final User? user;

  const UserData({this.user});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user!.toJson(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// User
// ─────────────────────────────────────────────────────────────────────────────

class User {
  final BankDetails? bankDetails;
  final TechnicianProfile? technicianProfile;
  final ProfileImage? profileImage;
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? role;
  final List<String> skills;
  final String? experienceLevel;
  final List<String> certifications;
  final bool? profileCompleted;
  final int? totalJobsDone;
  final num? totalEarnings;
  final num? totalWithdrawn;
  final bool? isPhoneVerified;
  final String? createdAt;
  final String? updatedAt;

  const User({
    this.bankDetails,
    this.technicianProfile,
    this.profileImage,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.role,
    this.skills = const [],
    this.experienceLevel,
    this.certifications = const [],
    this.profileCompleted,
    this.totalJobsDone,
    this.totalEarnings,
    this.totalWithdrawn,
    this.isPhoneVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        bankDetails: json['bankDetails'] != null
            ? BankDetails.fromJson(json['bankDetails'] as Map<String, dynamic>)
            : null,
        technicianProfile: json['technicianProfile'] != null
            ? TechnicianProfile.fromJson(
                json['technicianProfile'] as Map<String, dynamic>)
            : null,
        profileImage: json['profileImage'] != null
            ? ProfileImage.fromJson(
                json['profileImage'] as Map<String, dynamic>)
            : null,
        id: json['_id']?.toString(),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        role: json['role']?.toString(),
        skills: _toStringList(json['skills']),
        experienceLevel: json['experienceLevel']?.toString(),
        certifications: _toStringList(json['certifications']),
        profileCompleted: json['profileCompleted'] as bool?,
        totalJobsDone: (json['totalJobsDone'] as num?)?.toInt(),
        totalEarnings: json['totalEarnings'] as num?,
        totalWithdrawn: json['totalWithdrawn'] as num?,
        isPhoneVerified: json['isPhoneVerified'] as bool?,
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (bankDetails != null) 'bankDetails': bankDetails!.toJson(),
        if (technicianProfile != null)
          'technicianProfile': technicianProfile!.toJson(),
        if (profileImage != null) 'profileImage': profileImage!.toJson(),
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': role,
        'skills': skills,
        'experienceLevel': experienceLevel,
        'certifications': certifications,
        'profileCompleted': profileCompleted,
        'totalJobsDone': totalJobsDone,
        'totalEarnings': totalEarnings,
        'totalWithdrawn': totalWithdrawn,
        'isPhoneVerified': isPhoneVerified,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TechnicianProfile
// ─────────────────────────────────────────────────────────────────────────────

class TechnicianProfile {
  final DrivingLicense? drivingLicense;
  final TaxInformation? taxInformation;
  final List<String> skills;
  final String? experienceLevel;
  final int? yearsOfExperience;
  final List<String> certifications;
  final String? photoUrl;
  final String? previousCompanyName;
  final String? residentialProof;
  final String? cvResume;
  final String? backgroundVerification;
  final String? verificationStatus;
  final String? verificationNotes;
  final String? submittedAt;
  final List<DocumentItem> documents;

  const TechnicianProfile({
    this.drivingLicense,
    this.taxInformation,
    this.skills = const [],
    this.experienceLevel,
    this.yearsOfExperience,
    this.certifications = const [],
    this.photoUrl,
    this.previousCompanyName,
    this.residentialProof,
    this.cvResume,
    this.backgroundVerification,
    this.verificationStatus,
    this.verificationNotes,
    this.submittedAt,
    this.documents = const [],
  });

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) =>
      TechnicianProfile(
        drivingLicense: json['drivingLicense'] != null
            ? DrivingLicense.fromJson(
                json['drivingLicense'] as Map<String, dynamic>)
            : null,
        taxInformation: json['taxInformation'] != null
            ? TaxInformation.fromJson(
                json['taxInformation'] as Map<String, dynamic>)
            : null,
        skills: User._toStringList(json['skills']),
        experienceLevel: json['experienceLevel']?.toString(),
        yearsOfExperience: (json['yearsOfExperience'] as num?)?.toInt(),
        certifications: User._toStringList(json['certifications']),
        photoUrl: json['photoUrl']?.toString(),
        previousCompanyName: json['previousCompanyName']?.toString(),
        residentialProof: json['residentialProof']?.toString(),
        cvResume: json['cvResume']?.toString(),
        backgroundVerification: json['backgroundVerification']?.toString(),
        verificationStatus: json['verificationStatus']?.toString(),
        verificationNotes: json['verificationNotes']?.toString(),
        submittedAt: json['submittedAt']?.toString(),
        documents: (json['documents'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .map(DocumentItem.fromJson)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (drivingLicense != null) 'drivingLicense': drivingLicense!.toJson(),
        if (taxInformation != null) 'taxInformation': taxInformation!.toJson(),
        'skills': skills,
        'experienceLevel': experienceLevel,
        'yearsOfExperience': yearsOfExperience,
        'certifications': certifications,
        'photoUrl': photoUrl,
        'previousCompanyName': previousCompanyName,
        'residentialProof': residentialProof,
        'cvResume': cvResume,
        'backgroundVerification': backgroundVerification,
        'verificationStatus': verificationStatus,
        'verificationNotes': verificationNotes,
        'submittedAt': submittedAt,
        'documents': documents.map((d) => d.toJson()).toList(),
      };

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get isApproved => verificationStatus?.toLowerCase() == 'approved';
  bool get isPending => verificationStatus?.toLowerCase() == 'pending';
  bool get isRejected => verificationStatus?.toLowerCase() == 'rejected';
}

// ─────────────────────────────────────────────────────────────────────────────
// DocumentItem  (single entry in technicianProfile.documents[])
// ─────────────────────────────────────────────────────────────────────────────

class DocumentItem {
  final String documentId;
  final String label;
  final String s3Key;
  final String status; // "approved" | "rejected" | "pending"
  final String? rejectionReason;

  const DocumentItem({
    required this.documentId,
    required this.label,
    required this.s3Key,
    required this.status,
    this.rejectionReason,
  });

  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isApproved => status.toLowerCase() == 'approved';

  factory DocumentItem.fromJson(Map<String, dynamic> json) => DocumentItem(
        documentId: json['documentId']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        s3Key: json['s3Key']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        rejectionReason: json['rejectionReason']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'label': label,
        's3Key': s3Key,
        'status': status,
        'rejectionReason': rejectionReason,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// BankDetails
// ─────────────────────────────────────────────────────────────────────────────

class BankDetails {
  final String? accountHolder;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? blankCheque;

  const BankDetails({
    this.accountHolder,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.blankCheque,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        accountHolder: json['accountHolder']?.toString(),
        bankName: json['bankName']?.toString(),
        accountNumber: json['accountNumber']?.toString(),
        ifscCode: json['ifscCode']?.toString(),
        upiId: json['upiId']?.toString(),
        blankCheque: json['blankCheque']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'accountHolder': accountHolder,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
        'upiId': upiId,
        'blankCheque': blankCheque,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// DrivingLicense
// ─────────────────────────────────────────────────────────────────────────────

class DrivingLicense {
  final String? front;
  final String? back;

  const DrivingLicense({this.front, this.back});

  factory DrivingLicense.fromJson(Map<String, dynamic> json) => DrivingLicense(
        front: json['front']?.toString(),
        back: json['back']?.toString(),
      );

  Map<String, dynamic> toJson() => {'front': front, 'back': back};
}

// ─────────────────────────────────────────────────────────────────────────────
// TaxInformation
// ─────────────────────────────────────────────────────────────────────────────

class TaxInformation {
  final String? w9Form;
  final String? form1099;

  const TaxInformation({this.w9Form, this.form1099});

  factory TaxInformation.fromJson(Map<String, dynamic> json) => TaxInformation(
        w9Form: json['w9Form']?.toString(),
        form1099: json['form1099']?.toString(),
      );

  Map<String, dynamic> toJson() => {'w9Form': w9Form, 'form1099': form1099};
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileImage
// ─────────────────────────────────────────────────────────────────────────────

class ProfileImage {
  final String? url;
  final String? s3Key;

  const ProfileImage({this.url, this.s3Key});

  factory ProfileImage.fromJson(Map<String, dynamic> json) => ProfileImage(
        url: json['url']?.toString(),
        s3Key: json['s3Key']?.toString(),
      );

  Map<String, dynamic> toJson() => {'url': url, 's3Key': s3Key};
}
