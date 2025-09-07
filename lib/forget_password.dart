//----------------------------- dart_core ------------------------------
import 'dart:convert';
//----------------------------------------------------------------------

//------------------------ third_part_packages -------------------------
import 'package:flutter/material.dart';
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'package:plantcare/reset_password_screen.dart';
import 'package:plantcare/services/api_service.dart';
//----------------------------------------------------------------------

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _answerController = TextEditingController();

  String? _securityQuestion;
  bool _isLoading = false;

  Future<void> _fetchQuestion() async {
    // Only validate the username field for this step
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _securityQuestion = null;
    });

    try {
      final response = await ApiService.getSecurityQuestion(
        _usernameController.text.trim(),
      );
      final data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _securityQuestion = data['security_question']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to find user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToResetPassword() {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }
    // --- MODIFICATION: Pass the security question text to the next screen ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResetPasswordScreen(
              username: _usernameController.text.trim(),
              securityAnswer: _answerController.text.trim(),
              securityQuestion: _securityQuestion!, // Pass the question text
            ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = AppColors.primary;
    const Color backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Recover Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your username to find your security question.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icons.account_circle_outlined,
                  ),
                  enabled: _securityQuestion == null,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a username'
                              : null,
                ),
                const SizedBox(height: 24),
                if (_securityQuestion == null)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _fetchQuestion,
                    style: _buttonStyle(primaryColor),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              'Find My Security Question',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                if (_securityQuestion != null) ...[
                  const Text(
                    'Your Security Question:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _securityQuestion!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _answerController,
                    decoration: _buildInputDecoration(
                      hintText: 'Your Answer',
                      prefixIcon: Icons.lock_person_outlined,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please provide your answer'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _navigateToResetPassword,
                    style: _buttonStyle(primaryColor),
                    child: const Text(
                      'Verify & Reset Password',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(double.infinity, 50),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    const Color primaryColor = AppColors.primary;
    const Color hintColor = AppColors.textMuted;
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: hintColor),
      hintText: hintText,
      hintStyle: const TextStyle(color: hintColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 20.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
    );
  }
}
