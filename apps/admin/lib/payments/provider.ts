export type PaymentProviderState = "disabled" | "manual" | "stripe_ready";

export function getPaymentProviderState(): PaymentProviderState {
  const hasStripeSecrets =
    Boolean(process.env.STRIPE_SECRET_KEY) &&
    Boolean(process.env.STRIPE_WEBHOOK_SECRET) &&
    Boolean(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY);

  if (hasStripeSecrets) {
    return "stripe_ready";
  }
  if (process.env.SUPABASE_SERVICE_ROLE_KEY) {
    return "manual";
  }
  return "disabled";
}
