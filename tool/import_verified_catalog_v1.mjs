import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const repoRoot = process.cwd();
const inputPath =
  process.argv[2] ??
  '/Users/mohammadkhataei/Downloads/ufficiofacile_verified_catalog_seed_v1.json';
const dartOutputPath = path.join(
  repoRoot,
  'lib/features/italy_admin_copilot/data/catalog/verified_catalog_import_v1.dart',
);
const sqlOutputPath = path.join(
  repoRoot,
  'supabase/migrations/20260506100000_seed_verified_catalog_v1.sql',
);

const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));

const genericWarning = {
  en: 'Contacts and links may change. Verify on the official website before sending.',
  it: "Contatti e link possono cambiare. Verifica sul sito ufficiale prima dell'invio.",
  es: 'Los contactos y enlaces pueden cambiar. Verifícalos en el sitio oficial antes de enviar.',
  fa: 'لینک‌ها و اطلاعات تماس ممکن است تغییر کنند. قبل از ارسال در وب‌سایت رسمی بررسی کنید.',
  ar: 'قد تتغير الروابط وجهات الاتصال. تحقق من الموقع الرسمي قبل الإرسال.',
};

const needsReviewWarning = {
  en: 'This information still needs review before use.',
  it: "Questa informazione richiede ancora verifica prima dell'uso.",
  es: 'Esta información todavía necesita revisión antes de usarse.',
  fa: 'این اطلاعات هنوز قبل از استفاده نیاز به بررسی دارد.',
  ar: 'هذه المعلومات ما زالت تحتاج إلى مراجعة قبل الاستخدام.',
};

const noLegalAdviceWarning = {
  en: 'This is practical guidance only and not legal advice.',
  it: 'Questa è solo guida pratica e non consulenza legale.',
  es: 'Esta es solo una guía práctica y no asesoramiento legal.',
  fa: 'این فقط راهنمای عملی است و مشاوره حقوقی نیست.',
  ar: 'هذه إرشادات عملية فقط وليست استشارة قانونية.',
};

const energyProviderIdMap = {
  edison: 'edison-energia',
  a2a: 'a2a-energia',
};

const procedureCategoryMap = {
  TESSERA_SANITARIA_RENEWAL: 'health',
  CHANGE_DOCTOR: 'health',
  COMUNE_RESIDENCE_REQUEST: 'comune',
  INTERNET_PHONE_CANCELLATION: 'telecom',
  TELECOM_WRONG_BILL_COMPLAINT: 'telecom',
  HIGH_BILL_COMPLAINT: 'utilities',
  ENERGY_SUPPLIER_COMPARISON: 'utilities',
  CANONE_RAI_NO_TV_DECLARATION_CHECKLIST: 'canoneRai',
  CANONE_RAI_REFUND_OR_WRONG_CHARGE: 'canoneRai',
  RENTAL_CONTRACT_CHANGE: 'housing',
  LANDLORD_MAINTENANCE_OR_CONTRACT: 'housing',
  NASPI_PREPARATION: 'work',
};

const procedureTitleMap = {
  TESSERA_SANITARIA_RENEWAL: 'Tessera Sanitaria Renewal / Health Card Problem',
  CHANGE_DOCTOR: 'Change Family Doctor / Medico di Base',
  COMUNE_RESIDENCE_REQUEST: 'Comune Residence Request',
  INTERNET_PHONE_CANCELLATION: 'Internet / Phone Cancellation',
  TELECOM_WRONG_BILL_COMPLAINT: 'Telecom Wrong Bill Complaint',
  HIGH_BILL_COMPLAINT: 'High Bill Complaint',
  ENERGY_SUPPLIER_COMPARISON: 'Energy Supplier Comparison',
  CANONE_RAI_NO_TV_DECLARATION_CHECKLIST: 'Canone RAI No-TV Declaration Checklist',
  CANONE_RAI_REFUND_OR_WRONG_CHARGE: 'Canone RAI Refund or Wrong Charge',
  RENTAL_CONTRACT_CHANGE: 'Rental Contract Change',
  LANDLORD_MAINTENANCE_OR_CONTRACT: 'Landlord Maintenance / Contract Problem',
  NASPI_PREPARATION: 'NASpI Preparation',
};

const channelMap = {
  onlinePortal: 'online-portal',
  inPerson: 'in-person',
  pec: 'pec',
  normalEmail: 'normal-email',
  email: 'normal-email',
  raccomandataAR: 'raccomandata-ar',
  officialForm: 'official-form',
  providerCustomerArea: 'provider-customer-area',
  phone: 'phone-support',
  inPersonStore: 'in-person-store',
  inPersonAgencyWithReceipt: 'in-person',
  whatsappFirst: 'whatsapp',
  inpsOnline: 'online-portal',
  patronato: 'patronato',
  areraConciliazioneIfUnresolved: 'online-portal',
};

function stableUuid(seed) {
  const hex = crypto.createHash('md5').update(seed).digest('hex');
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-4${hex.slice(13, 16)}-a${hex.slice(17, 20)}-${hex.slice(20, 32)}`;
}

function isoDate(value) {
  if (!value) return null;
  return `${value}T00:00:00Z`;
}

function verificationStatus(value) {
  return value ?? 'needsReview';
}

function warningMap(status, customWarning) {
  if (customWarning && status !== 'verified') {
    return {
      ...needsReviewWarning,
      en: customWarning,
      it: customWarning,
    };
  }
  return status === 'verified' ? genericWarning : needsReviewWarning;
}

function officialLinkDescription(link) {
  const label = link.sourceLabel ?? link.title;
  return {
    en: `Official ${label} page for this procedure. Verify the current path before sending personal data.`,
    it: `Pagina ufficiale ${label} per questa procedura. Verifica il percorso attuale prima di inviare dati personali.`,
  };
}

function providerGuidance(name, kind) {
  const nounEn =
    kind === 'cancellation'
      ? 'cancellation'
      : kind === 'complaint'
        ? 'complaint'
        : kind === 'payment'
          ? 'payment-plan'
          : 'equipment return';
  const nounIt =
    kind === 'cancellation'
      ? 'disdetta'
      : kind === 'complaint'
        ? 'reclamo'
        : kind === 'payment'
          ? 'rateizzazione'
          : 'restituzione apparati';
  return {
    en: `Check the official ${name} website, customer area, or published forms for the current ${nounEn} path and proof requirements.`,
    it: `Controlla il sito ufficiale ${name}, l'area clienti o la modulistica pubblicata per il percorso attuale di ${nounIt} e le prove richieste.`,
  };
}

function normalizedProviderId(rawId) {
  return energyProviderIdMap[rawId] ?? rawId;
}

function normalizedProviderCategory(rawCategory) {
  if (rawCategory === 'energy') return 'dualEnergy';
  return rawCategory ?? 'other';
}

function buildOfficialLinks() {
  return data.officialLinks.map((link) => ({
    id: link.id,
    title: link.title,
    category: link.category,
    descriptionLocalized: officialLinkDescription(link),
    url: link.url ?? '',
    country: 'IT',
    region: link.region ?? null,
    city: link.city ?? null,
    relatedProcedureIds: link.procedureIds ?? [],
    sourceUrl: link.sourceUrl ?? link.url ?? null,
    sourceLabel: link.sourceLabel ?? null,
    lastVerifiedAt: isoDate(link.lastVerifiedAt),
    verificationStatus: verificationStatus(link.verificationStatus),
    warningLocalized: warningMap(link.verificationStatus),
    notes: {},
  }));
}

function buildOfficialContacts() {
  return data.officialContacts.map((contact) => {
    const displayParts = [];
    const valueCandidates = [];
    if (contact.pec) {
      displayParts.push(`PEC: ${contact.pec}`);
      valueCandidates.push(contact.pec);
    }
    if (contact.email) {
      displayParts.push(`Email: ${contact.email}`);
      valueCandidates.push(contact.email);
    }
    if (contact.phoneFixed) displayParts.push(`Phone: ${contact.phoneFixed}`);
    if (contact.phoneMobile) displayParts.push(`Mobile: ${contact.phoneMobile}`);
    if (contact.address) displayParts.push(`Address: ${contact.address}`);
    if (contact.value) {
      displayParts.push(contact.value);
      valueCandidates.push(contact.value);
    }
    return {
      id: contact.id,
      label: contact.label,
      contactType: contact.contactType,
      category: contact.category,
      displayValue: displayParts.join('\n') || contact.label,
      verificationStatus: verificationStatus(contact.verificationStatus),
      value: valueCandidates[0] ?? null,
      authorityType: contact.authorityType ?? null,
      procedureIds: contact.procedureIds ?? [],
      jurisdiction: contact.jurisdiction ?? 'national',
      region: contact.region ?? null,
      city: contact.city ?? null,
      providerId: contact.providerId ? normalizedProviderId(contact.providerId) : null,
      providerName: contact.providerName ?? null,
      sourceUrl: contact.sourceUrl ?? null,
      sourceLabel: contact.sourceLabel ?? null,
      lastVerifiedAt: isoDate(contact.lastVerifiedAt),
      warning: warningMap(contact.verificationStatus, contact.warning),
      notes: {
        ...(contact.phoneFixed ? { phoneFixed: contact.phoneFixed } : {}),
        ...(contact.phoneMobile ? { phoneMobile: contact.phoneMobile } : {}),
        ...(contact.email ? { email: contact.email } : {}),
        ...(contact.pec ? { pec: contact.pec } : {}),
        ...(contact.address ? { address: contact.address } : {}),
      },
    };
  });
}

function buildProviders() {
  return data.serviceProviders.map((provider) => {
    const providerId = normalizedProviderId(provider.id);
    const status = verificationStatus(provider.verificationStatus);
    const contactOptions = (provider.contacts ?? []).map((contact, index) => ({
      id: `${providerId}-${contact.type}-${index + 1}`,
      contactType:
        contact.type === 'postal'
          ? 'postalAddress'
          : contact.type === 'customerArea'
            ? 'customerArea'
            : contact.type,
      label: `${provider.name} ${contact.type}`,
      description: {
        en: contact.purpose
          ? `Official ${provider.name} contact for ${contact.purpose}.`
          : `Official ${provider.name} contact option.`,
        it: contact.purpose
          ? `Contatto ufficiale ${provider.name} per ${contact.purpose}.`
          : `Canale di contatto ufficiale ${provider.name}.`,
      },
      verificationStatus: verificationStatus(contact.verificationStatus),
      value: Array.isArray(contact.value)
        ? contact.value.join(' / ')
        : (contact.value ?? null),
      url: contact.url ?? null,
      sourceUrl: contact.sourceUrl ?? provider.sourceUrl ?? null,
      sourceLabel: provider.name,
      lastVerifiedAt: isoDate(provider.lastVerifiedAt),
      warning: warningMap(contact.verificationStatus),
      procedureIds: provider.category === 'telecom'
        ? [
            'INTERNET_PHONE_CANCELLATION',
            'TELECOM_WRONG_BILL_COMPLAINT',
            'SERVICE_NOT_WORKING_COMPLAINT',
            'MODEM_RETURN_OR_CHARGE_DISPUTE',
          ]
        : [
            'HIGH_BILL_COMPLAINT',
            'ENERGY_SUPPLIER_COMPARISON',
            'PAYMENT_PLAN_REQUEST',
            'WRONG_CHARGE_REFUND_REQUEST',
          ],
    }));
    const forms = (provider.forms ?? []).map((form, index) => ({
      id: `${providerId}-form-${index + 1}`,
      providerId,
      providerName: provider.name,
      formType: form.formTypes?.[0] ?? 'other',
      title: form.title,
      description: {
        en: `Official ${provider.name} form or page. Verify the current requirements before submitting.`,
        it: `Modulo o pagina ufficiale ${provider.name}. Verifica i requisiti attuali prima dell'invio.`,
      },
      verificationStatus: verificationStatus(form.verificationStatus),
      url: form.url ?? null,
      procedureIds: provider.category === 'telecom'
        ? ['INTERNET_PHONE_CANCELLATION', 'TELECOM_WRONG_BILL_COMPLAINT']
        : ['HIGH_BILL_COMPLAINT', 'ENERGY_SUPPLIER_COMPARISON'],
      requiredFields: [],
      requiredDocuments: [],
      submissionChannels: provider.category === 'telecom'
        ? ['provider-customer-area', 'official-form', 'pec', 'raccomandata-ar']
        : ['provider-customer-area', 'official-form', 'pec', 'raccomandata-ar'],
      sourceUrl: form.url ?? provider.sourceUrl ?? null,
      sourceLabel: provider.name,
      lastVerifiedAt: isoDate(provider.lastVerifiedAt),
      warning: warningMap(form.verificationStatus),
    }));
    return {
      id: providerId,
      name: provider.name,
      category: normalizedProviderCategory(provider.category),
      verificationStatus: status,
      websiteUrl: provider.websiteUrl ?? null,
      customerAreaUrl:
        (provider.contacts ?? []).find((contact) => contact.type === 'customerArea')?.sourceUrl ??
        null,
      cancellationPageUrl:
        provider.category === 'telecom' ? provider.sourceUrl ?? null : null,
      complaintPageUrl:
        provider.category === 'energy' ? provider.sourceUrl ?? null : null,
      forms,
      contactOptions,
      modemReturnGuidance: providerGuidance(provider.name, 'modem'),
      cancellationGuidance: providerGuidance(provider.name, 'cancellation'),
      complaintGuidance: providerGuidance(provider.name, 'complaint'),
      paymentPlanGuidance: providerGuidance(provider.name, 'payment'),
      sourceReferences:
        provider.category === 'telecom'
          ? ['agcom-conciliaweb', 'agcom-assistance-ref']
          : ['arera-portale-offerte', 'sportello-consumatore-ref'],
      lastVerifiedAt: isoDate(provider.lastVerifiedAt),
      warnings: warningMap(status),
    };
  });
}

function buildSourceReferences() {
  return [
    {
      id: 'inps-naspi-ref',
      title: 'INPS - NASpI guidance',
      sourceType: 'authorityGuidance',
      referenceLabel: 'INPS',
      url: 'https://www.inps.it/it/it/lavoro/disoccupazione/naspi.html',
      explanation: {
        en: 'Use the official INPS NASpI guidance and service pages before preparing or sending unemployment requests.',
        it: 'Usa le pagine ufficiali INPS dedicate alla NASpI prima di preparare o inviare richieste sulla disoccupazione.',
      },
      relevance: {
        en: 'Relevant for NASpI preparation, document checks, and portal steps.',
        it: 'Rilevante per preparazione NASpI, controllo documenti e passaggi sul portale.',
      },
      verificationStatus: 'verified',
      procedureIds: ['NASPI_PREPARATION'],
      lastVerifiedAt: '2026-05-06T00:00:00Z',
      warning: noLegalAdviceWarning,
      notLegalAdvice: true,
    },
    {
      id: 'sportello-consumatore-ref',
      title: 'ARERA / Sportello per il Consumatore',
      sourceType: 'energyAuthorityGuidance',
      referenceLabel: 'ARERA',
      url: 'https://www.sportelloperilconsumatore.it/',
      explanation: {
        en: 'Use the Sportello per il Consumatore for official consumer support and complaint escalation context in the energy sector.',
        it: 'Usa lo Sportello per il Consumatore per supporto ufficiale ai consumatori e contesto di escalation dei reclami nel settore energia.',
      },
      relevance: {
        en: 'Relevant for high bills, unresolved complaints, and escalation after provider contact.',
        it: 'Rilevante per bollette alte, reclami irrisolti ed escalation dopo il contatto con il provider.',
      },
      verificationStatus: 'verified',
      procedureIds: [
        'HIGH_BILL_COMPLAINT',
        'ENERGY_SUPPLIER_COMPARISON',
        'PAYMENT_PLAN_REQUEST',
        'WRONG_CHARGE_REFUND_REQUEST',
      ],
      lastVerifiedAt: '2026-05-06T00:00:00Z',
      warning: noLegalAdviceWarning,
      notLegalAdvice: true,
    },
    {
      id: 'agcom-assistance-ref',
      title: 'AGCOM assistance and ConciliaWeb guidance',
      sourceType: 'telecomAuthorityGuidance',
      referenceLabel: 'AGCOM',
      url: 'https://conciliaweb.agcom.it/conciliaweb/contatti/assistenza.htm',
      explanation: {
        en: 'Use AGCOM assistance and ConciliaWeb guidance for telecom dispute support, complaint escalation, and platform orientation.',
        it: 'Usa l’assistenza AGCOM e la guida ConciliaWeb per supporto su controversie telecom, escalation dei reclami e orientamento alla piattaforma.',
      },
      relevance: {
        en: 'Relevant for wrong bills, service issues, modem disputes, and unresolved telecom complaints.',
        it: 'Rilevante per bollette errate, problemi di servizio, controversie sul modem e reclami telecom irrisolti.',
      },
      verificationStatus: 'verified',
      procedureIds: [
        'INTERNET_PHONE_CANCELLATION',
        'TELECOM_WRONG_BILL_COMPLAINT',
        'SERVICE_NOT_WORKING_COMPLAINT',
        'MODEM_RETURN_OR_CHARGE_DISPUTE',
      ],
      lastVerifiedAt: '2026-05-06T00:00:00Z',
      warning: noLegalAdviceWarning,
      notLegalAdvice: true,
    },
    {
      id: 'agenzia-entrate-rli-ref',
      title: 'Agenzia Entrate - RLI and rental contract changes',
      sourceType: 'taxAuthorityGuidance',
      referenceLabel: 'Agenzia Entrate',
      url: 'https://www.agenziaentrate.gov.it/portale/web/guest/schede/istanze/rli-web',
      explanation: {
        en: 'Use Agenzia Entrate RLI guidance for official rental contract registration changes, cessions, and subentro steps.',
        it: 'Usa la guida RLI dell’Agenzia Entrate per variazioni ufficiali di registrazione del contratto di locazione, cessioni e subentro.',
      },
      relevance: {
        en: 'Relevant for rental contract change procedures and official tax-side steps.',
        it: 'Rilevante per procedure di variazione del contratto di affitto e passaggi fiscali ufficiali.',
      },
      verificationStatus: 'verified',
      procedureIds: [
        'RENTAL_CONTRACT_CHANGE',
        'LANDLORD_MAINTENANCE_OR_CONTRACT',
      ],
      lastVerifiedAt: '2026-05-06T00:00:00Z',
      warning: noLegalAdviceWarning,
      notLegalAdvice: true,
    },
  ];
}

function buildProcedureGuidance() {
  return data.procedureGuidanceOverrides.map((item) => {
    const procedureId = item.procedureId;
    const warningText = item.warning ?? data.globalWarning;
    const providers = (item.providers ?? []).map(normalizedProviderId);
    const contactIds = (item.addContacts ?? []).filter((id) => id !== 'bologna-protocollo-pec');
    const officialLinkIds = [...(item.addOfficialLinks ?? [])];
    const sourceReferences = [];
    if (procedureId === 'NASPI_PREPARATION') sourceReferences.push('inps-naspi-ref');
    if (procedureId === 'NASPI_PREPARATION') {
      officialLinkIds.push(
        'inps-naspi-servizio',
        'inps-naspi-come-fare-domanda',
        'inps-portale-disoccupazione',
      );
    }
    if (
      ['HIGH_BILL_COMPLAINT', 'ENERGY_SUPPLIER_COMPARISON'].includes(procedureId)
    ) {
      sourceReferences.push('arera-portale-offerte', 'sportello-consumatore-ref');
      officialLinkIds.push(
        'arera-consumatori',
        'arera-conciliazione',
        'sportello-consumatore-conciliazione',
      );
    }
    if (
      ['INTERNET_PHONE_CANCELLATION', 'TELECOM_WRONG_BILL_COMPLAINT'].includes(
        procedureId,
      )
    ) {
      sourceReferences.push('agcom-conciliaweb', 'agcom-assistance-ref');
      officialLinkIds.push(
        'agcom-conciliaweb',
        'agcom-contenzioso',
        'agcom-assistenza',
      );
    }
    if (
      ['CANONE_RAI_NO_TV_DECLARATION_CHECKLIST', 'CANONE_RAI_REFUND_OR_WRONG_CHARGE'].includes(
        procedureId,
      )
    ) {
      sourceReferences.push('agentrate-canone-rai');
    }
    if (
      ['RENTAL_CONTRACT_CHANGE', 'LANDLORD_MAINTENANCE_OR_CONTRACT'].includes(
        procedureId,
      )
    ) {
      sourceReferences.push('agenzia-entrate-rli-ref', 'rental-civil-code-placeholder');
    }
    return {
      id: `verified-${procedureId.toLowerCase()}`,
      procedureId,
      category: procedureCategoryMap[procedureId] ?? 'general',
      title: procedureTitleMap[procedureId] ?? procedureId,
      summary: {
        en: warningText,
        it: warningText,
      },
      destinationGuidance: {
        en: warningText,
        it: warningText,
      },
      contactRules: {},
      providerRules: {},
      cityRegionRules: {},
      submissionChannelIds: (item.submissionChannels ?? [])
        .map((value) => channelMap[value] ?? value)
        .filter(Boolean),
      officialLinkIds: [...new Set(officialLinkIds)],
      officialContactIds: contactIds,
      providerIds: providers,
      regionIds: [],
      cityIds: [],
      requiredDocuments: item.requiredDocuments ?? [],
      recommendedDocuments: [],
      proofItems: item.requiredDocuments ?? [],
      sourceReferenceIds: sourceReferences,
      beforeSendingChecklist: [
        'Verify the current official channel before sending.',
        'Keep proof of submission, screenshots, or receipts.',
      ],
      verificationStatus: 'needsReview',
      lastVerifiedAt: null,
      warnings: warningMap('needsReview', warningText),
      notes: {
        importedFromVerifiedSeed: true,
      },
    };
  });
}

function encodeDartJson(value) {
  return `jsonDecode(r'''${JSON.stringify(value, null, 2)}''') as Map<String, dynamic>`;
}

const officialLinks = buildOfficialLinks();
const officialContacts = buildOfficialContacts();
const serviceProviders = buildProviders();
const sourceReferences = buildSourceReferences();
const procedureGuidance = buildProcedureGuidance();

const dartFile = `import 'dart:convert';

import '../../domain/catalog_models.dart';

final verifiedCatalogOfficialLinks = <OfficialLink>[
${officialLinks.map((item) => `  OfficialLink.fromJson(${encodeDartJson(item)}),`).join('\n')}
];

final verifiedCatalogOfficialContacts = <OfficialContact>[
${officialContacts.map((item) => `  OfficialContact.fromJson(${encodeDartJson(item)}),`).join('\n')}
];

final verifiedCatalogServiceProviders = <ServiceProvider>[
${serviceProviders.map((item) => `  ServiceProvider.fromJson(${encodeDartJson(item)}),`).join('\n')}
];

final verifiedCatalogProviderForms = <ProviderForm>[
  ...verifiedCatalogServiceProviders.expand((item) => item.forms),
];

final verifiedCatalogSourceReferences = <SourceReference>[
${sourceReferences.map((item) => `  SourceReference.fromJson(${encodeDartJson(item)}),`).join('\n')}
];

final verifiedCatalogProcedureGuidance = <ProcedureGuidance>[
${procedureGuidance.map((item) => `  ProcedureGuidance.fromJson(${encodeDartJson(item)}),`).join('\n')}
];

final verifiedCatalogResearchTodos = <String>[
${(data.stillNeedsResearch ?? []).map((item) => `  ${JSON.stringify(item)},`).join('\n')}
];
`;

fs.writeFileSync(dartOutputPath, dartFile);

function sqlString(value) {
  if (value === null || value === undefined) return 'null';
  return `'${String(value).replace(/'/g, "''")}'`;
}

function sqlJson(value) {
  return `${sqlString(JSON.stringify(value))}::jsonb`;
}

function sqlArray(values) {
  if (!values || values.length === 0) {
    return "'{}'::text[]";
  }
  return `ARRAY[${values.map(sqlString).join(', ')}]::text[]`;
}

function linkRowSql(link) {
  return `(
  '${stableUuid(`ufficio-link:${link.id}`)}',
  ${sqlString(link.title)},
  ${sqlString(link.url)},
  ${sqlString(link.category)},
  ${sqlJson(link.descriptionLocalized)},
  ${sqlArray(link.relatedProcedureIds)},
  'national',
  ${sqlString(link.region)},
  ${sqlString(link.city)},
  null,
  null,
  ${sqlString(link.sourceUrl)},
  ${sqlString(link.sourceLabel)},
  ${sqlString(link.verificationStatus)},
  ${sqlString(link.lastVerifiedAt)},
  ${sqlJson(link.warningLocalized)},
  '{}'::jsonb,
  true
)`;
}

function contactRowSql(contact) {
  return `(
  '${stableUuid(`ufficio-contact:${contact.id}`)}',
  ${sqlString(contact.label)},
  ${sqlString(contact.contactType)},
  ${sqlString(contact.value)},
  ${sqlString(contact.displayValue)},
  ${sqlString(contact.category)},
  ${sqlString(contact.authorityType)},
  ${sqlArray(contact.procedureIds)},
  ${sqlString(contact.jurisdiction)},
  ${sqlString(contact.region)},
  ${sqlString(contact.city)},
  ${sqlString(contact.providerId)},
  ${sqlString(contact.providerName)},
  ${sqlString(contact.sourceUrl)},
  ${sqlString(contact.sourceLabel)},
  ${sqlString(contact.verificationStatus)},
  ${sqlString(contact.lastVerifiedAt)},
  ${sqlJson(contact.warning)},
  ${sqlJson(contact.notes)},
  true
)`;
}

function providerRowSql(provider) {
  return `(
  ${sqlString(provider.id)},
  ${sqlString(provider.name)},
  ${sqlString(provider.name.toLowerCase())},
  ${sqlString(provider.category)},
  ${sqlString(provider.websiteUrl)},
  ${sqlString(provider.customerAreaUrl)},
  ${sqlString(provider.cancellationPageUrl)},
  ${sqlString(provider.complaintPageUrl)},
  ${sqlJson(provider.modemReturnGuidance)},
  ${sqlJson(provider.cancellationGuidance)},
  ${sqlJson(provider.complaintGuidance)},
  ${sqlJson(provider.paymentPlanGuidance)},
  ${sqlArray(provider.sourceReferences)},
  ${sqlString(provider.verificationStatus)},
  ${sqlString(provider.lastVerifiedAt)},
  ${sqlJson(provider.warnings)},
  '{}'::jsonb,
  true
)`;
}

function providerFormRowSql(form) {
  return `(
  ${sqlString(form.id)},
  ${sqlString(form.providerId)},
  ${sqlString(form.providerName)},
  ${sqlString(form.formType)},
  ${sqlString(form.title)},
  ${sqlJson(form.description)},
  ${sqlString(form.url)},
  ${sqlArray(form.procedureIds)},
  ${sqlJson(form.requiredFields)},
  ${sqlJson(form.requiredDocuments)},
  ${sqlArray(form.submissionChannels)},
  ${sqlString(form.sourceUrl)},
  ${sqlString(form.sourceLabel)},
  ${sqlString(form.verificationStatus)},
  ${sqlString(form.lastVerifiedAt)},
  ${sqlJson(form.warning)},
  '{}'::jsonb,
  true
)`;
}

function providerContactRowSql(option, providerName) {
  return `(
  ${sqlString(option.id)},
  ${sqlString(option.id.split('-').slice(0, -2).join('-'))},
  ${sqlString(providerName)},
  ${sqlString(option.contactType)},
  ${sqlString(option.label)},
  ${sqlString(option.value)},
  ${sqlString(option.url)},
  ${sqlJson(option.description)},
  ${sqlArray(option.procedureIds)},
  ${sqlString(option.sourceUrl)},
  ${sqlString(option.sourceLabel)},
  ${sqlString(option.verificationStatus)},
  ${sqlString(option.lastVerifiedAt)},
  ${sqlJson(option.warning)},
  '{}'::jsonb,
  true
)`;
}

function sourceReferenceRowSql(ref) {
  return `(
  ${sqlString(ref.id)},
  ${sqlString(ref.title)},
  ${sqlString(ref.sourceType)},
  ${sqlString(ref.referenceLabel)},
  ${sqlString(ref.url)},
  ${sqlJson(ref.explanation)},
  ${sqlJson(ref.relevance)},
  ${sqlArray(ref.procedureIds)},
  ${sqlString(ref.verificationStatus)},
  ${sqlString(ref.lastVerifiedAt)},
  ${sqlJson(ref.warning)},
  '{}'::jsonb,
  ${ref.notLegalAdvice ? 'true' : 'false'},
  true
)`;
}

function procedureGuidanceRowSql(guidance) {
  const linkIds = guidance.officialLinkIds.map((id) => stableUuid(`ufficio-link:${id}`));
  const contactIds = guidance.officialContactIds.map((id) =>
    stableUuid(`ufficio-contact:${id}`),
  );
  return `(
  ${sqlString(guidance.id)},
  ${sqlString(guidance.procedureId)},
  ${sqlString(guidance.category)},
  ${sqlString(guidance.title)},
  ${sqlJson(guidance.summary)},
  ${sqlJson(guidance.destinationGuidance)},
  '{}'::jsonb,
  '{}'::jsonb,
  '{}'::jsonb,
  ${sqlArray(guidance.submissionChannelIds)},
  ${sqlArray(linkIds)},
  ${sqlArray(contactIds)},
  ${sqlArray(guidance.providerIds)},
  ${sqlArray(guidance.regionIds)},
  ${sqlArray(guidance.cityIds)},
  ${sqlArray(guidance.requiredDocuments)},
  ${sqlArray(guidance.recommendedDocuments)},
  ${sqlArray(guidance.proofItems)},
  ${sqlArray(guidance.sourceReferenceIds)},
  ${sqlArray(guidance.beforeSendingChecklist)},
  ${sqlJson(guidance.warnings)},
  ${sqlString(guidance.verificationStatus)},
  ${sqlString(guidance.lastVerifiedAt)},
  ${sqlJson(guidance.notes)},
  true
)`;
}

const providerForms = serviceProviders.flatMap((provider) => provider.forms);
const providerContacts = serviceProviders.flatMap((provider) =>
  provider.contactOptions.map((option) => ({ ...option, providerName: provider.name })),
);

const sqlFile = `-- Generated from ufficiofacile_verified_catalog_seed_v1.json
-- Do not edit manually; re-run tool/import_verified_catalog_v1.mjs when the verified seed changes.

insert into public.ufficio_official_links (
  id, title, url, category, description, procedure_ids, jurisdiction, region, city,
  provider_id, provider_name, source_url, source_label, verification_status,
  last_verified_at, warning, notes, is_active
)
values
${officialLinks.map(linkRowSql).join(',\n')}
on conflict (id) do update set
  title = excluded.title,
  url = excluded.url,
  category = excluded.category,
  description = excluded.description,
  procedure_ids = excluded.procedure_ids,
  region = excluded.region,
  city = excluded.city,
  source_url = excluded.source_url,
  source_label = excluded.source_label,
  verification_status = excluded.verification_status,
  last_verified_at = excluded.last_verified_at,
  warning = excluded.warning,
  updated_at = now();

insert into public.ufficio_official_contacts (
  id, label, contact_type, value, display_value, category, authority_type, procedure_ids,
  jurisdiction, region, city, provider_id, provider_name, source_url, source_label,
  verification_status, last_verified_at, warning, notes, is_active
)
values
${officialContacts.map(contactRowSql).join(',\n')}
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
  updated_at = now();

insert into public.ufficio_service_providers (
  id, name, normalized_name, category, website_url, customer_area_url,
  cancellation_page_url, complaint_page_url, modem_return_guidance, cancellation_guidance,
  complaint_guidance, payment_plan_guidance, source_references, verification_status,
  last_verified_at, warning, notes, is_active
)
values
${serviceProviders.map(providerRowSql).join(',\n')}
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
  updated_at = now();

insert into public.ufficio_provider_forms (
  id, provider_id, provider_name, form_type, title, description, url, procedure_ids,
  required_fields, required_documents, submission_channels, source_url, source_label,
  verification_status, last_verified_at, warning, notes, is_active
)
values
${providerForms.map(providerFormRowSql).join(',\n')}
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
  updated_at = now();

insert into public.ufficio_provider_contact_options (
  id, provider_id, provider_name, contact_type, label, value, url, description,
  procedure_ids, source_url, source_label, verification_status, last_verified_at,
  warning, notes, is_active
)
values
${providerContacts.map((option) => providerContactRowSql(option, option.providerName)).join(',\n')}
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
  updated_at = now();

insert into public.ufficio_source_references (
  id, title, source_type, reference_label, url, explanation, relevance, procedure_ids,
  verification_status, last_verified_at, warning, notes, not_legal_advice, is_active
)
values
${sourceReferences.map(sourceReferenceRowSql).join(',\n')}
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
  updated_at = now();

insert into public.ufficio_procedure_guidance (
  id, procedure_id, category, title, summary, destination_guidance, contact_rules,
  provider_rules, city_region_rules, submission_channels, official_links, official_contacts,
  provider_ids, region_ids, city_ids, required_documents, recommended_documents,
  proof_items, source_references, before_sending_checklist, warning, verification_status,
  last_verified_at, notes, is_active
)
values
${procedureGuidance.map(procedureGuidanceRowSql).join(',\n')}
on conflict (procedure_id) do update set
  id = excluded.id,
  category = excluded.category,
  title = excluded.title,
  summary = excluded.summary,
  destination_guidance = excluded.destination_guidance,
  submission_channels = excluded.submission_channels,
  official_links = excluded.official_links,
  official_contacts = excluded.official_contacts,
  provider_ids = excluded.provider_ids,
  required_documents = excluded.required_documents,
  proof_items = excluded.proof_items,
  source_references = excluded.source_references,
  before_sending_checklist = excluded.before_sending_checklist,
  warning = excluded.warning,
  verification_status = excluded.verification_status,
  notes = excluded.notes,
  updated_at = now();
`;

fs.writeFileSync(sqlOutputPath, sqlFile);

console.log(`Wrote ${path.relative(repoRoot, dartOutputPath)}`);
console.log(`Wrote ${path.relative(repoRoot, sqlOutputPath)}`);
