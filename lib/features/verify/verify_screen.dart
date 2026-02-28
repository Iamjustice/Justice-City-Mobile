import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../state/session_provider.dart';
import '../../state/verification_provider.dart';
import '../../state/repositories_providers.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _emailController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneCodeController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _officeAddressController = TextEditingController();
  final _dobController = TextEditingController();

  bool _busy = false;
  String? _uploadedIdentityFileName;
  String? _uploadedUtilityBillFileName;

  @override
  void dispose() {
    _emailController.dispose();
    _emailCodeController.dispose();
    _phoneController.dispose();
    _phoneCodeController.dispose();
    _homeAddressController.dispose();
    _officeAddressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAndUploadDocument({
    required String userId,
    required String documentType,
    required String successLabel,
  }) async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Selected file is empty or unreadable.');
    }

    final homeAddress = _homeAddressController.text.trim();
    if (homeAddress.isEmpty) {
      throw StateError(
          'Home address is required before uploading verification documents.');
    }

    final dateOfBirth = _dobController.text.trim();
    if (dateOfBirth.isNotEmpty &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth)) {
      throw StateError('Date of birth must be in YYYY-MM-DD format.');
    }

    final mimeType = lookupMimeType(file.name, headerBytes: bytes);
    await ref.read(verificationRepositoryProvider).uploadDocument(
          userId: userId,
          documentType: documentType,
          fileName: file.name,
          contentBase64: base64Encode(bytes),
          mimeType: mimeType,
          fileSizeBytes: file.size,
          homeAddress: homeAddress,
          officeAddress: _officeAddressController.text.trim(),
          dateOfBirth: dateOfBirth,
        );

    if (!mounted) return;
    setState(() {
      if (documentType == 'identity') {
        _uploadedIdentityFileName = file.name;
      } else if (documentType == 'utility_bill') {
        _uploadedUtilityBillFileName = file.name;
      }
    });

    _toast('$successLabel uploaded successfully.');
    await ref.read(verificationStatusProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final verification = ref.watch(verificationStatusProvider);
    final isVerified = verification.maybeWhen(
      data: (s) => s?.isVerified == true,
      orElse: () => false,
    );

    final userId = session?.userId ?? '';
    final userEmail = session?.email;

    if (_emailController.text.isEmpty && (userEmail?.isNotEmpty ?? false)) {
      _emailController.text = userEmail!;
    }

    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        title: const SizedBox(
          height: 32,
          child: _BrandWordmark(),
        ),
        actions: [
          IconButton(
            onPressed: _busy
                ? null
                : () => ref.read(verificationStatusProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const _VerifyHero(),
          const SizedBox(height: 12),
          const _VerifyProgressStrip(),
          const SizedBox(height: 12),
          _Card(
            child: verification.when(
              data: (s) {
                if (s == null) {
                  return const Text(
                    'Sign in to view verification status.',
                    style: TextStyle(color: _jcMuted),
                  );
                }
                final status = s.latestStatus ?? 'unknown';
                final updated =
                    s.latestUpdatedAt?.toLocal().toString() ?? 'unknown';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Current Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: _jcHeading,
                            ),
                          ),
                        ),
                        _StatusPill(
                          text: s.isVerified ? 'Verified' : 'Pending',
                          verified: s.isVerified,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Latest check: ${_formatVerificationStatus(status)}',
                        style: const TextStyle(color: _jcMuted)),
                    const SizedBox(height: 4),
                    Text('Updated: $updated',
                        style: const TextStyle(color: _jcMuted)),
                    if ((s.latestMessage ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Message: ${s.latestMessage}'),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      s.isVerified
                          ? 'Verification is complete. You can continue to the main app.'
                          : 'Complete all steps below. The system updates your access automatically after approval.',
                      style: const TextStyle(color: _jcMuted),
                    ),
                    if (s.isVerified) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Continue to app'),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Loading verification status...'),
                ],
              ),
              error: (e, _) => Text('Failed to load status: $e'),
            ),
          ),
          if (!isVerified) ...[
            const SizedBox(height: 12),
            _StepCard(
              title: 'Step 1 - Email OTP',
              subtitle: 'Confirm your email ownership.',
              child: Column(
                children: [
                  _Field(_emailController, label: 'Email'),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    final email = _emailController.text.trim();
                                    if (email.isEmpty) {
                                      _toast('Enter your email');
                                      return;
                                    }
                                    await ref
                                        .read(verificationRepositoryProvider)
                                        .sendEmailOtp(email: email);
                                    _toast('Email code sent (if allowed).');
                                  }),
                          child: const Text('Send code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    final email = _emailController.text.trim();
                                    final code = _emailCodeController.text.trim();
                                    if (email.isEmpty || code.isEmpty) {
                                      _toast('Enter email + code');
                                      return;
                                    }
                                    await ref
                                        .read(verificationRepositoryProvider)
                                        .checkEmailOtp(
                                          email: email,
                                          code: code,
                                          userId: userId,
                                        );
                                    _toast('Email verified (if code was valid).');
                                    await ref
                                        .read(verificationStatusProvider.notifier)
                                        .refresh();
                                  }),
                          child: const Text('Verify'),
                        ),
                      ),
                    ],
                  ),
                  _Field(_emailCodeController, label: 'Email code'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _StepCard(
              title: 'Step 2 - Phone OTP',
              subtitle: 'Confirm your active phone number.',
              child: Column(
                children: [
                  _Field(
                    _phoneController,
                    label: 'Phone (E.164 e.g. +2349012345678)',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    final phone = _phoneController.text.trim();
                                    if (phone.isEmpty) {
                                      _toast('Enter your phone in E.164 format');
                                      return;
                                    }
                                    await ref
                                        .read(verificationRepositoryProvider)
                                        .sendPhoneOtp(phone: phone);
                                    _toast('SMS code sent (if allowed).');
                                  }),
                          child: const Text('Send code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    final phone = _phoneController.text.trim();
                                    final code = _phoneCodeController.text.trim();
                                    if (phone.isEmpty || code.isEmpty) {
                                      _toast('Enter phone + code');
                                      return;
                                    }
                                    await ref
                                        .read(verificationRepositoryProvider)
                                        .checkPhoneOtp(
                                          phone: phone,
                                          code: code,
                                          userId: userId,
                                        );
                                    _toast('Phone verified (if code was valid).');
                                    await ref
                                        .read(verificationStatusProvider.notifier)
                                        .refresh();
                                  }),
                          child: const Text('Verify'),
                        ),
                      ),
                    ],
                  ),
                  _Field(_phoneCodeController, label: 'SMS code'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _StepCard(
              title: 'Step 3 - Address + Documents',
              subtitle: 'Submit address and supporting identity records.',
              child: Column(
                children: [
                  _Field(_homeAddressController,
                      label: 'Home address (required)'),
                  _Field(_officeAddressController,
                      label: 'Office address (optional)'),
                  _Field(_dobController,
                      label: 'Date of birth (YYYY-MM-DD, optional)'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    await _pickAndUploadDocument(
                                      userId: userId,
                                      documentType: 'identity',
                                      successLabel: 'Identity document',
                                    );
                                  }),
                          icon: const Icon(Icons.badge_outlined),
                          label: const Text('Upload ID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_busy || userId.isEmpty)
                              ? null
                              : () => _run(() async {
                                    await _pickAndUploadDocument(
                                      userId: userId,
                                      documentType: 'utility_bill',
                                      successLabel: 'Utility bill',
                                    );
                                  }),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Upload Utility Bill'),
                        ),
                      ),
                    ],
                  ),
                  if (_uploadedIdentityFileName != null ||
                      _uploadedUtilityBillFileName != null) ...[
                    const SizedBox(height: 10),
                    if (_uploadedIdentityFileName != null)
                      _UploadChip(label: 'ID: $_uploadedIdentityFileName'),
                    if (_uploadedUtilityBillFileName != null)
                      _UploadChip(
                          label: 'Utility bill: $_uploadedUtilityBillFileName'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _StepCard(
              title: 'Step 4 - Smile ID Submission',
              subtitle: 'Finalize KYC processing with provider submission.',
              child: FilledButton.icon(
                onPressed: (_busy || userId.isEmpty)
                    ? null
                    : () => _run(() async {
                          await ref
                              .read(verificationRepositoryProvider)
                              .submitSmileId(userId: userId, mode: 'kyc');
                          _toast(
                            'Submitted for verification. Refresh status in a moment.',
                          );
                          await ref
                              .read(verificationStatusProvider.notifier)
                              .refresh();
                        }),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Submit Smile ID (KYC)'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const _Card(
            child: Text(
              'If your backend is configured to use the real provider, approval may be async. '
              'Verification status is the final source of truth for access controls.',
              style: TextStyle(color: _jcMuted),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatVerificationStatus(String status) {
  if (status.isEmpty) return 'Unknown';
  final normalized = status.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) return 'Unknown';
  return normalized[0].toUpperCase() + normalized.substring(1);
}

class _VerifyHero extends StatelessWidget {
  const _VerifyHero();

  @override
  Widget build(BuildContext context) {
    return _Card(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Account Verification',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Verification center',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Complete these checks to unlock listings, chat, and dashboard workflows.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyProgressStrip extends StatelessWidget {
  const _VerifyProgressStrip();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Row(
        children: [
          Expanded(
            child: _VerifyMetric(
              step: '01',
              label: 'Email',
            ),
          ),
          Expanded(
            child: _VerifyMetric(
              step: '02',
              label: 'Phone',
            ),
          ),
          Expanded(
            child: _VerifyMetric(
              step: '03',
              label: 'Documents',
            ),
          ),
          Expanded(
            child: _VerifyMetric(
              step: '04',
              label: 'KYC',
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyMetric extends StatelessWidget {
  const _VerifyMetric({required this.step, required this.label});

  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          step,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _jcHeading,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _jcMuted),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _jcHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: _jcMuted)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _Field(this.controller, {required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _jcPanelBorder),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ).copyWith(
          labelText: label,
          labelStyle: const TextStyle(color: _jcMuted),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? const Color(0xFF1E293B) : _jcPanelBorder,
        ),
        boxShadow: dark
            ? const [
                BoxShadow(
                  color: Color(0x220F172A),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _UploadChip extends StatelessWidget {
  const _UploadChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _jcPanelBorder),
        ),
        child: Text(label, style: const TextStyle(color: _jcMuted)),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.verified});
  final String text;
  final bool verified;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: verified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: verified ? const Color(0xFF15803D) : const Color(0xFFB45309),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'JUSTICE CITY',
          style: TextStyle(
            color: _jcHeading,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
