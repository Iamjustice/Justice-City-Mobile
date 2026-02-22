import { apiRequest } from "@/lib/queryClient";

export type AdminVerificationStatus = "Awaiting Review" | "Approved" | "Rejected";
export type AdminFlaggedListingStatus = "Open" | "Under Review" | "Cleared";

export type AdminVerificationDocument = {
  name: string;
  url: string;
};

export type AdminVerificationRecord = {
  id: string;
  userId: string;
  user: string;
  type: "Agent" | "Seller";
  documents: AdminVerificationDocument[];
  status: AdminVerificationStatus;
  createdAt: string;
};

export type AdminFlaggedListingComment = {
  id: string;
  listingId: string;
  comment: string;
  problemTag: string;
  createdBy: string;
  createdAt: string;
  sentToChat: boolean;
};

export type AdminFlaggedListingRecord = {
  id: string;
  title: string;
  location: string;
  reason: string;
  status: AdminFlaggedListingStatus;
  affectedUserId: string;
  affectedUserName: string;
  comments: AdminFlaggedListingComment[];
  updatedAt: string;
};

export type AdminUserRecord = {
  id: string;
  name: string;
  role: "Buyer" | "Seller" | "Agent";
  email: string;
  status: "Active" | "Suspended";
  joinedAt: string;
};

export type AdminRevenueRecord = {
  id: string;
  month: string;
  date: string;
  source: string;
  grossAmount: number;
  netRevenue: number;
  status: "Received" | "Pending";
};

export type AdminRevenueTrendPoint = {
  label: string;
  amount: number;
};

export type AdminDashboardData = {
  overview: {
    commissionRate: number;
    totalUsers: number;
    pendingVerifications: number;
    flaggedListings: number;
    revenueJanLabel: string;
  };
  users: AdminUserRecord[];
  verifications: AdminVerificationRecord[];
  flaggedListings: AdminFlaggedListingRecord[];
  revenue: {
    records: AdminRevenueRecord[];
    trend: AdminRevenueTrendPoint[];
  };
};

export async function fetchAdminDashboardData(): Promise<AdminDashboardData> {
  const response = await fetch("/api/admin/dashboard", { credentials: "include" });
  if (!response.ok) {
    const text = (await response.text()) || response.statusText;
    throw new Error(`${response.status}: ${text}`);
  }

  return response.json();
}

export async function updateAdminVerificationStatus(
  verificationId: string,
  status: AdminVerificationStatus,
): Promise<void> {
  await apiRequest("PATCH", `/api/admin/verifications/${verificationId}`, { status });
}

export async function updateAdminFlaggedListingStatus(
  listingId: string,
  status: AdminFlaggedListingStatus,
): Promise<void> {
  await apiRequest("PATCH", `/api/admin/flagged-listings/${listingId}/status`, { status });
}

export async function addAdminFlaggedListingComment(
  listingId: string,
  payload: { comment: string; problemTag: string; createdBy: string; createdById?: string },
): Promise<AdminFlaggedListingComment> {
  const response = await apiRequest("POST", `/api/admin/flagged-listings/${listingId}/comments`, payload);
  return response.json();
}
