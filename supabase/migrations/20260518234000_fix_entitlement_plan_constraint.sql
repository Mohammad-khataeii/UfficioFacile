alter table if exists public.ufficio_user_entitlements
  drop constraint if exists ufficio_user_entitlements_plan_check;

alter table if exists public.ufficio_user_entitlements
  drop constraint if exists ufficcio_entitlements_plan_check;

alter table if exists public.ufficio_user_entitlements
  drop constraint if exists ufficio_user_entitlements_plan_check_v2;

alter table if exists public.ufficio_user_entitlements
  add constraint ufficio_user_entitlements_plan_check_v3
  check (
    plan in (
      'free',
      'premium',
      'plus_monthly',
      'plus_yearly',
      'pro',
      'consultant',
      'premium_monthly',
      'premium_yearly',
      'consultancy_one_shot',
      'admin_grant',
      'lifetime',
      'trial',
      'admin'
    )
  );
