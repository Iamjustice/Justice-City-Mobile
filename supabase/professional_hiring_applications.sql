-- Justice City - Professional Hiring Applications
-- Safe to run multiple times.
-- Run after supabase/schema.sql (or supabase/role_based_upgrade.sql).

create extension if not exists pgcrypto;

create table if not exists public.professional_hiring_applications (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null,
  phone text not null,
  location text not null,
  service_track text not null
    check (
      service_track in (
        'land_surveying',
        'real_estate_valuation',
        'land_verification',
        'snagging'
      )
    ),
  years_experience integer not null default 0 check (years_experience >= 0),
  license_id text not null,
  portfolio_url text,
  summary text not null,
  applicant_user_id uuid references public.users(id) on delete set null,
  status text not null default 'submitted'
    check (status in ('submitted', 'under_review', 'approved', 'rejected')),
  reviewer_notes text,
  reviewed_by uuid references public.users(id) on delete set null,
  reviewed_at timestamptz,
  consented_to_checks boolean not null default false,
  consented_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.professional_hiring_applications
  add column if not exists documents jsonb not null default '[]'::jsonb;

create index if not exists idx_hiring_applications_status_created_at
on public.professional_hiring_applications (status, created_at desc);

create index if not exists idx_hiring_applications_service_track_created_at
on public.professional_hiring_applications (service_track, created_at desc);

create index if not exists idx_hiring_applications_applicant_created_at
on public.professional_hiring_applications (applicant_user_id, created_at desc);

create or replace trigger trg_hiring_applications_updated_at
before update on public.professional_hiring_applications
for each row
execute function public.set_updated_at();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'hiring-documents',
  'hiring-documents',
  false,
  10485760,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'image/jpeg',
    'image/png',
    'image/webp'
  ]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

alter table public.professional_hiring_applications enable row level security;

drop policy if exists hiring_applications_self_submit on public.professional_hiring_applications;
create policy hiring_applications_self_submit
on public.professional_hiring_applications
for insert
with check (
  applicant_user_id = auth.uid()
  or (
    applicant_user_id is null
    and auth.role() = 'authenticated'
  )
  or exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
);

drop policy if exists hiring_applications_self_read on public.professional_hiring_applications;
create policy hiring_applications_self_read
on public.professional_hiring_applications
for select
using (
  applicant_user_id = auth.uid()
  or exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
);

drop policy if exists hiring_applications_admin_manage on public.professional_hiring_applications;
create policy hiring_applications_admin_manage
on public.professional_hiring_applications
for all
using (
  exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
)
with check (
  exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
);
