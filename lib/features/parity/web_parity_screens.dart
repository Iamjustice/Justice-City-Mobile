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

String _resolveRequesterRole(WidgetRef ref) {
  final role = (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
  const allowedRoles = <String>{'admin', 'agent', 'seller', 'buyer', 'owner', 'renter'};
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

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load profile: $e')),
        data: (me) {
          if (me == null) {
            return const Center(child: Text('Sign in to view profile.'));
          }

          if (!_hydrated) {
            _fullName.text = me.fullName ?? '';
            _dateOfBirth.text = me.dateOfBirth ?? '';
            _homeAddress.text = me.homeAddress ?? '';
            _officeAddress.text = me.officeAddress ?? '';
            _hydrated = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${me.email ?? "-"}'),
                      Text('Nickname: ${me.nickname ?? "-"}'),
                      Text('Role: ${me.role ?? "-"}'),
                      Text('Gender: ${me.gender ?? "-"}'),
                      Text('Verified: ${me.isVerified == true ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fullName,
                decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateOfBirth,
                decoration: const InputDecoration(
                  labelText: 'Date of birth (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _homeAddress,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Home address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _officeAddress,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Office address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        try {
                          await ref.read(authRepositoryProvider).patchProfile(
                                fullName: _fullName.text.trim(),
                                dateOfBirth: _dateOfBirth.text.trim(),
                                homeAddress: _homeAddress.text.trim(),
                                officeAddress: _officeAddress.text.trim(),
                              );
                          ref.invalidate(meProvider);
                          ref.invalidate(verificationStatusProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated.')),
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
          );
        },
      ),
    );
  }
}

class RequestCallbackScreen extends ConsumerStatefulWidget {
  const RequestCallbackScreen({super.key});

  @override
  ConsumerState<RequestCallbackScreen> createState() => _RequestCallbackScreenState();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Request Callback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Request a support callback and continue in chat.'),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone (E.164)',
              hintText: '+2349012345678',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.phone_forwarded_outlined),
            label: const Text('Send callback request'),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Tour')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _propertyRef,
            decoration: const InputDecoration(
              labelText: 'Property reference (optional)',
              border: OutlineInputBorder(),
            ),
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
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.event_available_outlined),
            label: const Text('Send tour request'),
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
      final when = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
      final initialMessage = [
        'TOUR REQUEST',
        'Preferred: ${when.toIso8601String()}',
        if (_propertyRef.text.trim().isNotEmpty) 'Property: ${_propertyRef.text.trim()}',
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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

    return Scaffold(
      appBar: AppBar(title: const Text('Hiring Application')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _fullName, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _serviceTrack,
            decoration: const InputDecoration(labelText: 'Service track', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'land_surveying', child: Text('Land Surveying')),
              DropdownMenuItem(value: 'real_estate_valuation', child: Text('Property Valuation')),
              DropdownMenuItem(value: 'land_verification', child: Text('Land Verification')),
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
            decoration: const InputDecoration(labelText: 'Years experience', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(controller: _licenseId, decoration: const InputDecoration(labelText: 'License ID', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _portfolioUrl, decoration: const InputDecoration(labelText: 'Portfolio URL (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(
            controller: _summary,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Professional summary', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('I consent to compliance checks'),
            value: _consented,
            onChanged: (v) => setState(() => _consented = v == true),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: const Text('Submit application'),
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
    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name, email, phone, and location are required.')),
      );
      return;
    }
    if (licenseId.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('License ID and professional summary are required.')),
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
      final message = (e.response?.data is Map && (e.response?.data as Map)['message'] != null)
          ? (e.response?.data as Map)['message'].toString()
          : e.message ?? 'Request failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: paragraphs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => Text(paragraphs[i]),
      ),
    );
  }
}
