import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return _ParityScaffold(
      currentPath: '/hiring',
      title: 'Hiring Application',
      subtitle: 'Professional partner onboarding for field service delivery.',
      body: Column(
        children: [
          const _PanelCard(
            child: _SupportFlowBanner(
              title: 'Professional onboarding',
              subtitle:
                  'Submit your field credentials and service track so the Justice City team can review your suitability for partner work.',
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: Column(
              children: [
                TextField(
                  controller: _fullName,
                  decoration: _fieldDecoration('Full name'),
                ),
            const SizedBox(height: 10),
            TextField(
              controller: _email,
              decoration: _fieldDecoration('Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phone,
              decoration: _fieldDecoration('Phone'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _location,
              decoration: _fieldDecoration('Location'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _serviceTrack,
              decoration: _fieldDecoration('Service track'),
              items: const [
                DropdownMenuItem(
                    value: 'land_surveying', child: Text('Land Surveying')),
                DropdownMenuItem(
                  value: 'real_estate_valuation',
                  child: Text('Property Valuation'),
                ),
                DropdownMenuItem(
                    value: 'land_verification',
                    child: Text('Land Verification')),
                DropdownMenuItem(value: 'snagging', child: Text('Snagging')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _serviceTrack = v);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearsExperience,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('Years experience'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _licenseId,
              decoration: _fieldDecoration('License ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _portfolioUrl,
              decoration: _fieldDecoration('Portfolio URL (optional)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _summary,
              minLines: 3,
              maxLines: 6,
              decoration: _fieldDecoration('Professional summary'),
            ),
            const SizedBox(height: 10),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I consent to compliance checks'),
                  value: _consented,
                  onChanged: (v) => setState(() => _consented = v == true),
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
                  label: const Text('Submit application'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Full name, email, phone, and location are required.')),
      );
      return;
    }
    if (licenseId.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('License ID and professional summary are required.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final session = ref.read(sessionProvider);
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
