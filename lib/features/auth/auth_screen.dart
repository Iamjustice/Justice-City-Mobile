import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/repositories_providers.dart';

const _authPageBg = Color(0xFFF8FAFC);
const _authPanelBorder = Color(0xFFE2E8F0);
const _authHeading = Color(0xFF0F172A);
const _authMuted = Color(0xFF64748B);
const _authPrimary = Color(0xFF2563EB);

enum AuthMode { signUp, signIn }

String _formatAuthError(Object error) {
  final raw = error.toString();
  final normalized = raw.toLowerCase();

  if (normalized.contains('failed host lookup') ||
      normalized.contains('socketexception') ||
      normalized.contains('connection error') ||
      normalized.contains('no address associated with hostname')) {
    if (normalized.contains('supabase.co')) {
      return 'Unable to reach the secure sign-in service right now. Check your internet connection and try again.';
    }
    if (normalized.contains('justicecityltd.com') ||
        normalized.contains('justice-city.onrender.com')) {
      return 'Unable to reach the Justice City app server right now. Check your internet connection, then try again.';
    }
    return 'Unable to reach Justice City services right now. Check your internet connection and try again.';
  }

  if (normalized.contains('invalid login credentials')) {
    return 'The email or password is incorrect.';
  }

  if (normalized.contains('email not confirmed')) {
    return 'Your email is not confirmed yet. Complete verification, then try again.';
  }

  if (normalized.contains('user already registered') ||
      normalized.contains('already been registered')) {
    return 'An account already exists for this email. Sign in instead.';
  }

  if (error is StateError) {
    return raw.replaceFirst('Bad state: ', '');
  }

  return raw;
}

InputDecoration _authInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _authMuted),
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _authPanelBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _authPrimary, width: 1.4),
    ),
  );
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signUp});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(initialMode: AuthMode.signIn);
  }
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'buyer';
  String _gender = 'male';
  bool _loading = false;
  String? _error;
  late AuthMode _mode;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _setMode(AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isSignUp) {
        final name = _name.text.trim();
        final email = _email.text.trim();
        final password = _password.text;

        if (name.isEmpty) {
          throw StateError('Full name is required for account creation.');
        }

        await ref.read(authRepositoryProvider).nodeSignup(
              payload: {
                'name': name,
                'email': email,
                'password': password,
                'gender': _gender,
                'role': _role,
              },
            );

        await ref.read(authRepositoryProvider).signInWithEmailPassword(
              email: email,
              password: password,
            );
      } else {
        await ref.read(authRepositoryProvider).signInWithEmailPassword(
              email: _email.text.trim(),
              password: _password.text,
            );
      }
    } catch (e) {
      setState(() => _error = _formatAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _isSignUp
        ? 'Join Justice City to start your verified real estate journey'
        : 'Enter your credentials to access your account';

    return Scaffold(
      backgroundColor: _authPageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _authPanelBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 18),
                    Text(
                      _isSignUp ? 'Create an account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _authHeading,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _authMuted,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 18),
                    _AuthModeToggle(
                      mode: _mode,
                      onChanged: _setMode,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isSignUp ? 'Sign Up' : 'Log In',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _authHeading,
                          ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_isSignUp) ...[
                      TextField(
                        controller: _name,
                        decoration: _authInputDecoration('Full name'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _authInputDecoration('Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      decoration: _authInputDecoration('Password'),
                      obscureText: true,
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _role,
                              decoration: _authInputDecoration('I am a...'),
                              items: const [
                                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                                DropdownMenuItem(value: 'seller', child: Text('Seller')),
                                DropdownMenuItem(value: 'agent', child: Text('Agent')),
                                DropdownMenuItem(value: 'owner', child: Text('Owner')),
                                DropdownMenuItem(value: 'renter', child: Text('Renter')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _role = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _gender,
                              decoration: _authInputDecoration('Gender'),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _gender = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _authPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'Sign Up' : 'Log In'),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account?' : "Don't have an account?",
                          style: const TextStyle(color: _authMuted),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => _setMode(_isSignUp ? AuthMode.signIn : AuthMode.signUp),
                          child: Text(_isSignUp ? 'Log In' : 'Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 44,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'JUSTICE CITY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _authHeading,
                ),
          ),
        ),
      ),
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  const _AuthModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              selected: mode == AuthMode.signUp,
              label: 'Sign Up',
              onTap: () => onChanged(AuthMode.signUp),
            ),
          ),
          Expanded(
            child: _ModeButton(
              selected: mode == AuthMode.signIn,
              label: 'Log In',
              onTap: () => onChanged(AuthMode.signIn),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x120F172A),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? _authPrimary : _authMuted,
          ),
        ),
      ),
    );
  }
}
