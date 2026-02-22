-- Justice City - Owner/Renter Permission Seed
-- Run AFTER supabase/role_based_upgrade.sql has completed successfully.
-- Safe to run multiple times.
--
-- Why separate file?
-- PostgreSQL requires enum additions to be committed before they can be used.
-- In Supabase SQL editor (single transaction execution), using newly added
-- enum labels in the same run can fail with:
--   ERROR 55P04: unsafe use of new value ... of enum type user_role

do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_enum e on e.enumtypid = t.oid
    where t.typnamespace = 'public'::regnamespace
      and t.typname = 'user_role'
      and e.enumlabel = 'owner'
  ) then
    raise exception
      'Enum label owner is missing in public.user_role. Run supabase/role_based_upgrade.sql first and commit.';
  end if;

  if not exists (
    select 1
    from pg_type t
    join pg_enum e on e.enumtypid = t.oid
    where t.typnamespace = 'public'::regnamespace
      and t.typname = 'user_role'
      and e.enumlabel = 'renter'
  ) then
    raise exception
      'Enum label renter is missing in public.user_role. Run supabase/role_based_upgrade.sql first and commit.';
  end if;
end
$$;

insert into public.permissions (code, description) values
  ('chat.use', 'Use in-app chat and conversation features'),
  ('documents.read', 'View property documents and contracts'),
  ('billing.read', 'View bills and expense records'),
  ('billing.manage', 'Manage bills and expense records')
on conflict (code) do nothing;

insert into public.role_permissions (role, permission_code) values
  ('owner', 'chat.use'),
  ('owner', 'verifications.read'),
  ('owner', 'documents.read'),
  ('owner', 'billing.read'),
  ('owner', 'billing.manage'),
  ('renter', 'chat.use'),
  ('renter', 'verifications.read'),
  ('renter', 'documents.read'),
  ('renter', 'billing.read')
on conflict (role, permission_code) do nothing;
