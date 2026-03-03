import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../data/api/api_client.dart';
import '../../data/api/endpoints.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import '../../state/verification_provider.dart';
import '../shell/justice_city_shell.dart';

const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);
const _maxHiringDocuments = 6;
const _maxHiringDocumentSizeBytes = 10 * 1024 * 1024;
const _allowedHiringDocumentMimeTypes = <String>{
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'text/plain',
  'image/jpeg',
  'image/png',
  'image/webp',
};
const _allowedHiringDocumentExtensions = <String>[
  '.pdf',
  '.doc',
  '.docx',
  '.txt',
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
];

String _formatFileSize(int value) {
  if (value < 1024) return '$value B';
  if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
  return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
}

bool _isAllowedHiringDocument(PlatformFile file) {
  final lowerName = file.name.toLowerCase();
  final bytes = file.bytes;
  final mime = bytes == null || bytes.isEmpty
      ? lookupMimeType(file.name)
      : lookupMimeType(file.name, headerBytes: bytes);
  final normalizedMime = (mime ?? '').trim().toLowerCase();
  if (normalizedMime.isNotEmpty &&
      _allowedHiringDocumentMimeTypes.contains(normalizedMime)) {
    return true;
  }
  return _allowedHiringDocumentExtensions
      .any((extension) => lowerName.endsWith(extension));
}

String _resolveRequesterRole(WidgetRef ref) {
  final role =
      (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
  const allowedRoles = <String>{
    'admin',
    'agent',
    'seller',
    'buyer',
    'owner',
    'renter'
  };
  return allowedRoles.contains(role) ? role : 'buyer';
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _fullName = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _homeAddress = TextEditingController();
  final _officeAddress = TextEditingController();
  bool _saving = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _fullName.dispose();
    _dateOfBirth.dispose();
    _homeAddress.dispose();
    _officeAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);

    return _ParityScaffold(
      currentPath: '/profile',
      title: 'Profile',
      subtitle: 'Personal information, identity details, and account records.',
      body: meAsync.when(
        loading: () => const _PanelCard(
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Loading profile...'),
            ],
          ),
        ),
        error: (e, _) => _PanelCard(
          child: Text('Failed to load profile: $e'),
        ),
        data: (me) {
          if (me == null) {
            return const _PanelCard(
              child: Text('Sign in to view profile.'),
            );
          }

          if (!_hydrated) {
            _fullName.text = me.fullName ?? '';
            _dateOfBirth.text = me.dateOfBirth ?? '';
            _homeAddress.text = me.homeAddress ?? '';
            _officeAddress.text = me.officeAddress ?? '';
            _hydrated = true;
          }

          final identity = (me.fullName ?? me.email ?? 'Member').trim();
          final initial = identity.isEmpty ? 'M' : identity[0].toUpperCase();
          final roleLabel = (me.role ?? 'member').trim();
          final capitalRole = roleLabel.isEmpty
              ? 'Member'
              : '${roleLabel[0].toUpperCase()}${roleLabel.substring(1)}';

          return Column(
            children: [
              _PanelCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: _jcHeading,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            identity.isEmpty ? 'Member' : identity,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _jcHeading,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$capitalRole - ${me.email ?? '-'}',
                            style: const TextStyle(color: _jcMuted),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusTag(
                                text: me.isVerified == true
                                    ? 'Verified'
                                    : 'Not Verified',
                                active: me.isVerified == true,
                              ),
                              _StatusTag(
                                text: 'Gender: ${me.gender ?? '-'}',
                                active: false,
                              ),
                              _StatusTag(
                                text: 'Nickname: ${me.nickname ?? '-'}',
                                active: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ParityMetricStrip(
                items: [
                  _ParityMetricItem(
                    label: 'Role',
                    value: capitalRole,
                  ),
                  _ParityMetricItem(
                    label: 'Status',
                    value: me.isVerified == true ? 'Verified' : 'Pending',
                  ),
                  _ParityMetricItem(
                    label: 'Contact',
                    value: (me.email ?? '-').trim().isEmpty ? '-' : me.email!,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fullName,
                      decoration: _fieldDecoration('Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dateOfBirth,
                      decoration:
                          _fieldDecoration('Date of birth (YYYY-MM-DD)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _homeAddress,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _fieldDecoration('Home address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _officeAddress,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _fieldDecoration('Office address'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              try {
                                await ref
                                    .read(authRepositoryProvider)
                                    .patchProfile(
                                      fullName: _fullName.text.trim(),
                                      dateOfBirth: _dateOfBirth.text.trim(),
                                      homeAddress: _homeAddress.text.trim(),
                                      officeAddress: _officeAddress.text.trim(),
                                    );
                                ref.invalidate(meProvider);
                                ref.invalidate(verificationStatusProvider);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Profile updated.')),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Update failed: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Save profile'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RequestCallbackScreen extends ConsumerStatefulWidget {
  const RequestCallbackScreen({super.key});

  @override
  ConsumerState<RequestCallbackScreen> createState() =>
      _RequestCallbackScreenState();
}

class _RequestCallbackScreenState extends ConsumerState<RequestCallbackScreen> {
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ParityScaffold(
      currentPath: '/request-callback',
      title: 'Request Callback',
      subtitle: 'Ask support to call you and continue the request in chat.',
      body: Column(
        children: [
          const _PanelCard(
            child: _SupportFlowBanner(
              title: 'Support callback workflow',
              subtitle:
                  'Your request is converted into a tracked support conversation so the team can follow up and keep a record.',
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration(
                    'Phone (E.164)',
                    hint: '+2349012345678',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _fieldDecoration('Notes'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.phone_forwarded_outlined),
                  label: const Text('Send callback request'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    setState(() => _sending = true);
    try {
      final phone = _phone.text.trim();
      final notes = _notes.text.trim();
      final initialMessage = [
        'CALLBACK REQUEST',
        if (phone.isNotEmpty) 'Phone: $phone',
        if (notes.isNotEmpty) 'Notes: $notes',
      ].join('\n');

      final convoId = await ref.read(chatRepositoryProvider).upsertConversation(
            requesterId: session.userId,
            requesterName: session.email ?? 'User',
            requesterRole: _resolveRequesterRole(ref),
            recipientName: 'Justice City Support',
            recipientRole: 'support',
            subject: 'Request Callback',
            initialMessage: initialMessage,
            conversationScope: 'support',
          );

      if (!mounted) return;
      context.go('/chat/$convoId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class ScheduleTourScreen extends ConsumerStatefulWidget {
  const ScheduleTourScreen({super.key});

  @override
  ConsumerState<ScheduleTourScreen> createState() => _ScheduleTourScreenState();
}

class _ScheduleTourScreenState extends ConsumerState<ScheduleTourScreen> {
  final _propertyRef = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _sending = false;

  @override
  void dispose() {
    _propertyRef.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _date == null
        ? 'Select date'
        : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
    final selectedTime = _time == null ? 'Select time' : _time!.format(context);

    return _ParityScaffold(
      currentPath: '/schedule-tour',
      title: 'Schedule Tour',
      subtitle:
          'Book a property inspection and route details into support chat.',
      body: Column(
        children: [
          const _PanelCard(
            child: _SupportFlowBanner(
              title: 'Tour scheduling workflow',
              subtitle:
                  'Choose a date and time. The request is sent into support chat so the visit can be coordinated and tracked.',
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: Column(
              children: [
                TextField(
                  controller: _propertyRef,
                  decoration: _fieldDecoration('Property reference (optional)'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(selectedDate),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _time = picked);
                          }
                        },
                        icon: const Icon(Icons.schedule),
                        label: Text(selectedTime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _fieldDecoration('Notes'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.event_available_outlined),
                  label: const Text('Send tour request'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time.')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final when = DateTime(
          _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
      final initialMessage = [
        'TOUR REQUEST',
        'Preferred: ${when.toIso8601String()}',
        if (_propertyRef.text.trim().isNotEmpty)
          'Property: ${_propertyRef.text.trim()}',
        if (_notes.text.trim().isNotEmpty) 'Notes: ${_notes.text.trim()}',
      ].join('\n');

      final convoId = await ref.read(chatRepositoryProvider).upsertConversation(
            requesterId: session.userId,
            requesterName: session.email ?? 'User',
            requesterRole: _resolveRequesterRole(ref),
            recipientName: 'Justice City Support',
            recipientRole: 'support',
            subject: 'Schedule Tour',
            initialMessage: initialMessage,
            conversationScope: 'support',
          );

      if (!mounted) return;
      context.go('/chat/$convoId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class HiringScreen extends ConsumerStatefulWidget {
  const HiringScreen({super.key});

  @override
  ConsumerState<HiringScreen> createState() => _HiringScreenState();
}

class _HiringScreenState extends ConsumerState<HiringScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _yearsExperience = TextEditingController(text: '1');
  final _licenseId = TextEditingController();
  final _portfolioUrl = TextEditingController();
  final _summary = TextEditingController();
  final List<PlatformFile> _documents = [];
  String _serviceTrack = 'land_surveying';
  bool _consented = false;
  bool _submitting = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    _yearsExperience.dispose();
    _licenseId.dispose();
    _portfolioUrl.dispose();
    _summary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider).valueOrNull;
    final session = ref.watch(sessionProvider);

    if (!_hydrated) {
      _fullName.text = me?.fullName ?? '';
      _email.text = me?.email ?? (session?.email ?? '');
      _hydrated = true;
    }

    return JusticeCityShell(
      currentPath: '/hiring',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const _HiringHeroCard(),
          const SizedBox(height: 12),
          const _HiringTrustCard(
            icon: Icons.badge_outlined,
            accent: Color(0xFF2563EB),
            title: 'Credential Review',
            description:
                'Professional licenses, certifications, and years of experience are validated before approval.',
          ),
          const SizedBox(height: 12),
          const _HiringTrustCard(
            icon: Icons.verified_user_outlined,
            accent: Color(0xFFF59E0B),
            title: 'Mandatory Screening',
            description:
                'All applicants undergo identity verification, background checks, and reference screening.',
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Professional Application',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _jcHeading,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Complete this form to be considered for Justice City professional service delivery.',
                  style: TextStyle(color: _jcMuted, height: 1.45),
                ),
                const SizedBox(height: 18),
                const _HiringSectionHeader(
                  title: 'Personal Information',
                  subtitle: 'Tell us who you are and where you currently operate.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fullName,
                  decoration: _fieldDecoration('Full name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration('Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration('Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _location,
                  decoration: _fieldDecoration('Location'),
                ),
                const SizedBox(height: 18),
                const Divider(color: _jcPanelBorder, height: 1),
                const SizedBox(height: 18),
                const _HiringSectionHeader(
                  title: 'Service Track & Credentials',
                  subtitle: 'Select the professional track and supporting credentials you want reviewed.',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _serviceTrack,
                  decoration: _fieldDecoration('Primary service track'),
                  items: const [
                    DropdownMenuItem(
                      value: 'land_surveying',
                      child: Text('Land Surveying'),
                    ),
                    DropdownMenuItem(
                      value: 'real_estate_valuation',
                      child: Text('Property Valuation'),
                    ),
                    DropdownMenuItem(
                      value: 'land_verification',
                      child: Text('Land Verification'),
                    ),
                    DropdownMenuItem(
                      value: 'snagging',
                      child: Text('Snagging'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _serviceTrack = value);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _yearsExperience,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('Years of experience'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _licenseId,
                  decoration: _fieldDecoration('License or certification ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _portfolioUrl,
                  keyboardType: TextInputType.url,
                  decoration: _fieldDecoration('Portfolio URL (optional)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _summary,
                  minLines: 4,
                  maxLines: 6,
                  decoration: _fieldDecoration('Professional summary'),
                ),
                const SizedBox(height: 18),
                const Divider(color: _jcPanelBorder, height: 1),
                const SizedBox(height: 18),
                const _HiringSectionHeader(
                  title: 'Supporting Documents',
                  subtitle: 'Upload your resume, CV, or supporting documents for the review team.',
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _jcPanelBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _submitting ? null : _pickDocuments,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text('Upload documents'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Required. Upload 1-6 files (PDF, DOC, DOCX, TXT, JPG, PNG, WEBP). Max 10MB each.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: _jcMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_documents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (final file in _documents) ...[
                    _HiringDocumentTile(
                      name: file.name,
                      sizeLabel: _formatFileSize(file.size),
                      onRemove: _submitting ? null : () => _removeDocument(file),
                    ),
                    if (file != _documents.last) const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 18),
                const Divider(color: _jcPanelBorder, height: 1),
                const SizedBox(height: 18),
                const _HiringSectionHeader(
                  title: 'Compliance',
                  subtitle: 'Justice City verifies applicants before enabling partner assignments.',
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Compliance Notice',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'All applicants are required to complete identity verification, credential validation, and background checks before approval.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I understand and consent to Justice City''s identity verification and background screening process as part of this application.',
                    style: TextStyle(height: 1.45),
                  ),
                  value: _consented,
                  onChanged: (value) => setState(() => _consented = value == true),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(_submitting ? 'Submitting...' : 'Submit Application'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const JusticeCityFooter(),
        ],
      ),
    );
  }

  Future<void> _pickDocuments() async {
    if (_documents.length >= _maxHiringDocuments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum of 6 documents allowed.'),
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'txt',
        'jpg',
        'jpeg',
        'png',
        'webp',
      ],
    );
    if (result == null) return;

    final merged = <PlatformFile>[..._documents];
    final rejected = <String>[];

    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        rejected.add('${file.name}: file data missing');
        continue;
      }
      if (!_isAllowedHiringDocument(file)) {
        rejected.add('${file.name}: unsupported format');
        continue;
      }
      if (file.size > _maxHiringDocumentSizeBytes) {
        rejected.add('${file.name}: exceeds 10MB');
        continue;
      }
      final exists = merged.any((item) =>
          item.name == file.name &&
          item.size == file.size &&
          item.bytes?.length == file.bytes?.length);
      if (exists) {
        continue;
      }
      if (merged.length >= _maxHiringDocuments) {
        rejected.add('${file.name}: max $_maxHiringDocuments files');
        continue;
      }
      merged.add(file);
    }

    setState(() {
      _documents
        ..clear()
        ..addAll(merged);
    });

    if (rejected.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rejected.take(3).join(' | '))),
      );
    }
  }

  void _removeDocument(PlatformFile target) {
    setState(() {
      _documents.removeWhere((file) =>
          file.name == target.name &&
          file.size == target.size &&
          file.bytes?.length == target.bytes?.length);
    });
  }

  Future<void> _submit() async {
    if (!_consented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consent is required.')),
      );
      return;
    }

    final fullName = _fullName.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final location = _location.text.trim();
    final licenseId = _licenseId.text.trim();
    final summary = _summary.text.trim();

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full name, email, phone, and location are required.'),
        ),
      );
      return;
    }

    if (licenseId.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('License ID and professional summary are required.'),
        ),
      );
      return;
    }

    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload at least one resume, CV, or supporting document.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final session = ref.read(sessionProvider);
      final documents = <Map<String, dynamic>>[];
      for (final file in _documents) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) continue;
        documents.add({
          'fileName': file.name,
          'mimeType': lookupMimeType(file.name, headerBytes: bytes),
          'fileSizeBytes': file.size,
          'contentBase64': base64Encode(bytes),
        });
      }

      await ref.read(dioProvider).post(
        ApiEndpoints.hiringApplications,
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'location': location,
          'serviceTrack': _serviceTrack,
          'yearsExperience': int.tryParse(_yearsExperience.text.trim()) ?? 0,
          'licenseId': licenseId,
          'portfolioUrl': _portfolioUrl.text.trim(),
          'summary': summary,
          'consentedToChecks': true,
          'documents': documents,
          if (session != null) 'applicantUserId': session.userId,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted.')),
      );
      context.go('/home');
    } on DioException catch (e) {
      if (!mounted) return;
      final message = (e.response?.data is Map &&
              (e.response?.data as Map)['message'] != null)
          ? (e.response?.data as Map)['message'].toString()
          : e.message ?? 'Request failed';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _HiringHeroCard extends StatelessWidget {
  const _HiringHeroCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 6),
              Text(
                'Hiring Professionals',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join Justice City''s Verified Professional Network',
          style: TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: _jcHeading,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We hire qualified professionals for land surveying, valuation, land verification, and snagging services. Every approved applicant goes through strict trust and compliance checks.',
          style: TextStyle(
            fontSize: 18,
            height: 1.55,
            color: _jcMuted,
          ),
        ),
      ],
    );
  }
}

class _HiringTrustCard extends StatelessWidget {
  const _HiringTrustCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _jcHeading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    height: 1.45,
                    color: _jcMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HiringSectionHeader extends StatelessWidget {
  const _HiringSectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(
          subtitle,
          style: const TextStyle(
            color: _jcMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _HiringDocumentTile extends StatelessWidget {
  const _HiringDocumentTile({
    required this.name,
    required this.sizeLabel,
    required this.onRemove,
  });

  final String name;
  final String sizeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_rounded, color: _jcMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _jcHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sizeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _jcMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Remove document',
          ),
        ],
      ),
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Terms of Service',
      paragraphs: [
        'Use the platform lawfully and provide accurate property and identity information.',
        'Listings and verification actions are subject to compliance review by Justice City.',
        'Misrepresentation, fraud, or abuse may lead to account suspension and legal escalation.',
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Privacy Policy',
      paragraphs: [
        'We process account, listing, verification, and communication data to deliver trust-first services.',
        'Verification documents are stored in controlled storage and access is role-restricted.',
        'You can request profile updates; some records are retained for compliance and audit purposes.',
      ],
    );
  }
}

class EscrowPolicyScreen extends StatelessWidget {
  const EscrowPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PolicyScaffold(
      title: 'Escrow Policy',
      paragraphs: [
        'Escrow milestones and dispute controls are used to reduce transaction risk.',
        'Transaction status updates and dispute events are logged for auditability.',
        'Final release and resolution are governed by platform policy and applicable law.',
      ],
    );
  }
}

class _PolicyScaffold extends StatelessWidget {
  const _PolicyScaffold({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return _ParityScaffold(
      currentPath: '/terms-of-service',
      title: title,
      subtitle:
          'Policy reference for Justice City platform usage and compliance.',
      body: Column(
        children: [
          const _PanelCard(
            child: Row(
              children: [
                Expanded(
                  child: _ParityMetric(
                    item: _ParityMetricItem(label: 'Type', value: 'Compliance'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ParityMetric(
                    item: _ParityMetricItem(label: 'Scope', value: 'Platform-wide'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ParityMetric(
                    item: _ParityMetricItem(label: 'Status', value: 'Active'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final paragraph in paragraphs) ...[
            _PanelCard(
              child: Text(
                paragraph,
                style: const TextStyle(color: Color(0xFF334155)),
              ),
            ),
            if (paragraph != paragraphs.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ParityScaffold extends StatelessWidget {
  const _ParityScaffold({
    required this.currentPath,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String currentPath;
  final String title;
  final String subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return JusticeCityShell(
      currentPath: currentPath,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _ParityHeroCard(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          body,
          const SizedBox(height: 12),
          const JusticeCityFooter(),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ParityHeroCard extends StatelessWidget {
  const _ParityHeroCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            color: Color(0x220F172A),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.dashboard_customize_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(label: 'Trust-first flow'),
              _HeroPill(label: 'Role-aware access'),
              _HeroPill(label: 'Recorded activity'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xFF15803D) : const Color(0xFF475569),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: _jcPanelBorder),
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.4),
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
    labelStyle: const TextStyle(color: _jcMuted),
  );
}

class _SupportFlowBanner extends StatelessWidget {
  const _SupportFlowBanner({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: _jcMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ParityMetricStrip extends StatelessWidget {
  const _ParityMetricStrip({required this.items});

  final List<_ParityMetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _ParityMetric(item: items[i])),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ParityMetricItem {
  const _ParityMetricItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _ParityMetric extends StatelessWidget {
  const _ParityMetric({required this.item});

  final _ParityMetricItem item;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: const TextStyle(fontSize: 12, color: _jcMuted),
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _jcHeading,
            ),
          ),
        ],
      ),
    );
  }
}





