class Appointment {
  final int id;
  final String appointmentDate;
  final String status;
  final String? doctorNotes;
  final String doctorName;
  final String? patientName;

  Appointment({
    required this.id,
    required this.appointmentDate,
    required this.status,
    this.doctorNotes,
    required this.doctorName,
    this.patientName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      appointmentDate: json['appointment_date'] ?? '',
      status: json['status'] ?? 'pending',
      doctorNotes: json['doctor_notes'],
      doctorName: json['doctor_name'] ?? '',
      patientName: json['patient_name'] ?? 'Unknown Patient',
    );
  }
}
