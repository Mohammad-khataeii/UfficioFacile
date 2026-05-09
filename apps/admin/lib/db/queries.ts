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

export type SafeQueryResult<T> = {
  data: T;
  warning?: string;
};

function isMissingTableError(error: any) {
  return (
    error?.code === "PGRST205" ||
    String(error?.message ?? "").includes("Could not find table")
  );
}

function missingTableWarning(table: string) {
  return `Missing Supabase table: ${table}. Run the latest Supabase migrations.`;
}

export async function safeSelectRows(
  supabase: any,
  table: string,
  build?: (query: any) => any,
): Promise<SafeQueryResult<any[]>> {
  let query = supabase.from(table).select("*");
  if (build) {
    query = build(query);
  }
  const { data, error } = await query;
  if (error) {
    if (isMissingTableError(error)) {
      return { data: [], warning: missingTableWarning(table) };
    }
    throw error;
  }
  return { data: data ?? [] };
}

export async function safeMaybeSingle(
  supabase: any,
  table: string,
  build?: (query: any) => any,
): Promise<SafeQueryResult<any | null>> {
  let query = supabase.from(table).select("*");
  if (build) {
    query = build(query);
  }
  const { data, error } = await query.maybeSingle();
  if (error) {
    if (isMissingTableError(error)) {
      return { data: null, warning: missingTableWarning(table) };
    }
    throw error;
  }
  return { data: data ?? null };
}

export async function safeCountRows(
  supabase: any,
  table: string,
  filter?: { column: string; value: string | boolean },
): Promise<SafeQueryResult<number>> {
  let query = supabase.from(table).select("*", { count: "exact", head: true });
  if (filter) {
    query = query.eq(filter.column, filter.value);
  }
  const { count, error } = await query;
  if (error) {
    if (isMissingTableError(error)) {
      return { data: 0, warning: missingTableWarning(table) };
    }
    throw error;
  }
  return { data: count ?? 0 };
}

export async function safeSelectRowsWithFallback(
  supabase: any,
  tables: string[],
  build?: (query: any) => any,
): Promise<SafeQueryResult<any[]>> {
  const warnings: string[] = [];
  for (const table of tables) {
    const result = await safeSelectRows(supabase, table, build);
    if (!result.warning) {
      return { data: result.data, warning: warnings[0] };
    }
    warnings.push(result.warning);
  }
  return { data: [], warning: warnings[0] };
}

export async function safeMaybeSingleWithFallback(
  supabase: any,
  tables: string[],
  build?: (query: any) => any,
): Promise<SafeQueryResult<any | null>> {
  const warnings: string[] = [];
  for (const table of tables) {
    const result = await safeMaybeSingle(supabase, table, build);
    if (!result.warning) {
      return { data: result.data, warning: warnings[0] };
    }
    warnings.push(result.warning);
  }
  return { data: null, warning: warnings[0] };
}

export async function safeCountRowsWithFallback(
  supabase: any,
  tables: string[],
  filter?: { column: string; value: string | boolean },
): Promise<SafeQueryResult<number>> {
  const warnings: string[] = [];
  for (const table of tables) {
    const result = await safeCountRows(supabase, table, filter);
    if (!result.warning) {
      return { data: result.data, warning: warnings[0] };
    }
    warnings.push(result.warning);
  }
  return { data: 0, warning: warnings[0] };
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
    planCount,
  ] = await Promise.all([
    safeCountRowsWithFallback(supabase, ["ufficio_profiles", "ufficcio_profiles"]),
    safeCountRows(supabase, "ufficio_user_entitlements", {
      column: "premium_access",
      value: true,
    }),
    safeCountRows(supabase, "ufficio_problem_requests", {
      column: "status",
      value: "new",
    }),
    safeCountRows(supabase, "ufficio_consultancy_requests", {
      column: "status",
      value: "newRequest",
    }),
    safeSelectRows(supabase, "ufficio_admin_audit_logs", (query) =>
      query.order("created_at", { ascending: false }).limit(10),
    ),
    safeCountRows(supabase, "ufficio_cms_categories"),
    safeCountRows(supabase, "ufficio_cms_procedures"),
    safeCountRows(supabase, "ufficio_cms_content_blocks"),
    safeCountRows(supabase, "ufficio_plan_products"),
  ]);

  const warnings = [
    userCount.warning,
    premiumCount.warning,
    problemCount.warning,
    consultancyCount.warning,
    auditRows.warning,
    categoryCount.warning,
    procedureCount.warning,
    blockCount.warning,
    planCount.warning,
  ].filter((warning): warning is string => Boolean(warning));

  return {
    totalUsers: userCount.data,
    premiumUsers: premiumCount.data,
    freeUsers: Math.max(userCount.data - premiumCount.data, 0),
    openProblemRequests: problemCount.data,
    openConsultancyRequests: consultancyCount.data,
    cmsCategories: categoryCount.data,
    cmsProcedures: procedureCount.data,
    cmsBlocks: blockCount.data,
    planProducts: planCount.data,
    auditRows: auditRows.data,
    warnings,
  };
}

export async function countRows(
  supabase: any,
  table: string,
  filter?: { column: string; value: string | boolean },
) {
  const result = await safeCountRows(supabase, table, filter);
  return result.data;
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
    usageCounters,
    consultancy,
    problemRequests,
    costItems,
    contacts,
    documents,
    unlocks,
    paymentEvents,
  ] = await Promise.all([
    safeMaybeSingleWithFallback(supabase, ["ufficio_profiles", "ufficcio_profiles"], (query) =>
      query.eq("user_id", userId),
    ),
    safeMaybeSingle(supabase, "ufficio_user_entitlements", (query) =>
      query.eq("user_id", userId),
    ),
    safeSelectRows(supabase, "ufficcio_requests", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_usage_counters", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_consultancy_requests", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_problem_requests", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_cost_items", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_directory_contacts", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_documents_directory", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(20),
    ),
    safeSelectRows(supabase, "ufficio_user_content_unlocks", (query) =>
      query.eq("user_id", userId).order("updated_at", { ascending: false }).limit(50),
    ),
    safeSelectRows(supabase, "ufficio_payment_events", (query) =>
      query.eq("user_id", userId).order("created_at", { ascending: false }).limit(50),
    ),
  ]);

  return {
    profile: profile.data,
    entitlement: entitlement.data,
    requests: requests.data,
    usageCounters: usageCounters.data,
    consultancy: consultancy.data,
    problemRequests: problemRequests.data,
    costItems: costItems.data,
    contacts: contacts.data,
    documents: documents.data,
    unlocks: unlocks.data,
    paymentEvents: paymentEvents.data,
    warnings: [
      profile.warning,
      entitlement.warning,
      requests.warning,
      usageCounters.warning,
      consultancy.warning,
      problemRequests.warning,
      costItems.warning,
      contacts.warning,
      documents.warning,
      unlocks.warning,
      paymentEvents.warning,
    ].filter((warning): warning is string => Boolean(warning)),
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
  return (
    await safeSelectRows(supabase, "ufficio_user_entitlements", (query) =>
      query.order("updated_at", { ascending: false }),
    )
  ).data;
}

export async function getPlanProducts(supabase: any) {
  return (
    await safeSelectRows(supabase, "ufficio_plan_products", (query) =>
      query.order("sort_order", { ascending: true }),
    )
  ).data;
}

export async function getPremiumEvents(supabase: any) {
  return (
    await safeSelectRows(supabase, "ufficio_premium_events", (query) =>
      query.order("created_at", { ascending: false }).limit(100),
    )
  ).data;
}

export async function getPaymentEvents(supabase: any) {
  return (
    await safeSelectRows(supabase, "ufficio_payment_events", (query) =>
      query.order("created_at", { ascending: false }).limit(100),
    )
  ).data;
}

export async function getContentUnlocks(supabase: any) {
  return (
    await safeSelectRows(supabase, "ufficio_user_content_unlocks", (query) =>
      query.order("updated_at", { ascending: false }).limit(200),
    )
  ).data;
}

export async function getPremiumOverviewData(supabase: any) {
  const [entitlements, plans, events, paymentEvents, unlocks] =
    await Promise.all([
      safeSelectRows(supabase, "ufficio_user_entitlements", (query) =>
        query.order("updated_at", { ascending: false }),
      ),
      safeSelectRows(supabase, "ufficio_plan_products", (query) =>
        query.order("sort_order", { ascending: true }),
      ),
      safeSelectRows(supabase, "ufficio_premium_events", (query) =>
        query.order("created_at", { ascending: false }).limit(100),
      ),
      safeSelectRows(supabase, "ufficio_payment_events", (query) =>
        query.order("created_at", { ascending: false }).limit(100),
      ),
      safeSelectRows(supabase, "ufficio_user_content_unlocks", (query) =>
        query.order("updated_at", { ascending: false }).limit(200),
      ),
    ]);

  return {
    entitlements: entitlements.data,
    plans: plans.data,
    events: events.data,
    paymentEvents: paymentEvents.data,
    unlocks: unlocks.data,
    warnings: [
      entitlements.warning,
      plans.warning,
      events.warning,
      paymentEvents.warning,
      unlocks.warning,
    ].filter((warning): warning is string => Boolean(warning)),
  };
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
