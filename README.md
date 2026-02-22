# Justice City: Trust-First Real Estate Marketplace

Justice City is a verified real estate platform dedicated to restoring trust in the Nigerian property market. By enforcing mandatory biometric identity verification (KYC) and property title verification, we reduce fraud risks and provide a safer environment for buyers, renters, owners, and agents.

## Key Features

### Verification and Security
- Biometric Identity Verification: Integrated with Smile ID for real-time facial recognition and document verification.
- Identity Checks: Users are expected to verify identity before accessing core trust-sensitive workflows.
- Property Title Verification: Listings can pass through a structured review process by legal and land professionals.
- Verified Badge System: Verified status is surfaced in user and listing experiences.

### Property Marketplace
- Listings marketplace with pricing, specs, and location context.
- Property detail views for bedrooms, bathrooms, size, and status.
- Search and filtering for listing type, location, and price bands.

### Professional Services
- Land Surveying
- Property Valuation
- Land Verification
- Service request conversations with document and transcript foundations.

## Tech Stack

- Frontend: React, Vite, TanStack Query, Tailwind CSS, Framer Motion, Wouter
- Backend: Node.js, Express
- Database/Auth/Storage: Supabase (PostgreSQL, Auth, Storage)
- ORM/Schema: Drizzle ORM + shared schema typing
- Identity Verification: Smile ID Web SDK integration points

## Project Structure

```text
.
├── client/                     # Frontend React application
│   ├── public/                 # Static assets (logos, icons, metadata images)
│   └── src/
│       ├── components/         # Reusable UI and role dashboards
│       ├── hooks/              # Custom React hooks
│       ├── lib/                # API clients and feature utilities
│       ├── pages/              # Route-level pages
│       └── App.tsx             # Main route composition
├── server/                     # Express server and repositories
│   ├── index.ts                # Server entry point
│   ├── routes.ts               # API routes
│   └── *-repository.ts         # Feature-specific data access
├── shared/
│   └── schema.ts               # Shared schema/types
├── supabase/                   # SQL schema and migration scripts
└── README.md
```

## Setup and Installation

### Prerequisites
- Node.js v20 or later
- Supabase project with PostgreSQL/Auth/Storage enabled
- Smile ID credentials for verification workflows

### 1) Clone and install

```bash
git clone <repository-url>
cd justice-city
npm install
```

### 2) Environment configuration

Create a `.env` file in the project root with:

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
DATABASE_URL=...
SMILE_ID_API_KEY=...
```

### 3) Database setup

Run your required SQL scripts in Supabase (for example files under `supabase/`), then run:

```bash
npm run db:push
```

### 4) Start development

```bash
npm run dev
```

## Architecture and Core Logic

### Trust Gate
Justice City applies a trust-gated model where high-risk actions (for example listing, professional workflows, and sensitive interactions) are tied to verification and role checks.

### Role-Based Access Control (RBAC)
Primary roles include:
- Buyer
- Seller (Owner)
- Agent
- Renter
- Admin

### Commission Model
Platform commission is modeled at 5% for completed qualifying transactions.

## Verification Flow

1. User registration and role selection.
2. User proceeds to verification flow (`/verify`) for Smile ID capture.
3. Verification outcome updates identity status in Supabase.
4. Verified state unlocks broader platform capabilities.

## Legal

- Terms of Service
- Privacy Policy
- Escrow Policy

## License

Copyright (c) 2026 Justice City Ltd. All rights reserved.
