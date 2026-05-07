import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@15.12.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

serve(async (request) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const appBaseUrl = Deno.env.get("APP_BASE_URL") ?? "";
  const stripePriceId = Deno.env.get("STRIPE_PREMIUM_PRICE_ID") ?? "";

  if (request.method != "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "content-type": "application/json" },
    });
  }

  if (!supabaseUrl || !serviceRoleKey || !stripeKey || !appBaseUrl || !stripePriceId) {
    return new Response(
      JSON.stringify({ error: "Stripe checkout is not configured yet." }),
      { status: 503, headers: { "content-type": "application/json" } },
    );
  }

  const authHeader = request.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "content-type": "application/json" },
    });
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "content-type": "application/json" },
    });
  }

  const stripe = new Stripe(stripeKey, { apiVersion: "2024-04-10" });
  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    success_url: `${appBaseUrl}/?checkout=success`,
    cancel_url: `${appBaseUrl}/?checkout=cancel`,
    customer_email: user.email ?? undefined,
    line_items: [
      {
        price: stripePriceId,
        quantity: 1,
      },
    ],
    metadata: {
      user_id: user.id,
      product: "ufficiofacile_premium",
    },
  });

  return new Response(JSON.stringify({ url: session.url }), {
    headers: { "content-type": "application/json" },
  });
});
