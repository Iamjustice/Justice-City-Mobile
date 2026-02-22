# Justice City Deployment & Implementation Guide

This guide explains the implementation process, next-step process, and publishing process for GoDaddy, Hostinger, or Zoho-domain setups.

---

## A) Implementation Process (from local to production)

### Step 1: Prepare backend dependencies
1. Ensure dependencies are installed:
   - `npm install`
2. Confirm project compiles:
   - `npm run check`
3. Confirm production build works:
   - `npm run build`

### Step 2: Provision Supabase
1. Create a Supabase project.
2. Open SQL Editor and run `supabase/schema.sql`.
3. Confirm these objects exist:
   - `public.users`
   - `public.verifications`
   - `public.verification_summary`

### Step 3: Configure environment variables
Set the following on your deployment platform:
- `NODE_ENV=production`
- `PORT=5000` (or platform port pattern)
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SMILE_ID_PARTNER_ID`
- `SMILE_ID_API_KEY`
- `SMILE_ID_CALLBACK_URL=https://justicecityltd.com/api/verification/smile-id/callback`

### Step 4: Configure Smile ID callback endpoint
In Smile ID dashboard webhook/callback settings, set:
- `https://justicecityltd.com/api/verification/smile-id/callback`

### Step 5: Verify production integration
1. Create a test verification from app UI (`/verify`).
2. Confirm `POST /api/verification/smile-id` succeeds.
3. Confirm callback updates the same `job_id` status in Supabase table `public.verifications`.

---

## B) Next-Step Implementation Process (recommended)

1. **Security hardening**
   - Add callback authenticity verification (signature/token validation).
2. **Resilience**
   - Add idempotency key checks for duplicate callbacks.
   - Add retry strategy/queue for transient failures.
3. **Operations**
   - Add admin dashboard section for verification audit + manual review.
   - Add alerting on callback failures.
4. **Testing**
   - Add integration tests for submit->callback status transitions.

---

## C) Publishing Process: GoDaddy, Hostinger, or Zoho domain

> Important: Your domain is from Zoho, but hosting can be any provider. Domain registrar and hosting provider can be different.

### Option 1: Publish with GoDaddy hosting
1. Deploy your app backend/frontend to GoDaddy-compatible Node hosting (or a VPS under GoDaddy).
2. In GoDaddy DNS zone for `justicecityltd.com`:
   - Add/Update `A` record for root (`@`) to server IP.
   - Add `CNAME` for `www` to root domain (or host target).
3. Install SSL certificate and force HTTPS.
4. Set your server env vars (including Supabase + Smile ID callback URL).
5. Smoke test `/` and `/api/verification/smile-id/callback`.

### Option 2: Publish with Hostinger hosting
1. Deploy app to Hostinger VPS/Node hosting.
2. Point `justicecityltd.com` DNS to Hostinger server:
   - `A` record for `@`
   - `CNAME` for `www`
3. Enable SSL in Hostinger panel.
4. Configure environment variables on host.
5. Verify Smile callback delivery in logs.

### Option 3: Keep Zoho as registrar + deploy elsewhere
1. Keep domain managed at Zoho.
2. In Zoho DNS:
   - Set `A` record for `@` to hosting IP.
   - Set `CNAME` for `www` to `@` (or host target).
3. Wait for DNS propagation.
4. Confirm `https://justicecityltd.com` resolves to deployed app.
5. Keep Smile callback URL as:
   - `https://justicecityltd.com/api/verification/smile-id/callback`

---

## D) DNS quick reference

- Root domain: `justicecityltd.com` (`@` record)
- Subdomain: `www.justicecityltd.com` (`CNAME`)
- API callback path: `/api/verification/smile-id/callback`

Final callback URL to use in Smile ID:
- `https://justicecityltd.com/api/verification/smile-id/callback`

---

## E) Practical rollout checklist

- [ ] Supabase schema applied
- [ ] Production env variables set
- [ ] DNS pointed to host
- [ ] HTTPS active
- [ ] Smile callback configured
- [ ] End-to-end verification tested
- [ ] Monitoring + error alerts enabled
