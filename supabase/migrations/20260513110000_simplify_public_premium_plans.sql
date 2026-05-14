alter table if exists public.ufficio_usage_counters
  add column if not exists problem_requests_used int not null default 0;

create or replace function public.increment_ufficio_usage_counter(
  counter_key text,
  delta_amount int default 1,
  target_user_id uuid default auth.uid()
)
returns public.ufficio_usage_counters
language plpgsql
security definer
set search_path = public
as $$
declare
  period_key_value text := to_char(date_trunc('month', now()), 'YYYY-MM');
  result_row public.ufficio_usage_counters;
begin
  if target_user_id is null then
    raise exception 'target_user_id is required';
  end if;

  if auth.uid() is distinct from target_user_id and not public.is_ufficio_admin() then
    raise exception 'not allowed';
  end if;

  insert into public.ufficio_usage_counters (
    user_id,
    period_key
  )
  values (
    target_user_id,
    period_key_value
  )
  on conflict (user_id, period_key) do nothing;

  update public.ufficio_usage_counters
  set
    generated_packs_used = generated_packs_used + case when counter_key = 'generated_packs_used' then delta_amount else 0 end,
    problem_requests_used = problem_requests_used + case when counter_key = 'problem_requests_used' then delta_amount else 0 end,
    saved_requests_used = saved_requests_used + case when counter_key = 'saved_requests_used' then delta_amount else 0 end,
    reminders_used = reminders_used + case when counter_key = 'reminders_used' then delta_amount else 0 end,
    documents_used = documents_used + case when counter_key = 'documents_used' then delta_amount else 0 end,
    contacts_used = contacts_used + case when counter_key = 'contacts_used' then delta_amount else 0 end,
    cost_items_used = cost_items_used + case when counter_key = 'cost_items_used' then delta_amount else 0 end,
    utility_comparisons_used = utility_comparisons_used + case when counter_key = 'utility_comparisons_used' then delta_amount else 0 end,
    bill_analyses_used = bill_analyses_used + case when counter_key = 'bill_analyses_used' then delta_amount else 0 end,
    household_members_used = household_members_used + case when counter_key = 'household_members_used' then delta_amount else 0 end,
    proof_cases_used = proof_cases_used + case when counter_key = 'proof_cases_used' then delta_amount else 0 end,
    consultancy_requests_used = consultancy_requests_used + case when counter_key = 'consultancy_requests_used' then delta_amount else 0 end,
    updated_at = now()
  where user_id = target_user_id
    and period_key = period_key_value
  returning * into result_row;

  return result_row;
end;
$$;

comment on function public.increment_ufficio_usage_counter(text, int, uuid) is
  'Server-backed usage counter increment for authenticated users and admins. Keeps premium/free limits out of client authority.';

insert into public.ufficio_plan_products (
  product_key,
  title,
  description,
  plan_type,
  billing_interval,
  amount_cents,
  currency,
  is_active,
  sort_order,
  features,
  limits,
  provider_metadata
)
values
  (
    'premium_monthly',
    '{"en":"Premium Monthly","it":"Premium mensile","fr":"Premium mensuel","es":"Premium mensual","fa":"پریمیوم ماهانه","ar":"بريميوم شهري"}'::jsonb,
    '{"en":"Full access to UfficioFacile guides, plus 2 problem requests and 2 private consultancies per month.","it":"Accesso completo alle guide di UfficioFacile, più 2 richieste problema e 2 consulenze private al mese.","fr":"Accès complet aux guides UfficioFacile, plus 2 demandes de problème et 2 consultations privées par mois.","es":"Acceso completo a las guías de UfficioFacile, más 2 solicitudes de problema y 2 consultorías privadas al mes.","fa":"دسترسی کامل به راهنماهای UfficioFacile، به‌علاوه ۲ درخواست مشکل و ۲ مشاوره خصوصی در هر ماه.","ar":"وصول كامل إلى أدلة UfficioFacile، بالإضافة إلى طلبي مشكلة واستشارتين خاصتين كل شهر."}'::jsonb,
    'subscription',
    'month',
    999,
    'EUR',
    true,
    1,
    '{"all_premium_guides":true,"problem_requests_per_month":2,"private_consultancies_per_month":2}'::jsonb,
    '{"problem_requests_per_month":2,"consultancy_included_per_month":2}'::jsonb,
    '{}'::jsonb
  ),
  (
    'premium_yearly',
    '{"en":"Premium Yearly","it":"Premium annuale","fr":"Premium annuel","es":"Premium anual","fa":"پریمیوم سالانه","ar":"بريميوم سنوي"}'::jsonb,
    '{"en":"Full access to UfficioFacile guides, plus 2 problem requests and 2 private consultancies per month.","it":"Accesso completo alle guide di UfficioFacile, più 2 richieste problema e 2 consulenze private al mese.","fr":"Accès complet aux guides UfficioFacile, plus 2 demandes de problème et 2 consultations privées par mois.","es":"Acceso completo a las guías de UfficioFacile, más 2 solicitudes de problema y 2 consultorías privadas al mes.","fa":"دسترسی کامل به راهنماهای UfficioFacile، به‌علاوه ۲ درخواست مشکل و ۲ مشاوره خصوصی در هر ماه.","ar":"وصول كامل إلى أدلة UfficioFacile، بالإضافة إلى طلبي مشكلة واستشارتين خاصتين كل شهر."}'::jsonb,
    'subscription',
    'year',
    7999,
    'EUR',
    true,
    2,
    '{"all_premium_guides":true,"problem_requests_per_month":2,"private_consultancies_per_month":2}'::jsonb,
    '{"problem_requests_per_month":2,"consultancy_included_per_month":2}'::jsonb,
    '{}'::jsonb
  )
on conflict (product_key) do update
set
  title = excluded.title,
  description = excluded.description,
  plan_type = excluded.plan_type,
  billing_interval = excluded.billing_interval,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  is_active = true,
  sort_order = excluded.sort_order,
  features = excluded.features,
  limits = excluded.limits,
  provider_metadata = coalesce(public.ufficio_plan_products.provider_metadata, '{}'::jsonb),
  updated_at = now();

update public.ufficio_plan_products
set
  is_active = false,
  updated_at = now()
where product_key in (
  'plus_monthly',
  'plus_yearly',
  'consultancy_one_shot',
  'subcategory_unlock',
  'lifetime',
  'trial',
  'pro',
  'consultant'
);

insert into public.ufficio_app_public_config (key, value)
values
  ('paywallEnabled', 'true'::jsonb),
  ('showPremiumBadges', 'true'::jsonb),
  ('problemRequestsPerMonth', '2'::jsonb),
  ('consultancyRequestsPerMonth', '2'::jsonb)
on conflict (key) do update
set value = excluded.value;
