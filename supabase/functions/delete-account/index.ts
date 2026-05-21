import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient, type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

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

function failure(message: string, status = 400) {
  return json({ ok: false, error: message }, status);
}

function isIgnorableMissingRelation(error: { code?: string; message?: string } | null) {
  if (!error) return false;
  return error.code === "42P01" ||
    error.code === "PGRST205" ||
    `${error.message ?? ""}`.toLowerCase().includes("could not find the table");
}

async function deleteWhereUserId(
  client: SupabaseClient,
  table: string,
  userId: string,
) {
  const { error } = await client.from(table).delete().eq("user_id", userId);
  if (isIgnorableMissingRelation(error)) {
    console.warn(`delete-account: skipped missing table ${table}`);
    return;
  }
  if (error) {
    throw error;
  }
}

async function updateWhereUserId(
  client: SupabaseClient,
  table: string,
  userId: string,
  values: Record<string, unknown>,
) {
  const { error } = await client.from(table).update(values).eq("user_id", userId);
  if (isIgnorableMissingRelation(error)) {
    console.warn(`delete-account: skipped missing table ${table}`);
    return;
  }
  if (error) {
    throw error;
  }
}

async function updateWhereActorUserId(
  client: SupabaseClient,
  table: string,
  userId: string,
  values: Record<string, unknown>,
) {
  const { error } = await client.from(table).update(values).eq(
    "actor_user_id",
    userId,
  );
  if (isIgnorableMissingRelation(error)) {
    console.warn(`delete-account: skipped missing table ${table}`);
    return;
  }
  if (error) {
    throw error;
  }
}

async function collectStoragePaths(
  client: SupabaseClient,
  table: string,
  userId: string,
) {
  const { data, error } = await client
    .from(table)
    .select("storage_bucket,storage_path")
    .eq("user_id", userId);
  if (isIgnorableMissingRelation(error)) {
    return new Map<string, string[]>();
  }
  if (error) {
    throw error;
  }
  const bucketMap = new Map<string, string[]>();
  for (const row of data ?? []) {
    const bucket = typeof row.storage_bucket === "string"
      ? row.storage_bucket.trim()
      : "";
    const path = typeof row.storage_path === "string"
      ? row.storage_path.trim()
      : "";
    if (!bucket || !path) continue;
    const paths = bucketMap.get(bucket) ?? [];
    paths.push(path);
    bucketMap.set(bucket, paths);
  }
  return bucketMap;
}

async function removeStoredFiles(client: SupabaseClient, userId: string) {
  const buckets = new Map<string, string[]>();
  for (const table of ["ufficcio_documents", "ufficcio_proof_items"]) {
    const found = await collectStoragePaths(client, table, userId);
    for (const [bucket, paths] of found.entries()) {
      const next = buckets.get(bucket) ?? [];
      next.push(...paths);
      buckets.set(bucket, next);
    }
  }

  for (const [bucket, paths] of buckets.entries()) {
    const uniquePaths = [...new Set(paths)];
    if (uniquePaths.length == 0) continue;
    try {
      const { error } = await client.storage.from(bucket).remove(uniquePaths);
      if (error) {
        console.warn(
          `delete-account: storage cleanup skipped for ${bucket}: ${error.message}`,
        );
      }
    } catch (error) {
      console.warn(`delete-account: storage cleanup skipped for ${bucket}`, error);
    }
  }
}

serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  if (request.method !== "POST") {
    return failure("Method not allowed.", 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    return failure("Account deletion is not configured right now.", 503);
  }

  const authHeader = request.headers.get("Authorization");
  if (!authHeader) {
    return failure("Unauthorized.", 401);
  }

  const authClient = createClient(supabaseUrl, serviceRoleKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: authData, error: authError } = await authClient.auth.getUser();
  const user = authData.user;
  if (authError || !user) {
    return failure("Unauthorized.", 401);
  }

  const { data: adminUser, error: adminLookupError } = await adminClient
    .from("ufficio_admin_users")
    .select("user_id")
    .eq("user_id", user.id)
    .eq("is_active", true)
    .maybeSingle();
  if (adminLookupError && !isIgnorableMissingRelation(adminLookupError)) {
    console.error("delete-account: admin lookup failed", adminLookupError);
    return failure("We could not process your account deletion right now.", 500);
  }
  if (adminUser != null) {
    return failure(
      "This account must be deleted by support. Please email support@ufficiofacile.app.",
      403,
    );
  }

  let deleteRequestId: string | null = null;

  try {
    const { data: deleteRequestRow, error: deleteRequestError } = await adminClient
      .from("ufficcio_delete_requests")
      .insert({
        user_id: user.id,
        status: "processing",
        requested_at: new Date().toISOString(),
        notes: "Self-service deletion via delete-account edge function.",
      })
      .select("id")
      .maybeSingle();
    if (!deleteRequestError && deleteRequestRow?.id) {
      deleteRequestId = `${deleteRequestRow.id}`;
    }
  } catch (error) {
    console.warn("delete-account: delete request audit insert skipped", error);
  }

  try {
    await removeStoredFiles(adminClient, user.id);

    for (const table of [
      "ufficio_problem_requests",
      "ufficio_consultancy_requests",
      "ufficio_promo_redemptions",
      "ufficcio_feedback",
      "ufficcio_community_templates",
      "ufficcio_usage_events",
    ]) {
      await deleteWhereUserId(adminClient, table, user.id);
    }

    for (const table of [
      "ufficio_payment_events",
      "ufficio_premium_events",
      "ufficio_consultancy_payments",
    ]) {
      await updateWhereUserId(adminClient, table, user.id, {
        user_id: null,
      });
    }

    await updateWhereActorUserId(adminClient, "ufficio_premium_events", user.id, {
      actor_user_id: null,
    });

    const { error: deleteUserError } = await adminClient.auth.admin.deleteUser(
      user.id,
    );
    if (deleteUserError) {
      console.error("delete-account: auth delete failed", deleteUserError);
      return failure("We could not delete your account right now.", 500);
    }

    if (deleteRequestId) {
      const { error } = await adminClient
        .from("ufficcio_delete_requests")
        .update({
          status: "completed",
          completed_at: new Date().toISOString(),
        })
        .eq("id", deleteRequestId);
      if (error && !isIgnorableMissingRelation(error)) {
        console.warn("delete-account: could not mark delete request complete", error);
      }
    }

    return json({ ok: true });
  } catch (error) {
    console.error("delete-account: unexpected failure", error);
    if (deleteRequestId) {
      try {
        await adminClient
          .from("ufficcio_delete_requests")
          .update({
            status: "failed",
            completed_at: new Date().toISOString(),
            notes:
              "Self-service deletion failed. User may need support follow-up.",
          })
          .eq("id", deleteRequestId);
      } catch (_) {}
    }
    return failure(
      "We could not delete your account right now. Please try again or email support.",
      500,
    );
  }
});
