import { createClient } from "jsr:@supabase/supabase-js@2";

type InsuranceSearchInput = {
  city?: string;
  region?: string;
  citizenshipGroup?: string;
  status?: string;
  age?: number | null;
  durationMonths?: number;
  needsPermessoSupport?: boolean;
  needsEmergencyOnly?: boolean;
  needsGpAccess?: boolean;
  needsHospitalCoverage?: boolean;
  needsSpecialistCoverage?: boolean;
  needsMedicationCoverage?: boolean;
  budgetMonthly?: number | null;
  languagePreference?: string;
  alreadyHasSsn?: boolean;
  hasResidenza?: boolean;
  hasDomicileInTorino?: boolean;
};

type InsuranceOffer = {
  providerName: string;
  productName: string;
  monthlyPrice?: number;
  annualPrice?: number;
  currency: string;
  priceText: string;
  coverageSummary: string;
  coverageItems: string[];
  exclusions: string[];
  waitingPeriods: string;
  deductible: string;
  maxCoverageAmount: string;
  suitableFor: string;
  notSuitableFor: string;
  adminUsefulness: string;
  buyUrl: string;
  policyUrl: string;
  sourceUrl: string;
  sourceOwner: string;
  retrievedAt: string;
  confidence: number;
  warnings: string[];
  rankReason: string;
};

type InsuranceSearchResult = {
  ok: boolean;
  liveAvailable: boolean;
  offers: InsuranceOffer[];
  warnings: string[];
  retrievedAt: string;
  unavailableReason?: string;
  topRecommendedOffer?: string;
  cheapestOffer?: string;
  bestCoverageOffer?: string;
  bestStudentFitOffer?: string;
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
    },
  });
}

function safeUnavailable(reason: string): InsuranceSearchResult {
  return {
    ok: true,
    liveAvailable: false,
    offers: [],
    warnings: [
      "Private insurance may not replace SSN/ASL registration for every situation.",
      "Verify the policy wording and the requirement of your university, Questura, employer, or ASL before buying.",
      "Do not choose a policy by price alone.",
    ],
    retrievedAt: new Date().toISOString(),
    unavailableReason: reason,
  };
}

type InsuranceFinderAdapter = {
  search(input: InsuranceSearchInput): Promise<InsuranceSearchResult>;
};

class DisabledInsuranceOfferAdapter implements InsuranceFinderAdapter {
  constructor(private readonly reason: string) {}

  async search(): Promise<InsuranceSearchResult> {
    return safeUnavailable(this.reason);
  }
}

class SearchApiInsuranceAdapter implements InsuranceFinderAdapter {
  constructor(private readonly apiKey: string) {}

  async search(_input: InsuranceSearchInput): Promise<InsuranceSearchResult> {
    if (!this.apiKey.trim()) {
      return safeUnavailable(
        "Live offers are unavailable because the insurance search provider is not configured.",
      );
    }
    return safeUnavailable(
      "Live offers are disabled in this deployment until a verified insurance provider integration is connected.",
    );
  }
}

class CachedInsuranceOfferAdapter implements InsuranceFinderAdapter {
  constructor(
    private readonly inner: InsuranceFinderAdapter,
    private readonly ttlHours: number,
  ) {}

  private cache = new Map<string, { expiresAt: number; value: InsuranceSearchResult }>();

  async search(input: InsuranceSearchInput): Promise<InsuranceSearchResult> {
    const key = JSON.stringify(input);
    const now = Date.now();
    const cached = this.cache.get(key);
    if (cached != null && cached.expiresAt > now) {
      return cached.value;
    }
    const value = await this.inner.search(input);
    const ttlMs = Math.max(1, this.ttlHours) * 60 * 60 * 1000;
    this.cache.set(key, { expiresAt: now + ttlMs, value });
    return value;
  }
}

function buildAdapter(): InsuranceFinderAdapter {
  const enabled =
    (Deno.env.get("INSURANCE_FINDER_ENABLED") ?? "false").toLowerCase() ===
    "true";
  const provider = (Deno.env.get("INSURANCE_SEARCH_PROVIDER") ?? "").trim();
  const apiKey = Deno.env.get("INSURANCE_SEARCH_API_KEY") ?? "";
  const ttlHours = Number(Deno.env.get("INSURANCE_FINDER_CACHE_TTL_HOURS") ?? "6");

  if (!enabled) {
    return new DisabledInsuranceOfferAdapter(
      "Live offers are turned off for this deployment. Static Torino guidance is still available.",
    );
  }
  const base =
    provider === "search_api"
      ? new SearchApiInsuranceAdapter(apiKey)
      : new DisabledInsuranceOfferAdapter(
          "Live offers are unavailable because no verified provider adapter is configured.",
        );
  return new CachedInsuranceOfferAdapter(base, ttlHours);
}

async function authenticatedClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const authHeader = req.headers.get("Authorization") ?? "";
  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data, error } = await client.auth.getUser();
  if (error != null || data.user == null) {
    return null;
  }
  return { client, user: data.user };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "Method not allowed" }, 405);
  }

  const authed = await authenticatedClient(req);
  if (authed == null) {
    return json({ ok: false, error: "Unauthorized" }, 401);
  }

  let body: InsuranceSearchInput;
  try {
    body = (await req.json()) as InsuranceSearchInput;
  } catch {
    return json({ ok: false, error: "Invalid request body" }, 400);
  }

  const city = (body.city ?? "").trim().toLowerCase();
  if (city.length > 0 && city !== "torino") {
    return json(
      safeUnavailable(
        "The live Insurance Finder is currently configured only for Torino.",
      ),
    );
  }

  try {
    const result = await buildAdapter().search(body);
    return json(result);
  } catch (error) {
    console.error("insurance-finder: unexpected failure", error);
    return json(
      safeUnavailable(
        "Live offers are temporarily unavailable. Use the official sources in the app and verify policy wording before you pay.",
      ),
    );
  }
});
