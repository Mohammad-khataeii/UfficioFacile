import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@15.12.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type CheckoutRequest = {
  product_key?: string;
  category_slug?: string;
  procedure_slug?: string;
};

const allowedPlanProductKeys = new Set(["premium_monthly", "premium_yearly"]);

const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json",
      ...corsHeaders,
    },
  });
}

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const appBaseUrl = Deno.env.get("APP_BASE_URL") ?? "";

  if (!supabaseUrl || !serviceRoleKey || !stripeKey || !appBaseUrl) {
    return json({ error: "Stripe checkout is not configured yet." }, 503);
  }

  const authHeader = request.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Unauthorized" }, 401);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return json({ error: "Unauthorized" }, 401);
  }

  const body = (await request.json().catch(() => ({}))) as CheckoutRequest;
  const productKey = (body.product_key ?? "").trim();
  if (!productKey) {
    return json({ error: "product_key is required" }, 400);
  }
  if (!allowedPlanProductKeys.has(productKey)) {
    return json({ error: "This product is not available for checkout." }, 400);
  }

  const { data: product, error: productError } = await supabase
    .from("ufficio_plan_products")
    .select("*")
    .eq("product_key", productKey)
    .eq("is_active", true)
    .maybeSingle();
  if (productError || !product) {
    return json({ error: "Unknown or inactive product." }, 400);
  }

  const stripe = new Stripe(stripeKey, { apiVersion: "2024-04-10" });
  const providerMetadata =
    product.provider_metadata && typeof product.provider_metadata === "object"
      ? product.provider_metadata
      : {};
  const stripePriceId =
    (product.stripe_price_id as string | null) ??
    (providerMetadata.stripe_price_id as string | undefined) ??
    "";
  const mode =
    product.plan_type === "subscription" ||
    product.billing_interval === "month" ||
    product.billing_interval === "year"
      ? "subscription"
      : "payment";

  const { data: entitlement } = await supabase
    .from("ufficio_user_entitlements")
    .select("stripe_customer_id")
    .eq("user_id", user.id)
    .maybeSingle();

  const metadata = {
    user_id: user.id,
    product_key: productKey,
    category_slug: body.category_slug ?? "",
    procedure_slug: body.procedure_slug ?? "",
  };

  const lineItems = stripePriceId
    ? [{ price: stripePriceId, quantity: 1 }]
    : [
        {
          price_data: {
            currency: (product.currency as string | null)?.toLowerCase() ?? "eur",
            product_data: {
              name:
                (product.title?.en as string | undefined) ??
                (product.product_key as string),
            },
            unit_amount: (product.amount_cents as number | null) ?? 0,
            recurring:
              mode === "subscription"
                ? {
                    interval:
                      product.billing_interval === "year" ? "year" : "month",
                  }
                : undefined,
          },
          quantity: 1,
        },
      ];

  const session = await stripe.checkout.sessions.create({
    mode,
    success_url: `${appBaseUrl}/?checkout=success`,
    cancel_url: `${appBaseUrl}/?checkout=cancel`,
    customer: (entitlement?.stripe_customer_id as string | null) ?? undefined,
    customer_email:
      (entitlement?.stripe_customer_id as string | null) == null
        ? user.email ?? undefined
        : undefined,
    client_reference_id: user.id,
    line_items: lineItems,
    metadata,
    subscription_data:
      mode === "subscription"
        ? {
            metadata,
          }
        : undefined,
    payment_intent_data:
      mode === "payment"
        ? {
            metadata,
          }
        : undefined,
  });

  await supabase.from("ufficio_payment_events").insert({
    user_id: user.id,
    provider: "stripe",
    event_id: session.id,
    event_type: "checkout.session.created",
    product_key: productKey,
    product_type: product.plan_type,
    category_slug: body.category_slug ?? null,
    procedure_slug: body.procedure_slug ?? null,
    amount_cents: product.amount_cents ?? null,
    currency: product.currency ?? "EUR",
    status: "created",
    raw_payload: {
      mode,
      checkout_url: session.url,
      stripe_price_id: stripePriceId || null,
    },
    processed_at: new Date().toISOString(),
  });

  return json({
    url: session.url,
    checkout_url: session.url,
    session_id: session.id,
  });
});
