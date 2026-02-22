-- Clear service-chat test data (DB rows only).
-- Safe to run multiple times.
--
-- This targets service conversations only:
-- - public.chat_conversations where scope = 'service'
-- - linked rows in service/transcript/attachment tables
--
-- Important:
-- Supabase blocks direct DELETE against storage.objects from SQL
-- (storage.protect_delete trigger). This script intentionally does not touch
-- storage.objects. Clean bucket files via the Storage API or Supabase dashboard.

begin;

create temporary table if not exists tmp_target_service_conversations (
  id uuid primary key
) on commit drop;

truncate table tmp_target_service_conversations;

insert into tmp_target_service_conversations (id)
select distinct c.id
from public.chat_conversations c
where c.scope = 'service'
union
select distinct sr.conversation_id
from public.service_request_records sr
where sr.conversation_id is not null;

-- Remove relational rows.
delete from public.conversation_file_attachments a
using tmp_target_service_conversations tc
where a.conversation_id = tc.id;

delete from public.conversation_transcripts t
using tmp_target_service_conversations tc
where t.conversation_id = tc.id;

delete from public.service_request_records sr
using tmp_target_service_conversations tc
where sr.conversation_id = tc.id;

-- Remove orphaned service request rows left from previous test runs.
delete from public.service_request_records sr
where sr.conversation_id is null
  and (
    sr.folder_root like 'Services/%'
    or lower(sr.folder_root) like 'services/%'
  );

-- Deleting conversations cascades to chat_messages and chat_conversation_members.
delete from public.chat_conversations c
using tmp_target_service_conversations tc
where c.id = tc.id;

commit;
