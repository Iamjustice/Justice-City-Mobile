-- Justice City - Professional Services Pricing/Delivery Admin Controls
-- Safe to run multiple times.

create table if not exists public.service_catalog (
  code text primary key,
  name text not null unique
);

insert into public.service_catalog (code, name) values
  ('land_surveying', 'Land Surveying'),
  ('snagging', 'Snagging Services'),
  ('real_estate_valuation', 'Property Valuation'),
  ('land_verification', 'Land Info Verification')
on conflict (code) do update set name = excluded.name;

create table if not exists public.service_offerings (
  code text primary key references public.service_catalog(code) on delete cascade,
  display_name text not null,
  description text not null default '',
  icon_key text not null default 'ClipboardCheck',
  price_label text not null,
  turnaround_label text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace trigger trg_service_offerings_updated_at
before update on public.service_offerings
for each row
execute function public.set_updated_at();

insert into public.service_offerings (
  code,
  display_name,
  description,
  icon_key,
  price_label,
  turnaround_label
) values
  (
    'real_estate_valuation',
    'Property Valuation',
    'Get a certified valuation report for your property from licensed estate surveyors.',
    'ClipboardCheck',
    'NGN 50,000',
    '48 Hours'
  ),
  (
    'land_surveying',
    'Land Surveying',
    'Professional boundary surveys and topographic mapping by verified surveyors.',
    'Compass',
    'NGN 120,000',
    '5-7 Days'
  ),
  (
    'land_verification',
    'Land Info Verification',
    'Verify land titles and historical records at the state land registry.',
    'FileSearch',
    'NGN 35,000',
    '24 Hours'
  ),
  (
    'snagging',
    'Snagging Services',
    'Detailed inspection of new buildings to identify defects before you move in.',
    'Building2',
    'NGN 45,000',
    '48 Hours'
  )
on conflict (code) do update
set
  display_name = excluded.display_name,
  description = excluded.description,
  icon_key = excluded.icon_key,
  price_label = excluded.price_label,
  turnaround_label = excluded.turnaround_label,
  updated_at = now();

alter table public.service_offerings enable row level security;

drop policy if exists service_offerings_public_read on public.service_offerings;
create policy service_offerings_public_read
on public.service_offerings
for select
using (true);

drop policy if exists service_offerings_admin_manage on public.service_offerings;
create policy service_offerings_admin_manage
on public.service_offerings
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
