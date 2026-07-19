import 'package:flutter/material.dart';
import '../api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedRole = 'patient';
  int? _selectedSpecialtyId;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 50,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create New Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a unique username',
                      prefixIcon: const Icon(Icons.account_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter a password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'patient',
                        child: Text('Patient'),
                      ),
                      DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                        if (value == 'patient') {
                          _selectedSpecialtyId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedRole == 'doctor') ...[
                    DropdownButtonFormField<int>(
                      value: _selectedSpecialtyId,
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Pediatrics')),
                        DropdownMenuItem(value: 2, child: Text('Cardiology')),
                        DropdownMenuItem(value: 3, child: Text('Dentistry')),
                        DropdownMenuItem(value: 4, child: Text('Dermatology')),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('Ophthalmology'),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('Internal Medicine'),
                        ),
                        DropdownMenuItem(value: 7, child: Text('Gynecology')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialtyId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty) {
      _showSnackBar('Please enter your full name');
      return;
    }
    if (username.isEmpty) {
      _showSnackBar('Please enter a username');
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('Please enter a password');
      return;
    }
    if (password.length < 4) {
      _showSnackBar('Password must be at least 4 characters');
      return;
    }
    if (_selectedRole == 'doctor' && _selectedSpecialtyId == null) {
      _showSnackBar('Please select a specialty for the doctor');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.register(
        username,
        password,
        _selectedRole,
        fullName,
        email,
        specialtyId: _selectedSpecialtyId,
      );

      if (result['status'] == 'success') {
        _showSnackBar('Account created successfully!');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      debugPrint('Register Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
