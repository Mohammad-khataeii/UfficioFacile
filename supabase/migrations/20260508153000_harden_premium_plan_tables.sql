create extension if not exists pgcrypto;

create table if not exists public.ufficio_plan_products (
  id uuid primary key default gen_random_uuid(),
  product_key text unique not null,
  title jsonb not null default '{}'::jsonb,
  description jsonb not null default '{}'::jsonb,
  plan_type text not null default 'free',
  billing_interval text not null default 'none',
  amount_cents int not null default 0,
  currency text not null default 'EUR',
  is_active boolean not null default true,
  sort_order int not null default 0,
  features jsonb not null default '{}'::jsonb,
  limits jsonb not null default '{}'::jsonb,
  provider_metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table if exists public.ufficio_plan_products
  alter column title set default '{}'::jsonb,
  alter column description set default '{}'::jsonb,
  alter column plan_type set default 'free',
  alter column billing_interval set default 'none',
  alter column amount_cents set default 0,
  alter column currency set default 'EUR',
  alter column is_active set default true,
  alter column sort_order set default 0,
  alter column features set default '{}'::jsonb,
  alter column limits set default '{}'::jsonb,
  alter column provider_metadata set default '{}'::jsonb;

alter table if exists public.ufficio_user_entitlements
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists plan text not null default 'free',
  add column if not exists status text not null default 'active',
  add column if not exists source text not null default 'system',
  add column if not exists premium_access boolean not null default false,
  add column if not exists current_period_start timestamptz,
  add column if not exists current_period_end timestamptz,
  add column if not exists trial_end timestamptz,
  add column if not exists cancelled_at timestamptz,
  add column if not exists revoked_at timestamptz,
  add column if not exists provider text,
  add column if not exists provider_customer_id text,
  add column if not exists provider_subscription_id text,
  add column if not exists provider_product_id text,
  add column if not exists provider_price_id text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create table if not exists public.ufficio_usage_counters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  period_key text not null,
  generated_packs_used int not null default 0,
  saved_requests_used int not null default 0,
  documents_used int not null default 0,
  contacts_used int not null default 0,
  cost_items_used int not null default 0,
  consultancy_requests_used int not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, period_key)
);

create table if not exists public.ufficio_payment_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  provider text not null default 'manual',
  event_id text,
  event_type text not null,
  product_key text,
  product_type text,
  category_slug text,
  procedure_slug text,
  amount_cents int,
  currency text default 'EUR',
  status text,
  raw_payload jsonb not null default '{}'::jsonb,
  processed_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_ufficio_payment_events_provider_event_v2
  on public.ufficio_payment_events(provider, event_id)
  where event_id is not null;

create table if not exists public.ufficio_user_content_unlocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_slug text not null,
  procedure_slug text not null,
  unlock_type text not null default 'single_purchase',
  status text not null default 'active',
  product_key text not null default 'subcategory_unlock',
  amount_cents int,
  currency text not null default 'EUR',
  provider text,
  provider_payment_id text,
  provider_checkout_id text,
  purchased_at timestamptz,
  expires_at timestamptz,
  revoked_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, category_slug, procedure_slug)
);

create table if not exists public.ufficio_consultancy_payments (
  id uuid primary key default gen_random_uuid(),
  consultancy_request_id uuid references public.ufficio_consultancy_requests(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  product_key text not null default 'consultancy_one_shot',
  status text not null default 'required',
  amount_cents int,
  currency text default 'EUR',
  provider text,
  provider_checkout_id text,
  provider_payment_id text,
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficio_premium_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  actor_user_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  plan text,
  source text,
  provider text,
  provider_event_id text,
  amount_cents int,
  currency text default 'EUR',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table if exists public.ufficio_premium_events
  add column if not exists user_id uuid references auth.users(id) on delete set null,
  add column if not exists actor_user_id uuid references auth.users(id) on delete set null,
  add column if not exists event_type text,
  add column if not exists plan text,
  add column if not exists source text,
  add column if not exists provider text,
  add column if not exists provider_event_id text,
  add column if not exists amount_cents int,
  add column if not exists currency text default 'EUR',
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now();

create or replace function public.user_has_premium(target_user_id uuid default auth.uid())
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.ufficio_user_entitlements
    where user_id = target_user_id
      and status in ('active', 'trialing')
      and revoked_at is null
      and (current_period_end is null or current_period_end >= now())
      and (
        premium_access = true
        or plan in ('plus_monthly', 'plus_yearly', 'premium_monthly', 'premium_yearly', 'admin_grant')
      )
  );
$$;

create or replace function public.user_has_content_unlock(
  target_category_slug text,
  target_procedure_slug text,
  target_user_id uuid default auth.uid()
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.user_has_premium(target_user_id)
    or exists (
      select 1
      from public.ufficio_user_content_unlocks
      where user_id = target_user_id
        and category_slug = target_category_slug
        and procedure_slug = target_procedure_slug
        and status = 'active'
        and revoked_at is null
        and (expires_at is null or expires_at >= now())
    );
$$;

alter table public.ufficio_plan_products enable row level security;
alter table public.ufficio_user_entitlements enable row level security;
alter table public.ufficio_usage_counters enable row level security;
alter table public.ufficio_user_content_unlocks enable row level security;
alter table public.ufficio_premium_events enable row level security;
alter table public.ufficio_payment_events enable row level security;
alter table public.ufficio_consultancy_payments enable row level security;

drop policy if exists "plan_products_public_read_v2" on public.ufficio_plan_products;
create policy "plan_products_public_read_v2"
on public.ufficio_plan_products for select to anon, authenticated
using (is_active = true);

drop policy if exists "plan_products_admin_all_v2" on public.ufficio_plan_products;
create policy "plan_products_admin_all_v2"
on public.ufficio_plan_products for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "entitlements_read_own_v2" on public.ufficio_user_entitlements;
create policy "entitlements_read_own_v2"
on public.ufficio_user_entitlements for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "entitlements_admin_write_v2" on public.ufficio_user_entitlements;
create policy "entitlements_admin_write_v2"
on public.ufficio_user_entitlements for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "usage_counters_read_own_v2" on public.ufficio_usage_counters;
create policy "usage_counters_read_own_v2"
on public.ufficio_usage_counters for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "usage_counters_admin_all_v2" on public.ufficio_usage_counters;
create policy "usage_counters_admin_all_v2"
on public.ufficio_usage_counters for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "content_unlocks_read_own_v2" on public.ufficio_user_content_unlocks;
create policy "content_unlocks_read_own_v2"
on public.ufficio_user_content_unlocks for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "content_unlocks_admin_all_v2" on public.ufficio_user_content_unlocks;
create policy "content_unlocks_admin_all_v2"
on public.ufficio_user_content_unlocks for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "premium_events_read_own_v2" on public.ufficio_premium_events;
create policy "premium_events_read_own_v2"
on public.ufficio_premium_events for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "premium_events_admin_all_v2" on public.ufficio_premium_events;
create policy "premium_events_admin_all_v2"
on public.ufficio_premium_events for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "payment_events_admin_all_v2" on public.ufficio_payment_events;
create policy "payment_events_admin_all_v2"
on public.ufficio_payment_events for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "consultancy_payments_read_own_v2" on public.ufficio_consultancy_payments;
create policy "consultancy_payments_read_own_v2"
on public.ufficio_consultancy_payments for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "consultancy_payments_admin_all_v2" on public.ufficio_consultancy_payments;
create policy "consultancy_payments_admin_all_v2"
on public.ufficio_consultancy_payments for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create index if not exists idx_ufficio_usage_counters_user_period_v2
  on public.ufficio_usage_counters(user_id, period_key);
create index if not exists idx_ufficio_user_content_unlocks_user_v2
  on public.ufficio_user_content_unlocks(user_id);
create index if not exists idx_ufficio_user_content_unlocks_target_v2
  on public.ufficio_user_content_unlocks(category_slug, procedure_slug);
create index if not exists idx_ufficio_user_content_unlocks_status_v2
  on public.ufficio_user_content_unlocks(status);

insert into public.ufficio_plan_products (
  product_key, title, description, plan_type, billing_interval, amount_cents, currency, is_active, sort_order, features, limits
)
values
  ('free','{"en":"Free","it":"Gratis","fr":"Gratuit","es":"Gratis","fa":"رایگان","ar":"مجاني"}'::jsonb,'{"en":"Basic access with limits.","it":"Accesso base con limiti.","fr":"Accès de base avec limites.","es":"Acceso básico con límites.","fa":"دسترسی پایه با محدودیت.","ar":"وصول أساسي مع حدود."}'::jsonb,'free','none',0,'EUR',true,0,'{"premium_sections":false,"priority_requests":false}'::jsonb,'{"generated_packs_per_month":3,"saved_requests_limit":5,"documents_limit":5,"contacts_limit":5,"cost_items_limit":5,"consultancy_included_per_month":0}'::jsonb),
  ('plus_monthly','{"en":"Plus Monthly","it":"Plus mensile","fr":"Plus mensuel","es":"Plus mensual","fa":"پلاس ماهانه","ar":"بلس شهري"}'::jsonb,'{"en":"More usage, priority requests, and expanded tools.","it":"Più utilizzo, richieste prioritarie e strumenti estesi.","fr":"Plus d’utilisations, demandes prioritaires et outils étendus.","es":"Más uso, solicitudes prioritarias y herramientas ampliadas.","fa":"استفاده بیشتر، درخواست‌های اولویت‌دار و ابزارهای گسترده‌تر.","ar":"استخدام أكثر وطلبات ذات أولوية وأدوات موسعة."}'::jsonb,'subscription','month',499,'EUR',true,1,'{"premium_sections":false,"priority_requests":true}'::jsonb,'{"generated_packs_per_month":20,"saved_requests_limit":50,"documents_limit":50,"contacts_limit":50,"cost_items_limit":50,"consultancy_included_per_month":0}'::jsonb),
  ('plus_yearly','{"en":"Plus Yearly","it":"Plus annuale","fr":"Plus annuel","es":"Plus anual","fa":"پلاس سالانه","ar":"بلس سنوي"}'::jsonb,'{"en":"One-year Plus access with better value.","it":"Accesso Plus per un anno con prezzo migliore.","fr":"Accès Plus d’un an avec meilleur prix.","es":"Acceso Plus de un año con mejor valor.","fa":"دسترسی پلاس یک‌ساله با ارزش بهتر.","ar":"وصول بلس لمدة سنة بقيمة أفضل."}'::jsonb,'subscription','year',3999,'EUR',true,2,'{"premium_sections":false,"priority_requests":true}'::jsonb,'{"generated_packs_per_month":20,"saved_requests_limit":50,"documents_limit":50,"contacts_limit":50,"cost_items_limit":50,"consultancy_included_per_month":0}'::jsonb),
  ('premium_monthly','{"en":"Premium Monthly","it":"Premium mensile","fr":"Premium mensuel","es":"Premium mensual","fa":"پریمیوم ماهانه","ar":"بريميوم شهري"}'::jsonb,'{"en":"Full premium access each month.","it":"Accesso premium completo ogni mese.","fr":"Accès premium complet chaque mois.","es":"Acceso premium completo cada mes.","fa":"دسترسی کامل پریمیوم در هر ماه.","ar":"وصول بريميوم كامل كل شهر."}'::jsonb,'subscription','month',999,'EUR',true,3,'{"premium_sections":true,"priority_requests":true}'::jsonb,'{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb),
  ('premium_yearly','{"en":"Premium Yearly","it":"Premium annuale","fr":"Premium annuel","es":"Premium anual","fa":"پریمیوم سالانه","ar":"بريميوم سنوي"}'::jsonb,'{"en":"Full premium access for one year.","it":"Accesso premium completo per un anno.","fr":"Accès premium complet pendant un an.","es":"Acceso premium completo durante un año.","fa":"دسترسی کامل پریمیوم برای یک سال.","ar":"وصول بريميوم كامل لمدة سنة."}'::jsonb,'subscription','year',7999,'EUR',true,4,'{"premium_sections":true,"priority_requests":true}'::jsonb,'{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb),
  ('subcategory_unlock','{"en":"Single Guide Unlock","it":"Sblocco guida singola","fr":"Déblocage d’un guide","es":"Desbloqueo de una guía","fa":"باز کردن یک راهنما","ar":"فتح دليل واحد"}'::jsonb,'{"en":"Pay once to unlock one premium guide.","it":"Paga una volta per sbloccare una guida premium.","fr":"Payez une fois pour débloquer un guide premium.","es":"Paga una vez para desbloquear una guía premium.","fa":"برای باز کردن یک راهنمای پریمیوم یک بار پرداخت کن.","ar":"ادفع مرة واحدة لفتح دليل بريميوم واحد."}'::jsonb,'one_time','one_time',399,'EUR',true,5,'{"unlocks_single_procedure":true}'::jsonb,'{"procedure_count":1}'::jsonb),
  ('consultancy_one_shot','{"en":"One-shot Consultancy","it":"Consulenza una tantum","fr":"Consultation ponctuelle","es":"Consultoría puntual","fa":"مشاوره تک‌مرحله‌ای","ar":"استشارة لمرة واحدة"}'::jsonb,'{"en":"Pay once for one private consultancy request.","it":"Paga una volta per una richiesta di consulenza privata.","fr":"Payez une fois pour une demande de consultation privée.","es":"Paga una vez por una solicitud de consultoría privada.","fa":"برای یک درخواست مشاوره خصوصی یک بار پرداخت کن.","ar":"ادفع مرة واحدة مقابل طلب استشارة خاصة."}'::jsonb,'one_time','one_time',1499,'EUR',true,6,'{"private_consultancy":true}'::jsonb,'{"procedure_count":1}'::jsonb),
  ('admin_grant','{"en":"Admin Grant","it":"Grant admin","fr":"Attribution admin","es":"Concesión admin","fa":"اعطای ادمین","ar":"منح إداري"}'::jsonb,'{"en":"Internal administrative entitlement grant.","it":"Concessione interna amministrativa.","fr":"Attribution administrative interne.","es":"Concesión administrativa interna.","fa":"اعطای داخلی مدیریتی.","ar":"منح إداري داخلي."}'::jsonb,'admin_only','none',0,'EUR',true,7,'{"premium_sections":true,"priority_requests":true}'::jsonb,'{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb)
on conflict (product_key) do update
set
  title = excluded.title,
  description = excluded.description,
  plan_type = excluded.plan_type,
  billing_interval = excluded.billing_interval,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  features = excluded.features,
  limits = excluded.limits;
