import fs from "node:fs";

const catalogPaths = [
  "assets/catalog/ufficio_catalog.torino.v1.json",
  "assets/catalog/ufficio_catalog.v1.json",
];

const t = (en, it, extras = {}) => ({ en, it, ...extras });

const updates = {
  "public_office_comune": {
    description: t(
      "Torino public-office help: start from the exact Comune, anagrafe, digital-access, or protocol problem.",
      "Uffici pubblici a Torino: parti dal problema giusto tra Comune, anagrafe, accesso digitale o protocollo.",
    ),
    subcategories: {
      "first_week_public_office_map": t(
        "I just arrived in Torino and do not know which public office comes first",
        "Sono appena arrivato a Torino e non so quale ufficio pubblico viene prima",
      ),
      "digital_access_italy": t(
        "I need SPID, CIE, or digital access that actually works",
        "Mi serve SPID, CIE o accesso digitale che funzioni davvero",
      ),
      "permesso_kit": t(
        "I need the kit or first permesso practical orientation",
        "Mi serve il kit o l'orientamento pratico iniziale sul permesso",
      ),
      "residenza_address": t(
        "I need residence, address, or hospitality registration help",
        "Mi serve aiuto su residenza, indirizzo o ospitalita",
      ),
      "identity_card_cie": t(
        "I need an identity card or CIE appointment",
        "Mi serve carta d'identita o appuntamento CIE",
      ),
      "certificates_self_certification": t(
        "I need a certificate or self-certification",
        "Mi serve un certificato o un'autocertificazione",
      ),
      "pec_protocol_formal_requests": t(
        "I need PEC, protocol, or a formal written request",
        "Mi serve PEC, protocollo o una richiesta formale scritta",
      ),
      "rejected_stuck_requests": t(
        "My Comune or public-office request is stuck or rejected",
        "La mia pratica Comune o ufficio pubblico e bloccata o respinta",
      ),
    },
  },
  "work_inps_patronato": {
    description: t(
      "Torino work and INPS help: start from the job-loss, patronato, employer-document, or contribution problem you actually have.",
      "Lavoro e INPS a Torino: parti dal problema reale tra perdita lavoro, patronato, documenti datore o contributi.",
    ),
    subcategories: {
      "understand_work_support": t(
        "I do not know which work or INPS route applies",
        "Non so quale percorso lavoro o INPS si applica",
      ),
      "naspi_unemployment": t(
        "I lost my job and need NASpI or unemployment help",
        "Ho perso il lavoro e mi serve aiuto per NASpI o disoccupazione",
      ),
      "cpi_did_job_obligations": t(
        "I need Centro per l'Impiego or DID obligations help",
        "Mi serve aiuto su Centro per l'Impiego o obblighi DID",
      ),
      "patronato_caf_union": t(
        "I need patronato, CAF, or union support",
        "Mi serve supporto da patronato, CAF o sindacato",
      ),
      "work_documents_employer": t(
        "I need documents from the employer",
        "Mi servono documenti dal datore di lavoro",
      ),
      "salary_payslip_tfr": t(
        "Salary, payslip, or TFR problem",
        "Problema di stipendio, busta paga o TFR",
      ),
      "inps_requests_followup": t(
        "My INPS request is pending, blocked, or unclear",
        "La mia pratica INPS e in attesa, bloccata o poco chiara",
      ),
      "sick_leave_family_benefits": t(
        "I need sick-leave or family-benefit help",
        "Mi serve aiuto su malattia o prestazioni familiari",
      ),
      "partita_iva_freelance": t(
        "I need freelance or partita IVA basics",
        "Mi servono basi pratiche su freelance o partita IVA",
      ),
      "contributions_tax_basics": t(
        "I need contribution or tax basics",
        "Mi servono basi pratiche su contributi o tasse",
      ),
    },
  },
  "university_student": {
    description: t(
      "Torino student help: start from the exact university, EDISU, immigration, fee, housing, or student-rights problem.",
      "Aiuto studenti a Torino: parti dal problema giusto tra universita, EDISU, immigrazione, tasse, casa o diritti studente.",
    ),
    subcategories: {
      "torino_student_map": t(
        "I just arrived in Torino as a student",
        "Sono appena arrivato a Torino come studente",
      ),
      "polito_guide": t(
        "I need PoliTO practical help",
        "Mi serve aiuto pratico PoliTO",
      ),
      "unito_guide": t(
        "I need UniTO practical help",
        "Mi serve aiuto pratico UniTO",
      ),
      "student_permesso_visa": t(
        "I need visa or permesso support as a student",
        "Mi serve supporto su visto o permesso come studente",
      ),
      "student_work_rules": t(
        "I need work rules for students",
        "Mi servono le regole lavoro per studenti",
      ),
      "edisu_scholarships_housing": t(
        "I need EDISU scholarship or housing help",
        "Mi serve aiuto EDISU per borsa o alloggio",
      ),
      "tuition_isee_fees": t(
        "I need tuition, ISEE, or fee-reduction help",
        "Mi serve aiuto su tasse, ISEE o riduzione contributi",
      ),
      "university_documents_certificates": t(
        "I need university documents or certificates",
        "Mi servono documenti o certificati universitari",
      ),
      "academic_career_exams": t(
        "I need help with exams, career, or academic offices",
        "Mi serve aiuto su esami, carriera o uffici accademici",
      ),
      "student_housing_rental_proof": t(
        "I need housing proof or rental help as a student",
        "Mi serve prova alloggio o aiuto affitto come studente",
      ),
      "student_health_insurance": t(
        "I need student health or insurance help",
        "Mi serve aiuto su salute o assicurazione studente",
      ),
      "student_support_services": t(
        "I need student support services",
        "Mi servono servizi di supporto studente",
      ),
      "student_tickets_formal_requests": t(
        "I need a formal student request, ticket, or written escalation",
        "Mi serve una richiesta formale studente, ticket o escalation scritta",
      ),
    },
  },
  "general": {
    description: t(
      "General Torino admin help: use this when the problem spans several offices or you first need order, documents, and the right message.",
      "Aiuto amministrativo generale a Torino: usalo quando il problema tocca piu uffici o prima ti serve ordine, documenti e il messaggio giusto.",
    ),
    subcategories: {
      "find_right_office": t(
        "I do not know which office should handle this",
        "Non so quale ufficio deve gestire questo problema",
      ),
      "formal_messages": t(
        "I need to write a clear formal message",
        "Devo scrivere un messaggio formale chiaro",
      ),
      "pec_and_attachments": t(
        "I need to send PEC or attachments correctly",
        "Devo inviare bene PEC o allegati",
      ),
      "followup_and_protocol": t(
        "I need follow-up, protocol, or proof that they received it",
        "Mi serve follow-up, protocollo o prova di ricezione",
      ),
      "missing_documents_and_rejections": t(
        "They asked for missing documents or rejected the request",
        "Mi hanno chiesto integrazioni o hanno respinto la pratica",
      ),
      "refunds_and_payments": t(
        "I need refund, payment, or correction help",
        "Mi serve aiuto su rimborso, pagamento o correzione",
      ),
      "proof_and_document_folder": t(
        "I need to organize proof and documents",
        "Devo organizzare prove e documenti",
      ),
      "appointments_and_calls": t(
        "I need an appointment or I have to call the office",
        "Mi serve un appuntamento o devo chiamare l'ufficio",
      ),
      "unknown_problem_private_help": t(
        "I still do not know where to start",
        "Ancora non so da dove iniziare",
      ),
    },
  },
  "bonuses-benefits": {
    description: t(
      "Torino bonuses and benefits: start from the right family, housing, ISEE, or local-support problem instead of searching random calls.",
      "Bonus e agevolazioni a Torino: parti dal problema giusto tra famiglia, casa, ISEE o supporti locali invece di cercare bandi a caso.",
    ),
    subcategories: {
      "bonus_finder": t(
        "I do not know which bonus may fit",
        "Non so quale bonus potrebbe fare al caso mio",
      ),
      "isee_documents": t(
        "I need ISEE and the right documents",
        "Mi serve l'ISEE con i documenti giusti",
      ),
      "bonus_sociale_bills": t(
        "I need help with bonus sociale in the bills",
        "Mi serve aiuto con il bonus sociale in bolletta",
      ),
      "family_child_benefits": t(
        "I need family or child-related benefits",
        "Mi servono agevolazioni per famiglia o figli",
      ),
      "nursery_school_benefits": t(
        "I need nursery or school support",
        "Mi serve supporto per nido o scuola",
      ),
      "rent_housing_support": t(
        "I need housing or rent support",
        "Mi serve supporto per casa o affitto",
      ),
      "poverty_inclusion_support": t(
        "I need inclusion or economic-emergency support",
        "Mi serve supporto per inclusione o emergenza economica",
      ),
      "health_psychology_support": t(
        "I need health or psychology-related support",
        "Mi serve supporto collegato a salute o psicologia",
      ),
      "cards_local_support": t(
        "I need local cards or Comune support tools",
        "Mi servono carte locali o strumenti di supporto del Comune",
      ),
      "bonus_application_problems": t(
        "My bonus request was blocked or I do not understand the outcome",
        "La mia richiesta bonus e bloccata o non capisco l'esito",
      ),
    },
  },
  "loans-credit": {
    description: t(
      "Loans and credit in Torino: start from the exact study, home, consumer-credit, or rejection problem before signing anything.",
      "Prestiti e credito a Torino: parti dal problema giusto tra studio, casa, credito al consumo o rifiuto prima di firmare qualunque cosa.",
    ),
    subcategories: {
      "understand_loans_credit": t(
        "I need to understand the loan basics first",
        "Devo capire prima le basi del prestito",
      ),
      "student_loans_study_credit": t(
        "I need student loan or study-credit help",
        "Mi serve aiuto su prestito studentesco o credito studio",
      ),
      "first_home_mortgage_guarantee": t(
        "I need first-home mortgage guarantee help",
        "Mi serve aiuto sulla garanzia mutuo prima casa",
      ),
      "mortgage_suspension": t(
        "I need mortgage suspension or payment relief",
        "Mi serve sospensione mutuo o sollievo pagamenti",
      ),
      "personal_loans_consumer_credit": t(
        "I need personal-loan or consumer-credit help",
        "Mi serve aiuto su prestito personale o credito al consumo",
      ),
      "rent_deposit_housing_credit": t(
        "I need help with rent deposit or housing credit",
        "Mi serve aiuto su deposito affitto o credito casa",
      ),
      "compare_loans_safely": t(
        "I need to compare loans safely",
        "Devo confrontare prestiti in modo sicuro",
      ),
      "credit_problems_rejections": t(
        "The bank or lender rejected me or the credit file is blocked",
        "Banca o finanziaria mi hanno rifiutato o la pratica e bloccata",
      ),
      "before_signing_credit": t(
        "I am about to sign and want a final risk check",
        "Sto per firmare e voglio un ultimo controllo dei rischi",
      ),
    },
  },
};

for (const catalogPath of catalogPaths) {
  const raw = fs.readFileSync(catalogPath, "utf8");
  const catalog = JSON.parse(raw);

  for (const [categoryId, update] of Object.entries(updates)) {
    const category = catalog.categories.find((item) => item.id === categoryId);
    if (!category) {
      throw new Error(`${categoryId} not found in ${catalogPath}`);
    }
    category.description = update.description;
    for (const subcategory of category.subcategories ?? []) {
      const title = update.subcategories[subcategory.id];
      if (title) {
        subcategory.title = title;
      }
    }
  }

  fs.writeFileSync(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`);
  console.log(`Relabeled remaining Torino categories in ${catalogPath}`);
}
