-- Justice City - Automated Commission Calculation
-- Run after supabase/agent_roles_listings_storage.sql
-- Safe to run multiple times.

create extension if not exists pgcrypto;

do $$
begin
  if to_regclass('public.users') is null then
    raise exception
      'Missing public.users. Run supabase/role_based_upgrade.sql first.';
  end if;

  if to_regclass('public.listings') is null then
    raise exception
      'Missing public.listings. Run supabase/agent_roles_listings_storage.sql successfully before this script.';
  end if;

  if to_regclass('public.revenue_records') is null then
    raise exception
      'Missing public.revenue_records. Run supabase/role_based_upgrade.sql first.';
  end if;
end
$$;

-- -------------------------------------------------------------------
-- COMMISSION POLICY
-- -------------------------------------------------------------------
create table if not exists public.commission_policies (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  total_rate numeric(6,5) not null default 0.05000 check (total_rate >= 0 and total_rate <= 1),
  agent_share numeric(6,5) not null default 0.60000 check (agent_share >= 0 and agent_share <= 1),
  company_share numeric(6,5) not null default 0.40000 check (company_share >= 0 and company_share <= 1),
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (abs((agent_share + company_share) - 1) < 0.00001)
);

create or replace trigger trg_commission_policies_updated_at
before update on public.commission_policies
for each row
execute function public.set_updated_at();

insert into public.commission_policies (
  name,
  total_rate,
  agent_share,
  company_share,
  is_active
) values (
  'default_5_percent_split',
  0.05000,
  0.60000,
  0.40000,
  true
)
on conflict (name) do update
set
  total_rate = excluded.total_rate,
  agent_share = excluded.agent_share,
  company_share = excluded.company_share,
  is_active = true,
  updated_at = now();

-- Keep exactly one active policy.
with ranked as (
  select id,
         row_number() over (order by updated_at desc, created_at desc) as rn
  from public.commission_policies
  where is_active = true
)
update public.commission_policies p
set is_active = (r.rn = 1)
from ranked r
where p.id = r.id;

-- -------------------------------------------------------------------
-- LISTING COMMISSION LEDGER
-- -------------------------------------------------------------------
create table if not exists public.listing_commissions (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null unique references public.listings(id) on delete cascade,
  agent_id uuid not null references public.users(id) on delete cascade,
  close_status text not null check (close_status in ('sold', 'rented')),
  close_amount numeric(14,2) not null check (close_amount >= 0),
  total_commission numeric(14,2) not null check (total_commission >= 0),
  agent_commission numeric(14,2) not null check (agent_commission >= 0),
  company_commission numeric(14,2) not null check (company_commission >= 0),
  total_rate numeric(6,5) not null check (total_rate >= 0 and total_rate <= 1),
  agent_share numeric(6,5) not null check (agent_share >= 0 and agent_share <= 1),
  company_share numeric(6,5) not null check (company_share >= 0 and company_share <= 1),
  agent_payout_status text not null default 'pending' check (agent_payout_status in ('pending', 'processing', 'paid')),
  company_revenue_status text not null default 'recorded' check (company_revenue_status in ('recorded', 'settled')),
  closed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_listing_commissions_agent_id
on public.listing_commissions (agent_id, closed_at desc);

create index if not exists idx_listing_commissions_close_status
on public.listing_commissions (close_status, closed_at desc);

create or replace trigger trg_listing_commissions_updated_at
before update on public.listing_commissions
for each row
execute function public.set_updated_at();

-- -------------------------------------------------------------------
-- REVENUE RECORDS EXTENSIONS (COMPANY COMMISSION TRACEABILITY)
-- -------------------------------------------------------------------
alter table public.revenue_records
  add column if not exists listing_id uuid references public.listings(id) on delete set null,
  add column if not exists revenue_category text default 'general',
  add column if not exists notes text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'revenue_records_revenue_category_check'
      and conrelid = 'public.revenue_records'::regclass
  ) then
    alter table public.revenue_records
      add constraint revenue_records_revenue_category_check
      check (
        revenue_category in (
          'general',
          'company_commission',
          'verification_fees',
          'service_fees'
        )
      );
  end if;
exception
  when duplicate_object then null;
end
$$;

create index if not exists idx_revenue_records_listing_id
on public.revenue_records (listing_id);

create unique index if not exists idx_revenue_company_commission_unique
on public.revenue_records (listing_id, revenue_category)
where listing_id is not null and revenue_category = 'company_commission';

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'permissions'
  ) then
    insert into public.permissions (code, description) values
      ('commissions.read', 'View commission records'),
      ('commissions.manage', 'Manage commission records and payouts')
    on conflict (code) do nothing;
  end if;

  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'role_permissions'
  ) then
    insert into public.role_permissions (role, permission_code) values
      ('admin', 'commissions.read'),
      ('admin', 'commissions.manage'),
      ('agent', 'commissions.read')
    on conflict (role, permission_code) do nothing;
  end if;
end;
$$;

-- -------------------------------------------------------------------
-- HELPERS
-- -------------------------------------------------------------------
create or replace function public.refresh_agent_closed_deal_counts(p_agent_id uuid)
returns void
language plpgsql
as $$
declare
  v_closed_count integer := 0;
  v_recent_count integer := 0;
begin
  if p_agent_id is null then
    return;
  end if;

  if not exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'agent_profiles'
  ) then
    return;
  end if;

  select
    count(*)::integer,
    count(*) filter (
      where coalesce(updated_at, created_at) >= now() - interval '30 days'
    )::integer
  into v_closed_count, v_recent_count
  from public.listings
  where agent_id = p_agent_id
    and status in ('sold', 'rented');

  insert into public.agent_profiles (
    user_id,
    closed_deals_count,
    recent_deals_count,
    updated_at
  )
  values (
    p_agent_id,
    v_closed_count,
    v_recent_count,
    now()
  )
  on conflict (user_id) do update
  set
    closed_deals_count = excluded.closed_deals_count,
    recent_deals_count = excluded.recent_deals_count,
    updated_at = now();
end;
$$;

create or replace function public.recalculate_listing_commission(p_listing_id uuid)
returns void
language plpgsql
as $$
declare
  v_listing record;
  v_total_rate numeric(6,5) := 0.05000;
  v_agent_share numeric(6,5) := 0.60000;
  v_company_share numeric(6,5) := 0.40000;
  v_close_amount numeric(14,2) := 0;
  v_total_commission numeric(14,2) := 0;
  v_agent_commission numeric(14,2) := 0;
  v_company_commission numeric(14,2) := 0;
  v_record_date date := current_date;
  v_month text;
begin
  select
    id,
    agent_id,
    title,
    price,
    status,
    coalesce(updated_at, created_at, now()) as closed_at
  into v_listing
  from public.listings
  where id = p_listing_id;

  if not found then
    raise exception 'Listing % was not found.', p_listing_id;
  end if;

  if v_listing.status not in ('sold', 'rented') then
    delete from public.listing_commissions
    where listing_id = p_listing_id;

    delete from public.revenue_records
    where listing_id = p_listing_id
      and revenue_category = 'company_commission';

    perform public.refresh_agent_closed_deal_counts(v_listing.agent_id);
    return;
  end if;

  select
    total_rate,
    agent_share,
    company_share
  into
    v_total_rate,
    v_agent_share,
    v_company_share
  from public.commission_policies
  where is_active = true
  order by updated_at desc, created_at desc
  limit 1;

  v_total_rate := coalesce(v_total_rate, 0.05000);
  v_agent_share := coalesce(v_agent_share, 0.60000);
  v_company_share := coalesce(v_company_share, 0.40000);

  v_close_amount := coalesce(v_listing.price, 0);
  v_total_commission := round(v_close_amount * v_total_rate, 2);
  v_agent_commission := round(v_total_commission * v_agent_share, 2);
  v_company_commission := round(v_total_commission - v_agent_commission, 2);
  v_record_date := v_listing.closed_at::date;
  v_month := to_char(v_record_date, 'YYYY-MM');

  insert into public.listing_commissions (
    listing_id,
    agent_id,
    close_status,
    close_amount,
    total_commission,
    agent_commission,
    company_commission,
    total_rate,
    agent_share,
    company_share,
    closed_at
  )
  values (
    v_listing.id,
    v_listing.agent_id,
    v_listing.status,
    v_close_amount,
    v_total_commission,
    v_agent_commission,
    v_company_commission,
    v_total_rate,
    v_agent_share,
    v_company_share,
    v_listing.closed_at
  )
  on conflict (listing_id) do update
  set
    agent_id = excluded.agent_id,
    close_status = excluded.close_status,
    close_amount = excluded.close_amount,
    total_commission = excluded.total_commission,
    agent_commission = excluded.agent_commission,
    company_commission = excluded.company_commission,
    total_rate = excluded.total_rate,
    agent_share = excluded.agent_share,
    company_share = excluded.company_share,
    closed_at = excluded.closed_at,
    updated_at = now();

  insert into public.revenue_records (
    month,
    record_date,
    source,
    gross_amount,
    commission_rate,
    net_revenue,
    status,
    listing_id,
    revenue_category,
    notes
  )
  values (
    v_month,
    v_record_date,
    concat('Company commission from listing: ', coalesce(v_listing.title, v_listing.id::text)),
    v_company_commission,
    v_total_rate,
    v_company_commission,
    'received',
    v_listing.id,
    'company_commission',
    concat('Auto-calculated on close status: ', v_listing.status)
  )
  on conflict (listing_id, revenue_category)
  where (listing_id is not null and revenue_category = 'company_commission')
  do update
  set
    month = excluded.month,
    record_date = excluded.record_date,
    source = excluded.source,
    gross_amount = excluded.gross_amount,
    commission_rate = excluded.commission_rate,
    net_revenue = excluded.net_revenue,
    status = excluded.status,
    notes = excluded.notes,
    updated_at = now();

  perform public.refresh_agent_closed_deal_counts(v_listing.agent_id);
end;
$$;

-- -------------------------------------------------------------------
-- TRIGGER: AUTOMATE ON CLOSED DEAL STATUS
-- -------------------------------------------------------------------
create or replace function public.trg_sync_listing_commission()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if new.status in ('sold', 'rented') then
      perform public.recalculate_listing_commission(new.id);
    end if;
    return new;
  end if;

  if new.status is distinct from old.status
     or new.price is distinct from old.price
     or new.agent_id is distinct from old.agent_id then
    perform public.recalculate_listing_commission(new.id);

    if old.agent_id is distinct from new.agent_id then
      perform public.refresh_agent_closed_deal_counts(old.agent_id);
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_sync_listing_commission on public.listings;
create trigger trg_sync_listing_commission
after insert or update of status, price, agent_id
on public.listings
for each row
execute function public.trg_sync_listing_commission();

-- -------------------------------------------------------------------
-- COMMISSION VIEWS
-- -------------------------------------------------------------------
create or replace view public.listing_commission_summary as
select
  c.id,
  c.listing_id,
  l.title as listing_title,
  c.agent_id,
  u.username as agent_username,
  c.close_status,
  c.close_amount,
  c.total_commission,
  c.agent_commission,
  c.company_commission,
  c.agent_payout_status,
  c.company_revenue_status,
  c.closed_at
from public.listing_commissions c
left join public.listings l on l.id = c.listing_id
left join public.users u on u.id = c.agent_id;

create or replace view public.company_commission_monthly as
select
  to_char(closed_at, 'YYYY-MM') as month,
  count(*) as closed_deals,
  sum(close_amount)::numeric(14,2) as closed_deal_value,
  sum(agent_commission)::numeric(14,2) as total_agent_commission,
  sum(company_commission)::numeric(14,2) as total_company_commission
from public.listing_commissions
group by to_char(closed_at, 'YYYY-MM')
order by month desc;

-- -------------------------------------------------------------------
-- OPTIONAL BACKFILL FOR EXISTING CLOSED LISTINGS
-- -------------------------------------------------------------------
do $$
declare
  v_listing record;
begin
  for v_listing in
    select id
    from public.listings
    where status in ('sold', 'rented')
  loop
    perform public.recalculate_listing_commission(v_listing.id);
  end loop;
end;
$$;

-- -------------------------------------------------------------------
-- RLS FOR LISTING COMMISSIONS
-- -------------------------------------------------------------------
alter table public.listing_commissions enable row level security;

drop policy if exists listing_commissions_owner_admin_read on public.listing_commissions;
create policy listing_commissions_owner_admin_read
on public.listing_commissions
for select
using (
  agent_id = auth.uid()
  or exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.role = 'admin'
  )
);

drop policy if exists listing_commissions_admin_manage on public.listing_commissions;
create policy listing_commissions_admin_manage
on public.listing_commissions
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
