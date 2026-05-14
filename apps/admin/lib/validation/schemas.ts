import { z } from "zod";

export const adminUserSchema = z.object({
  userId: z.string().uuid(),
  email: z.string().email().optional().or(z.literal("")),
  role: z.enum(["owner", "admin", "editor", "support", "viewer"]),
  isActive: z.boolean(),
});

export const entitlementSchema = z.object({
  userId: z.string().uuid(),
  plan: z.enum([
    "free",
    "plus_monthly",
    "plus_yearly",
    "premium_monthly",
    "premium_yearly",
    "consultancy_one_shot",
    "admin_grant",
    "lifetime",
    "trial",
    "pro",
    "consultant",
  ]),
  status: z.enum([
    "active",
    "trialing",
    "past_due",
    "cancelled",
    "expired",
    "revoked",
  ]),
  premiumAccess: z.boolean().optional().default(false),
  freePackLimit: z.coerce.number().int().nonnegative(),
  freePacksUsed: z.coerce.number().int().nonnegative(),
  periodDays: z.coerce.number().int().nonnegative().optional().default(30),
});

export const localizedValueSchema = z.record(
  z.enum(["en", "it", "fr", "es", "fa", "ar"]),
  z.string().trim(),
);

export const categorySchema = z.object({
  slug: z.string().regex(/^[a-z0-9_/-]+$/),
  internalLabel: z.string().optional(),
  titleEn: z.string().min(1),
  titleIt: z.string().optional(),
  titleFr: z.string().optional(),
  titleEs: z.string().optional(),
  titleFa: z.string().optional(),
  titleAr: z.string().optional(),
  descriptionEn: z.string().optional(),
  icon: z.string().optional(),
  color: z.string().optional(),
  sortOrder: z.coerce.number().int().default(0),
  isActive: z.boolean(),
  isPremium: z.boolean(),
  verificationStatus: z.enum(["verified", "needsReview", "unverified"]),
  adminNotes: z.string().optional(),
  tags: z.string().optional(),
  synonyms: z.string().optional(),
  searchableKeywords: z.string().optional(),
  monetizationType: z.string().optional(),
  allowSingleUnlock: z.boolean().optional(),
  singleUnlockPriceCents: z.coerce.number().int().optional(),
});

export const procedureSchema = z.object({
  categorySlug: z.string().min(1),
  subcategorySlug: z.string().optional(),
  slug: z.string().regex(/^[a-z0-9_/-]+$/),
  titleEn: z.string().min(1),
  titleIt: z.string().optional(),
  titleFr: z.string().optional(),
  titleEs: z.string().optional(),
  titleFa: z.string().optional(),
  titleAr: z.string().optional(),
  summaryEn: z.string().optional(),
  whatIsItEn: z.string().optional(),
  status: z.enum(["draft", "published", "archived"]),
  sortOrder: z.coerce.number().int().default(0),
  isActive: z.boolean(),
  isPremium: z.boolean(),
  verificationStatus: z.enum(["verified", "needsReview", "unverified"]),
  adminNotes: z.string().optional(),
  tags: z.string().optional(),
  synonyms: z.string().optional(),
  searchableKeywords: z.string().optional(),
  monetizationType: z.string().optional(),
  allowSingleUnlock: z.boolean().optional(),
  singleUnlockPriceCents: z.coerce.number().int().optional(),
});
