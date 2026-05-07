import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@15.12.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

serve(async (request) => {
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!stripeKey || !webhookSecret || !supabaseUrl || !serviceRoleKey) {
    return new Response("Webhook is not configured.", { status: 503 });
  }

  const signature = request.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing signature", { status: 400 });
  }

  const body = await request.text();
  const stripe = new Stripe(stripeKey, { apiVersion: "2024-04-10" });
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret);
  } catch (error) {
    return new Response(`Signature verification failed: ${error}`, { status: 400 });
  }

  if (
    event.type === "checkout.session.completed" ||
    event.type === "customer.subscription.updated" ||
    event.type === "customer.subscription.deleted"
  ) {
    const object = event.data.object as Stripe.Checkout.Session | Stripe.Subscription;
    const userId = object.metadata?.user_id;
    if (userId) {
      const plan = event.type === "customer.subscription.deleted" ? "free" : "premium";
      const status = event.type === "customer.subscription.deleted" ? "canceled" : "active";
      const currentPeriodEndUnix =
        "current_period_end" in object ? object.current_period_end : undefined;
      const currentPeriodEnd = currentPeriodEndUnix
        ? new Date(currentPeriodEndUnix * 1000).toISOString()
        : null;
      const customerId =
        typeof object.customer === "string" ? object.customer : object.customer?.id ?? null;
      const subscriptionId =
        "subscription" in object && typeof object.subscription === "string"
          ? object.subscription
          : "id" in object
          ? object.id
          : null;

      await supabase.from("ufficio_user_entitlements").upsert({
        user_id: userId,
        plan,
        status,
        source: "stripe",
        stripe_customer_id: customerId,
        stripe_subscription_id: subscriptionId,
        current_period_end: currentPeriodEnd,
        premium_since: event.type === "customer.subscription.deleted"
          ? null
          : new Date().toISOString(),
        metadata: { event_type: event.type },
      });

      await supabase.from("ufficio_premium_events").insert({
        user_id: userId,
        event_type: event.type,
        source: "stripe",
        payload: event,
      });
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "content-type": "application/json" },
  });
});
