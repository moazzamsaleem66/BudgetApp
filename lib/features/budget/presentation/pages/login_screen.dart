import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.startInLoginMode = true});

  final bool startInLoginMode;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _nameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authRepo = FirebaseAuthRepository();

  late bool _isLogin;
  bool _authLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.startInLoginMode;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Future<void> _handleLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _authLoading = true);

    try {
      await _authRepo.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (!mounted) return;
      _showMessage('Login successful.');
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _authLoading = false);
      }
    }
  }

  Future<void> _handleSignup() async {
    if (!(_signupFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _authLoading = true);

    try {
      await _authRepo.signUp(
        name: _nameController.text.trim(),
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
      );
      if (!mounted) return;
      _showMessage('Account created successfully.');
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(_friendlyAuthError(e), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _authLoading = false);
      }
    }
  }

  Future<void> _openForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _loginEmailController.text.trim());
    final formKey = GlobalKey<FormState>();
    var sending = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Reset Password'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                  validator: _validateEmail,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: sending ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: sending
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          setDialogState(() => sending = true);
                          try {
                            await _authRepo.sendPasswordResetEmail(emailController.text);
                            if (context.mounted) {
                              Navigator.of(dialogContext).pop();
                              _showMessage('Password reset email sent. Check your inbox.');
                            }
                          } on FirebaseAuthException catch (e) {
                            if (context.mounted) {
                              _showMessage(_friendlyAuthError(e), isError: true);
                            }
                            setDialogState(() => sending = false);
                          } catch (_) {
                            if (context.mounted) {
                              _showMessage('Unable to send reset email right now.', isError: true);
                            }
                            setDialogState(() => sending = false);
                          }
                        },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF08A66F)),
                  child: sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFB42318) : const Color(0xFF087C5D),
      ),
    );
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'Email/Password login is disabled in Firebase. Enable it from Firebase Auth settings.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16, 20, 16, isKeyboardOpen ? 12 : 0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 26, 24, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _isLogin ? _buildLoginCard() : _buildSignUpCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardOpen)
                  Container(
                    height: 84,
                    color: const Color(0xFFD7E8E1),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _BottomModeButton(
                            label: 'LOGIN',
                            icon: Icons.login,
                            selected: _isLogin,
                            dashedWhenInactive: true,
                            onTap: () => setState(() => _isLogin = true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _BottomModeButton(
                            label: 'SIGNUP',
                            icon: Icons.person_add,
                            selected: !_isLogin,
                            dashedWhenInactive: false,
                            onTap: () => setState(() => _isLogin = false),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_authLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF08A66F),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpCard() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF0D1B35)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in your details to start your portfolio.',
            style: TextStyle(fontSize: 21 / 1.6, color: Color(0xFF27374E), height: 1.25),
          ),
          const SizedBox(height: 24),
          const _Label('FULL NAME'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            enabled: !_authLoading,
            decoration: _fieldDecoration(hint: 'Johnathan Doe', prefixIcon: Icons.person_outline),
            validator: (value) => (value ?? '').trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          const _Label('EMAIL ADDRESS'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _signupEmailController,
            enabled: !_authLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecoration(hint: 'john@smartbudget.app', prefixIcon: Icons.alternate_email),
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          const _Label('PASSWORD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _signupPasswordController,
            enabled: !_authLoading,
            obscureText: true,
            decoration: _fieldDecoration(hint: '********', prefixIcon: Icons.lock_outline),
            validator: _validatePassword,
          ),
          const SizedBox(height: 14),
          const _Label('CONFIRM'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_authLoading,
            obscureText: true,
            decoration: _fieldDecoration(hint: '********', prefixIcon: Icons.shield_outlined),
            validator: (value) {
              if ((value ?? '').isEmpty) return 'Confirm password';
              if (value != _signupPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _authLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08A66F),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF08A66F).withValues(alpha: 0.28),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _authLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Sign Up', style: TextStyle(fontSize: 22 / 2, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 14),
              ),
              TextButton(
                onPressed: _authLoading ? null : () => setState(() => _isLogin = true),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Color(0xFF005BB8),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF0D1B35)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your credentials to access your account.',
            style: TextStyle(fontSize: 21 / 1.6, color: Color(0xFF27374E), height: 1.25),
          ),
          const SizedBox(height: 20),
          const _Label('EMAIL ADDRESS'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginEmailController,
            enabled: !_authLoading,
            keyboardType: TextInputType.emailAddress,
            decoration: _fieldDecoration(hint: 'john@smartbudget.app', prefixIcon: Icons.alternate_email),
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          const _Label('PASSWORD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginPasswordController,
            enabled: !_authLoading,
            obscureText: true,
            decoration: _fieldDecoration(hint: '********', prefixIcon: Icons.lock_outline),
            validator: _validatePassword,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _authLoading ? null : _openForgotPasswordDialog,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF087C5D), fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _authLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08A66F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _authLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Login', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Don\'t have an account? ',
                style: TextStyle(color: Color(0xFF1E293B), fontSize: 14),
              ),
              TextButton(
                onPressed: _authLoading ? null : () => setState(() => _isLogin = false),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF005BB8),
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB6C4BC), fontSize: 17 / 1.2),
      filled: true,
      fillColor: const Color(0xFFE7EAEC),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFFB4C6BB)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF08A66F), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD64550), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD64550), width: 1.4),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final input = (value ?? '').trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (input.isEmpty) return 'Email is required';
    if (!regex.hasMatch(input)) return 'Invalid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return 'Password is required';
    if (input.length < 8) return 'Use at least 8 characters';
    return null;
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1F2937), fontSize: 12),
    );
  }
}

class _BottomModeButton extends StatelessWidget {
  const _BottomModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.dashedWhenInactive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool dashedWhenInactive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFAEE9CF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: selected ? const Color(0xFF117A5A) : const Color(0xFF8C95A5)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? const Color(0xFF117A5A) : const Color(0xFF8C95A5),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected
          ? child
          : dashedWhenInactive
              ? _DashedRRectContainer(color: const Color(0xFF9FDCC8), radius: 12, child: child)
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9FDCC8), width: 1.4),
                  ),
                  child: child,
                ),
    );
  }
}

class _DashedRRectContainer extends StatelessWidget {
  const _DashedRRectContainer({
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));

    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dash);
        canvas.drawPath(segment, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
