import { createServiceRoleClient } from "@/lib/supabase/server";

export const editableCatalogTables = [
  "ufficio_official_links",
  "ufficio_official_contacts",
  "ufficio_service_providers",
  "ufficio_provider_forms",
  "ufficio_provider_contact_options",
  "ufficio_region_guidance",
  "ufficio_city_guidance",
  "ufficio_authority_guidance",
  "ufficio_procedure_guidance",
  "ufficio_source_references",
  "ufficio_service_terms",
  "ufficio_submission_channels",
  "ufficio_app_public_config",
  "ufficio_premium_public_config",
] as const;

export type EditableCatalogTable = (typeof editableCatalogTables)[number];

export function catalogPrimaryKey(table: EditableCatalogTable) {
  return table === "ufficio_app_public_config" ||
    table === "ufficio_premium_public_config"
    ? "key"
    : "id";
}

export async function getDashboardMetrics(supabase: any) {
  const [
    userCount,
    premiumCount,
    problemCount,
    consultancyCount,
    auditRows,
    categoryCount,
    procedureCount,
    blockCount,
  ] = await Promise.all([
    countRows(supabase, "ufficcio_profiles"),
    countRows(supabase, "ufficcio_entitlements", {
      column: "premium_access",
      value: true,
    }),
    countRows(supabase, "ufficio_problem_requests", {
      column: "status",
      value: "new",
    }),
    countRows(supabase, "ufficio_consultancy_requests", {
      column: "status",
      value: "newRequest",
    }),
    supabase
      .from("ufficio_admin_audit_logs")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(10),
    countRows(supabase, "ufficio_cms_categories"),
    countRows(supabase, "ufficio_cms_procedures"),
    countRows(supabase, "ufficio_cms_content_blocks"),
  ]);

  return {
    totalUsers: userCount,
    premiumUsers: premiumCount,
    freeUsers: Math.max(userCount - premiumCount, 0),
    openProblemRequests: problemCount,
    openConsultancyRequests: consultancyCount,
    cmsCategories: categoryCount,
    cmsProcedures: procedureCount,
    cmsBlocks: blockCount,
    auditRows: auditRows.data ?? [],
  };
}

export async function countRows(
  supabase: any,
  table: string,
  filter?: { column: string; value: string | boolean },
) {
  let query = supabase.from(table).select("*", { count: "exact", head: true });
  if (filter) {
    query = query.eq(filter.column, filter.value);
  }
  const { count } = await query;
  return count ?? 0;
}

export async function listAuthUsers(search?: string) {
  const service = createServiceRoleClient();
  const { data, error } = await service.auth.admin.listUsers();
  if (error) throw error;
  const users = data.users ?? [];
  if (!search?.trim()) return users;
  const needle = search.toLowerCase();
  return users.filter(
    (user) =>
      user.email?.toLowerCase().includes(needle) ||
      user.id.toLowerCase().includes(needle),
  );
}

export async function getAuthUser(userId: string) {
  const service = createServiceRoleClient();
  const { data, error } = await service.auth.admin.getUserById(userId);
  if (error) throw error;
  return data.user;
}

export async function getUserBundle(supabase: any, userId: string) {
  const [
    profile,
    entitlement,
    requests,
    consultancy,
    problemRequests,
    costItems,
    contacts,
    documents,
  ] = await Promise.all([
    supabase.from("ufficcio_profiles").select("*").eq("user_id", userId).maybeSingle(),
    supabase.from("ufficcio_entitlements").select("*").eq("user_id", userId).maybeSingle(),
    supabase.from("ufficcio_requests").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    supabase.from("ufficio_consultancy_requests").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    supabase.from("ufficio_problem_requests").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    supabase.from("ufficio_cost_items").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    supabase.from("ufficio_directory_contacts").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    supabase.from("ufficio_documents_directory").select("*").eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
  ]);

  return {
    profile: profile.data,
    entitlement: entitlement.data,
    requests: requests.data ?? [],
    consultancy: consultancy.data ?? [],
    problemRequests: problemRequests.data ?? [],
    costItems: costItems.data ?? [],
    contacts: contacts.data ?? [],
    documents: documents.data ?? [],
  };
}

export async function getAdminUsers(supabase: any) {
  const { data, error } = await supabase
    .from("ufficio_admin_users")
    .select("*")
    .order("created_at", { ascending: true });
  if (error) throw error;
  return data ?? [];
}

export async function getEntitlements(supabase: any) {
  const { data, error } = await supabase
    .from("ufficcio_entitlements")
    .select("*")
    .order("updated_at", { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function getPremiumEvents(supabase: any) {
  const { data, error } = await supabase
    .from("ufficio_premium_events")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(100);
  if (error) throw error;
  return data ?? [];
}

export async function getProblemRequests(supabase: any) {
  const { data, error } = await supabase
    .from("ufficio_problem_requests")
    .select("*")
    .order("updated_at", { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function getConsultancyRequests(supabase: any) {
  const { data, error } = await supabase
    .from("ufficio_consultancy_requests")
    .select("*")
    .order("updated_at", { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function getCatalogTableRows(
  supabase: any,
  table: EditableCatalogTable,
) {
  const { data, error } = await supabase
    .from(table)
    .select("*")
    .limit(200)
    .order("updated_at", { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function getCatalogTableRow(
  supabase: any,
  table: EditableCatalogTable,
  id: string,
) {
  const { data, error } = await supabase
    .from(table)
    .select("*")
    .eq(catalogPrimaryKey(table), id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function getCmsTree(supabase: any) {
  const [categories, procedures] = await Promise.all([
    supabase
      .from("ufficio_cms_categories")
      .select("slug,title,is_active,sort_order,verification_status")
      .order("sort_order", { ascending: true }),
    supabase
      .from("ufficio_cms_procedures")
      .select("slug,category_slug,title,status,is_active,sort_order,verification_status")
      .order("sort_order", { ascending: true }),
  ]);

  return {
    categories: categories.data ?? [],
    procedures: procedures.data ?? [],
  };
}

export async function getCmsCategory(supabase: any, slug: string) {
  const { data, error } = await supabase
    .from("ufficio_cms_categories")
    .select("*")
    .eq("slug", slug)
    .maybeSingle();
  if (error) throw error;
  return data;
}

export async function getCmsProcedure(supabase: any, slug: string) {
  const [procedure, blocks, links, contacts, documents, sources, revisions, drafts] =
    await Promise.all([
      supabase.from("ufficio_cms_procedures").select("*").eq("slug", slug).maybeSingle(),
      supabase.from("ufficio_cms_content_blocks").select("*").eq("procedure_slug", slug).order("sort_order"),
      supabase.from("ufficio_cms_links").select("*").eq("procedure_slug", slug).order("sort_order"),
      supabase.from("ufficio_cms_contacts").select("*").eq("procedure_slug", slug).order("sort_order"),
      supabase.from("ufficio_cms_documents").select("*").eq("procedure_slug", slug).order("sort_order"),
      supabase.from("ufficio_cms_sources").select("*").eq("procedure_slug", slug).order("created_at", { ascending: false }),
      supabase.from("ufficio_cms_revisions").select("*").eq("entity_slug", slug).order("created_at", { ascending: false }).limit(50),
      supabase.from("ufficio_cms_drafts").select("*").eq("entity_slug", slug).order("updated_at", { ascending: false }).limit(20),
    ]);

  return {
    procedure: procedure.data,
    blocks: blocks.data ?? [],
    links: links.data ?? [],
    contacts: contacts.data ?? [],
    documents: documents.data ?? [],
    sources: sources.data ?? [],
    revisions: revisions.data ?? [],
    drafts: drafts.data ?? [],
  };
}

export async function getTranslationsSummary(supabase: any) {
  const [categories, procedures, blocks] = await Promise.all([
    supabase.from("ufficio_cms_categories").select("slug,title,subtitle,description"),
    supabase.from("ufficio_cms_procedures").select("slug,title,subtitle,summary,what_is_it"),
    supabase.from("ufficio_cms_content_blocks").select("id,title,body"),
  ]);

  return {
    categories: categories.data ?? [],
    procedures: procedures.data ?? [],
    blocks: blocks.data ?? [],
  };
}

export async function getAuditRows(supabase: any) {
  const { data, error } = await supabase
    .from("ufficio_admin_audit_logs")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(250);
  if (error) throw error;
  return data ?? [];
}

export async function getSettingsData(supabase: any) {
  const [appConfig, premiumConfig] = await Promise.all([
    supabase.from("ufficio_app_public_config").select("*").order("key"),
    supabase.from("ufficio_premium_public_config").select("*").order("key"),
  ]);
  return {
    appConfig: appConfig.data ?? [],
    premiumConfig: premiumConfig.data ?? [],
  };
}
