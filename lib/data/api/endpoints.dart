class ApiEndpoints {
  // Auth
  static const signup = '/api/auth/signup';
  static const me = '/api/auth/me';
  static const patchProfile = '/api/auth/profile';

  // Listings (agent)
  static const agentListings = '/api/agent/listings';
  static String listingAssets(String listingId) => '/api/agent/listings/$listingId/assets';
  static String patchListing(String listingId) => '/api/agent/listings/$listingId';
  static String deleteListing(String listingId) => '/api/agent/listings/$listingId';
  static String patchListingStatus(String listingId) => '/api/agent/listings/$listingId/status';
  static String patchListingPayout(String listingId) => '/api/agent/listings/$listingId/payout';

  // Chat
  static const upsertConversation = '/api/chat/conversations/upsert';
  static const listConversations = '/api/chat/conversations';
  static String messages(String conversationId) => '/api/chat/conversations/$conversationId/messages';
  static String attachments(String conversationId) => '/api/chat/conversations/$conversationId/attachments';

  // Admin / dashboard
  static const adminDashboard = '/api/admin/dashboard';

  // Admin moderation
  static const adminHiringApplications = '/api/admin/hiring-applications';
  static String adminHiringStatus(String id) => '/api/admin/hiring-applications/$id/status';
  static String adminServiceOffering(String code) => '/api/admin/service-offerings/$code';
  static const adminChatConversations = '/api/admin/chat/conversations';
  static String adminVerification(String id) => '/api/admin/verifications/$id';
  static String adminFlaggedListingStatus(String id) => '/api/admin/flagged-listings/$id/status';
  static String adminFlaggedListingComments(String id) => '/api/admin/flagged-listings/$id/comments';

  // Verification
  static const verificationStatus = '/api/verification/status';
  static const phoneOtpSend = '/api/verification/phone/send';
  static const phoneOtpCheck = '/api/verification/phone/check';
  static const emailOtpSend = '/api/verification/email/send';
  static const emailOtpCheck = '/api/verification/email/check';
  static const smileIdSubmit = '/api/verification/smile-id';


  // Transactions / Escrow / Disputes
  static const transactionsUpsert = '/api/transactions/upsert';
  static String transactionByConversation(String conversationId) => '/api/transactions/by-conversation/$conversationId';
  static String transactionById(String transactionId) => '/api/transactions/$transactionId';
  static String transactionStatus(String transactionId) => '/api/transactions/$transactionId/status';
  static String transactionActions(String transactionId) => '/api/transactions/$transactionId/actions';
  static String transactionDisputes(String transactionId) => '/api/transactions/$transactionId/disputes';
  static const openDisputes = '/api/disputes/open';
  static String resolveDispute(String disputeId) => '/api/disputes/$disputeId/resolve';


  // Services
  static const serviceOfferings = '/api/service-offerings';
  static String providerPackage(String token) => '/api/provider-package/$token';

}
