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
  parentSlug: z.string().optional(),
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
  premiumVisibility: z.enum([
    "free",
    "premium_preview",
    "premium_only",
    "hidden",
  ]),
  requiredPlan: z.enum(["premium"]).optional().or(z.literal("")),
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
  premiumVisibility: z.enum([
    "free",
    "premium_preview",
    "premium_only",
    "hidden",
  ]),
  requiredPlan: z.enum(["premium"]).optional().or(z.literal("")),
  verificationStatus: z.enum(["verified", "needsReview", "unverified"]),
  adminNotes: z.string().optional(),
  tags: z.string().optional(),
  synonyms: z.string().optional(),
  searchableKeywords: z.string().optional(),
  monetizationType: z.string().optional(),
  allowSingleUnlock: z.boolean().optional(),
  singleUnlockPriceCents: z.coerce.number().int().optional(),
});

export const promoCodeSchema = z.object({
  id: z.string().uuid().optional().or(z.literal("")),
  code: z.string().trim().min(3).max(64),
  title: z.string().trim().min(1).max(120),
  description: z.string().trim().optional(),
  promoKind: z.enum(["grant_entitlement", "percent_discount"]),
  planKey: z.enum([
    "premium_monthly",
    "premium_yearly",
    "trial",
    "admin_grant",
  ]),
  durationDays: z.coerce.number().int().positive().max(3650),
  discountPercent: z.coerce.number().int().min(1).max(100).optional(),
  targetPlanKeys: z
    .array(z.enum(["premium_monthly", "premium_yearly"]))
    .min(1)
    .default(["premium_monthly", "premium_yearly"]),
  maxRedemptions: z.coerce.number().int().positive().optional(),
  startsAt: z.string().trim().optional(),
  endsAt: z.string().trim().optional(),
  assignedUserId: z.string().uuid().optional().or(z.literal("")),
  successMessage: z.string().trim().optional(),
  isActive: z.boolean().optional().default(true),
}).superRefine((value, ctx) => {
  if (value.promoKind === "percent_discount" && value.discountPercent == null) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ["discountPercent"],
      message: "Discount percent is required for percentage promos.",
    });
  }
});
