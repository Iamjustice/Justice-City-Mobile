-- Justice City - Supabase reset script
-- WARNING: This deletes ALL objects and data in the `public` schema.
-- Run this first in Supabase SQL Editor, then run `supabase/schema.sql`.

drop schema if exists public cascade;
create schema public;

grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres, service_role;

-- Keep default privileges aligned for tables/sequences/functions created later.
alter default privileges in schema public
grant all on tables to postgres, service_role;

alter default privileges in schema public
grant all on sequences to postgres, service_role;

alter default privileges in schema public
grant all on functions to postgres, service_role;
