// models/profile_models/profile_model.dart
class Profile {
  PersonalInfo personalInfo;
  List<Education> education;
  List<Experience> experience;

  Profile({
    required this.personalInfo,
    required this.education,
    required this.experience,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      experience: (json['experience'] as List<dynamic>?)
          ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class PersonalInfo {
  String firstName;
  String lastName;
  String email;
  String phone;
  String dob;
  String hometownCity;
  String hometownState;
  String currentState;
  String currentLocation;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.hometownCity,
    required this.hometownState,
    required this.currentState,
    required this.currentLocation,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      hometownCity: json['hometownCity'] ?? '',
      hometownState: json['hometownState'] ?? '',
      currentState: json['currentState'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
    );
  }
}

class Education {
  String postGraduationDegree;
  String postGraduationSpecialization;
  String postGraduationPercentage;
  String postGraduationCollege;
  String postGraduationYear;
  bool postGraduationCompleted;
  String diplomaDegree;
  String diplomaSpecialization;
  String diplomaCollege;
  String diplomaPercentage;
  String diplomaYear;
  bool diplomaCompleted;
  String tenthPercentage;
  String tenthPassingYear;
  String twelfthPercentage;
  String twelfthPassingYear;
  String graduationDegree;
  String graduationSpecialization;
  String graduationCollege;
  String graduationPercentage;
  String graduationYear;
  bool graduationCompleted;
  bool hasEducationalGap;
  bool hasBacklog;

  Education({
    required this.postGraduationDegree,
    required this.postGraduationSpecialization,
    required this.postGraduationPercentage,
    required this.postGraduationCollege,
    required this.postGraduationYear,
    required this.postGraduationCompleted,
    required this.diplomaDegree,
    required this.diplomaSpecialization,
    required this.diplomaCollege,
    required this.diplomaPercentage,
    required this.diplomaYear,
    required this.diplomaCompleted,
    required this.tenthPercentage,
    required this.tenthPassingYear,
    required this.twelfthPercentage,
    required this.twelfthPassingYear,
    required this.graduationDegree,
    required this.graduationSpecialization,
    required this.graduationCollege,
    required this.graduationPercentage,
    required this.graduationYear,
    required this.graduationCompleted,
    required this.hasEducationalGap,
    required this.hasBacklog,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    bool _parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false; // Default value if parsing fails
    }

    return Education(
      postGraduationDegree: json['postGraduationDegree'] ?? '',
      postGraduationSpecialization: json['postGraduationSpecialization'] ?? '',
      postGraduationPercentage: json['postGraduationPercentage'] ?? '',
      postGraduationCollege: json['postGraduationCollege'] ?? '',
      postGraduationYear: json['postGraduationYear'] ?? '',
      postGraduationCompleted: _parseBool(json['postGraduationCompleted']),
      diplomaDegree: json['diplomaDegree'] ?? '',
      diplomaSpecialization: json['diplomaSpecialization'] ?? '',
      diplomaCollege: json['diplomaCollege'] ?? '',
      diplomaPercentage: json['diplomaPercentage'] ?? '',
      diplomaYear: json['diplomaYear'] ?? '',
      diplomaCompleted: _parseBool(json['diplomaCompleted']),
      tenthPercentage: json['tenthPercentage'] ?? '',
      tenthPassingYear: json['tenthPassingYear'] ?? '',
      twelfthPercentage: json['twelfthPercentage'] ?? '',
      twelfthPassingYear: json['twelfthPassingYear'] ?? '',
      graduationDegree: json['graduationDegree'] ?? '',
      graduationSpecialization: json['graduationSpecialization'] ?? '',
      graduationCollege: json['graduationCollege'] ?? '',
      graduationPercentage: json['graduationPercentage'] ?? '',
      graduationYear: json['graduationYear'] ?? '',
      graduationCompleted: _parseBool(json['graduationCompleted']),
      hasEducationalGap: _parseBool(json['hasEducationalGap']),
      hasBacklog: _parseBool(json['hasBacklog']),
    );
  }
}

class Experience {
  String company;
  String years;
  String role;
  String experienceLevel;
  String internshipDetails;
  String previousCompany;
  String certification;
  String lastCTC;

  Experience({
    required this.company,
    required this.years,
    required this.role,
    required this.experienceLevel,
    required this.internshipDetails,
    required this.previousCompany,
    required this.certification,
    required this.lastCTC,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] ?? '',
      years: json['years'] ?? '',
      role: json['role'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      internshipDetails: json['internshipDetails'] ?? '',
      previousCompany: json['previousCompany'] ?? '',
      certification: json['certification'] ?? '',
      lastCTC: json['lastCTC'] ?? '',
    );
  }
}