-- Normalize service chat folder roots to the canonical structure:
-- Services/<Service-Label>/<Requester-User-Id>/<Conversation-Id>
-- Safe to run multiple times.
--
-- Note:
-- This updates DB metadata paths only. Existing storage objects already uploaded
-- under old prefixes are not moved by SQL and should be re-uploaded or moved via storage API.

with normalized as (
  select
    sr.id as service_request_id,
    sr.conversation_id,
    sr.service_code,
    sr.requester_id,
    case
      when sr.service_code = 'land_surveying' then 'Land-Surveying'
      when sr.service_code = 'snagging' then 'Snagging'
      when sr.service_code = 'real_estate_valuation' then 'Property-Valuation'
      when sr.service_code = 'land_verification' then 'Land-Verification'
      when sr.service_code = 'general_service' then 'General-Service'
      else initcap(replace(coalesce(sr.service_code, 'general_service'), '_', '-'))
    end as service_segment
  from public.service_request_records sr
  where sr.conversation_id is not null
    and sr.requester_id is not null
),
paths as (
  select
    n.service_request_id,
    n.conversation_id,
    n.service_code,
    concat(
      'Services/',
      n.service_segment,
      '/',
      n.requester_id::text,
      '/',
      n.conversation_id::text
    ) as folder_root
  from normalized n
)
update public.service_request_records sr
set
  folder_root = p.folder_root,
  updated_at = now()
from paths p
where sr.id = p.service_request_id
  and sr.folder_root is distinct from p.folder_root;

with normalized as (
  select
    sr.id as service_request_id,
    sr.conversation_id,
    sr.service_code,
    sr.requester_id,
    case
      when sr.service_code = 'land_surveying' then 'Land-Surveying'
      when sr.service_code = 'snagging' then 'Snagging'
      when sr.service_code = 'real_estate_valuation' then 'Property-Valuation'
      when sr.service_code = 'land_verification' then 'Land-Verification'
      when sr.service_code = 'general_service' then 'General-Service'
      else initcap(replace(coalesce(sr.service_code, 'general_service'), '_', '-'))
    end as service_segment
  from public.service_request_records sr
  where sr.conversation_id is not null
    and sr.requester_id is not null
),
paths as (
  select
    n.conversation_id,
    n.service_code,
    concat(
      'Services/',
      n.service_segment,
      '/',
      n.requester_id::text,
      '/',
      n.conversation_id::text
    ) as folder_root
  from normalized n
)
update public.chat_conversations c
set
  scope = 'service',
  service_type = coalesce(p.service_code, c.service_type),
  record_folder = concat(p.folder_root, '/chat'),
  updated_at = now()
from paths p
where c.id = p.conversation_id
  and (
    c.scope is distinct from 'service'
    or c.service_type is distinct from p.service_code
    or c.record_folder is distinct from concat(p.folder_root, '/chat')
  );

with normalized as (
  select
    sr.id as service_request_id,
    sr.conversation_id,
    sr.service_code,
    sr.requester_id,
    case
      when sr.service_code = 'land_surveying' then 'Land-Surveying'
      when sr.service_code = 'snagging' then 'Snagging'
      when sr.service_code = 'real_estate_valuation' then 'Property-Valuation'
      when sr.service_code = 'land_verification' then 'Land-Verification'
      when sr.service_code = 'general_service' then 'General-Service'
      else initcap(replace(coalesce(sr.service_code, 'general_service'), '_', '-'))
    end as service_segment
  from public.service_request_records sr
  where sr.conversation_id is not null
    and sr.requester_id is not null
),
paths as (
  select
    n.conversation_id,
    concat(
      'Services/',
      n.service_segment,
      '/',
      n.requester_id::text,
      '/',
      n.conversation_id::text
    ) as folder_root
  from normalized n
)
insert into public.conversation_transcripts (
  conversation_id,
  transcript_format,
  bucket_id,
  storage_path,
  generated_at
)
select
  p.conversation_id,
  'pdf',
  'conversation-transcripts',
  concat(p.folder_root, '/transcripts/', p.conversation_id::text, '.pdf'),
  now()
from paths p
where not exists (
  select 1
  from public.conversation_transcripts t
  where t.conversation_id = p.conversation_id
);

with normalized as (
  select
    sr.id as service_request_id,
    sr.conversation_id,
    sr.service_code,
    sr.requester_id,
    case
      when sr.service_code = 'land_surveying' then 'Land-Surveying'
      when sr.service_code = 'snagging' then 'Snagging'
      when sr.service_code = 'real_estate_valuation' then 'Property-Valuation'
      when sr.service_code = 'land_verification' then 'Land-Verification'
      when sr.service_code = 'general_service' then 'General-Service'
      else initcap(replace(coalesce(sr.service_code, 'general_service'), '_', '-'))
    end as service_segment
  from public.service_request_records sr
  where sr.conversation_id is not null
    and sr.requester_id is not null
),
paths as (
  select
    n.conversation_id,
    concat(
      'Services/',
      n.service_segment,
      '/',
      n.requester_id::text,
      '/',
      n.conversation_id::text
    ) as folder_root
  from normalized n
)
update public.conversation_transcripts t
set
  transcript_format = 'pdf',
  bucket_id = 'conversation-transcripts',
  storage_path = concat(p.folder_root, '/transcripts/', p.conversation_id::text, '.pdf'),
  generated_at = coalesce(t.generated_at, now())
from paths p
where t.conversation_id = p.conversation_id
  and (
    t.bucket_id is distinct from 'conversation-transcripts'
    or t.storage_path is distinct from concat(p.folder_root, '/transcripts/', p.conversation_id::text, '.pdf')
  );
