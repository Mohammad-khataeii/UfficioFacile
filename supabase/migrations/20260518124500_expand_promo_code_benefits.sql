alter table public.ufficio_promo_codes
  add column if not exists promo_kind text not null default 'grant_entitlement',
  add column if not exists target_plan_keys text[] not null default array['premium_monthly','premium_yearly']::text[],
  add column if not exists discount_percent int,
  add column if not exists success_message text;

alter table public.ufficio_promo_codes
  drop constraint if exists ufficio_promo_codes_promo_kind_check;
alter table public.ufficio_promo_codes
  add constraint ufficio_promo_codes_promo_kind_check
  check (promo_kind in ('grant_entitlement', 'percent_discount'));

alter table public.ufficio_promo_codes
  drop constraint if exists ufficio_promo_codes_discount_percent_check;
alter table public.ufficio_promo_codes
  add constraint ufficio_promo_codes_discount_percent_check
  check (
    promo_kind <> 'percent_discount'
    or (discount_percent is not null and discount_percent between 1 and 100)
  );

alter table public.ufficio_promo_codes
  drop constraint if exists ufficio_promo_codes_target_plan_keys_check;
alter table public.ufficio_promo_codes
  add constraint ufficio_promo_codes_target_plan_keys_check
  check (
    array_length(target_plan_keys, 1) is not null
    and target_plan_keys <@ array['premium_monthly','premium_yearly']::text[]
  );

update public.ufficio_promo_codes
set promo_kind = coalesce(promo_kind, 'grant_entitlement'),
    target_plan_keys = coalesce(target_plan_keys, array['premium_monthly','premium_yearly']::text[]);

create or replace function public.redeem_ufficio_promo_code(input_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  target_user_id uuid := auth.uid();
  normalized_code text := upper(trim(coalesce(input_code, '')));
  promo_row public.ufficio_promo_codes%rowtype;
  redeemed_total int;
  existing_entitlement public.ufficio_user_entitlements%rowtype;
  next_start timestamptz := now();
  next_end timestamptz;
  next_plan text;
  applied_message text;
  target_plan_keys jsonb;
begin
  if target_user_id is null then
    return jsonb_build_object(
      'ok', false,
      'message', 'Log in to redeem a code.'
    );
  end if;

  if normalized_code = '' then
    return jsonb_build_object(
      'ok', false,
      'message', 'Enter a valid code.'
    );
  end if;

  select *
  into promo_row
  from public.ufficio_promo_codes
  where upper(code) = normalized_code
  limit 1;

  if not found or promo_row.is_active is not true then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is not active.'
    );
  end if;

  if promo_row.starts_at is not null and now() < promo_row.starts_at then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is not active yet.'
    );
  end if;

  if promo_row.ends_at is not null and now() > promo_row.ends_at then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code has expired.'
    );
  end if;

  if promo_row.assigned_user_id is not null and promo_row.assigned_user_id <> target_user_id then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is assigned to another account.'
    );
  end if;

  if exists (
    select 1
    from public.ufficio_promo_redemptions
    where promo_code_id = promo_row.id
      and user_id = target_user_id
      and status = 'redeemed'
  ) then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code was already used on this account.'
    );
  end if;

  redeemed_total := coalesce(promo_row.redeemed_count, 0);
  if promo_row.max_redemptions is not null and redeemed_total >= promo_row.max_redemptions then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code reached its usage limit.'
    );
  end if;

  select *
  into existing_entitlement
  from public.ufficio_user_entitlements
  where user_id = target_user_id
  limit 1;

  if promo_row.promo_kind = 'percent_discount' then
    applied_message := coalesce(
      nullif(trim(promo_row.success_message), ''),
      format(
        '%s%% off saved. It will be used on your next Premium checkout.',
        promo_row.discount_percent
      )
    );
    target_plan_keys := to_jsonb(coalesce(promo_row.target_plan_keys, array['premium_monthly','premium_yearly']::text[]));

    insert into public.ufficio_user_entitlements (
      user_id,
      plan,
      status,
      source,
      premium_access,
      metadata
    )
    values (
      target_user_id,
      coalesce(existing_entitlement.plan, 'free'),
      coalesce(existing_entitlement.status, 'active'),
      coalesce(existing_entitlement.source, 'promo_code'),
      coalesce(existing_entitlement.premium_access, false),
      jsonb_build_object(
        'active_checkout_discount',
        jsonb_build_object(
          'promo_code', promo_row.code,
          'promo_code_id', promo_row.id,
          'promo_kind', promo_row.promo_kind,
          'discount_percent', promo_row.discount_percent,
          'target_plan_keys', target_plan_keys,
          'redeemed_at', now()
        )
      )
    )
    on conflict (user_id) do update
    set metadata =
          coalesce(public.ufficio_user_entitlements.metadata, '{}'::jsonb) ||
          jsonb_build_object(
            'active_checkout_discount',
            jsonb_build_object(
              'promo_code', promo_row.code,
              'promo_code_id', promo_row.id,
              'promo_kind', promo_row.promo_kind,
              'discount_percent', promo_row.discount_percent,
              'target_plan_keys', target_plan_keys,
              'redeemed_at', now()
            )
          ),
        updated_at = now();

    insert into public.ufficio_promo_redemptions (
      promo_code_id,
      user_id,
      code,
      status,
      message,
      plan_key,
      expires_at,
      metadata
    )
    values (
      promo_row.id,
      target_user_id,
      promo_row.code,
      'redeemed',
      applied_message,
      null,
      null,
      jsonb_build_object(
        'promo_kind', promo_row.promo_kind,
        'discount_percent', promo_row.discount_percent,
        'target_plan_keys', target_plan_keys,
        'assigned_user_id', promo_row.assigned_user_id
      )
    );

    update public.ufficio_promo_codes
    set redeemed_count = coalesce(redeemed_count, 0) + 1,
        updated_at = now()
    where id = promo_row.id;

    perform public.log_ufficio_public_event(
      'promo_code_redeemed',
      target_user_id,
      'promo_code',
      jsonb_build_object(
        'code', promo_row.code,
        'promo_code_id', promo_row.id,
        'promo_kind', promo_row.promo_kind,
        'discount_percent', promo_row.discount_percent
      ),
      jsonb_build_object(
        'code', promo_row.code,
        'title', promo_row.title
      )
    );

    return jsonb_build_object(
      'ok', true,
      'message', applied_message,
      'promo_kind', promo_row.promo_kind,
      'discount_percent', promo_row.discount_percent,
      'target_plan_keys', target_plan_keys
    );
  end if;

  if found and existing_entitlement.current_period_end is not null and existing_entitlement.current_period_end > now() then
    next_start := existing_entitlement.current_period_end;
  else
    next_start := now();
  end if;

  next_end := next_start + make_interval(days => promo_row.duration_days);
  next_plan := promo_row.plan_key;
  applied_message := coalesce(
    nullif(trim(promo_row.success_message), ''),
    format(
      'Code applied successfully. Premium starts now and stays active until %s.',
      to_char(next_end at time zone 'UTC', 'DD Mon YYYY')
    )
  );

  insert into public.ufficio_user_entitlements (
    user_id,
    plan,
    status,
    source,
    premium_access,
    current_period_start,
    current_period_end,
    premium_since,
    metadata
  )
  values (
    target_user_id,
    next_plan,
    'active',
    'promo_code',
    true,
    now(),
    next_end,
    now(),
    jsonb_build_object(
      'promo_code', promo_row.code,
      'promo_code_id', promo_row.id,
      'promo_duration_days', promo_row.duration_days,
      'promo_kind', promo_row.promo_kind
    )
  )
  on conflict (user_id) do update
  set plan = excluded.plan,
      status = 'active',
      source = 'promo_code',
      premium_access = true,
      current_period_start = now(),
      current_period_end = greatest(
        coalesce(public.ufficio_user_entitlements.current_period_end, now()),
        next_end
      ),
      premium_since = coalesce(public.ufficio_user_entitlements.premium_since, now()),
      metadata = coalesce(public.ufficio_user_entitlements.metadata, '{}'::jsonb) || excluded.metadata,
      updated_at = now();

  insert into public.ufficio_promo_redemptions (
    promo_code_id,
    user_id,
    code,
    status,
    message,
    plan_key,
    expires_at,
    metadata
  )
  values (
    promo_row.id,
    target_user_id,
    promo_row.code,
    'redeemed',
    applied_message,
    next_plan,
    next_end,
    jsonb_build_object(
      'promo_title', promo_row.title,
      'assigned_user_id', promo_row.assigned_user_id,
      'promo_kind', promo_row.promo_kind
    )
  );

  update public.ufficio_promo_codes
  set redeemed_count = coalesce(redeemed_count, 0) + 1,
      updated_at = now()
  where id = promo_row.id;

  perform public.log_ufficio_public_event(
    'promo_code_redeemed',
    target_user_id,
    'promo_code',
    jsonb_build_object(
      'code', promo_row.code,
      'promo_code_id', promo_row.id,
      'duration_days', promo_row.duration_days,
      'plan', next_plan,
      'promo_kind', promo_row.promo_kind
    ),
    jsonb_build_object(
      'code', promo_row.code,
      'title', promo_row.title
    )
  );

  return jsonb_build_object(
    'ok', true,
    'message', applied_message,
    'plan', next_plan,
    'expires_at', next_end,
    'promo_kind', promo_row.promo_kind
  );
end;
$$;

grant execute on function public.redeem_ufficio_promo_code(text) to authenticated;
