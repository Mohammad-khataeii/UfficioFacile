import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@15.12.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function stripeStatusToEntitlementStatus(
  status: string | null | undefined,
): string {
  switch (status) {
    case "trialing":
      return "trialing";
    case "active":
      return "active";
    case "past_due":
    case "unpaid":
      return "past_due";
    case "canceled":
    case "cancelled":
      return "cancelled";
    case "incomplete_expired":
      return "expired";
    default:
      return "active";
  }
}

async function resolveUserIdForObject(
  supabase: ReturnType<typeof createClient>,
  object:
    | Stripe.Checkout.Session
    | Stripe.Subscription
    | Stripe.Invoice
    | Stripe.PaymentIntent,
) {
  const metadataUserId = object.metadata?.user_id?.trim();
  if (metadataUserId) {
    return metadataUserId;
  }

  const customerId =
    typeof object.customer === "string" ? object.customer : object.customer?.id;
  if (customerId) {
    const { data } = await supabase
      .from("ufficio_user_entitlements")
      .select("user_id")
      .eq("stripe_customer_id", customerId)
      .maybeSingle();
    if (data?.user_id) {
      return data.user_id as string;
    }
  }

  const subscriptionId =
    "subscription" in object && typeof object.subscription === "string"
      ? object.subscription
      : "id" in object
      ? object.id
      : null;
  if (subscriptionId) {
    const { data } = await supabase
      .from("ufficio_user_entitlements")
      .select("user_id")
      .eq("stripe_subscription_id", subscriptionId)
      .maybeSingle();
    if (data?.user_id) {
      return data.user_id as string;
    }
  }

  return null;
}

async function logStripeEvent(
  supabase: ReturnType<typeof createClient>,
  event: Stripe.Event,
  values: {
    user_id?: string | null;
    plan?: string | null;
    source?: string | null;
    metadata?: Record<string, unknown>;
  },
) {
  const { error } = await supabase.from("ufficio_premium_events").insert({
    user_id: values.user_id ?? null,
    actor_user_id: null,
    event_type: event.type,
    plan: values.plan ?? null,
    source: values.source ?? "stripe",
    stripe_event_id: event.id,
    metadata: {
      stripe_created: event.created,
      ...values.metadata,
    },
  });

  if (error && `${error.code}` === "23505") {
    return false;
  }
  if (error) {
    throw error;
  }
  return true;
}

serve(async (request) => {
  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY") ?? "";
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (!stripeKey || !webhookSecret || !supabaseUrl || !serviceRoleKey) {
    return json({ error: "Webhook is not configured." }, 503);
  }

  const signature = request.headers.get("stripe-signature");
  if (!signature) {
    return json({ error: "Missing stripe-signature header." }, 400);
  }

  const rawBody = await request.text();
  const stripe = new Stripe(stripeKey, { apiVersion: "2024-04-10" });
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      rawBody,
      signature,
      webhookSecret,
    );
  } catch {
    return json({ error: "Invalid Stripe signature." }, 400);
  }

  if (
    ![
      "checkout.session.completed",
      "customer.subscription.created",
      "customer.subscription.updated",
      "customer.subscription.deleted",
      "invoice.payment_succeeded",
      "invoice.payment_failed",
      "payment_intent.succeeded",
    ].includes(event.type)
  ) {
    return json({ received: true, ignored: true });
  }

  const object = event.data.object as
    | Stripe.Checkout.Session
    | Stripe.Subscription
    | Stripe.Invoice
    | Stripe.PaymentIntent;
  const userId = await resolveUserIdForObject(supabase, object);

  const metadata = object.metadata ?? {};
  const productKey = metadata.product_key?.trim() || null;
  const categorySlug = metadata.category_slug?.trim() || null;
  const procedureSlug = metadata.procedure_slug?.trim() || null;

  const inserted = await logStripeEvent(supabase, event, {
    user_id: userId,
    plan: productKey,
    metadata: {
      product_key: productKey,
      category_slug: categorySlug,
      procedure_slug: procedureSlug,
    },
  });
  if (!inserted) {
    return json({ received: true, duplicate: true });
  }

  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = object as Stripe.PaymentIntent;
    if (
      userId &&
      productKey === "subcategory_unlock" &&
      categorySlug &&
      procedureSlug
    ) {
      await supabase.from("ufficio_user_content_unlocks").upsert(
        {
          user_id: userId,
          category_slug: categorySlug,
          procedure_slug: procedureSlug,
          status: "active",
          unlock_type: "single_purchase",
          product_key: productKey,
          amount_cents: paymentIntent.amount_received ?? paymentIntent.amount,
          currency: paymentIntent.currency?.toUpperCase() ?? "EUR",
          provider: "stripe",
          stripe_payment_intent_id: paymentIntent.id,
          purchased_at: new Date().toISOString(),
          metadata: {
            stripe_event_type: event.type,
          },
        },
        { onConflict: "user_id,category_slug,procedure_slug" },
      );
    }
    return json({ received: true });
  }

  if (event.type === "checkout.session.completed") {
    const session = object as Stripe.Checkout.Session;
    await supabase.from("ufficio_payment_events").upsert(
      {
        user_id: userId,
        provider: "stripe",
        event_id: session.id,
        event_type: event.type,
        product_key: productKey,
        product_type: session.mode,
        category_slug: categorySlug,
        procedure_slug: procedureSlug,
        amount_cents: session.amount_total,
        currency: session.currency?.toUpperCase() ?? "EUR",
        status: "completed",
        raw_payload: { payment_status: session.payment_status },
        processed_at: new Date().toISOString(),
      },
      { onConflict: "provider,event_id" },
    );
    if (
      userId &&
      session.mode === "payment" &&
      productKey === "subcategory_unlock" &&
      categorySlug &&
      procedureSlug
    ) {
      await supabase.from("ufficio_user_content_unlocks").upsert(
        {
          user_id: userId,
          category_slug: categorySlug,
          procedure_slug: procedureSlug,
          status: "active",
          unlock_type: "single_purchase",
          product_key: productKey,
          amount_cents: session.amount_total,
          currency: session.currency?.toUpperCase() ?? "EUR",
          provider: "stripe",
          stripe_checkout_session_id: session.id,
          purchased_at: new Date().toISOString(),
          metadata: {
            stripe_event_type: event.type,
          },
        },
        { onConflict: "user_id,category_slug,procedure_slug" },
      );
    }
    return json({ received: true });
  }

  const subscription =
    event.type.startsWith("customer.subscription")
      ? (object as Stripe.Subscription)
      : event.type.startsWith("invoice.")
      ? await stripe.subscriptions.retrieve(
          typeof (object as Stripe.Invoice).subscription === "string"
            ? ((object as Stripe.Invoice).subscription as string)
            : ((object as Stripe.Invoice).subscription?.id ?? ""),
        )
      : null;

  if (!subscription || !userId) {
    return json({ received: true, skipped: true });
  }

  const subscriptionItem = subscription.items.data[0];
  const priceId = subscriptionItem?.price?.id ?? null;
  const derivedProductKey =
    productKey ||
    subscription.metadata?.product_key ||
    (() => {
      if (!priceId) return null;
      return null;
    })();
  const entitlementStatus = stripeStatusToEntitlementStatus(subscription.status);
  const currentPeriodStart = subscription.current_period_start
    ? new Date(subscription.current_period_start * 1000).toISOString()
    : null;
  const currentPeriodEnd = subscription.current_period_end
    ? new Date(subscription.current_period_end * 1000).toISOString()
    : null;
  const cancelledAt = subscription.canceled_at
    ? new Date(subscription.canceled_at * 1000).toISOString()
    : null;

  await supabase.from("ufficio_user_entitlements").upsert(
    {
      user_id: userId,
      plan: derivedProductKey ?? "free",
      status:
        event.type === "customer.subscription.deleted"
          ? "cancelled"
          : entitlementStatus,
      premium_access:
        event.type !== "customer.subscription.deleted" &&
        ["active", "trialing"].includes(entitlementStatus),
      source: "stripe",
      current_period_start: currentPeriodStart,
      current_period_end: currentPeriodEnd,
      trial_end:
        subscription.status === "trialing" ? currentPeriodEnd : null,
      cancelled_at: cancelledAt,
      revoked_at: null,
      stripe_customer_id:
        typeof subscription.customer === "string"
          ? subscription.customer
          : subscription.customer?.id ?? null,
      stripe_subscription_id: subscription.id,
      stripe_price_id: priceId,
      provider: "stripe",
      provider_customer_id:
        typeof subscription.customer === "string"
          ? subscription.customer
          : subscription.customer?.id ?? null,
      provider_subscription_id: subscription.id,
      provider_price_id: priceId,
      metadata: {
        stripe_status: subscription.status,
        last_event_type: event.type,
      },
    },
    { onConflict: "user_id" },
  );

  return json({ received: true });
});
