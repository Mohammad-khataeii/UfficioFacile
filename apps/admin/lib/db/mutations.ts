"use server";

import { revalidatePath } from "next/cache";

import { canManageAdminTarget, type AdminRole } from "@/lib/auth/permissions";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  catalogPrimaryKey,
  editableCatalogTables,
  type EditableCatalogTable,
} from "@/lib/db/queries";
import {
  adminUserSchema,
  categorySchema,
  entitlementSchema,
  procedureSchema,
} from "@/lib/validation/schemas";

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
  });

  const { data: before } = await admin.supabase
    .from("ufficcio_entitlements")
    .select("*")
    .eq("user_id", parsed.userId)
    .maybeSingle();

  const payload = {
    user_id: parsed.userId,
    plan: parsed.plan,
    status: parsed.status,
    premium_access: parsed.premiumAccess,
    free_pack_limit: parsed.freePackLimit,
    free_packs_used: parsed.freePacksUsed,
  };

  const { error } = await admin.supabase
    .from("ufficcio_entitlements")
    .upsert(payload);
  if (error) throw error;

  await admin.supabase.from("ufficio_premium_events").insert({
    user_id: parsed.userId,
    actor_user_id: admin.userId,
    event_type: "manual_admin_update",
    plan_before: before?.plan ?? null,
    plan_after: parsed.plan,
    premium_access_before: before?.premium_access ?? null,
    premium_access_after: parsed.premiumAccess,
    metadata: payload,
  });

  await logAdminAction({
    action: "premium.entitlement.updated",
    targetTable: "ufficcio_entitlements",
    targetId: parsed.userId,
    targetUserId: parsed.userId,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/premium");
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

export async function upsertCmsCategory(formData: FormData) {
  const admin = await requireAdmin("content.manage");
  const parsed = categorySchema.parse({
    slug: formData.get("slug"),
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
    isPremium: formData.get("isPremium") === "on",
    verificationStatus: formData.get("verificationStatus"),
    adminNotes: formData.get("adminNotes"),
  });

  const payload = {
    slug: parsed.slug,
    internal_label: parsed.internalLabel || null,
    title: localizedFromFormData(formData, "title"),
    subtitle: localizedFromFormData(formData, "subtitle"),
    description: localizedFromFormData(formData, "description"),
    icon: parsed.icon || null,
    color: parsed.color || null,
    sort_order: parsed.sortOrder,
    is_active: parsed.isActive,
    is_premium: parsed.isPremium,
    verification_status: parsed.verificationStatus,
    admin_notes: parsed.adminNotes || null,
  };

  const { data: before } = await admin.supabase
    .from("ufficio_cms_categories")
    .select("*")
    .eq("slug", parsed.slug)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_cms_categories")
    .upsert(payload);
  if (error) throw error;

  await logAdminAction({
    action: before ? "cms.category.updated" : "cms.category.created",
    targetTable: "ufficio_cms_categories",
    targetId: before?.id ?? parsed.slug,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/content/categories");
  revalidatePath(`/content/categories/${parsed.slug}`);
}

export async function upsertCmsProcedure(formData: FormData) {
  const admin = await requireAdmin("content.manage");
  const parsed = procedureSchema.parse({
    categorySlug: formData.get("categorySlug"),
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
    isPremium: formData.get("isPremium") === "on",
    verificationStatus: formData.get("verificationStatus"),
    adminNotes: formData.get("adminNotes"),
  });

  const payload = {
    category_slug: parsed.categorySlug,
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
    is_active: parsed.isActive,
    is_premium: parsed.isPremium,
    verification_status: parsed.verificationStatus,
    admin_notes: parsed.adminNotes || null,
  };

  const { data: before } = await admin.supabase
    .from("ufficio_cms_procedures")
    .select("*")
    .eq("slug", parsed.slug)
    .maybeSingle();
  const { error } = await admin.supabase
    .from("ufficio_cms_procedures")
    .upsert(payload);
  if (error) throw error;

  await logAdminAction({
    action: before ? "cms.procedure.updated" : "cms.procedure.created",
    targetTable: "ufficio_cms_procedures",
    targetId: before?.id ?? parsed.slug,
    beforeValue: before ?? {},
    afterValue: payload,
  });
  revalidatePath("/content/procedures");
  revalidatePath(`/content/procedures/${parsed.slug}`);
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

function splitTextarea(value: FormDataEntryValue | null) {
  return String(value ?? "")
    .split("\n")
    .map((item) => item.trim())
    .filter(Boolean);
}
