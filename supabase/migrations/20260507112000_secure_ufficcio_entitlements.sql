create or replace function public.ensure_ufficcio_entitlement_row()
returns public.ufficcio_entitlements
language plpgsql
security definer
set search_path = public
as $$
declare
  existing_row public.ufficcio_entitlements;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select *
  into existing_row
  from public.ufficcio_entitlements
  where user_id = auth.uid()
  limit 1;

  if existing_row.id is not null then
    return existing_row;
  end if;

  insert into public.ufficcio_entitlements (
    user_id,
    plan,
    status,
    free_pack_limit,
    free_packs_used,
    premium_access
  )
  values (
    auth.uid(),
    'free',
    'inactive',
    5,
    0,
    false
  )
  returning * into existing_row;

  return existing_row;
end;
$$;

drop policy if exists "ufficcio_entitlements_own_all" on public.ufficcio_entitlements;
drop policy if exists "ufficcio_entitlements_read_own" on public.ufficcio_entitlements;
create policy "ufficcio_entitlements_read_own"
on public.ufficcio_entitlements
for select
to authenticated
using (user_id = auth.uid() or public.is_ufficcio_admin());

drop policy if exists "ufficcio_entitlements_admin_write" on public.ufficcio_entitlements;
create policy "ufficcio_entitlements_admin_write"
on public.ufficcio_entitlements
for all
to authenticated
using (public.is_ufficcio_admin())
with check (public.is_ufficcio_admin());
