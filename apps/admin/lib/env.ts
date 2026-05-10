import { z } from "zod";

const publicEnvSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().trim().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().trim().min(1),
});

const serviceEnvSchema = publicEnvSchema.extend({
  SUPABASE_SERVICE_ROLE_KEY: z.string().trim().min(1),
});

type PublicEnv = z.infer<typeof publicEnvSchema>;
type ServiceEnv = z.infer<typeof serviceEnvSchema>;

function formatEnvError(scope: string, error: z.ZodError) {
  const details = error.issues
    .map((issue) => `${issue.path.join(".")}: ${issue.message}`)
    .join("; ");
  return `Invalid ${scope} environment for admin app: ${details}`;
}

export function getPublicSupabaseEnv(): PublicEnv {
  const parsed = publicEnvSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error(formatEnvError("public Supabase", parsed.error));
  }
  return parsed.data;
}

export function getServiceRoleEnv(): ServiceEnv {
  const parsed = serviceEnvSchema.safeParse(process.env);
  if (!parsed.success) {
    throw new Error(formatEnvError("service-role Supabase", parsed.error));
  }
  return parsed.data;
}

export function readOptionalPublicSupabaseEnv():
  | { ok: true; data: PublicEnv }
  | { ok: false; error: string } {
  const parsed = publicEnvSchema.safeParse(process.env);
  if (parsed.success) {
    return { ok: true, data: parsed.data };
  }
  return { ok: false, error: formatEnvError("public Supabase", parsed.error) };
}
