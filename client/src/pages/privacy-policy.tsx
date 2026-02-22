import { Link } from "wouter";
import { ArrowLeft, ShieldCheck } from "lucide-react";

export default function PrivacyPolicyPage() {
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
                <ShieldCheck className="w-3.5 h-3.5" />
                Data Privacy Policy
              </div>
              <h1 className="text-3xl md:text-4xl font-display font-bold text-slate-900">
                Justice City Ltd Privacy Policy
              </h1>
              <p className="text-sm text-slate-500">
                Effective date: February 14, 2026
              </p>
            </div>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">1. Who We Are</h2>
              <p className="text-slate-700 leading-7">
                Justice City Ltd operates a real estate marketplace that includes identity
                and property verification services. This policy explains how we collect,
                use, store, and protect personal information when you use our services.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">2. Information We Collect</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>Account details (such as name, email, username, and login credentials).</li>
                <li>Verification information you submit (for example ID or biometric checks).</li>
                <li>Technical data such as device/browser information and basic usage logs.</li>
                <li>Communication records when you contact our support team.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">3. How We Use Information</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>To create and manage your account.</li>
                <li>To process verification requests and prevent fraud.</li>
                <li>To improve platform security, reliability, and service quality.</li>
                <li>To comply with legal and regulatory obligations.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">4. Sharing of Information</h2>
              <p className="text-slate-700 leading-7">
                We only share personal information with trusted providers that support our
                operations, such as verification and hosting partners, and only where needed
                to provide the service. We may also share information where required by law.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">5. Data Security</h2>
              <p className="text-slate-700 leading-7">
                We use reasonable technical and organizational safeguards to protect personal
                information against unauthorized access, disclosure, alteration, or loss.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">6. Data Retention</h2>
              <p className="text-slate-700 leading-7">
                We retain personal information for as long as needed to provide services,
                meet legal obligations, resolve disputes, and enforce agreements.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">7. Your Rights</h2>
              <p className="text-slate-700 leading-7">
                Depending on applicable law, you may request access, correction, deletion,
                or restriction of your personal information by contacting us.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">8. Contact Us</h2>
              <p className="text-slate-700 leading-7">
                For privacy-related requests, contact:{" "}
                <a className="text-blue-600 hover:underline" href="mailto:contact@justicecityltd.com">
                  contact@justicecityltd.com
                </a>
              </p>
            </section>
          </div>
        </div>
      </section>
    </div>
  );
}
