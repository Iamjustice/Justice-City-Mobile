import { randomUUID } from "crypto";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const HIRING_APPLICATIONS_TABLE =
  process.env.SUPABASE_HIRING_APPLICATIONS_TABLE || "professional_hiring_applications";
const USERS_TABLE = process.env.SUPABASE_USERS_TABLE || "users";
const HIRING_DOCUMENTS_BUCKET = process.env.SUPABASE_HIRING_DOCUMENTS_BUCKET || "hiring-documents";

const HIRING_DOCUMENT_MAX_FILES = 6;
const HIRING_DOCUMENT_MAX_SIZE_BYTES = 10 * 1024 * 1024;
const HIRING_DOCUMENT_SIGNED_URL_TTL_SECONDS = 60 * 60;

const ALLOWED_HIRING_DOCUMENT_MIME_TYPES = new Set<string>([
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "text/plain",
  "image/jpeg",
  "image/png",
  "image/webp",
]);

export type HiringServiceTrack =
  | "land_surveying"
  | "real_estate_valuation"
  | "land_verification"
  | "snagging";

export type HiringApplicationStatus = "submitted" | "under_review" | "approved" | "rejected";

export type HiringApplicationDocument = {
  bucketId: string;
  storagePath: string;
  fileName: string;
  mimeType?: string;
  fileSizeBytes?: number;
  previewUrl?: string;
};

export type HiringApplicationDocumentInput = {
  fileName: string;
  mimeType?: string;
  fileSizeBytes?: number;
  contentBase64: string;
};

export type HiringApplicationRecord = {
  id: string;
  fullName: string;
  email: string;
  phone: string;
  location: string;
  serviceTrack: HiringServiceTrack;
  yearsExperience: number;
  licenseId: string;
  portfolioUrl?: string;
  summary: string;
  applicantUserId?: string;
  status: HiringApplicationStatus;
  reviewerNotes?: string;
  reviewedBy?: string;
  reviewedAt?: string;
  documents: HiringApplicationDocument[];
  createdAt: string;
  updatedAt: string;
};

export type CreateHiringApplicationInput = {
  fullName: string;
  email: string;
  phone: string;
  location: string;
  serviceTrack: HiringServiceTrack;
  yearsExperience: number;
  licenseId: string;
  portfolioUrl?: string;
  summary: string;
  applicantUserId?: string;
  consentedToChecks: boolean;
  documents?: HiringApplicationDocumentInput[];
};

type UpdateHiringApplicationStatusInput = {
  id: string;
  status: HiringApplicationStatus;
  reviewerNotes?: string;
  reviewerId?: string;
  reviewerName?: string;
};

const ALLOWED_SERVICE_TRACKS: HiringServiceTrack[] = [
  "land_surveying",
  "real_estate_valuation",
  "land_verification",
  "snagging",
];

let fallbackApplications: HiringApplicationRecord[] = [];

function getClient(): SupabaseClient | null {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) return null;

  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

function isTableMissingError(error: { message?: string } | null): boolean {
  const message = String(error?.message ?? "").toLowerCase();
  return message.includes("relation") && message.includes("does not exist");
}

function isColumnMissingError(error: { message?: string } | null): boolean {
  const message = String(error?.message ?? "").toLowerCase();
  return message.includes("column") && message.includes("does not exist");
}

function sanitizeStorageFileName(value: string): string {
  const safe = String(value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return safe || "document.bin";
}

function sanitizePathSegment(value: string, fallback: string): string {
  const safe = String(value ?? "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, "_")
    .replace(/^_+|_+$/g, "");
  return safe || fallback;
}

function normalizeServiceTrack(rawValue: string): HiringServiceTrack {
  const value = String(rawValue ?? "")
    .trim()
    .toLowerCase();

  if (ALLOWED_SERVICE_TRACKS.includes(value as HiringServiceTrack)) {
    return value as HiringServiceTrack;
  }
  throw new Error("Invalid service track.");
}

function normalizeStatus(rawValue: string): HiringApplicationStatus {
  const value = String(rawValue ?? "")
    .trim()
    .toLowerCase();
  if (value === "under review") return "under_review";
  if (value === "under_review") return "under_review";
  if (value === "approved") return "approved";
  if (value === "rejected") return "rejected";
  return "submitted";
}

function toServiceTrackSegment(track: HiringServiceTrack): string {
  const known: Record<HiringServiceTrack, string> = {
    land_surveying: "Land-Surveying",
    snagging: "Snagging",
    real_estate_valuation: "Property-Valuation",
    land_verification: "Land-Verification",
  };
  return known[track];
}

function inferMimeTypeFromFileName(fileName: string): string | undefined {
  const normalized = String(fileName ?? "").trim().toLowerCase();
  if (normalized.endsWith(".pdf")) return "application/pdf";
  if (normalized.endsWith(".doc")) return "application/msword";
  if (normalized.endsWith(".docx")) {
    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
  }
  if (normalized.endsWith(".txt")) return "text/plain";
  if (normalized.endsWith(".jpg") || normalized.endsWith(".jpeg")) return "image/jpeg";
  if (normalized.endsWith(".png")) return "image/png";
  if (normalized.endsWith(".webp")) return "image/webp";
  return undefined;
}

function normalizeDocument(input: unknown): HiringApplicationDocument | null {
  if (typeof input !== "object" || input === null) return null;
  const payload = input as Record<string, unknown>;

  const storagePath = String(payload.storagePath ?? payload.storage_path ?? "").trim();
  const fileName = String(payload.fileName ?? payload.file_name ?? "").trim();
  if (!storagePath || !fileName) return null;

  const bucketId = String(payload.bucketId ?? payload.bucket_id ?? HIRING_DOCUMENTS_BUCKET).trim();
  const mimeType = String(payload.mimeType ?? payload.mime_type ?? "").trim() || undefined;
  const previewUrl = String(payload.previewUrl ?? payload.preview_url ?? "").trim() || undefined;

  const fileSizeRaw = payload.fileSizeBytes ?? payload.file_size_bytes;
  const fileSizeBytes =
    typeof fileSizeRaw === "number" && Number.isFinite(fileSizeRaw)
      ? Math.max(0, Math.trunc(fileSizeRaw))
      : undefined;

  return {
    bucketId: bucketId || HIRING_DOCUMENTS_BUCKET,
    storagePath,
    fileName,
    mimeType,
    fileSizeBytes,
    previewUrl,
  };
}

function normalizeDocuments(input: unknown): HiringApplicationDocument[] {
  if (!input) return [];

  let source = input;
  if (typeof source === "string") {
    try {
      source = JSON.parse(source);
    } catch {
      return [];
    }
  }

  if (!Array.isArray(source)) return [];
  return source
    .map((item) => normalizeDocument(item))
    .filter((item): item is HiringApplicationDocument => Boolean(item));
}

function mapFallbackDocuments(
  inputs: HiringApplicationDocumentInput[] | undefined,
): HiringApplicationDocument[] {
  if (!Array.isArray(inputs) || inputs.length === 0) return [];

  const limited = inputs.slice(0, HIRING_DOCUMENT_MAX_FILES);
  return limited.map((item) => ({
    bucketId: "local",
    storagePath: `local/hiring/${randomUUID()}-${sanitizeStorageFileName(item.fileName)}`,
    fileName: String(item.fileName ?? "").trim() || "document.bin",
    mimeType: String(item.mimeType ?? "").trim() || undefined,
    fileSizeBytes:
      typeof item.fileSizeBytes === "number" && Number.isFinite(item.fileSizeBytes)
        ? Math.max(0, Math.trunc(item.fileSizeBytes))
        : undefined,
  }));
}

function mapDbRow(row: Record<string, unknown>): HiringApplicationRecord {
  const createdAt =
    typeof row.created_at === "string" && row.created_at.trim()
      ? row.created_at
      : new Date().toISOString();
  const updatedAt =
    typeof row.updated_at === "string" && row.updated_at.trim()
      ? row.updated_at
      : createdAt;

  return {
    id: String(row.id ?? randomUUID()),
    fullName: String(row.full_name ?? ""),
    email: String(row.email ?? ""),
    phone: String(row.phone ?? ""),
    location: String(row.location ?? ""),
    serviceTrack: normalizeServiceTrack(String(row.service_track ?? "land_surveying")),
    yearsExperience:
      typeof row.years_experience === "number"
        ? Math.max(0, row.years_experience)
        : Number.parseInt(String(row.years_experience ?? "0"), 10) || 0,
    licenseId: String(row.license_id ?? ""),
    portfolioUrl: String(row.portfolio_url ?? "").trim() || undefined,
    summary: String(row.summary ?? ""),
    applicantUserId: String(row.applicant_user_id ?? "").trim() || undefined,
    status: normalizeStatus(String(row.status ?? "submitted")),
    reviewerNotes: String(row.reviewer_notes ?? "").trim() || undefined,
    reviewedBy: String(row.reviewed_by ?? "").trim() || undefined,
    reviewedAt: String(row.reviewed_at ?? "").trim() || undefined,
    documents: normalizeDocuments(row.documents),
    createdAt,
    updatedAt,
  };
}

async function uploadHiringDocuments(
  client: SupabaseClient,
  input: {
    applicationId: string;
    applicantUserId?: string;
    serviceTrack: HiringServiceTrack;
    documents: HiringApplicationDocumentInput[];
  },
): Promise<HiringApplicationDocument[]> {
  const documents = Array.isArray(input.documents) ? input.documents : [];
  if (documents.length === 0) return [];
  if (documents.length > HIRING_DOCUMENT_MAX_FILES) {
    throw new Error(`You can upload at most ${HIRING_DOCUMENT_MAX_FILES} documents.`);
  }

  const ownerSegment = sanitizePathSegment(input.applicantUserId ?? "", "applicant");
  const serviceSegment = toServiceTrackSegment(input.serviceTrack);
  const storageRoot = `Hiring/${serviceSegment}/${ownerSegment}/${input.applicationId}/documents`;
  const uploaded: HiringApplicationDocument[] = [];

  for (const item of documents) {
    const originalName = String(item.fileName ?? "").trim();
    if (!originalName) {
      throw new Error("Each uploaded document must include fileName.");
    }

    const base64Raw = String(item.contentBase64 ?? "").trim();
    const normalizedBase64 = base64Raw.includes(",") ? base64Raw.split(",").pop() ?? "" : base64Raw;
    const fileBuffer = Buffer.from(normalizedBase64, "base64");
    if (!normalizedBase64 || fileBuffer.length === 0) {
      throw new Error(`Document "${originalName}" is empty.`);
    }
    if (fileBuffer.length > HIRING_DOCUMENT_MAX_SIZE_BYTES) {
      throw new Error(
        `Document "${originalName}" exceeds the ${Math.trunc(
          HIRING_DOCUMENT_MAX_SIZE_BYTES / (1024 * 1024),
        )}MB limit.`,
      );
    }

    const rawMime = String(item.mimeType ?? "")
      .trim()
      .toLowerCase();
    const inferredMime = inferMimeTypeFromFileName(originalName);
    const mimeType = rawMime || inferredMime;
    if (!mimeType || !ALLOWED_HIRING_DOCUMENT_MIME_TYPES.has(mimeType)) {
      throw new Error(
        `Document "${originalName}" must be PDF, DOC, DOCX, TXT, JPG, PNG, or WEBP.`,
      );
    }

    const safeName = sanitizeStorageFileName(originalName);
    const storagePath = `${storageRoot}/${Date.now()}-${randomUUID()}-${safeName}`;
    const { error } = await client.storage
      .from(HIRING_DOCUMENTS_BUCKET)
      .upload(storagePath, fileBuffer, { contentType: mimeType, upsert: false });

    if (error) {
      throw new Error(`Failed to upload "${originalName}": ${error.message}`);
    }

    uploaded.push({
      bucketId: HIRING_DOCUMENTS_BUCKET,
      storagePath,
      fileName: originalName,
      mimeType,
      fileSizeBytes:
        typeof item.fileSizeBytes === "number" && Number.isFinite(item.fileSizeBytes)
          ? Math.max(0, Math.trunc(item.fileSizeBytes))
          : fileBuffer.length,
    });
  }

  return uploaded;
}

async function cleanupUploadedDocuments(
  client: SupabaseClient,
  documents: HiringApplicationDocument[],
): Promise<void> {
  if (documents.length === 0) return;

  const grouped = new Map<string, string[]>();
  for (const item of documents) {
    const bucket = String(item.bucketId ?? "").trim();
    const path = String(item.storagePath ?? "").trim();
    if (!bucket || !path) continue;

    if (!grouped.has(bucket)) {
      grouped.set(bucket, []);
    }
    grouped.get(bucket)?.push(path);
  }

  await Promise.all(
    Array.from(grouped.entries()).map(async ([bucket, paths]) => {
      if (paths.length === 0) return;
      await client.storage.from(bucket).remove(paths);
    }),
  );
}

async function withDocumentPreviewUrls(
  client: SupabaseClient,
  record: HiringApplicationRecord,
): Promise<HiringApplicationRecord> {
  if (!Array.isArray(record.documents) || record.documents.length === 0) {
    return record;
  }

  const documents = await Promise.all(
    record.documents.map(async (item) => {
      const bucketId = String(item.bucketId ?? "").trim();
      const storagePath = String(item.storagePath ?? "").trim();
      if (!bucketId || !storagePath) return item;

      const { data, error } = await client.storage
        .from(bucketId)
        .createSignedUrl(storagePath, HIRING_DOCUMENT_SIGNED_URL_TTL_SECONDS);
      if (error || !data?.signedUrl) return item;

      return {
        ...item,
        previewUrl: data.signedUrl,
      };
    }),
  );

  return {
    ...record,
    documents,
  };
}

async function ensureUserExists(
  client: SupabaseClient,
  userId: string,
  displayName: string,
): Promise<void> {
  const normalizedUserId = String(userId ?? "").trim();
  if (!normalizedUserId) return;

  const { data, error } = await client
    .from(USERS_TABLE)
    .select("id")
    .eq("id", normalizedUserId)
    .maybeSingle();

  if (error) {
    if (isTableMissingError(error)) return;
    throw error;
  }

  if (data?.id) return;

  const username = displayName
    .toLowerCase()
    .replace(/[^a-z0-9_]/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 30) || "applicant";

  const { error: insertError } = await client.from(USERS_TABLE).insert({
    id: normalizedUserId,
    username: `${username}_${normalizedUserId.replace(/-/g, "").slice(0, 8)}`,
    full_name: displayName,
    role: "buyer",
    password: "hiring_placeholder_password",
  });

  if (insertError && !isTableMissingError(insertError)) {
    throw insertError;
  }
}

export async function createHiringApplication(
  input: CreateHiringApplicationInput,
): Promise<HiringApplicationRecord> {
  if (!input.consentedToChecks) {
    throw new Error("Consent to verification and background checks is required.");
  }

  const payload = {
    fullName: String(input.fullName ?? "").trim(),
    email: String(input.email ?? "").trim(),
    phone: String(input.phone ?? "").trim(),
    location: String(input.location ?? "").trim(),
    serviceTrack: normalizeServiceTrack(input.serviceTrack),
    yearsExperience: Math.max(0, Number.parseInt(String(input.yearsExperience ?? 0), 10) || 0),
    licenseId: String(input.licenseId ?? "").trim(),
    portfolioUrl: String(input.portfolioUrl ?? "").trim() || undefined,
    summary: String(input.summary ?? "").trim(),
    applicantUserId: String(input.applicantUserId ?? "").trim() || undefined,
    documents: Array.isArray(input.documents) ? input.documents : [],
  };

  if (!payload.fullName || !payload.email || !payload.phone || !payload.location) {
    throw new Error("Full name, email, phone, and location are required.");
  }
  if (!payload.licenseId || !payload.summary) {
    throw new Error("License ID and professional summary are required.");
  }

  const client = getClient();
  if (!client) {
    const createdAt = new Date().toISOString();
    const record: HiringApplicationRecord = {
      id: randomUUID(),
      fullName: payload.fullName,
      email: payload.email,
      phone: payload.phone,
      location: payload.location,
      serviceTrack: payload.serviceTrack,
      yearsExperience: payload.yearsExperience,
      licenseId: payload.licenseId,
      portfolioUrl: payload.portfolioUrl,
      summary: payload.summary,
      applicantUserId: payload.applicantUserId,
      status: "submitted",
      documents: mapFallbackDocuments(payload.documents),
      createdAt,
      updatedAt: createdAt,
    };
    fallbackApplications = [record, ...fallbackApplications];
    return record;
  }

  try {
    if (payload.applicantUserId) {
      await ensureUserExists(client, payload.applicantUserId, payload.fullName);
    }

    const { data, error } = await client
      .from(HIRING_APPLICATIONS_TABLE)
      .insert({
        full_name: payload.fullName,
        email: payload.email,
        phone: payload.phone,
        location: payload.location,
        service_track: payload.serviceTrack,
        years_experience: payload.yearsExperience,
        license_id: payload.licenseId,
        portfolio_url: payload.portfolioUrl ?? null,
        summary: payload.summary,
        applicant_user_id: payload.applicantUserId ?? null,
        status: "submitted",
        consented_to_checks: true,
        consented_at: new Date().toISOString(),
      })
      .select("*")
      .single();

    if (error) throw error;

    let created = mapDbRow(data as unknown as Record<string, unknown>);

    if (payload.documents.length > 0) {
      const uploadedDocuments = await uploadHiringDocuments(client, {
        applicationId: created.id,
        applicantUserId: payload.applicantUserId,
        serviceTrack: payload.serviceTrack,
        documents: payload.documents,
      });

      if (uploadedDocuments.length > 0) {
        const nowIso = new Date().toISOString();
        const { data: updatedData, error: updateError } = await client
          .from(HIRING_APPLICATIONS_TABLE)
          .update({
            documents: uploadedDocuments,
            updated_at: nowIso,
          })
          .eq("id", created.id)
          .select("*")
          .maybeSingle();

        if (updateError) {
          await cleanupUploadedDocuments(client, uploadedDocuments);

          if (isColumnMissingError(updateError)) {
            throw new Error(
              "Hiring document storage is not fully configured. Run supabase/professional_hiring_applications.sql and retry.",
            );
          }
          throw updateError;
        }

        if (updatedData) {
          created = mapDbRow(updatedData as unknown as Record<string, unknown>);
        } else {
          created = {
            ...created,
            documents: uploadedDocuments,
            updatedAt: nowIso,
          };
        }
      }
    }

    return withDocumentPreviewUrls(client, created);
  } catch (error) {
    if (
      typeof error === "object" &&
      error !== null &&
      "message" in error &&
      (isTableMissingError(error as { message?: string }) ||
        isColumnMissingError(error as { message?: string }))
    ) {
      const createdAt = new Date().toISOString();
      const record: HiringApplicationRecord = {
        id: randomUUID(),
        fullName: payload.fullName,
        email: payload.email,
        phone: payload.phone,
        location: payload.location,
        serviceTrack: payload.serviceTrack,
        yearsExperience: payload.yearsExperience,
        licenseId: payload.licenseId,
        portfolioUrl: payload.portfolioUrl,
        summary: payload.summary,
        applicantUserId: payload.applicantUserId,
        status: "submitted",
        documents: mapFallbackDocuments(payload.documents),
        createdAt,
        updatedAt: createdAt,
      };
      fallbackApplications = [record, ...fallbackApplications];
      return record;
    }

    const message = error instanceof Error ? error.message : "Unknown error";
    throw new Error(`Failed to create hiring application: ${message}`);
  }
}

export async function listHiringApplications(): Promise<HiringApplicationRecord[]> {
  const client = getClient();
  if (!client) {
    return [...fallbackApplications];
  }

  try {
    const { data, error } = await client
      .from(HIRING_APPLICATIONS_TABLE)
      .select("*")
      .order("created_at", { ascending: false });

    if (error) throw error;

    const rows = Array.isArray(data) ? data : [];
    const mapped = rows.map((row) => mapDbRow(row as unknown as Record<string, unknown>));
    return Promise.all(mapped.map((record) => withDocumentPreviewUrls(client, record)));
  } catch (error) {
    if (
      typeof error === "object" &&
      error !== null &&
      "message" in error &&
      (isTableMissingError(error as { message?: string }) ||
        isColumnMissingError(error as { message?: string }))
    ) {
      return [...fallbackApplications];
    }
    const message = error instanceof Error ? error.message : "Unknown error";
    throw new Error(`Failed to load hiring applications: ${message}`);
  }
}

export async function updateHiringApplicationStatus(
  input: UpdateHiringApplicationStatusInput,
): Promise<HiringApplicationRecord> {
  const id = String(input.id ?? "").trim();
  if (!id) throw new Error("Application id is required.");

  const status = normalizeStatus(input.status);
  const reviewerNotes = String(input.reviewerNotes ?? "").trim() || undefined;
  const reviewerId = String(input.reviewerId ?? "").trim() || undefined;
  const reviewerName = String(input.reviewerName ?? "").trim() || "Admin Reviewer";

  const client = getClient();
  if (!client) {
    const existing = fallbackApplications.find((item) => item.id === id);
    if (!existing) throw new Error("Application not found.");
    const updated: HiringApplicationRecord = {
      ...existing,
      status,
      reviewerNotes,
      reviewedBy: reviewerId || reviewerName,
      reviewedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    fallbackApplications = fallbackApplications.map((item) => (item.id === id ? updated : item));
    return updated;
  }

  try {
    if (reviewerId) {
      await ensureUserExists(client, reviewerId, reviewerName);
    }

    const { data, error } = await client
      .from(HIRING_APPLICATIONS_TABLE)
      .update({
        status,
        reviewer_notes: reviewerNotes ?? null,
        reviewed_by: reviewerId ?? null,
        reviewed_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .select("*")
      .maybeSingle();

    if (error) throw error;

    if (!data) {
      throw new Error("Application not found.");
    }

    return mapDbRow(data as unknown as Record<string, unknown>);
  } catch (error) {
    if (
      typeof error === "object" &&
      error !== null &&
      "message" in error &&
      (isTableMissingError(error as { message?: string }) ||
        isColumnMissingError(error as { message?: string }))
    ) {
      const existing = fallbackApplications.find((item) => item.id === id);
      if (!existing) throw new Error("Application not found.");
      const updated: HiringApplicationRecord = {
        ...existing,
        status,
        reviewerNotes,
        reviewedBy: reviewerId || reviewerName,
        reviewedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      fallbackApplications = fallbackApplications.map((item) => (item.id === id ? updated : item));
      return updated;
    }

    const message = error instanceof Error ? error.message : "Unknown error";
    throw new Error(`Failed to update hiring application: ${message}`);
  }
}
