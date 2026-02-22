import { useState } from "react";
import { useLocation } from "wouter";
import { useAuth } from "@/lib/auth";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { BadgeCheck, CheckCircle2, Paperclip, ShieldAlert, UserCheck, X } from "lucide-react";
import { toast } from "@/hooks/use-toast";
import { createHiringApplication, type HiringServiceTrack } from "@/lib/hiring";

const MAX_HIRING_DOCUMENTS = 6;
const MAX_HIRING_DOCUMENT_SIZE_BYTES = 10 * 1024 * 1024;

const ALLOWED_HIRING_DOCUMENT_MIME_TYPES = new Set<string>([
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "text/plain",
  "image/jpeg",
  "image/png",
  "image/webp",
]);

const ALLOWED_HIRING_DOCUMENT_EXTENSIONS = [".pdf", ".doc", ".docx", ".txt", ".jpg", ".jpeg", ".png", ".webp"];

function formatBytes(value: number): string {
  if (value < 1024) return `${value} B`;
  if (value < 1024 * 1024) return `${(value / 1024).toFixed(1)} KB`;
  return `${(value / (1024 * 1024)).toFixed(1)} MB`;
}

function isAllowedDocument(file: File): boolean {
  const mime = String(file.type ?? "")
    .trim()
    .toLowerCase();
  if (mime && ALLOWED_HIRING_DOCUMENT_MIME_TYPES.has(mime)) {
    return true;
  }

  const lowerName = file.name.toLowerCase();
  return ALLOWED_HIRING_DOCUMENT_EXTENSIONS.some((extension) => lowerName.endsWith(extension));
}

export default function HiringPage() {
  const [, setLocation] = useLocation();
  const { user } = useAuth();
  const [submitted, setSubmitted] = useState(false);
  const [consentChecked, setConsentChecked] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [selectedDocuments, setSelectedDocuments] = useState<File[]>([]);
  const [form, setForm] = useState({
    fullName: user?.name ?? "",
    email: user?.email ?? "",
    phone: "",
    location: "",
    serviceTrack: "" as "" | HiringServiceTrack,
    yearsExperience: "",
    licenseId: "",
    portfolioUrl: "",
    summary: "",
  });

  const handleDocumentSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(event.target.files ?? []);
    event.target.value = "";

    if (files.length === 0) return;

    const rejected: string[] = [];
    const accepted: File[] = [];

    for (const file of files) {
      if (!isAllowedDocument(file)) {
        rejected.push(`${file.name}: unsupported format`);
        continue;
      }
      if (file.size > MAX_HIRING_DOCUMENT_SIZE_BYTES) {
        rejected.push(`${file.name}: exceeds 10MB`);
        continue;
      }
      accepted.push(file);
    }

    setSelectedDocuments((current) => {
      const merged = [...current];
      for (const file of accepted) {
        if (merged.length >= MAX_HIRING_DOCUMENTS) {
          rejected.push(`${file.name}: max ${MAX_HIRING_DOCUMENTS} files`);
          continue;
        }

        const exists = merged.some(
          (item) =>
            item.name === file.name &&
            item.size === file.size &&
            item.lastModified === file.lastModified,
        );
        if (!exists) {
          merged.push(file);
        }
      }
      return merged;
    });

    if (rejected.length > 0) {
      toast({
        title: "Some files were not added",
        description: rejected.slice(0, 3).join(" | "),
        variant: "destructive",
      });
    }
  };

  const removeDocument = (target: File) => {
    setSelectedDocuments((current) =>
      current.filter(
        (item) =>
          !(
            item.name === target.name &&
            item.size === target.size &&
            item.lastModified === target.lastModified
          ),
      ),
    );
  };

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (!consentChecked) {
      toast({
        title: "Compliance consent required",
        description:
          "Please confirm that you understand verification and background screening are mandatory.",
        variant: "destructive",
      });
      return;
    }
    if (selectedDocuments.length === 0) {
      toast({
        title: "Resume/CV required",
        description: "Upload at least one resume, CV, or supporting document before submitting.",
        variant: "destructive",
      });
      return;
    }

    const yearsExperience = Number.parseInt(form.yearsExperience, 10);
    if (!form.serviceTrack) {
      toast({
        title: "Select service track",
        description: "Please choose your primary service track.",
        variant: "destructive",
      });
      return;
    }
    if (!Number.isFinite(yearsExperience) || yearsExperience < 0) {
      toast({
        title: "Invalid experience",
        description: "Years of experience must be 0 or greater.",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);
    try {
      await createHiringApplication({
        fullName: form.fullName.trim(),
        email: form.email.trim(),
        phone: form.phone.trim(),
        location: form.location.trim(),
        serviceTrack: form.serviceTrack,
        yearsExperience,
        licenseId: form.licenseId.trim(),
        portfolioUrl: form.portfolioUrl.trim() || undefined,
        summary: form.summary.trim(),
        applicantUserId: user?.id ?? undefined,
        consentedToChecks: true,
        documents: selectedDocuments,
      });

      setSubmitted(true);
      setSelectedDocuments([]);
      toast({
        title: "Application submitted",
        description: "Your hiring application has been received for compliance review.",
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Failed to submit hiring application.";
      toast({
        title: "Submission failed",
        description: message,
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <div className="container mx-auto px-4 py-20 text-center max-w-xl">
        <div className="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
          <CheckCircle2 className="w-10 h-10" />
        </div>
        <h2 className="text-2xl font-bold mb-2">Application Received</h2>
        <p className="text-slate-500 mb-8">
          Thank you for applying. Our team will review your credentials, then initiate identity
          verification and background checks before onboarding.
        </p>
        <Button onClick={() => setLocation("/")} variant="outline" className="w-full">
          Return Home
        </Button>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-12 max-w-6xl">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="space-y-6">
          <div className="inline-flex items-center gap-2 rounded-full bg-blue-50 text-blue-700 border border-blue-200 px-3 py-1 text-xs font-semibold">
            <BadgeCheck className="w-3.5 h-3.5" />
            Hiring Professionals
          </div>
          <h1 className="text-4xl font-display font-bold text-slate-900 leading-tight">
            Join Justice City&apos;s Verified Professional Network
          </h1>
          <p className="text-slate-600 text-lg">
            We hire qualified professionals for land surveying, valuation, land verification, and
            snagging services. Every approved applicant goes through strict trust and compliance checks.
          </p>

          <div className="space-y-3">
            <div className="rounded-2xl border border-slate-200 bg-white p-4">
              <div className="flex items-start gap-3">
                <UserCheck className="w-5 h-5 text-blue-600 mt-0.5" />
                <div>
                  <p className="font-semibold text-slate-900">Credential Review</p>
                  <p className="text-sm text-slate-600">
                    Professional licenses, certifications, and years of experience are validated.
                  </p>
                </div>
              </div>
            </div>
            <div className="rounded-2xl border border-slate-200 bg-white p-4">
              <div className="flex items-start gap-3">
                <ShieldAlert className="w-5 h-5 text-amber-600 mt-0.5" />
                <div>
                  <p className="font-semibold text-slate-900">Mandatory Screening</p>
                  <p className="text-sm text-slate-600">
                    All applicants undergo identity verification, background checks, and reference screening.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <Card className="shadow-xl border-slate-200">
          <CardHeader>
            <CardTitle>Professional Application</CardTitle>
            <CardDescription>
              Complete this form to be considered for Justice City professional services.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="fullName">Full Name</Label>
                  <Input
                    id="fullName"
                    value={form.fullName}
                    onChange={(event) => setForm((current) => ({ ...current, fullName: event.target.value }))}
                    placeholder="Your full legal name"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    value={form.email}
                    onChange={(event) => setForm((current) => ({ ...current, email: event.target.value }))}
                    placeholder="name@example.com"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone Number</Label>
                  <Input
                    id="phone"
                    value={form.phone}
                    onChange={(event) => setForm((current) => ({ ...current, phone: event.target.value }))}
                    placeholder="+234..."
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="location">Location</Label>
                  <Input
                    id="location"
                    value={form.location}
                    onChange={(event) => setForm((current) => ({ ...current, location: event.target.value }))}
                    placeholder="City, State"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="serviceTrack">Primary Service Track</Label>
                  <select
                    id="serviceTrack"
                    required
                    className="w-full h-10 rounded-md border border-slate-200 bg-white px-3 text-sm"
                    value={form.serviceTrack}
                    onChange={(event) =>
                      setForm((current) => ({
                        ...current,
                        serviceTrack: event.target.value as "" | HiringServiceTrack,
                      }))
                    }
                  >
                    <option value="" disabled>
                      Select service track
                    </option>
                    <option value="land_surveying">Land Surveying</option>
                    <option value="real_estate_valuation">Property Valuation</option>
                    <option value="land_verification">Land Info Verification</option>
                    <option value="snagging">Snagging Services</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="experience">Years of Experience</Label>
                  <Input
                    id="experience"
                    type="number"
                    min={0}
                    value={form.yearsExperience}
                    onChange={(event) =>
                      setForm((current) => ({ ...current, yearsExperience: event.target.value }))
                    }
                    placeholder="e.g. 6"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="licenseId">License or Certification ID</Label>
                  <Input
                    id="licenseId"
                    value={form.licenseId}
                    onChange={(event) =>
                      setForm((current) => ({ ...current, licenseId: event.target.value }))
                    }
                    placeholder="Professional license ID"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="portfolio">Portfolio URL (optional)</Label>
                  <Input
                    id="portfolio"
                    value={form.portfolioUrl}
                    onChange={(event) =>
                      setForm((current) => ({ ...current, portfolioUrl: event.target.value }))
                    }
                    placeholder="https://..."
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="summary">Professional Summary</Label>
                <Textarea
                  id="summary"
                  value={form.summary}
                  onChange={(event) => setForm((current) => ({ ...current, summary: event.target.value }))}
                  placeholder="Tell us about your qualifications, past projects, and what makes you a strong fit."
                  className="min-h-[120px]"
                  required
                />
              </div>

              <div className="space-y-3">
                <div className="space-y-2">
                  <Label htmlFor="hiringDocuments">Resume / CV / Supporting Documents</Label>
                  <Input
                    id="hiringDocuments"
                    type="file"
                    multiple
                    onChange={handleDocumentSelect}
                    accept=".pdf,.doc,.docx,.txt,.jpg,.jpeg,.png,.webp"
                  />
                  <p className="text-xs text-slate-500">
                    Required. Upload 1-{MAX_HIRING_DOCUMENTS} files (PDF, DOC, DOCX, TXT, JPG, PNG, WEBP). Max 10MB each.
                  </p>
                </div>

                {selectedDocuments.length > 0 && (
                  <div className="rounded-lg border border-slate-200 bg-slate-50 p-3 space-y-2">
                    {selectedDocuments.map((file) => (
                      <div
                        key={`${file.name}-${file.lastModified}-${file.size}`}
                        className="flex items-center justify-between gap-3 text-sm"
                      >
                        <div className="flex items-center gap-2 min-w-0">
                          <Paperclip className="w-4 h-4 text-slate-500 shrink-0" />
                          <span className="truncate text-slate-700">{file.name}</span>
                          <span className="text-xs text-slate-500 shrink-0">{formatBytes(file.size)}</span>
                        </div>
                        <button
                          type="button"
                          onClick={() => removeDocument(file)}
                          className="text-slate-500 hover:text-slate-700"
                          aria-label={`Remove ${file.name}`}
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="rounded-xl border border-amber-200 bg-amber-50 p-3 text-sm text-amber-800">
                <p className="font-semibold">Important Compliance Notice</p>
                <p className="mt-1">
                  All applicants are required to complete identity verification, credential
                  validation, and background checks before approval.
                </p>
              </div>

              <label className="flex items-start gap-2 text-sm text-slate-700">
                <input
                  type="checkbox"
                  checked={consentChecked}
                  onChange={(event) => setConsentChecked(event.target.checked)}
                  className="mt-0.5"
                  required
                />
                <span>
                  I understand and consent to Justice City&apos;s identity verification and
                  background screening process as part of this application.
                </span>
              </label>

              <Button
                type="submit"
                className="w-full bg-blue-600 hover:bg-blue-700 h-11"
                disabled={isSubmitting}
              >
                {isSubmitting ? "Submitting..." : "Submit Application"}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
