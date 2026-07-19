import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/appointment_model.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _doctorId = 0;
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all';

  final Map<int, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in. Please login again.';
      });
      return;
    }

    try {
      final response = await ApiService.getDoctorIdByUserId(userId);

      if (response['status'] == 'success' && response['doctor_id'] != null) {
        setState(() {
          _doctorId = response['doctor_id'];
        });
        await _fetchAppointments();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You are not registered as a doctor.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading doctor profile: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchAppointments() async {
    if (_doctorId == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Doctor ID not found.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getDoctorAppointments(_doctorId);

      if (response['status'] == 'success') {
        final List data = response['data'] ?? [];
        setState(() {
          _appointments = data
              .map((json) => Appointment.fromJson(json))
              .toList();
          _isLoading = false;
          _errorMessage = null;

          for (var appointment in _appointments) {
            if (!_noteControllers.containsKey(appointment.id)) {
              _noteControllers[appointment.id] = TextEditingController(
                text: appointment.doctorNotes ?? '',
              );
            }
          }
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load appointments';
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

  List<Appointment> get _filteredAppointments {
    if (_filterStatus == 'all') return _appointments;
    return _appointments.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⚠️ $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDoctorId,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Filter:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _filterStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'accepted',
                              child: Text('Accepted'),
                            ),
                            DropdownMenuItem(
                              value: 'canceled',
                              child: Text('Canceled'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _filterStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredAppointments.isEmpty
                      ? const Center(
                          child: Text(
                            'No appointments found.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchAppointments,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _filteredAppointments[index];
                              return _buildAppointmentCard(appointment);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final controller = _noteControllers.putIfAbsent(
      appointment.id,
      () => TextEditingController(text: appointment.doctorNotes ?? ''),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        title: Text(
          'Patient: ${appointment.patientName ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${appointment.appointmentDate}'),
            const SizedBox(height: 4),
            _buildStatusChip(appointment.status),
          ],
        ),
        leading: _getStatusIcon(appointment.status),
        children: [
          const Text(
            'Update Status:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusButton('Accept', 'accepted', appointment),
              _buildStatusButton('Cancel', 'canceled', appointment),
              _buildStatusButton('Complete', 'completed', appointment),
            ],
          ),
          const Divider(height: 24),

          const Text(
            'Doctor Notes:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Write notes here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final notes = controller.text.trim();
                  if (notes.isNotEmpty) {
                    await _saveDoctorNotes(appointment.id, notes);
                  } else {
                    _showSnackBar('Please write some notes before saving.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),

          if (appointment.doctorNotes != null &&
              appointment.doctorNotes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Previous Notes: ${appointment.doctorNotes}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _saveDoctorNotes(int appointmentId, String notes) async {
    try {
      final result = await ApiService.addDoctorNotes(appointmentId, notes);
      if (result['status'] == 'success') {
        _showSnackBar('Notes saved successfully!');
        await _fetchAppointments();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to save notes');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _getStatusIcon(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(Icons.circle, color: color, size: 20),
    );
  }

  Widget _buildStatusButton(
    String label,
    String status,
    Appointment appointment,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: appointment.status == status
            ? Colors.green
            : Colors.grey.shade200,
        foregroundColor: appointment.status == status
            ? Colors.white
            : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () async {
        final result = await ApiService.updateAppointmentStatus(
          appointment.id,
          status,
        );
        if (result['status'] == 'success') {
          _showSnackBar('Status updated to $status successfully!');
          await _fetchAppointments();
        } else {
          _showSnackBar(result['message'] ?? 'Failed to update status');
        }
      },
      child: Text(label),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message.contains('success') || message.contains('saved')
            ? Colors.green
            : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
