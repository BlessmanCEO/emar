import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../sync/api_client.dart';
import '../services/auth_service.dart';
import 'site_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  final _baseUrlController = TextEditingController(
    text: 'http://10.0.2.2:8080',
  );
  bool _loading = false;
  String _error = '';

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initAuthService();
  }

  Future<void> _initAuthService() async {
    final prefs = await SharedPreferences.getInstance();
    final secureStorage = const FlutterSecureStorage();
    final apiClient = ApiClient(baseUrl: _baseUrlController.text.trim());
    _authService = AuthService(
      apiClient: apiClient,
      secureStorage: secureStorage,
      prefs: prefs,
    );

    if (_authService.isLoggedIn()) {
      _navigateToHome();
    }
  }

  Future<void> _login() async {
    if (_usernameController.text.trim().isEmpty ||
        _pinController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter username and PIN');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final request = LoginRequest(
        username: _usernameController.text.trim(),
        pin: _pinController.text.trim(),
      );
      await _authService.login(request);
      _navigateToHome();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Login failed: ${e.toString()}';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SiteSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F2EA), Color(0xFFE6F0F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'eMAR',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF185C6B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Electronic Medication Administration Record',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF5F6B6D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      filled: true,
                      fillColor: const Color(0xFFF4F6F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF185C6B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      filled: true,
                      fillColor: const Color(0xFFF4F6F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF185C6B),
                      ),
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error,
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFE76F51),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF185C6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
}
