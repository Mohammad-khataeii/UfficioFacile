"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import { canManageAdminTarget, type AdminRole } from "@/lib/auth/permissions";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  catalogPrimaryKey,
  editableCatalogTables,
  type EditableCatalogTable,
} from "@/lib/db/queries";
import { createServiceRoleClient } from "@/lib/supabase/server";
import {
  adminUserSchema,
  categorySchema,
  entitlementSchema,
  procedureSchema,
} from "@/lib/validation/schemas";

export type CmsActionResult =
  | { ok: true; message: string; redirectTo?: string }
  | {
      ok: false;
      message: string;
      code?: string;
      details?: string | null;
      hint?: string | null;
      redirectTo?: string;
    };

const allowedPremiumVisibility = new Set([
  "free",
  "premium_preview",
  "premium_only",
  "hidden",
]);

function splitTextarea(value: FormDataEntryValue | null): string[] {
  return String(value ?? "")
    .split("\n")
    .map((item) => item.trim())
    .filter(Boolean);
}

function normalizePremiumInput(input: {
  premiumVisibility: string;
  requiredPlan?: string | null;
  isPublished?: boolean;
}) {
  const premiumVisibility = allowedPremiumVisibility.has(input.premiumVisibility)
    ? input.premiumVisibility
    : "free";
  const requiredPlan =
    input.requiredPlan && input.requiredPlan.trim().length > 0
      ? input.requiredPlan.trim()
      : null;
  if (requiredPlan && requiredPlan !== "premium") {
    throw new Error("Required plan must be premium or empty.");
  }
  const isPremium = premiumVisibility === "premium_only";
  const monetizationType =
    premiumVisibility === "free" || premiumVisibility === "hidden"
      ? "free"
      : "premium";
  const visibility =
    premiumVisibility === "hidden"
      ? "hidden"
      : premiumVisibility === "premium_only"
        ? "premium"
        : "public";
  return {
    premiumVisibility,
    requiredPlan,
    isPremium,
    monetizationType,
    visibility,
    isActive:
      premiumVisibility === "hidden" ? false : Boolean(input.isPublished),
  };
}

function buildCmsMetadata(formData: FormData, normalized: {
  premiumVisibility: string;
  requiredPlan: string | null;
}) {
  return {
    premium_visibility: normalized.premiumVisibility,
    required_plan: normalized.requiredPlan,
    searchable_keywords: splitTextarea(formData.get("searchableKeywords")),
    synonyms: splitTextarea(formData.get("synonyms")),
    tags: splitTextarea(formData.get("tags")),
  };
}

function serializeSupabaseError(error: any) {
  return {
    message: String(error?.message ?? "Save failed."),
    code: typeof error?.code === "string" ? error.code : undefined,
    details:
      error?.details == null ? null : String(error.details),
    hint: error?.hint == null ? null : String(error.hint),
  };
}

function actionResultQuery(result: CmsActionResult) {
  const params = new URLSearchParams({
    cmsStatus: result.ok ? "ok" : "error",
    cmsMessage: result.message,
  });
  if (!result.ok) {
    if (result.code) params.set("cmsCode", result.code);
    if (result.details) params.set("cmsDetails", result.details);
    if (result.hint) params.set("cmsHint", result.hint);
  }
  return params.toString();
}

export async function logAdminAction(input: {
  action: string;
  targetTable: string;
  targetId?: string | null;
  targetUserId?: string | null;
  summary?: string | null;
  beforeValue?: unknown;
  afterValue?: unknown;
  metadata?: unknown;
}) {
  const admin = await requireAdmin();
  await admin.supabase.from("ufficio_admin_audit_logs").insert({
    actor_user_id: admin.userId,
    actor_email: admin.email,
    actor_role: admin.role,
    action: input.action,
    target_table: input.targetTable,
    target_id: input.targetId ?? null,
    target_user_id: input.targetUserId ?? null,
    summary: input.summary ?? null,
    before_value: input.beforeValue ?? {},
    after_value: input.afterValue ?? {},
    metadata: input.metadata ?? {},
  });
}

async function resolveProfileTable(
  service: ReturnType<typeof createServiceRoleClient>,
) {
  try {
    await service.from("ufficio_profiles").select("user_id").limit(1);
    return "ufficio_profiles";
  } catch {
    return "ufficcio_profiles";
  }
}

async function profileTableSupportsMetadata(
  service: ReturnType<typeof createServiceRoleClient>,
  table: string,
) {
  try {
    await service.from(table).select("metadata").limit(1);
    return true;
  } catch {
    return false;
  }
}

async function assertManageableUserTarget(
  actorRole: AdminRole,
  actorUserId: string,
  targetUserId: string,
  {
    allowSelf = false,
    actionLabel = "manage this user",
  }: { allowSelf?: boolean; actionLabel?: string } = {},
) {
  if (!allowSelf && actorUserId === targetUserId) {
    throw new Error(
      `You cannot ${actionLabel} for your own account from the admin panel.`,
    );
  }

  const service = createServiceRoleClient();
  const { data: targetAdmin, error } = await service
    .from("ufficio_admin_users")
    .select("role, is_active")
    .eq("user_id", targetUserId)
    .maybeSingle();
  if (error) throw error;
  if (!targetAdmin?.role) return;

  const targetRole = targetAdmin.role as AdminRole;
  if (
    !canManageAdminTarget(actorRole, targetRole) &&
    actorRole !== "owner"
  ) {
    throw new Error("You do not have permission to manage that admin account.");
  }
}

export async function upsertAdminUser(formData: FormData) {
  const admin = await requireAdmin("admins.manage");
  const parsed = adminUserSchema.parse({
    userId: formData.get("userId"),
    email: formData.get("email"),
    role: formData.get("role"),
    isActive: formData.get("isActive") === "on",
  });

  const { data: existing } = await admin.supabase
    .from("ufficio_admin_users")
    .select("*")
    .eq("user_id", parsed.userId)
    .maybeSingle();

  const existingRole = (existing?.role ?? "viewer") as AdminRole;
  if (!canManageAdminTarget(admin.role, parsed.role) && admin.role !== "owner") {
    throw new Error("You do not have permission to assign that admin role.");
  }
  if (existing && !canManageAdminTarget(admin.role, existingRole) && admin.role !== "owner") {
    throw new Error("You do not have permission to modify that admin user.");
  }

  const payload = {
    user_id: parsed.userId,
    email: parsed.email || null,
    role: parsed.role,
    is_active: parsed.isActive,
    updated_by: admin.userId,
    created_by: existing?.created_by ?? admin.userId,
  };

  const { error } = await admin.supabase
    .from("ufficio_admin_users")
    .upsert(payload);
  if (error) throw error;

  await logAdminAction({
    action: existing ? "admin.updated" : "admin.created",
    targetTable: "ufficio_admin_users",
    targetId: parsed.userId,
    targetUserId: parsed.userId,
    summary: `${parsed.email || parsed.userId} -> ${parsed.role}`,
    beforeValue: existing ?? {},
    afterValue: payload,
  });
  revalidatePath("/admins");
}

export async function updateEntitlement(formData: FormData) {
  const admin = await requireAdmin("premium.manage");
  const parsed = entitlementSchema.parse({
    userId: formData.get("userId"),
    plan: formData.get("plan"),
    status: formData.get("status"),
    premiumAccess: formData.get("premiumAccess") === "on",
    freePackLimit: formData.get("freePackLimit"),
    freePacksUsed: formData.get("freePacksUsed"),
    periodDays: formData.get("periodDays"),
  });

  const { data: before } = await admin.supabase
    .from("ufficio_user_entitlements")
    .select("*")
    .eq("user_id", parsed.userId)
    .maybeSingle();

  const premiumPlans = new Set([
    "plus_monthly",
    "plus_yearly",
    "premium_monthly",
    "premium_yearly",
    "admin_grant",
    "lifetime",
    "trial",
    "pro",
    "consultant",
  ]);
  const statusAllowsPremium =
    parsed.status === "active" || parsed.status === "trialing";
  const isPremiumAccess =
    statusAllowsPremium &&
    (parsed.premiumAccess || premiumPlans.has(parsed.plan));
  const currentPeriodStart = new Date();
  const currentPeriodEnd =
    parsed.plan === "free" || parsed.status === "revoked" || parsed.status === "expired"
      ? null
      : new Date(
          currentPeriodStart.getTime() + parsed.periodDays * 24 * 60 * 60 * 1000,
        ).toISOString();
  const payload = {
    user_id: parsed.userId,
    plan: parsed.plan,
    status: parsed.status,
    premium_access: isPremiumAccess,
    source: "admin_grant",
    current_period_start: currentPeriodStart.toISOString(),
    current_period_end: currentPeriodEnd,
    trial_end: parsed.status === "trialing" ? currentPeriodEnd : null,
    cancelled_at: parsed.status === "cancelled" ? new Date().toISOString() : null,
    revoked_at: parsed.status === "revoked" ? new Date().toISOString() : null,
    metadata: {
      free_pack_limit: parsed.freePackLimit,
      free_packs_used: parsed.freePacksUsed,
      updated_by_role: admin.role,
    },
  };

  const { error } = await admin.supabase
    .from("ufficio_user_entitlements")
    .upsert(payload);
  if (error) throw error;

  await admin.supabase.from("ufficio_premium_events").insert({
    user_id: parsed.userId,
    actor_user_id: admin.userId,
    event_type: "entitlement_updated",
    plan: parsed.plan,
    source: "admin_grant",
    metadata: payload,
  });

  await logAdminAction({
    action: "premium.entitlement.updated",
    targetTable: "ufficio_user_entitlements",
    targetId: parsed.userId,
    targetUserId: parsed.userId,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/premium");
  revalidatePath("/premium/users");
  revalidatePath(`/premium/users/${parsed.userId}`);
}

export async function resetUsageCounters(formData: FormData) {
  const admin = await requireAdmin("premium.manage");
  const userId = String(formData.get("userId") ?? "");
  if (!userId) throw new Error("User ID is required.");

  const { data: before } = await admin.supabase
    .from("ufficio_usage_counters")
    .select("*")
    .eq("user_id", userId);

  const { error } = await admin.supabase
    .from("ufficio_usage_counters")
    .delete()
    .eq("user_id", userId);
  if (error) throw error;

  await admin.supabase.from("ufficio_premium_events").insert({
    user_id: userId,
    actor_user_id: admin.userId,
    event_type: "usage_counters_reset",
    source: "admin_grant",
    metadata: { userId },
  });

  await logAdminAction({
    action: "premium.usage.reset",
    targetTable: "ufficio_usage_counters",
    targetId: userId,
    targetUserId: userId,
    beforeValue: before ?? [],
    afterValue: [],
  });

  revalidatePath("/premium");
  revalidatePath("/premium/users");
  revalidatePath(`/premium/users/${userId}`);
}

export async function upsertPlanProduct(formData: FormData) {
  const admin = await requireAdmin("premium.manage");
  const productKey = String(formData.get("productKey") ?? "");
  const stripePriceId = String(formData.get("stripePriceId") ?? "").trim();
  const providerMetadata = JSON.parse(
    String(formData.get("providerMetadataJson") ?? "{}"),
  );
  const payload = {
    product_key: productKey,
    plan_type: String(formData.get("planType") ?? "free"),
    billing_interval: String(formData.get("billingInterval") ?? "none"),
    amount_cents: Number(formData.get("amountCents") ?? 0),
    currency: String(formData.get("currency") ?? "EUR"),
    stripe_price_id: stripePriceId || null,
    is_active: formData.get("isActive") === "on",
    sort_order: Number(formData.get("sortOrder") ?? 0),
    title: localizedFromFormData(formData, "title"),
    description: localizedFromFormData(formData, "description"),
    features: JSON.parse(String(formData.get("featuresJson") ?? "{}")),
    limits: JSON.parse(String(formData.get("limitsJson") ?? "{}")),
    provider_metadata: {
      ...providerMetadata,
      ...(stripePriceId ? { stripe_price_id: stripePriceId } : {}),
    },
  };

  const { data: before } = await admin.supabase
    .from("ufficio_plan_products")
    .select("*")
    .eq("product_key", productKey)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_plan_products")
    .upsert(payload);
  if (error) throw error;
  await logAdminAction({
    action: before ? "premium.plan.updated" : "premium.plan.created",
    targetTable: "ufficio_plan_products",
    targetId: productKey,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/premium");
  revalidatePath("/premium/plans");
}

export async function grantContentUnlock(formData: FormData) {
  const admin = await requireAdmin("premium.manage");
  const payload = {
    user_id: String(formData.get("userId") ?? ""),
    category_slug: String(formData.get("categorySlug") ?? ""),
    procedure_slug: String(formData.get("procedureSlug") ?? ""),
    product_key: String(formData.get("productKey") ?? "subcategory_unlock"),
    status: String(formData.get("status") ?? "active"),
    unlock_type: String(formData.get("unlockType") ?? "admin_grant"),
    amount_cents: Number(formData.get("amountCents") ?? 0) || null,
    currency: String(formData.get("currency") ?? "EUR"),
    purchased_at: new Date().toISOString(),
  };
  const { data: before } = await admin.supabase
    .from("ufficio_user_content_unlocks")
    .select("*")
    .eq("user_id", payload.user_id)
    .eq("category_slug", payload.category_slug)
    .eq("procedure_slug", payload.procedure_slug)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_user_content_unlocks")
    .upsert(payload);
  if (error) throw error;
  await admin.supabase.from("ufficio_premium_events").insert({
    user_id: payload.user_id,
    actor_user_id: admin.userId,
    event_type: before ? "content_unlock_updated" : "content_unlock_granted",
    plan: payload.product_key,
    source: payload.unlock_type,
    metadata: payload,
  });
  await logAdminAction({
    action: before ? "content_unlock.updated" : "content_unlock.granted",
    targetTable: "ufficio_user_content_unlocks",
    targetId: `${payload.user_id}:${payload.category_slug}:${payload.procedure_slug}`,
    targetUserId: payload.user_id,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/premium");
  revalidatePath("/premium/users");
}

export async function revokeContentUnlock(formData: FormData) {
  const admin = await requireAdmin("premium.manage");
  const userId = String(formData.get("userId") ?? "");
  const categorySlug = String(formData.get("categorySlug") ?? "");
  const procedureSlug = String(formData.get("procedureSlug") ?? "");
  const { data: before } = await admin.supabase
    .from("ufficio_user_content_unlocks")
    .select("*")
    .eq("user_id", userId)
    .eq("category_slug", categorySlug)
    .eq("procedure_slug", procedureSlug)
    .maybeSingle();
  const payload = {
    status: "revoked",
    revoked_at: new Date().toISOString(),
  };
  const { error } = await admin.supabase
    .from("ufficio_user_content_unlocks")
    .update(payload)
    .eq("user_id", userId)
    .eq("category_slug", categorySlug)
    .eq("procedure_slug", procedureSlug);
  if (error) throw error;
  await admin.supabase.from("ufficio_premium_events").insert({
    user_id: userId,
    actor_user_id: admin.userId,
    event_type: "content_unlock_revoked",
    source: "admin_grant",
    metadata: { categorySlug, procedureSlug },
  });
  await logAdminAction({
    action: "content_unlock.revoked",
    targetTable: "ufficio_user_content_unlocks",
    targetId: `${userId}:${categorySlug}:${procedureSlug}`,
    targetUserId: userId,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/premium");
  revalidatePath("/premium/users");
}

export async function updateProblemRequest(formData: FormData) {
  const admin = await requireAdmin("requests.manage");
  const id = String(formData.get("id") ?? "");
  const payload = {
    status: String(formData.get("status") ?? "new"),
    admin_notes: String(formData.get("adminNotes") ?? ""),
    linked_category_slug: String(formData.get("linkedCategorySlug") ?? "") || null,
    linked_procedure_slug: String(formData.get("linkedProcedureSlug") ?? "") || null,
    reviewed_by: admin.userId,
    reviewed_at: new Date().toISOString(),
  };

  const { data: before } = await admin.supabase
    .from("ufficio_problem_requests")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_problem_requests")
    .update(payload)
    .eq("id", id);
  if (error) throw error;
  await logAdminAction({
    action: "problem_request.updated",
    targetTable: "ufficio_problem_requests",
    targetId: id,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/requests/problem");
  revalidatePath(`/requests/problem/${id}`);
}

export async function updateConsultancyRequest(formData: FormData) {
  const admin = await requireAdmin("requests.manage");
  const id = String(formData.get("id") ?? "");
  const payload = {
    status: String(formData.get("status") ?? "newRequest"),
    payment_status: String(formData.get("paymentStatus") ?? "paymentRequired"),
    admin_notes: String(formData.get("adminNotes") ?? ""),
    response_notes: String(formData.get("responseNotes") ?? ""),
    reviewed_by: admin.userId,
    reviewed_at: new Date().toISOString(),
  };

  const { data: before } = await admin.supabase
    .from("ufficio_consultancy_requests")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_consultancy_requests")
    .update(payload)
    .eq("id", id);
  if (error) throw error;
  await logAdminAction({
    action: "consultancy_request.updated",
    targetTable: "ufficio_consultancy_requests",
    targetId: id,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/requests/consultancy");
  revalidatePath(`/requests/consultancy/${id}`);
}

export async function updateUserDeviceLock(formData: FormData) {
  const admin = await requireAdmin("users.manage");
  const userId = String(formData.get("userId") ?? "").trim();
  const mode = String(formData.get("mode") ?? "").trim();
  if (!userId) throw new Error("User ID is required.");
  if (!["unlock", "lockNextSignIn"].includes(mode)) {
    throw new Error("Invalid device lock action.");
  }

  await assertManageableUserTarget(admin.role, admin.userId, userId, {
    actionLabel: "change the device lock",
  });

  const service = createServiceRoleClient();
  const table = await resolveProfileTable(service);
  const supportsMetadata = await profileTableSupportsMetadata(service, table);
  if (!supportsMetadata) {
    throw new Error(
      "This Supabase project does not have profile metadata yet. Apply the latest profile migration before managing device locks.",
    );
  }

  const { data: beforeRow, error: beforeError } = await service
    .from(table)
    .select("user_id, email, metadata")
    .eq("user_id", userId)
    .maybeSingle();
  if (beforeError) throw beforeError;

  const beforeMetadata =
    beforeRow?.metadata && typeof beforeRow.metadata === "object"
      ? { ...(beforeRow.metadata as Record<string, unknown>) }
      : {};
  const existingBinding =
    beforeMetadata.device_binding &&
    typeof beforeMetadata.device_binding === "object"
      ? { ...(beforeMetadata.device_binding as Record<string, unknown>) }
      : {};

  const now = new Date().toISOString();
  const nextBinding: Record<string, unknown> =
    mode === "unlock"
      ? {
          ...existingBinding,
          enabled: false,
          unlocked_by_admin_at: now,
          unlocked_by_admin_user_id: admin.userId,
        }
      : {
          ...existingBinding,
          enabled: true,
          locked_by_admin_at: now,
          locked_by_admin_user_id: admin.userId,
        };

  if (mode === "lockNextSignIn") {
    delete nextBinding.installation_id;
    delete nextBinding.platform;
    delete nextBinding.bound_at;
    delete nextBinding.last_seen_at;
    delete nextBinding.unlocked_by_admin_at;
    delete nextBinding.unlocked_by_admin_user_id;
  }

  const payload = {
    user_id: userId,
    email: typeof beforeRow?.email === "string" ? beforeRow.email : null,
    metadata: {
      ...beforeMetadata,
      device_binding: nextBinding,
    },
  };

  const { error } = await service
    .from(table)
    .upsert(payload, { onConflict: "user_id" });
  if (error) throw error;

  await logAdminAction({
    action: `user.device_lock.${mode}`,
    targetTable: table,
    targetId: userId,
    targetUserId: userId,
    beforeValue: beforeRow ?? {},
    afterValue: payload,
  });
  revalidatePath("/users");
  revalidatePath(`/users/${userId}`);
}

export async function deleteUserAccount(formData: FormData) {
  const admin = await requireAdmin("users.manage");
  const userId = String(formData.get("userId") ?? "").trim();
  if (!userId) throw new Error("User ID is required.");

  await assertManageableUserTarget(admin.role, admin.userId, userId, {
    actionLabel: "delete",
  });

  const service = createServiceRoleClient();
  const authUserResult = await service.auth.admin.getUserById(userId);
  if (authUserResult.error) throw authUserResult.error;

  const { data: adminRow, error: adminRowError } = await service
    .from("ufficio_admin_users")
    .select("*")
    .eq("user_id", userId)
    .maybeSingle();
  if (adminRowError) throw adminRowError;

  const deleteResult = await service.auth.admin.deleteUser(userId);
  if (deleteResult.error) throw deleteResult.error;

  await logAdminAction({
    action: "user.account.deleted",
    targetTable: "auth.users",
    targetId: userId,
    targetUserId: userId,
    summary: authUserResult.data.user?.email ?? userId,
    beforeValue: {
      authUser: authUserResult.data.user ?? null,
      adminUser: adminRow ?? null,
    },
    afterValue: {},
  });
  revalidatePath("/users");
}

function localizedFromFormData(formData: FormData, prefix: string) {
  return {
    en: String(formData.get(`${prefix}En`) ?? ""),
    it: String(formData.get(`${prefix}It`) ?? ""),
    fr: String(formData.get(`${prefix}Fr`) ?? ""),
    es: String(formData.get(`${prefix}Es`) ?? ""),
    fa: String(formData.get(`${prefix}Fa`) ?? ""),
    ar: String(formData.get(`${prefix}Ar`) ?? ""),
  };
}

async function upsertCmsCategoryInternal(
  formData: FormData,
  options: { isSubcategory?: boolean } = {},
): Promise<CmsActionResult> {
  try {
    const admin = await requireAdmin("content.manage");
    const parsed = categorySchema.parse({
      slug: formData.get("slug"),
      parentSlug: formData.get("parentSlug"),
      internalLabel: formData.get("internalLabel"),
      titleEn: formData.get("titleEn"),
      titleIt: formData.get("titleIt"),
      titleFr: formData.get("titleFr"),
      titleEs: formData.get("titleEs"),
      titleFa: formData.get("titleFa"),
      titleAr: formData.get("titleAr"),
      descriptionEn: formData.get("descriptionEn"),
      icon: formData.get("icon"),
      color: formData.get("color"),
      sortOrder: formData.get("sortOrder"),
      isActive: formData.get("isActive") === "on",
      premiumVisibility: formData.get("premiumVisibility"),
      requiredPlan: formData.get("requiredPlan"),
      verificationStatus: formData.get("verificationStatus"),
      adminNotes: formData.get("adminNotes"),
      tags: formData.get("tags"),
      synonyms: formData.get("synonyms"),
      searchableKeywords: formData.get("searchableKeywords"),
      monetizationType: formData.get("monetizationType"),
      allowSingleUnlock: formData.get("allowSingleUnlock") === "on",
      singleUnlockPriceCents: formData.get("singleUnlockPriceCents"),
    });
    const normalized = normalizePremiumInput({
      premiumVisibility: parsed.premiumVisibility,
      requiredPlan: parsed.requiredPlan || null,
      isPublished: parsed.isActive,
    });
    const metadata = buildCmsMetadata(formData, normalized);
    const payload = {
      slug: parsed.slug,
      parent_slug: parsed.parentSlug?.trim() || null,
      internal_label: parsed.internalLabel || null,
      title: localizedFromFormData(formData, "title"),
      subtitle: localizedFromFormData(formData, "subtitle"),
      description: localizedFromFormData(formData, "description"),
      icon: parsed.icon || null,
      color: parsed.color || null,
      sort_order: parsed.sortOrder,
      is_active: normalized.isActive,
      is_premium: normalized.isPremium,
      premium_visibility_rule: normalized.premiumVisibility,
      verification_status: parsed.verificationStatus,
      tags: metadata.tags,
      synonyms: metadata.synonyms,
      searchable_keywords: metadata.searchable_keywords,
      monetization_type: normalized.monetizationType,
      allow_single_unlock: formData.get("allowSingleUnlock") === "on",
      single_unlock_price_cents:
        Number(formData.get("singleUnlockPriceCents") ?? "") || null,
      single_unlock_currency: "EUR",
      premium_reason: localizedFromFormData(formData, "premiumReason"),
      premium_teaser: localizedFromFormData(formData, "premiumTeaser"),
      admin_notes: parsed.adminNotes || null,
      metadata,
    };

    const { data: before } = await admin.supabase
      .from("ufficio_cms_categories")
      .select("*")
      .eq("slug", parsed.slug)
      .maybeSingle();
    const { error } = await admin.supabase
      .from("ufficio_cms_categories")
      .upsert(payload);
    if (error) {
      const serialized = serializeSupabaseError(error);
      return {
        ok: false,
        ...serialized,
        message: options.isSubcategory
          ? "Save failed for this subcategory."
          : "Save failed.",
      };
    }

    await logAdminAction({
      action: before
        ? options.isSubcategory
          ? "cms.subcategory.updated"
          : "cms.category.updated"
        : options.isSubcategory
          ? "cms.subcategory.created"
          : "cms.category.created",
      targetTable: "ufficio_cms_categories",
      targetId: before?.id ?? parsed.slug,
      beforeValue: before ?? {},
      afterValue: payload,
    });
    revalidatePath("/content/categories");
    revalidatePath(`/content/categories/${parsed.parentSlug ?? parsed.slug}`);
    return {
      ok: true,
      message: options.isSubcategory
        ? "Subcategory saved."
        : "Category saved.",
    };
  } catch (error) {
    const serialized = serializeSupabaseError(error);
    return { ok: false, ...serialized, message: "Save failed." };
  }
}

export async function upsertCmsCategory(formData: FormData) {
  const result = await upsertCmsCategoryInternal(formData);
  const redirectTo =
    String(formData.get("redirectTo") ?? "") ||
    `/content/categories/${String(formData.get("slug") ?? "")}`;
  revalidatePath(redirectTo.split("?")[0] || "/content/categories");
  redirect(`${redirectTo}?${actionResultQuery(result)}`);
}

export async function upsertCmsSubcategory(formData: FormData) {
  const result = await upsertCmsCategoryInternal(formData, {
    isSubcategory: true,
  });
  const redirectTo =
    String(formData.get("redirectTo") ?? "") ||
    `/content/categories/${String(formData.get("parentSlug") ?? "")}`;
  revalidatePath(redirectTo.split("?")[0] || "/content/categories");
  redirect(`${redirectTo}?${actionResultQuery(result)}`);
}

export async function upsertCmsProcedure(formData: FormData) {
  let result: CmsActionResult;
  try {
    const admin = await requireAdmin("content.manage");
    const parsed = procedureSchema.parse({
      categorySlug: formData.get("categorySlug"),
      subcategorySlug: formData.get("subcategorySlug"),
      slug: formData.get("slug"),
      titleEn: formData.get("titleEn"),
      titleIt: formData.get("titleIt"),
      titleFr: formData.get("titleFr"),
      titleEs: formData.get("titleEs"),
      titleFa: formData.get("titleFa"),
      titleAr: formData.get("titleAr"),
      summaryEn: formData.get("summaryEn"),
      whatIsItEn: formData.get("whatIsItEn"),
      status: formData.get("status"),
      sortOrder: formData.get("sortOrder"),
      isActive: formData.get("isActive") === "on",
      premiumVisibility: formData.get("premiumVisibility"),
      requiredPlan: formData.get("requiredPlan"),
      verificationStatus: formData.get("verificationStatus"),
      adminNotes: formData.get("adminNotes"),
      tags: formData.get("tags"),
      synonyms: formData.get("synonyms"),
      searchableKeywords: formData.get("searchableKeywords"),
      monetizationType: formData.get("monetizationType"),
      allowSingleUnlock: formData.get("allowSingleUnlock") === "on",
      singleUnlockPriceCents: formData.get("singleUnlockPriceCents"),
    });
    const normalized = normalizePremiumInput({
      premiumVisibility: parsed.premiumVisibility,
      requiredPlan: parsed.requiredPlan || null,
      isPublished: parsed.isActive,
    });
    const metadata = buildCmsMetadata(formData, normalized);
    const payload = {
      category_slug: parsed.categorySlug,
      subcategory_slug: String(parsed.subcategorySlug ?? "").trim() || null,
      slug: parsed.slug,
      title: localizedFromFormData(formData, "title"),
      subtitle: localizedFromFormData(formData, "subtitle"),
      summary: localizedFromFormData(formData, "summary"),
      what_is_it: localizedFromFormData(formData, "whatIsIt"),
      why_you_may_need_it: splitTextarea(formData.get("whyYouMayNeedIt")),
      how_to_do_it: splitTextarea(formData.get("howToDoIt")),
      required_documents: splitTextarea(formData.get("requiredDocuments")),
      optional_documents: splitTextarea(formData.get("optionalDocuments")),
      warnings: splitTextarea(formData.get("warnings")),
      common_mistakes: splitTextarea(formData.get("commonMistakes")),
      proof_to_keep: splitTextarea(formData.get("proofToKeep")),
      faq: splitTextarea(formData.get("faq")),
      official_links: splitTextarea(formData.get("officialLinks")),
      status: parsed.status,
      sort_order: parsed.sortOrder,
      is_active: normalized.isActive,
      is_premium: normalized.isPremium,
      verification_status: parsed.verificationStatus,
      tags: metadata.tags,
      synonyms: metadata.synonyms,
      searchable_keywords: metadata.searchable_keywords,
      monetization_type: normalized.monetizationType,
      allow_single_unlock: formData.get("allowSingleUnlock") === "on",
      single_unlock_price_cents:
        Number(formData.get("singleUnlockPriceCents") ?? "") || null,
      single_unlock_currency: "EUR",
      premium_reason: localizedFromFormData(formData, "premiumReason"),
      premium_teaser: localizedFromFormData(formData, "premiumTeaser"),
      admin_notes: parsed.adminNotes || null,
      metadata: {
        ...metadata,
        premium_visibility: normalized.premiumVisibility,
        required_plan: normalized.requiredPlan,
        subcategory_slug: String(parsed.subcategorySlug ?? "").trim() || null,
      },
    };

    const { data: before } = await admin.supabase
      .from("ufficio_cms_procedures")
      .select("*")
      .eq("category_slug", parsed.categorySlug)
      .eq("slug", parsed.slug)
      .maybeSingle();
    const { error } = await admin.supabase
      .from("ufficio_cms_procedures")
      .upsert(payload, { onConflict: "category_slug,slug" });
    if (error) {
      result = {
        ok: false,
        ...serializeSupabaseError(error),
        message: "Save failed.",
      };
    } else {
      await logAdminAction({
        action: before ? "cms.procedure.updated" : "cms.procedure.created",
        targetTable: "ufficio_cms_procedures",
        targetId: before?.id ?? parsed.slug,
        beforeValue: before ?? {},
        afterValue: payload,
      });
      revalidatePath("/content/procedures");
      revalidatePath(`/content/procedures/${parsed.slug}`);
      revalidatePath(`/content/procedures/${parsed.categorySlug}/${parsed.slug}`);
      revalidatePath(`/content/categories/${parsed.categorySlug}`);
      result = { ok: true, message: "Procedure saved." };
    }
  } catch (error) {
    result = {
      ok: false,
      ...serializeSupabaseError(error),
      message: "Save failed.",
    };
  }
  const redirectTo =
    String(formData.get("redirectTo") ?? "") ||
    `/content/procedures/${String(formData.get("categorySlug") ?? "")}/${String(formData.get("slug") ?? "")}`;
  revalidatePath(redirectTo.split("?")[0] || "/content/procedures");
  redirect(`${redirectTo}?${actionResultQuery(result)}`);
}

export async function updatePublicConfig(
  table: "ufficio_app_public_config" | "ufficio_premium_public_config",
  formData: FormData,
) {
  const admin = await requireAdmin("settings.manage");
  const key = String(formData.get("key") ?? "");
  const rawValue = String(formData.get("value") ?? "null");
  const value = JSON.parse(rawValue);
  const payload = { key, value, is_active: true };

  const { data: before } = await admin.supabase.from(table).select("*").eq("key", key).maybeSingle();
  const { error } = await admin.supabase.from(table).upsert(payload);
  if (error) throw error;
  await logAdminAction({
    action: "public_config.updated",
    targetTable: table,
    targetId: key,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/settings");
}

export async function upsertCatalogRow(formData: FormData) {
  const admin = await requireAdmin("catalog.manage");
  const table = String(formData.get("table") ?? "") as EditableCatalogTable;
  if (!editableCatalogTables.includes(table)) {
    throw new Error("Unsupported catalog table");
  }
  const id = String(formData.get("id") ?? "");
  const raw = String(formData.get("payload") ?? "{}");
  const payload = JSON.parse(raw);

  const primaryKey = catalogPrimaryKey(table);
  const targetId = id || String((payload as Record<string, unknown>)[primaryKey] ?? "");
  const { data: before } = await admin.supabase
    .from(table)
    .select("*")
    .eq(primaryKey, targetId)
    .maybeSingle();
  const { error } = await admin.supabase.from(table).upsert(payload);
  if (error) throw error;
  await logAdminAction({
    action: before ? "catalog.row.updated" : "catalog.row.created",
    targetTable: table,
    targetId: targetId,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/catalog");
  revalidatePath(`/catalog/${table}`);
  if (id) {
    revalidatePath(`/catalog/${table}/${id}`);
  }
}
