import { Link } from "wouter";
import { ArrowLeft, Scale } from "lucide-react";

export default function TermsOfServicePage() {
  return (
    <div className="min-h-screen bg-slate-50">
      <section className="container mx-auto px-4 py-12 md:py-16">
        <div className="max-w-4xl mx-auto">
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-sm text-slate-600 hover:text-blue-600 mb-6"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to home
          </Link>

          <div className="bg-white border border-slate-200 rounded-2xl shadow-sm p-6 md:p-10 space-y-8">
            <div className="space-y-3">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-xs font-semibold">
                <Scale className="w-3.5 h-3.5" />
                Terms of Service
              </div>
              <h1 className="text-3xl md:text-4xl font-display font-bold text-slate-900">
                Justice City Ltd Terms of Service
              </h1>
              <p className="text-sm text-slate-500">Effective date: February 15, 2026</p>
            </div>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">1. Agreement to Terms</h2>
              <p className="text-slate-700 leading-7">
                By accessing or using Justice City Ltd, you agree to these Terms of Service and
                our platform policies. If you do not agree, do not use the platform.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">2. Eligibility and Accounts</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>You must provide accurate account information and keep it up to date.</li>
                <li>You are responsible for activity under your account credentials.</li>
                <li>Identity and profile compliance checks may be required for continued access.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">3. Platform Use Rules</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>Do not submit false listings, forged documents, or misleading information.</li>
                <li>Do not abuse chat, impersonate others, or attempt fraud.</li>
                <li>Do not bypass verification, payment, or escrow requirements where applicable.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">4. Listings and Verification</h2>
              <p className="text-slate-700 leading-7">
                Listings may be moderated, suspended, or removed if they fail legal, ownership,
                or trust checks. Verification results, compliance reviews, and moderation actions
                are made at Justice City&apos;s sole discretion.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">5. Service Fees and Payments</h2>
              <p className="text-slate-700 leading-7">
                Fees for platform services may change from time to time. Where escrow is used,
                disbursement and dispute handling follow the Escrow Policy.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">6. Suspension and Termination</h2>
              <p className="text-slate-700 leading-7">
                We may suspend or terminate accounts that violate law, policy, or trust standards,
                including repeated non-compliance with identity and profile requirements.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">7. Disclaimers and Liability</h2>
              <p className="text-slate-700 leading-7">
                The platform is provided on an &quot;as available&quot; basis. To the extent permitted by
                law, Justice City disclaims implied warranties and is not liable for indirect or
                consequential losses.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">8. Contact</h2>
              <p className="text-slate-700 leading-7">
                Questions about these terms can be sent to{" "}
                <a className="text-blue-600 hover:underline" href="mailto:contact@justicecityltd.com">
                  contact@justicecityltd.com
                </a>
                .
              </p>
            </section>
          </div>
        </div>
      </section>
    </div>
  );
}
