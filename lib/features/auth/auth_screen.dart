import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../env.dart';
import '../../state/repositories_providers.dart';

const _authPageBg = Color(0xFFF4F7FB);
const _authPanelBorder = Color(0xFFE2E8F0);
const _authHeading = Color(0xFF0F172A);
const _authMuted = Color(0xFF64748B);

String _formatAuthError(Object error) {
  final raw = error.toString();
  final normalized = raw.toLowerCase();

  if (normalized.contains('failed host lookup') ||
      normalized.contains('socketexception') ||
      normalized.contains('connection error') ||
      normalized.contains('no address associated with hostname')) {
    if (normalized.contains('supabase.co')) {
      return 'Unable to reach the secure sign-in service right now. Check your internet connection or emulator DNS, then try again.';
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
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: _authPanelBorder),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.4),
    ),
  );
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({
    super.key,
    this.showServiceStatusBanner = true,
  });

  final bool showServiceStatusBanner;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'buyer';
  String _gender = 'male';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
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
    } catch (e) {
      setState(() => _error = _formatAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Create an account',
      subtitle: 'Welcome to Justice City. Sign up to begin verification and access your dashboard.',
      showServiceStatusBanner: widget.showServiceStatusBanner,
      child: _AuthCard(
        title: 'Sign up',
        error: _error,
        children: [
          TextField(
            controller: _name,
            decoration: _authInputDecoration('Full name'),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Row(
            children: [
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: _authInputDecoration('Role'),
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
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _signUp,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create Account'),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loading ? null : () => context.go('/sign-in'),
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    this.showServiceStatusBanner = true,
  });

  final bool showServiceStatusBanner;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithEmailPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
    } catch (e) {
      setState(() => _error = _formatAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to your verification and dashboard workspace.',
      showServiceStatusBanner: widget.showServiceStatusBanner,
      child: _AuthCard(
        title: 'Sign in',
        error: _error,
        children: [
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _signIn,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _loading ? null : () => context.go('/welcome'),
            child: const Text('New here? Create account'),
          ),
        ],
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.title,
    required this.subtitle,
    required this.showServiceStatusBanner,
    required this.child,
  });

  final String title;
  final String subtitle;
  final bool showServiceStatusBanner;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authPageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 18),
                  if (showServiceStatusBanner) ...[
                    const _ServiceStatusBanner(),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A0F172A),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFCBD5E1),
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AuthHeroPill(label: 'Secure sign-in'),
                            _AuthHeroPill(label: 'Verification workflow'),
                            _AuthHeroPill(label: 'Role-based dashboard'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _ServiceStatusBanner extends StatefulWidget {
  const _ServiceStatusBanner();

  @override
  State<_ServiceStatusBanner> createState() => _ServiceStatusBannerState();
}

class _ServiceStatusBannerState extends State<_ServiceStatusBanner> {
  late Future<_ServiceStatus> _statusFuture;
  final CancelToken _cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
  }

  @override
  void dispose() {
    _cancelToken.cancel('Auth service banner disposed');
    super.dispose();
  }

  Future<_ServiceStatus> _loadStatus() async {
    final supabaseClient = Dio(
      BaseOptions(
        baseUrl: Env.supabaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'apikey': Env.supabaseAnonKey,
          'Accept': 'application/json',
        },
      ),
    );

    final backendClient = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );

    var supabaseOk = false;
    var backendOk = false;
    var backendFallbackActive = false;

    try {
      final response = await supabaseClient.get(
        '/auth/v1/settings',
        cancelToken: _cancelToken,
      );
      supabaseOk = response.statusCode != null && response.statusCode! < 500;
    } on DioException {
      supabaseOk = false;
    }

    try {
      final response = await backendClient.get(
        '/api/service-offerings',
        cancelToken: _cancelToken,
      );
      backendOk = response.statusCode == 200;
    } on DioException {
      final fallbackUri = Env.apiFallbackUri;
      if (fallbackUri != null) {
        final fallbackClient = Dio(
          BaseOptions(
            baseUrl: '${fallbackUri.scheme}://${fallbackUri.authority}',
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        try {
          final fallbackResponse = await fallbackClient.get(
            '/api/service-offerings',
            cancelToken: _cancelToken,
          );
          backendOk = fallbackResponse.statusCode == 200;
          backendFallbackActive = backendOk;
        } on DioException {
          backendOk = false;
        }
      }
    }

    return _ServiceStatus(
      supabaseOk: supabaseOk,
      backendOk: backendOk,
      backendFallbackActive: backendFallbackActive,
    );
  }

  void _retry() {
    setState(() {
      _statusFuture = _loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ServiceStatus>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StatusPanel(
            color: Color(0xFFE0F2FE),
            borderColor: Color(0xFFBAE6FD),
            title: 'Checking service availability',
            message: 'Testing secure sign-in and app server connectivity.',
            trailing: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final status = snapshot.data;
        if (status == null) {
          return _StatusPanel(
            color: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            title: 'Service check unavailable',
            message: 'Unable to determine connectivity right now.',
            trailing: TextButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          );
        }

        if (status.supabaseOk && status.backendOk && !status.backendFallbackActive) {
          return _StatusPanel(
            color: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
            title: 'All services are online',
            message: 'Secure sign-in and the Justice City app server are reachable.',
            trailing: TextButton(
              onPressed: _retry,
              child: const Text('Refresh'),
            ),
          );
        }

        if (status.supabaseOk && status.backendOk && status.backendFallbackActive) {
          return _StatusPanel(
            color: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            title: 'Backup app server active',
            message: 'Secure sign-in is online. The app server is reachable through the backup connection.',
            trailing: TextButton(
              onPressed: _retry,
              child: const Text('Refresh'),
            ),
          );
        }

        final issues = <String>[
          if (!status.supabaseOk) 'Secure sign-in service is unavailable.',
          if (!status.backendOk) 'Justice City app server is unavailable.',
        ];

        return _StatusPanel(
          color: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
          title: 'Service issue detected',
          message: issues.join(' '),
          trailing: TextButton(
            onPressed: _retry,
            child: const Text('Retry'),
          ),
        );
      },
    );
  }
}

class _ServiceStatus {
  const _ServiceStatus({
    required this.supabaseOk,
    required this.backendOk,
    required this.backendFallbackActive,
  });

  final bool supabaseOk;
  final bool backendOk;
  final bool backendFallbackActive;
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.color,
    required this.borderColor,
    required this.title,
    required this.message,
    required this.trailing,
  });

  final Color color;
  final Color borderColor;
  final String title;
  final String message;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _authHeading,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _authMuted,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 44,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                'JUSTICE CITY',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.title,
    required this.children,
    required this.error,
  });

  final String title;
  final List<Widget> children;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _authPanelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _authHeading,
                ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _AuthHeroPill extends StatelessWidget {
  const _AuthHeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

