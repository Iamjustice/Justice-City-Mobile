import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';

import '../../state/session_provider.dart';
import '../../state/verification_provider.dart';
import '../../state/repositories_providers.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      throw StateError('Home address is required before uploading verification documents.');
    }

    final dateOfBirth = _dobController.text.trim();
    if (dateOfBirth.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth)) {
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

    final userId = session?.userId ?? '';
    final userEmail = session?.email;

    if (_emailController.text.isEmpty && (userEmail?.isNotEmpty ?? false)) {
      _emailController.text = userEmail!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your account'),
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
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: verification.when(
                data: (s) {
                  if (s == null) return const Text('Sign in to view verification status.');
                  final status = s.latestStatus ?? 'unknown';
                  final provider = s.latestProvider ?? 'unknown';
                  final updated = s.latestUpdatedAt?.toLocal().toString() ?? 'unknown';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${s.isVerified ? "VERIFIED" : "NOT VERIFIED"}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Latest: $status ($provider)'),
                      const SizedBox(height: 4),
                      Text('Updated: $updated'),
                      if ((s.latestMessage ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Message: ${s.latestMessage}'),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'Complete email + phone verification, then submit Smile ID. '
                        'After approval, refresh this page.',
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('Loading verification status...'),
                    ],
                  ),
                ),
                error: (e, _) => Text('Failed to load status: $e'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const _SectionTitle('Step 1 - Email OTP'),
          _Field(_emailController, label: 'Email'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_busy || userId.isEmpty)
                      ? null
                      : () => _run(() async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              _toast('Enter your email');
                              return;
                            }
                            await ref.read(verificationRepositoryProvider).sendEmailOtp(email: email);
                            _toast('Email code sent (if allowed).');
                          }),
                  child: const Text('Send code'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_busy || userId.isEmpty)
                      ? null
                      : () => _run(() async {
                            final email = _emailController.text.trim();
                            final code = _emailCodeController.text.trim();
                            if (email.isEmpty || code.isEmpty) {
                              _toast('Enter email + code');
                              return;
                            }
                            await ref.read(verificationRepositoryProvider).checkEmailOtp(
                                  email: email,
                                  code: code,
                                  userId: userId,
                                );
                            _toast('Email verified (if code was valid).');
                            await ref.read(verificationStatusProvider.notifier).refresh();
                          }),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
          _Field(_emailCodeController, label: 'Email code'),
          const SizedBox(height: 16),

          const _SectionTitle('Step 2 - Phone OTP'),
          _Field(_phoneController, label: 'Phone (E.164 e.g. +2349012345678)'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (_busy || userId.isEmpty)
                      ? null
                      : () => _run(() async {
                            final phone = _phoneController.text.trim();
                            if (phone.isEmpty) {
                              _toast('Enter your phone in E.164 format');
                              return;
                            }
                            await ref.read(verificationRepositoryProvider).sendPhoneOtp(phone: phone);
                            _toast('SMS code sent (if allowed).');
                          }),
                  child: const Text('Send code'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_busy || userId.isEmpty)
                      ? null
                      : () => _run(() async {
                            final phone = _phoneController.text.trim();
                            final code = _phoneCodeController.text.trim();
                            if (phone.isEmpty || code.isEmpty) {
                              _toast('Enter phone + code');
                              return;
                            }
                            await ref.read(verificationRepositoryProvider).checkPhoneOtp(
                                  phone: phone,
                                  code: code,
                                  userId: userId,
                                );
                            _toast('Phone verified (if code was valid).');
                            await ref.read(verificationStatusProvider.notifier).refresh();
                          }),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
          _Field(_phoneCodeController, label: 'SMS code'),
          const SizedBox(height: 16),

          const _SectionTitle('Step 3 - Address + documents'),
          _Field(_homeAddressController, label: 'Home address (required)'),
          _Field(_officeAddressController, label: 'Office address (optional)'),
          _Field(_dobController, label: 'Date of birth (YYYY-MM-DD, optional)'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
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
                  label: const Text('Upload ID Document'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
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
          if (_uploadedIdentityFileName != null || _uploadedUtilityBillFileName != null) ...[
            const SizedBox(height: 8),
            if (_uploadedIdentityFileName != null)
              Text('ID: $_uploadedIdentityFileName'),
            if (_uploadedUtilityBillFileName != null)
              Text('Utility bill: $_uploadedUtilityBillFileName'),
          ],
          const SizedBox(height: 16),

          const _SectionTitle('Step 4 - Smile ID submission'),
          ElevatedButton(
            onPressed: (_busy || userId.isEmpty)
                ? null
                : () => _run(() async {
                      await ref.read(verificationRepositoryProvider).submitSmileId(userId: userId, mode: 'kyc');
                      _toast('Submitted to Smile ID (or mock). Refresh status in a moment.');
                      await ref.read(verificationStatusProvider.notifier).refresh();
                    }),
            child: const Text('Submit Smile ID (KYC)'),
          ),

          const SizedBox(height: 24),
          Text(
            'Note: If your backend is configured to use the real provider, approval may be async. '
            'The status endpoint is the source of truth for the Trust Gate.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
