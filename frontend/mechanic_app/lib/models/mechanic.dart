class Mechanic {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final double? rating;
  final int? totalRatings;
  final int? jobsCompleted;
  final int? activeJobs;
  final double? totalEarnings;
  final List<String> skills;
  final bool? idCardVerified;
  final bool? licenseVerified;
  final bool? insuranceVerified;
  final String? bankAccountNumber;

  Mechanic({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.rating,
    this.totalRatings,
    this.jobsCompleted,
    this.activeJobs,
    this.totalEarnings,
    this.skills = const [],
    this.idCardVerified,
    this.licenseVerified,
    this.insuranceVerified,
    this.bankAccountNumber,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      jobsCompleted: json['jobs_completed'] as int?,
      activeJobs: json['active_jobs'] as int?,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble(),
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      idCardVerified: json['id_card_verified'] as bool?,
      licenseVerified: json['license_verified'] as bool?,
      insuranceVerified: json['insurance_verified'] as bool?,
      bankAccountNumber: json['bank_account_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'rating': rating,
      'total_ratings': totalRatings,
      'jobs_completed': jobsCompleted,
      'active_jobs': activeJobs,
      'total_earnings': totalEarnings,
      'skills': skills,
      'id_card_verified': idCardVerified,
      'license_verified': licenseVerified,
      'insurance_verified': insuranceVerified,
      'bank_account_number': bankAccountNumber,
    };
  }

  Mechanic copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    double? rating,
    int? totalRatings,
    int? jobsCompleted,
    int? activeJobs,
    double? totalEarnings,
    List<String>? skills,
    bool? idCardVerified,
    bool? licenseVerified,
    bool? insuranceVerified,
    String? bankAccountNumber,
  }) {
    return Mechanic(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      activeJobs: activeJobs ?? this.activeJobs,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      skills: skills ?? this.skills,
      idCardVerified: idCardVerified ?? this.idCardVerified,
      licenseVerified: licenseVerified ?? this.licenseVerified,
      insuranceVerified: insuranceVerified ?? this.insuranceVerified,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
    );
  }
}
