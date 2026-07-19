import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
 static const String baseUrl = 'https://backend-dumx.onrender.com';

  // ---------------------- LOGIN ----------------------
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    return jsonDecode(response.body);
  }

  // ---------------------- REGISTER ----------------------
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String role,
    String fullName,
    String email, {
    int? specialtyId,
  }) async {
    final body = {
      'username': username,
      'password': password,
      'role': role,
      'full_name': fullName,
      'email': email,
    };
    if (specialtyId != null) {
      body['specialty_id'] = specialtyId.toString();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    return jsonDecode(response.body);
  }

  // ---------------------- GET DOCTOR ID BY USER ID ----------------------
  static Future<Map<String, dynamic>> getDoctorIdByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctors/by_user_id/$userId'),
    );
    return jsonDecode(response.body);
  }

  // ---------------------- SPECIALTIES ----------------------
  static Future<Map<String, dynamic>> getSpecialties() async {
    final response = await http.get(Uri.parse('$baseUrl/specialties'));
    return jsonDecode(response.body);
  }

  // ---------------------- DOCTORS ----------------------
  static Future<Map<String, dynamic>> getDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/doctors'));
    return jsonDecode(response.body);
  }

  // ---------------------- BOOK APPOINTMENT ----------------------
  static Future<Map<String, dynamic>> bookAppointment(
    int patientId,
    int doctorId,
    String appointmentDate,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/book'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'patient_id': patientId.toString(),
        'doctor_id': doctorId.toString(),
        'appointment_date': appointmentDate,
      },
    );
    return jsonDecode(response.body);
  }

  // ---------------------- PATIENT APPOINTMENTS ----------------------
  static Future<Map<String, dynamic>> getPatientAppointments(
    int patientId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/patient/$patientId'),
    );
    return jsonDecode(response.body);
  }

  // ---------------------- DOCTOR APPOINTMENTS ----------------------
  static Future<Map<String, dynamic>> getDoctorAppointments(
    int doctorId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/doctor/$doctorId'),
    );
    return jsonDecode(response.body);
  }

  // ---------------------- UPDATE APPOINTMENT STATUS ----------------------
  static Future<Map<String, dynamic>> updateAppointmentStatus(
    int appointmentId,
    String status,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/update_status'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'appointment_id': appointmentId.toString(), 'status': status},
    );
    return jsonDecode(response.body);
  }

  // ---------------------- ADD DOCTOR NOTES ----------------------
  static Future<Map<String, dynamic>> addDoctorNotes(
    int appointmentId,
    String doctorNotes,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/add_notes'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'appointment_id': appointmentId.toString(),
        'doctor_notes': doctorNotes,
      },
    );
    return jsonDecode(response.body);
  }
}
