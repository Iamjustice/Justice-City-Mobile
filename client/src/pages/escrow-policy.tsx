import { Link } from "wouter";
import { ArrowLeft, Landmark } from "lucide-react";

export default function EscrowPolicyPage() {
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
                <Landmark className="w-3.5 h-3.5" />
                Escrow Policy
              </div>
              <h1 className="text-3xl md:text-4xl font-display font-bold text-slate-900">
                Justice City Ltd Escrow Policy
              </h1>
              <p className="text-sm text-slate-500">Effective date: February 15, 2026</p>
            </div>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">1. Purpose of Escrow</h2>
              <p className="text-slate-700 leading-7">
                Escrow protects both parties by holding funds until agreed transaction milestones
                are met and confirmed.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">2. When Escrow Applies</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>Selected property sales, rentals, and paid professional service requests.</li>
                <li>Any transaction marked by Justice City as &quot;escrow required&quot; for risk control.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">3. Funding and Confirmation</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>Buyer/requester funds escrow before delivery begins.</li>
                <li>Payment status and transaction references are recorded on-platform.</li>
                <li>Off-platform payment requests are prohibited and may trigger suspension.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">4. Release of Funds</h2>
              <p className="text-slate-700 leading-7">
                Funds are released when delivery conditions are met, including required documents,
                acceptance signals, and any mandatory verification steps.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">5. Disputes and Holds</h2>
              <ul className="list-disc pl-6 text-slate-700 leading-7 space-y-1">
                <li>Either party may open a dispute within the defined review window.</li>
                <li>During dispute review, funds remain on hold until a resolution is reached.</li>
                <li>Justice City may request additional evidence from both parties.</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">6. Fees, Refunds, and Chargebacks</h2>
              <p className="text-slate-700 leading-7">
                Escrow and processing fees may apply as disclosed at checkout. Refunds are handled
                based on delivery status, dispute findings, and applicable regulations.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">7. Compliance and Risk Controls</h2>
              <p className="text-slate-700 leading-7">
                We reserve the right to delay or block disbursement where fraud, sanctions, AML,
                identity concerns, or legal restrictions are detected.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-xl font-semibold text-slate-900">8. Contact</h2>
              <p className="text-slate-700 leading-7">
                Escrow support:{" "}
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
