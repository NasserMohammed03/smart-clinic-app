import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
  int _patientId = 0;
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    setState(() {
      _patientId = userId;
    });
    await _fetchDoctors();
    await _fetchAppointments();
  }

  Future<void> _fetchDoctors() async {
    try {
      final response = await ApiService.getDoctors();
      if (response['status'] == 'success') {
        final List data = response['data'];
        setState(() {
          _doctors = data.map((json) => Doctor.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load doctors';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAppointments() async {
    if (_patientId == 0) return;
    try {
      final response = await ApiService.getPatientAppointments(_patientId);
      if (response['status'] == 'success') {
        final List data = response['data'];
        setState(() {
          _appointments = data
              .map((json) => Appointment.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : _selectedIndex == 0
          ? _buildDoctorsList()
          : _buildAppointmentsList(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Appointments',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_doctors.isEmpty) {
      return const Center(
        child: Text(
          'No doctors available at the moment.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            title: Text(doctor.fullName),
            subtitle: Text(doctor.specialtyName),
            trailing: Text('\$${doctor.consultationFee.toStringAsFixed(2)}'),
            onTap: () => _showBookAppointmentDialog(doctor),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList() {
    if (_appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments booked yet.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        Color statusColor;
        switch (appointment.status) {
          case 'pending':
            statusColor = Colors.orange;
            break;
          case 'accepted':
            statusColor = Colors.green;
            break;
          case 'canceled':
            statusColor = Colors.red;
            break;
          case 'completed':
            statusColor = Colors.blue;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            title: Text('Dr. ${appointment.doctorName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${appointment.appointmentDate}'),
                if (appointment.doctorNotes != null &&
                    appointment.doctorNotes!.isNotEmpty)
                  Text(
                    'Doctor Notes: ${appointment.doctorNotes}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            trailing: Chip(
              label: Text(appointment.status),
              backgroundColor: statusColor.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBookAppointmentDialog(Doctor doctor) async {
    DateTime? selectedDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final appointmentDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final formattedDateTime = appointmentDateTime.toIso8601String();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Appointment with ${doctor.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Doctor: ${doctor.fullName}'),
            Text('Specialty: ${doctor.specialtyName}'),
            Text('Date: $formattedDateTime'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _bookAppointment(doctor.id, formattedDateTime);
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookAppointment(int doctorId, String appointmentDate) async {
    if (_patientId == 0) {
      _showSnackBar('Patient ID not found. Please login again.');
      return;
    }

    try {
      final response = await ApiService.bookAppointment(
        _patientId,
        doctorId,
        appointmentDate,
      );

      if (response['status'] == 'success') {
        _showSnackBar('Appointment booked successfully!');
        await _fetchAppointments();
      } else {
        _showSnackBar(response['message'] ?? 'Failed to book appointment');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('success')
            ? Colors.green
            : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
