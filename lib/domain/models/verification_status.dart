class VerificationStatus {
  final String userId;
  final bool isVerified;
  final bool userRowFound;
  final String? latestStatus; // approved|pending|failed|null
  final String? latestJobId;
  final String? latestSmileJobId;
  final String? latestProvider; // smile-id|mock|null
  final String? latestMessage;
  final DateTime? latestUpdatedAt;

  const VerificationStatus({
    required this.userId,
    required this.isVerified,
    required this.userRowFound,
    required this.latestStatus,
    required this.latestJobId,
    required this.latestSmileJobId,
    required this.latestProvider,
    required this.latestMessage,
    required this.latestUpdatedAt,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    final raw = json['latestUpdatedAt'];
    if (raw is String && raw.isNotEmpty) {
      parsed = DateTime.tryParse(raw);
    }
    return VerificationStatus(
      userId: (json['userId'] ?? '').toString(),
      isVerified: json['isVerified'] == true,
      userRowFound: json['userRowFound'] == true,
      latestStatus: json['latestStatus']?.toString(),
      latestJobId: json['latestJobId']?.toString(),
      latestSmileJobId: json['latestSmileJobId']?.toString(),
      latestProvider: json['latestProvider']?.toString(),
      latestMessage: json['latestMessage']?.toString(),
      latestUpdatedAt: parsed,
    );
  }
}
