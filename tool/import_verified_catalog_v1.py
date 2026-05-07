import json
from pathlib import Path

ROOT = Path("/Users/mohammadkhataei/Desktop/UfficioFacile")
SOURCE = Path("/Users/mohammadkhataei/Downloads/ufficiofacile_verified_catalog_seed_v1.json")
DART_OUT = ROOT / "lib/features/italy_admin_copilot/data/catalog/verified_catalog_import_v1.dart"
SQL_OUT = ROOT / "supabase/migrations/20260506170000_seed_verified_catalog_v1.sql"


def dart_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def dart_json_literal(value) -> str:
    return json.dumps(value, ensure_ascii=False, indent=2)


def channel_map(value: str) -> str:
    mapping = {
        "onlinePortal": "online-portal",
        "normalEmail": "normal-email",
        "email": "normal-email",
        "pec": "pec",
        "inPerson": "in-person",
        "raccomandataAR": "raccomandata-ar",
        "officialForm": "online-portal",
        "providerCustomerArea": "online-portal",
        "areraConciliazioneIfUnresolved": "online-portal",
        "inpsOnline": "online-portal",
        "patronato": "in-person",
        "inPersonAgencyWithReceipt": "in-person",
        "whatsappFirst": "whatsapp",
    }
    return mapping.get(value, value)


def category_map(value: str) -> str:
    mapping = {
        "energy": "dualEnergy",
        "telecom": "telecom",
        "health": "health",
        "canoneRai": "canoneRai",
        "housing": "housing",
        "publicOffice": "publicOffice",
        "work": "work",
    }
    return mapping.get(value, value)


def make_display(contact: dict) -> str:
    chunks = []
    for key in ["pec", "email", "phoneFixed", "phoneMobile", "phone", "address"]:
        value = contact.get(key)
        if isinstance(value, list):
            value = ", ".join(str(item) for item in value)
        if value:
            chunks.append(str(value))
    if not chunks and contact.get("value"):
        chunks.append(str(contact["value"]))
    return " | ".join(chunks) if chunks else contact.get("label", "")


def contact_value(contact: dict):
    for key in ["pec", "email", "phoneFixed", "phoneMobile", "address", "value"]:
        value = contact.get(key)
        if isinstance(value, list):
            return ", ".join(str(item) for item in value)
        if value:
            return value
    if isinstance(contact.get("phone"), list):
        return ", ".join(str(item) for item in contact["phone"])
    return contact.get("phone")


def build_official_contacts(raw_contacts, warning):
    contacts = []
    for item in raw_contacts:
        notes = {}
        for key in [
            "pec",
            "email",
            "phone",
            "phoneFixed",
            "phoneMobile",
            "address",
            "warning",
        ]:
            if key in item:
                notes[key] = item[key]
        contacts.append(
            {
                "id": item["id"],
                "label": item["label"],
                "contactType": item["contactType"],
                "category": item["category"],
                "displayValue": make_display(item),
                "verificationStatus": item["verificationStatus"],
                "value": contact_value(item),
                "authorityType": item.get("category"),
                "procedureIds": item.get("procedureIds", []),
                "jurisdiction": item.get("jurisdiction", item.get("city") and "city" or item.get("region") and "regional" or "national"),
                "region": item.get("region"),
                "city": item.get("city"),
                "providerId": item.get("providerId"),
                "providerName": item.get("provider"),
                "sourceUrl": item.get("sourceUrl"),
                "sourceLabel": item.get("sourceLabel"),
                "lastVerifiedAt": f"{item['lastVerifiedAt']}T00:00:00.000" if item.get("lastVerifiedAt") else None,
                "warning": {"en": item.get("warning", warning["en"]), "it": item.get("warning", warning["it"])},
                "notes": notes,
            }
        )
    return contacts


def build_official_links(raw_links, warning):
    links = []
    for item in raw_links:
        notes = {}
        if "warning" in item:
            notes["importWarning"] = item["warning"]
        links.append(
            {
                "id": item["id"],
                "title": item["title"],
                "category": item["category"],
                "descriptionLocalized": {
                    "en": item["title"],
                    "it": item["title"],
                },
                "url": item.get("url", ""),
                "country": "IT",
                "region": item.get("region"),
                "city": item.get("city"),
                "relatedProcedureIds": item.get("procedureIds", []),
                "sourceUrl": item.get("sourceUrl"),
                "sourceLabel": item.get("sourceLabel"),
                "lastVerifiedAt": f"{item['lastVerifiedAt']}T00:00:00.000" if item.get("lastVerifiedAt") else None,
                "verificationStatus": item["verificationStatus"],
                "warningLocalized": warning,
                "notes": notes,
            }
        )
    return links


def build_provider_forms(raw_providers, warning):
    forms = []
    for provider in raw_providers:
        for index, form in enumerate(provider.get("forms", []), start=1):
            form_types = form.get("formTypes", [])
            forms.append(
                {
                    "id": f"{provider['id']}-form-{index}",
                    "providerId": provider["id"],
                    "providerName": provider["name"],
                    "formType": form_types[0] if form_types else "other",
                    "title": form["title"],
                    "description": {"en": form["title"], "it": form["title"]},
                    "verificationStatus": form["verificationStatus"],
                    "url": form.get("url"),
                    "procedureIds": [],
                    "requiredFields": [],
                    "requiredDocuments": [],
                    "submissionChannels": [],
                    "sourceUrl": form.get("url") or provider.get("sourceUrl"),
                    "sourceLabel": provider["name"],
                    "lastVerifiedAt": f"{provider['lastVerifiedAt']}T00:00:00.000" if provider.get("lastVerifiedAt") and form["verificationStatus"] == "verified" else None,
                    "warning": warning,
                }
            )
    return forms


def build_provider_contact_options(raw_providers, warning):
    contacts = []
    for provider in raw_providers:
        for index, contact in enumerate(provider.get("contacts", []), start=1):
            contacts.append(
                {
                    "id": f"{provider['id']}-contact-{index}",
                    "contactType": contact["type"],
                    "label": contact.get("purpose", contact["type"]),
                    "description": {"en": contact.get("purpose", contact["type"]), "it": contact.get("purpose", contact["type"])},
                    "verificationStatus": contact["verificationStatus"],
                    "value": contact.get("value"),
                    "url": contact.get("url"),
                    "sourceUrl": contact.get("sourceUrl"),
                    "sourceLabel": provider["name"],
                    "lastVerifiedAt": f"{provider['lastVerifiedAt']}T00:00:00.000" if provider.get("lastVerifiedAt") and contact["verificationStatus"] == "verified" else None,
                    "warning": {"en": contact.get("warning", warning["en"]), "it": contact.get("warning", warning["it"])},
                    "procedureIds": [],
                    "providerId": provider["id"],
                    "providerName": provider["name"],
                }
            )
    return contacts


def build_service_providers(raw_providers, forms, contact_options, warning):
    forms_by_provider = {}
    for form in forms:
        forms_by_provider.setdefault(form["providerId"], []).append(form)
    contacts_by_provider = {}
    for contact in contact_options:
        contacts_by_provider.setdefault(contact["providerId"], []).append(contact)
    providers = []
    for item in raw_providers:
        provider_id = item["id"]
        providers.append(
            {
                "id": provider_id,
                "name": item["name"],
                "category": category_map(item["category"]),
                "verificationStatus": item["verificationStatus"],
                "websiteUrl": item.get("websiteUrl"),
                "customerAreaUrl": item.get("websiteUrl"),
                "cancellationPageUrl": item.get("sourceUrl"),
                "complaintPageUrl": item.get("sourceUrl"),
                "forms": forms_by_provider.get(provider_id, []),
                "contactOptions": contacts_by_provider.get(provider_id, []),
                "modemReturnGuidance": {
                    "en": "Verify official modem or equipment return rules on the provider page or current customer area.",
                    "it": "Verifica regole ufficiali di restituzione modem o apparati sulla pagina del provider o nell’area clienti aggiornata.",
                } if item["category"] == "telecom" else {},
                "cancellationGuidance": {
                    "en": "Use the official provider instructions, form, PEC, or postal channel listed on the verified source.",
                    "it": "Usa istruzioni, modulo, PEC o canale postale ufficiale indicati nella fonte verificata.",
                },
                "complaintGuidance": {
                    "en": "Keep bill numbers, dates, screenshots, and previous contacts before sending the complaint.",
                    "it": "Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare il reclamo.",
                },
                "paymentPlanGuidance": {
                    "en": "Check whether the provider offers an official instalment or payment-plan route in the customer area or form list.",
                    "it": "Verifica se il provider offre un percorso ufficiale di rateizzazione nell’area clienti o nella modulistica.",
                } if item["category"] == "energy" else {},
                "sourceReferences": [],
                "lastVerifiedAt": f"{item['lastVerifiedAt']}T00:00:00.000" if item.get("lastVerifiedAt") else None,
                "warnings": {"en": warning["en"], "it": warning["it"]},
            }
        )
    return providers


def build_source_references(warning):
    return [
        {
            "id": "inps-naspi-official",
            "title": "INPS - NASpI official guidance",
            "sourceType": "authorityGuidance",
            "referenceLabel": "INPS",
            "url": "https://www.inps.it/it/it/lavoro/disoccupazione.html",
            "explanation": {
                "en": "Use INPS as the primary official source for NASpI service access, application guidance, and unemployment portal orientation.",
                "it": "Usa INPS come fonte ufficiale primaria per accesso al servizio NASpI, guida alla domanda e portale disoccupazione.",
            },
            "relevance": {
                "en": "Relevant for NASpI preparation and application support.",
                "it": "Rilevante per preparazione e supporto alla domanda NASpI.",
            },
            "verificationStatus": "verified",
            "procedureIds": ["NASPI_PREPARATION"],
            "lastVerifiedAt": "2026-05-06T00:00:00.000",
            "warning": warning,
            "notLegalAdvice": True,
        },
        {
            "id": "sportello-consumatore-energy",
            "title": "Sportello per il Consumatore Energia",
            "sourceType": "consumerAuthority",
            "referenceLabel": "Sportello per il Consumatore",
            "url": "https://www.sportelloperilconsumatore.it/",
            "explanation": {
                "en": "Use the consumer sportello and related conciliation path when provider complaints remain unresolved.",
                "it": "Usa lo Sportello per il Consumatore e il relativo percorso di conciliazione quando i reclami al provider restano irrisolti.",
            },
            "relevance": {
                "en": "Relevant for energy bill complaints, written provider complaints, and escalation.",
                "it": "Rilevante per reclami su bollette energia, reclami scritti al provider ed escalation.",
            },
            "verificationStatus": "verified",
            "procedureIds": ["HIGH_BILL_COMPLAINT", "ENERGY_SUPPLIER_COMPARISON"],
            "lastVerifiedAt": "2026-05-06T00:00:00.000",
            "warning": warning,
            "notLegalAdvice": True,
        },
        {
            "id": "agenzia-entrate-rli-reference",
            "title": "Agenzia Entrate - RLI and rental contract changes",
            "sourceType": "taxAuthorityGuidance",
            "referenceLabel": "Agenzia Entrate",
            "url": "https://www.agenziaentrate.gov.it/portale/",
            "explanation": {
                "en": "Use Agenzia Entrate pages for RLI model, instructions, and cessione/subentro contract registration steps.",
                "it": "Usa le pagine Agenzia Entrate per modello RLI, istruzioni e passaggi di registrazione di cessione/subentro del contratto.",
            },
            "relevance": {
                "en": "Relevant for rental contract change procedures.",
                "it": "Rilevante per procedure di variazione del contratto di affitto.",
            },
            "verificationStatus": "verified",
            "procedureIds": ["RENTAL_CONTRACT_CHANGE"],
            "lastVerifiedAt": "2026-05-06T00:00:00.000",
            "warning": warning,
            "notLegalAdvice": True,
        },
        {
            "id": "salute-piemonte-medico-reference",
            "title": "Salute Piemonte / Regione Piemonte - Il mio medico",
            "sourceType": "healthAuthorityGuidance",
            "referenceLabel": "Salute Piemonte",
            "url": "https://www.salutepiemonte.it/",
            "explanation": {
                "en": "Use Piemonte health services and Il mio medico guidance for doctor choice/change and local ASL orientation.",
                "it": "Usa i servizi sanitari piemontesi e la guida Il mio medico per scelta/cambio medico e orientamento ASL locale.",
            },
            "relevance": {
                "en": "Relevant for change doctor and health-card support in Piemonte.",
                "it": "Rilevante per cambio medico e supporto tessera sanitaria in Piemonte.",
            },
            "verificationStatus": "verified",
            "procedureIds": ["CHANGE_DOCTOR", "TESSERA_SANITARIA_RENEWAL"],
            "lastVerifiedAt": "2026-05-06T00:00:00.000",
            "warning": warning,
            "notLegalAdvice": True,
        },
    ]


def build_procedure_overrides(raw_overrides):
    overrides = []
    for item in raw_overrides:
        overrides.append(
            {
                "procedureId": item["procedureId"],
                "officialLinkIds": item.get("addOfficialLinks", []),
                "officialContactIds": [x for x in item.get("addContacts", []) if x != "bologna-protocollo-pec"],
                "providerIds": item.get("providers", []),
                "submissionChannelIds": [channel_map(x) for x in item.get("submissionChannels", [])],
                "requiredDocuments": item.get("requiredDocuments", []),
                "warning": {
                    "en": item.get("warning", ""),
                    "it": item.get("warning", ""),
                },
            }
        )
    return overrides


def build_dart(data):
    warning = data["globalWarning"]
    if "es" not in warning:
        warning["es"] = warning["en"]
        warning["fa"] = warning["en"]
        warning["ar"] = warning["en"]

    official_links = build_official_links(data["officialLinks"], warning)
    official_contacts = build_official_contacts(data["officialContacts"], warning)
    provider_forms = build_provider_forms(data["serviceProviders"], warning)
    provider_contact_options = build_provider_contact_options(data["serviceProviders"], warning)
    service_providers = build_service_providers(
        data["serviceProviders"], provider_forms, provider_contact_options, warning
    )
    source_references = build_source_references(warning)
    procedure_overrides = build_procedure_overrides(data["procedureGuidanceOverrides"])

    return f"""import 'dart:convert';

import '../../domain/catalog_models.dart';
import '../../domain/official_link.dart';

class VerifiedProcedureGuidanceOverride {{
  const VerifiedProcedureGuidanceOverride({{
    required this.procedureId,
    this.officialLinkIds = const <String>[],
    this.officialContactIds = const <String>[],
    this.providerIds = const <String>[],
    this.submissionChannelIds = const <String>[],
    this.requiredDocuments = const <String>[],
    this.warning = const <String, String>{{}},
  }});

  final String procedureId;
  final List<String> officialLinkIds;
  final List<String> officialContactIds;
  final List<String> providerIds;
  final List<String> submissionChannelIds;
  final List<String> requiredDocuments;
  final Map<String, String> warning;

  factory VerifiedProcedureGuidanceOverride.fromJson(Map<String, dynamic> json) =>
      VerifiedProcedureGuidanceOverride(
        procedureId: json['procedureId'] as String? ?? '',
        officialLinkIds: ((json['officialLinkIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        officialContactIds: ((json['officialContactIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        providerIds: ((json['providerIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        submissionChannelIds:
            ((json['submissionChannelIds'] as List?) ?? const [])
                .map((item) => item.toString())
                .toList(),
        requiredDocuments: ((json['requiredDocuments'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{{}},
        ),
      );
}}

final verifiedCatalogOfficialLinks =
    ((jsonDecode(r'''{dart_json_literal(official_links)}''') as List))
        .map((item) => OfficialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList();

final verifiedCatalogOfficialContacts =
    ((jsonDecode(r'''{dart_json_literal(official_contacts)}''') as List))
        .map((item) => OfficialContact.fromJson(Map<String, dynamic>.from(item)))
        .toList();

final verifiedCatalogProviderForms =
    ((jsonDecode(r'''{dart_json_literal(provider_forms)}''') as List))
        .map((item) => ProviderForm.fromJson(Map<String, dynamic>.from(item)))
        .toList();

final verifiedCatalogProviderContactOptions =
    ((jsonDecode(r'''{dart_json_literal(provider_contact_options)}''') as List))
        .map(
          (item) =>
              ProviderContactOption.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

final verifiedCatalogServiceProviders =
    ((jsonDecode(r'''{dart_json_literal(service_providers)}''') as List))
        .map((item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item)))
        .toList();

final verifiedCatalogSourceReferences =
    ((jsonDecode(r'''{dart_json_literal(source_references)}''') as List))
        .map((item) => SourceReference.fromJson(Map<String, dynamic>.from(item)))
        .toList();

final verifiedCatalogProcedureOverrides =
    ((jsonDecode(r'''{dart_json_literal(procedure_overrides)}''') as List))
        .map(
          (item) => VerifiedProcedureGuidanceOverride.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
"""


def sql_quote(value):
    if value is None:
        return "null"
    return "'" + str(value).replace("'", "''") + "'"


def jsonb(value):
    return sql_quote(json.dumps(value, ensure_ascii=False)) + "::jsonb"


def text_array(values):
    escaped = ",".join(sql_quote(v) for v in values)
    return f"ARRAY[{escaped}]::text[]"


PROC_META = {
    "TESSERA_SANITARIA_RENEWAL": ("health", "Tessera Sanitaria Renewal / Health Card Problem"),
    "CHANGE_DOCTOR": ("health", "Change Doctor / Medico di Base Request"),
    "COMUNE_RESIDENCE_REQUEST": ("publicOffice", "Comune / Residenza / Anagrafe Request"),
    "INTERNET_PHONE_CANCELLATION": ("telecom", "Internet / Phone Cancellation"),
    "TELECOM_WRONG_BILL_COMPLAINT": ("telecom", "Telecom Wrong Bill Complaint"),
    "HIGH_BILL_COMPLAINT": ("utilities", "High Bill Complaint"),
    "ENERGY_SUPPLIER_COMPARISON": ("utilities", "Energy Supplier Comparison"),
    "CANONE_RAI_NO_TV_DECLARATION_CHECKLIST": ("canoneRai", "Canone RAI No-TV Declaration Checklist"),
    "CANONE_RAI_REFUND_OR_WRONG_CHARGE": ("canoneRai", "Canone RAI Refund or Wrong Charge"),
    "RENTAL_CONTRACT_CHANGE": ("housing", "Rental Contract Add Tenant / Subentro / Cessione / Integrazione"),
    "LANDLORD_MAINTENANCE_OR_CONTRACT": ("housing", "Landlord Maintenance / Contract Problem Letter"),
    "NASPI_PREPARATION": ("work", "NASpI Preparation"),
}


def build_sql(data):
    warning = data["globalWarning"]
    official_links = build_official_links(data["officialLinks"], warning)
    official_contacts = build_official_contacts(data["officialContacts"], warning)
    provider_forms = build_provider_forms(data["serviceProviders"], warning)
    provider_contact_options = build_provider_contact_options(data["serviceProviders"], warning)
    service_providers = build_service_providers(data["serviceProviders"], provider_forms, provider_contact_options, warning)
    source_references = build_source_references(warning)
    procedure_overrides = build_procedure_overrides(data["procedureGuidanceOverrides"])

    lines = ["-- Verified catalog seed v1 imported from external research pack"]

    for link in official_links:
        lines.append(
            f"""insert into public.ufficio_official_links
(id, title, url, category, description, procedure_ids, jurisdiction, region, city, provider_name, source_url, source_label, verification_status, last_verified_at, warning, notes, is_active, updated_at)
values (
  {sql_quote(link['id'])},
  {sql_quote(link['title'])},
  {sql_quote(link['url'])},
  {sql_quote(link['category'])},
  {jsonb(link['descriptionLocalized'])},
  {text_array(link['relatedProcedureIds'])},
  {sql_quote('regional' if link.get('region') else 'national')},
  {sql_quote(link.get('region'))},
  {sql_quote(link.get('city'))},
  null,
  {sql_quote(link.get('sourceUrl'))},
  {sql_quote(link.get('sourceLabel'))},
  {sql_quote(link['verificationStatus'])},
  {sql_quote(link.get('lastVerifiedAt'))},
  {jsonb(link['warningLocalized'])},
  {jsonb(link.get('notes', {}))},
  true,
  now()
)
on conflict (id) do update set
  title = excluded.title,
  url = excluded.url,
  category = excluded.category,
  description = excluded.description,
  procedure_ids = excluded.procedure_ids,
  jurisdiction = excluded.jurisdiction,
  region = excluded.region,
  city = excluded.city,
  source_url = excluded.source_url,
  source_label = excluded.source_label,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  notes = excluded.notes,
  is_active = true,
  updated_at = now();"""
        )

    for contact in official_contacts:
        lines.append(
            f"""insert into public.ufficio_official_contacts
(id, label, contact_type, value, display_value, category, authority_type, procedure_ids, jurisdiction, region, city, provider_id, provider_name, source_url, source_label, verification_status, last_verified_at, warning, notes, is_active, updated_at)
values (
  {sql_quote(contact['id'])},
  {sql_quote(contact['label'])},
  {sql_quote(contact['contactType'])},
  {sql_quote(contact.get('value'))},
  {sql_quote(contact['displayValue'])},
  {sql_quote(contact['category'])},
  {sql_quote(contact.get('authorityType'))},
  {text_array(contact['procedureIds'])},
  {sql_quote(contact['jurisdiction'])},
  {sql_quote(contact.get('region'))},
  {sql_quote(contact.get('city'))},
  {sql_quote(contact.get('providerId'))},
  {sql_quote(contact.get('providerName'))},
  {sql_quote(contact.get('sourceUrl'))},
  {sql_quote(contact.get('sourceLabel'))},
  {sql_quote(contact['verificationStatus'])},
  {sql_quote(contact.get('lastVerifiedAt'))},
  {jsonb(contact['warning'])},
  {jsonb(contact.get('notes', {}))},
  true,
  now()
)
on conflict (id) do update set
  label = excluded.label,
  contact_type = excluded.contact_type,
  value = excluded.value,
  display_value = excluded.display_value,
  category = excluded.category,
  authority_type = excluded.authority_type,
  procedure_ids = excluded.procedure_ids,
  jurisdiction = excluded.jurisdiction,
  region = excluded.region,
  city = excluded.city,
  provider_id = excluded.provider_id,
  provider_name = excluded.provider_name,
  source_url = excluded.source_url,
  source_label = excluded.source_label,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  notes = excluded.notes,
  is_active = true,
  updated_at = now();"""
        )

    for provider in service_providers:
        lines.append(
            f"""insert into public.ufficio_service_providers
(id, name, normalized_name, category, website_url, customer_area_url, cancellation_page_url, complaint_page_url, modem_return_guidance, cancellation_guidance, complaint_guidance, payment_plan_guidance, source_references, verification_status, last_verified_at, warning, notes, is_active, updated_at)
values (
  {sql_quote(provider['id'])},
  {sql_quote(provider['name'])},
  {sql_quote(provider['id'])},
  {sql_quote(provider['category'])},
  {sql_quote(provider.get('websiteUrl'))},
  {sql_quote(provider.get('customerAreaUrl'))},
  {sql_quote(provider.get('cancellationPageUrl'))},
  {sql_quote(provider.get('complaintPageUrl'))},
  {jsonb(provider.get('modemReturnGuidance', {}))},
  {jsonb(provider.get('cancellationGuidance', {}))},
  {jsonb(provider.get('complaintGuidance', {}))},
  {jsonb(provider.get('paymentPlanGuidance', {}))},
  {text_array(provider.get('sourceReferences', []))},
  {sql_quote(provider['verificationStatus'])},
  {sql_quote(provider.get('lastVerifiedAt'))},
  {jsonb(provider.get('warnings', {}))},
  '{{}}'::jsonb,
  true,
  now()
)
on conflict (id) do update set
  name = excluded.name,
  normalized_name = excluded.normalized_name,
  category = excluded.category,
  website_url = excluded.website_url,
  customer_area_url = excluded.customer_area_url,
  cancellation_page_url = excluded.cancellation_page_url,
  complaint_page_url = excluded.complaint_page_url,
  modem_return_guidance = excluded.modem_return_guidance,
  cancellation_guidance = excluded.cancellation_guidance,
  complaint_guidance = excluded.complaint_guidance,
  payment_plan_guidance = excluded.payment_plan_guidance,
  source_references = excluded.source_references,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  is_active = true,
  updated_at = now();"""
        )

    for form in provider_forms:
        lines.append(
            f"""insert into public.ufficio_provider_forms
(id, provider_id, provider_name, form_type, title, description, url, procedure_ids, required_fields, required_documents, submission_channels, source_url, source_label, verification_status, last_verified_at, warning, notes, is_active, updated_at)
values (
  {sql_quote(form['id'])},
  {sql_quote(form['providerId'])},
  {sql_quote(form['providerName'])},
  {sql_quote(form['formType'])},
  {sql_quote(form['title'])},
  {jsonb(form['description'])},
  {sql_quote(form.get('url'))},
  {text_array(form.get('procedureIds', []))},
  {jsonb(form.get('requiredFields', []))},
  {jsonb(form.get('requiredDocuments', []))},
  {text_array(form.get('submissionChannels', []))},
  {sql_quote(form.get('sourceUrl'))},
  {sql_quote(form.get('sourceLabel'))},
  {sql_quote(form['verificationStatus'])},
  {sql_quote(form.get('lastVerifiedAt'))},
  {jsonb(form.get('warning', {}))},
  '{{}}'::jsonb,
  true,
  now()
)
on conflict (id) do update set
  provider_id = excluded.provider_id,
  provider_name = excluded.provider_name,
  form_type = excluded.form_type,
  title = excluded.title,
  description = excluded.description,
  url = excluded.url,
  procedure_ids = excluded.procedure_ids,
  required_fields = excluded.required_fields,
  required_documents = excluded.required_documents,
  submission_channels = excluded.submission_channels,
  source_url = excluded.source_url,
  source_label = excluded.source_label,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  is_active = true,
  updated_at = now();"""
        )

    for contact in provider_contact_options:
        lines.append(
            f"""insert into public.ufficio_provider_contact_options
(id, provider_id, provider_name, contact_type, label, value, url, description, procedure_ids, source_url, source_label, verification_status, last_verified_at, warning, notes, is_active, updated_at)
values (
  {sql_quote(contact['id'])},
  {sql_quote(contact['providerId'])},
  {sql_quote(contact['providerName'])},
  {sql_quote(contact['contactType'])},
  {sql_quote(contact['label'])},
  {sql_quote(contact.get('value'))},
  {sql_quote(contact.get('url'))},
  {jsonb(contact['description'])},
  {text_array(contact.get('procedureIds', []))},
  {sql_quote(contact.get('sourceUrl'))},
  {sql_quote(contact.get('sourceLabel'))},
  {sql_quote(contact['verificationStatus'])},
  {sql_quote(contact.get('lastVerifiedAt'))},
  {jsonb(contact.get('warning', {}))},
  '{{}}'::jsonb,
  true,
  now()
)
on conflict (id) do update set
  provider_id = excluded.provider_id,
  provider_name = excluded.provider_name,
  contact_type = excluded.contact_type,
  label = excluded.label,
  value = excluded.value,
  url = excluded.url,
  description = excluded.description,
  procedure_ids = excluded.procedure_ids,
  source_url = excluded.source_url,
  source_label = excluded.source_label,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  is_active = true,
  updated_at = now();"""
        )

    for ref in source_references:
        lines.append(
            f"""insert into public.ufficio_source_references
(id, title, source_type, reference_label, url, explanation, relevance, procedure_ids, verification_status, last_verified_at, warning, notes, not_legal_advice, is_active, updated_at)
values (
  {sql_quote(ref['id'])},
  {sql_quote(ref['title'])},
  {sql_quote(ref['sourceType'])},
  {sql_quote(ref.get('referenceLabel'))},
  {sql_quote(ref.get('url'))},
  {jsonb(ref['explanation'])},
  {jsonb(ref['relevance'])},
  {text_array(ref['procedureIds'])},
  {sql_quote(ref['verificationStatus'])},
  {sql_quote(ref.get('lastVerifiedAt'))},
  {jsonb(ref['warning'])},
  '{{}}'::jsonb,
  {'true' if ref.get('notLegalAdvice', True) else 'false'},
  true,
  now()
)
on conflict (id) do update set
  title = excluded.title,
  source_type = excluded.source_type,
  reference_label = excluded.reference_label,
  url = excluded.url,
  explanation = excluded.explanation,
  relevance = excluded.relevance,
  procedure_ids = excluded.procedure_ids,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  not_legal_advice = excluded.not_legal_advice,
  is_active = true,
  updated_at = now();"""
        )

    for override in procedure_overrides:
        category, title = PROC_META[override["procedureId"]]
        lines.append(
            f"""insert into public.ufficio_procedure_guidance
(id, procedure_id, category, title, summary, destination_guidance, contact_rules, provider_rules, city_region_rules, submission_channels, official_links, official_contacts, provider_ids, region_ids, city_ids, required_documents, recommended_documents, proof_items, source_references, before_sending_checklist, warning, verification_status, last_verified_at, notes, is_active, updated_at)
values (
  {sql_quote('verified-' + override['procedureId'].lower())},
  {sql_quote(override['procedureId'])},
  {sql_quote(category)},
  {sql_quote(title)},
  '{{}}'::jsonb,
  '{{}}'::jsonb,
  '{{}}'::jsonb,
  '{{}}'::jsonb,
  '{{}}'::jsonb,
  {text_array(override['submissionChannelIds'])},
  {text_array(override['officialLinkIds'])},
  {text_array(override['officialContactIds'])},
  {text_array(override['providerIds'])},
  ARRAY[]::text[],
  ARRAY[]::text[],
  {text_array(override['requiredDocuments'])},
  ARRAY[]::text[],
  ARRAY[]::text[],
  ARRAY[]::text[],
  ARRAY[]::text[],
  {jsonb(override['warning'])},
  'verified',
  '2026-05-06T00:00:00.000',
  '{{"importedFrom":"verified_catalog_seed_v1"}}'::jsonb,
  true,
  now()
)
on conflict (procedure_id) do update set
  category = excluded.category,
  title = excluded.title,
  submission_channels = excluded.submission_channels,
  official_links = excluded.official_links,
  official_contacts = excluded.official_contacts,
  provider_ids = excluded.provider_ids,
  required_documents = excluded.required_documents,
  warning = excluded.warning,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  notes = excluded.notes,
  is_active = true,
  updated_at = now();"""
        )

    return "\n\n".join(lines) + "\n"


def main():
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    DART_OUT.write_text(build_dart(data), encoding="utf-8")
    SQL_OUT.write_text(build_sql(data), encoding="utf-8")
    print("wrote", DART_OUT)
    print("wrote", SQL_OUT)


if __name__ == "__main__":
    main()
