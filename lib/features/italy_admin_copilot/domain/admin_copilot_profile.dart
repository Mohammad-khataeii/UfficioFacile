class AdminCopilotProfile {
  const AdminCopilotProfile({
    this.fullName,
    this.codiceFiscale,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.nationality,
    this.preferredLanguage = 'en',
    this.hasSpid = false,
    this.hasCie = false,
    this.hasPec = false,
    this.studentStatus,
    this.universityName,
    this.matricola,
    this.workStatus,
    this.employerName,
    this.contractType,
    this.houseStatus,
    this.landlordName,
    this.utilityBillHolderName,
    this.electricityProvider,
    this.gasProvider,
    this.internetProvider,
    this.defaultAsl,
    this.defaultComune,
    this.defaultPatronato,
    this.notes,
    this.selectedCityPackId,
    this.activeMode,
  });

  final String? fullName;
  final String? codiceFiscale;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? nationality;
  final String preferredLanguage;
  final bool hasSpid;
  final bool hasCie;
  final bool hasPec;
  final String? studentStatus;
  final String? universityName;
  final String? matricola;
  final String? workStatus;
  final String? employerName;
  final String? contractType;
  final String? houseStatus;
  final String? landlordName;
  final String? utilityBillHolderName;
  final String? electricityProvider;
  final String? gasProvider;
  final String? internetProvider;
  final String? defaultAsl;
  final String? defaultComune;
  final String? defaultPatronato;
  final String? notes;
  final String? selectedCityPackId;
  final String? activeMode;

  AdminCopilotProfile copyWith({
    String? fullName,
    String? codiceFiscale,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? nationality,
    String? preferredLanguage,
    bool? hasSpid,
    bool? hasCie,
    bool? hasPec,
    String? studentStatus,
    String? universityName,
    String? matricola,
    String? workStatus,
    String? employerName,
    String? contractType,
    String? houseStatus,
    String? landlordName,
    String? utilityBillHolderName,
    String? electricityProvider,
    String? gasProvider,
    String? internetProvider,
    String? defaultAsl,
    String? defaultComune,
    String? defaultPatronato,
    String? notes,
    String? selectedCityPackId,
    String? activeMode,
  }) {
    return AdminCopilotProfile(
      fullName: fullName ?? this.fullName,
      codiceFiscale: codiceFiscale ?? this.codiceFiscale,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      hasSpid: hasSpid ?? this.hasSpid,
      hasCie: hasCie ?? this.hasCie,
      hasPec: hasPec ?? this.hasPec,
      studentStatus: studentStatus ?? this.studentStatus,
      universityName: universityName ?? this.universityName,
      matricola: matricola ?? this.matricola,
      workStatus: workStatus ?? this.workStatus,
      employerName: employerName ?? this.employerName,
      contractType: contractType ?? this.contractType,
      houseStatus: houseStatus ?? this.houseStatus,
      landlordName: landlordName ?? this.landlordName,
      utilityBillHolderName:
          utilityBillHolderName ?? this.utilityBillHolderName,
      electricityProvider: electricityProvider ?? this.electricityProvider,
      gasProvider: gasProvider ?? this.gasProvider,
      internetProvider: internetProvider ?? this.internetProvider,
      defaultAsl: defaultAsl ?? this.defaultAsl,
      defaultComune: defaultComune ?? this.defaultComune,
      defaultPatronato: defaultPatronato ?? this.defaultPatronato,
      notes: notes ?? this.notes,
      selectedCityPackId: selectedCityPackId ?? this.selectedCityPackId,
      activeMode: activeMode ?? this.activeMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'codiceFiscale': codiceFiscale,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'phone': phone,
    'email': email,
    'address': address,
    'city': city,
    'nationality': nationality,
    'preferredLanguage': preferredLanguage,
    'hasSpid': hasSpid,
    'hasCie': hasCie,
    'hasPec': hasPec,
    'studentStatus': studentStatus,
    'universityName': universityName,
    'matricola': matricola,
    'workStatus': workStatus,
    'employerName': employerName,
    'contractType': contractType,
    'houseStatus': houseStatus,
    'landlordName': landlordName,
    'utilityBillHolderName': utilityBillHolderName,
    'electricityProvider': electricityProvider,
    'gasProvider': gasProvider,
    'internetProvider': internetProvider,
    'defaultAsl': defaultAsl,
    'defaultComune': defaultComune,
    'defaultPatronato': defaultPatronato,
    'notes': notes,
    'selectedCityPackId': selectedCityPackId,
    'activeMode': activeMode,
  };

  factory AdminCopilotProfile.fromJson(Map<String, dynamic> json) =>
      AdminCopilotProfile(
        fullName: json['fullName'] as String?,
        codiceFiscale: json['codiceFiscale'] as String?,
        dateOfBirth: DateTime.tryParse(json['dateOfBirth'] as String? ?? ''),
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        nationality: json['nationality'] as String?,
        preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
        hasSpid: json['hasSpid'] as bool? ?? false,
        hasCie: json['hasCie'] as bool? ?? false,
        hasPec: json['hasPec'] as bool? ?? false,
        studentStatus: json['studentStatus'] as String?,
        universityName: json['universityName'] as String?,
        matricola: json['matricola'] as String?,
        workStatus: json['workStatus'] as String?,
        employerName: json['employerName'] as String?,
        contractType: json['contractType'] as String?,
        houseStatus: json['houseStatus'] as String?,
        landlordName: json['landlordName'] as String?,
        utilityBillHolderName: json['utilityBillHolderName'] as String?,
        electricityProvider: json['electricityProvider'] as String?,
        gasProvider: json['gasProvider'] as String?,
        internetProvider: json['internetProvider'] as String?,
        defaultAsl: json['defaultAsl'] as String?,
        defaultComune: json['defaultComune'] as String?,
        defaultPatronato: json['defaultPatronato'] as String?,
        notes: json['notes'] as String?,
        selectedCityPackId: json['selectedCityPackId'] as String?,
        activeMode: json['activeMode'] as String?,
      );

  int get completenessScore {
    final items = [
      fullName,
      codiceFiscale,
      city,
      email,
      nationality,
      defaultComune,
      defaultAsl,
      electricityProvider,
      internetProvider,
      universityName,
    ];
    final filled = items.where((item) => (item ?? '').trim().isNotEmpty).length;
    final bonus = [hasSpid, hasCie, hasPec].where((item) => item).length;
    return (((filled + bonus) / (items.length + 3)) * 100).round();
  }

  List<String> get completenessSuggestions {
    final suggestions = <String>[];
    if ((codiceFiscale ?? '').isEmpty) {
      suggestions.add(
        'Add your codice fiscale to fill ASL and INPS forms faster.',
      );
    }
    if ((defaultComune ?? '').isEmpty) {
      suggestions.add('Add your Comune to speed up residence requests.');
    }
    if ((electricityProvider ?? '').isEmpty || (gasProvider ?? '').isEmpty) {
      suggestions.add(
        'Add utility providers to prepare bill complaints faster.',
      );
    }
    return suggestions;
  }
}
