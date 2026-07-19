class Doctor {
  final int id;
  final String fullName;
  final String specialtyName;
  final double consultationFee;

  Doctor({
    required this.id,
    required this.fullName,
    required this.specialtyName,
    required this.consultationFee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      fullName: json['full_name'] ?? 'Unknown Doctor',
      specialtyName: json['specialty_name'] ?? 'Unknown Specialty',
      consultationFee: (json['consultation_fee'] ?? 0.0).toDouble(),
    );
  }
}
