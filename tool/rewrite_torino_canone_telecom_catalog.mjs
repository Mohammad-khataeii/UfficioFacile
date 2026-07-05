import fs from "node:fs";

const lastVerifiedAt = "2026-05-25";
const catalogPaths = [
  "assets/catalog/ufficio_catalog.torino.v1.json",
  "assets/catalog/ufficio_catalog.v1.json",
];

const t = (en, it, extras = {}) => ({ en, it, ...extras });

const sectionText = (key, titleEn, titleIt, bodyEn, bodyIt, options = {}) => ({
  type: "text",
  key,
  title: t(titleEn, titleIt),
  body: t(bodyEn, bodyIt),
  isPremiumOnly: options.isPremiumOnly ?? false,
});

const sectionChecklist = (
  key,
  titleEn,
  titleIt,
  itemsEn,
  itemsIt,
  options = {},
) => ({
  type: "checklist",
  key,
  title: t(titleEn, titleIt),
  body:
    options.bodyEn || options.bodyIt
      ? t(options.bodyEn ?? "", options.bodyIt ?? "")
      : undefined,
  items: t(itemsEn, itemsIt),
  isPremiumOnly: options.isPremiumOnly ?? false,
});

const link = (labelEn, labelIt, url, owner, scope, usedFor) => ({
  label: t(labelEn, labelIt),
  url,
  type: "official",
  owner,
  scope,
  usedFor,
  lastVerifiedAt,
});

const contact = (labelEn, labelIt, value, type) => ({
  label: t(labelEn, labelIt),
  value,
  type,
});

const related = (categoryId, titleEn, titleIt, subcategoryId, procedureId) => ({
  title: t(titleEn, titleIt),
  categoryId,
  subcategoryId,
  procedureId,
});

const procedure = ({
  categoryId,
  id,
  subcategoryId,
  sortOrder,
  titleEn,
  titleIt,
  shortEn,
  shortIt,
  sections,
  officialLinks = [],
  contacts = [],
  relatedProcedures = [],
  hasPremiumContent = false,
  premiumTeaserEn = "",
  premiumTeaserIt = "",
}) => ({
  id,
  categoryId,
  subcategoryId,
  sortOrder,
  isPremiumOnly: false,
  hasPremiumContent,
  requiresAuth: false,
  title: t(titleEn, titleIt),
  shortDescription: t(shortEn, shortIt),
  sections,
  officialLinks,
  contacts,
  warnings: {},
  relatedProcedures,
  premiumTeaser:
    premiumTeaserEn || premiumTeaserIt
      ? t(premiumTeaserEn || shortEn, premiumTeaserIt || shortIt)
      : {},
});

const subcategory = ({
  id,
  sortOrder,
  titleEn,
  titleIt,
  descriptionEn,
  descriptionIt,
  procedures,
  hasPremiumContent = false,
}) => ({
  id,
  sortOrder,
  isPremiumOnly: false,
  hasPremiumContent,
  title: t(titleEn, titleIt),
  description: t(descriptionEn, descriptionIt),
  procedures,
});

const canoneContacts = {
  raiWeb: contact(
    "RAI Canone TV contacts",
    "Contatti RAI Canone TV",
    "https://www.canone.rai.it/Ordinari/ScriveteciSez.aspx",
    "website",
  ),
  adeWeb: contact(
    "Agenzia delle Entrate - TV fee forms",
    "Agenzia delle Entrate - moduli Canone TV",
    "https://www.agenziaentrate.gov.it/portale/cittadini/agevolazioni/canone-tv",
    "website",
  ),
};

const telecomContacts = {
  agcomContact: contact(
    "AGCOM contact center",
    "Contact center AGCOM",
    "https://www.agcom.it/agcom-per-te/contact-center",
    "website",
  ),
  conciliaWeb: contact(
    "ConciliaWeb",
    "ConciliaWeb",
    "https://conciliaweb.agcom.it/conciliaweb/",
    "website",
  ),
  nemesys: contact(
    "MisuraInternet Ne.Me.Sys",
    "MisuraInternet Ne.Me.Sys",
    "https://misurainternet.it/info_nemesys/",
    "website",
  ),
};

const canoneRaiCategory = (existing = {}) => ({
  id: "canone_rai",
  icon: existing.icon ?? "tv",
  sortOrder: existing.sortOrder ?? 5,
  isPremiumOnly: false,
  hasPremiumContent: true,
  title: t(
    "Canone RAI",
    "Canone RAI",
    {
      fr: "Redevance TV italienne",
      es: "Canone RAI",
      fa: "عوارض تلویزیون RAI",
      ar: "رسم التلفزيون RAI",
    },
  ),
  description: t(
    "Torino TV-fee help: start from the exact doubt, wrong charge, exemption, or form you need.",
    "Canone TV a Torino: parti dal dubbio giusto, dall'addebito sbagliato, dall'esenzione o dal modulo che ti serve.",
  ),
  contacts: [canoneContacts.raiWeb, canoneContacts.adeWeb],
  officialLinks: [
    link(
      "RAI - TV fee general information",
      "RAI - informazioni generali Canone TV",
      "https://www.canone.rai.it/Ordinari/ilCanoneOrdinari.aspx",
      "RAI",
      "National",
      "General baseline for the Italian TV fee",
    ),
    link(
      "RAI - official FAQ",
      "RAI - FAQ ufficiali",
      "https://www.canone.rai.it/Ordinari/FAQ.aspx",
      "RAI",
      "National",
      "Official FAQs for ordinary TV fee cases",
    ),
  ],
  subcategories: [
    subcategory({
      id: "understand_canone_rai",
      sortOrder: 10,
      titleEn: "I need to understand if I really have to pay",
      titleIt: "Devo capire se devo davvero pagare",
      descriptionEn:
        "Start here if you are unsure whether the TV fee should appear on your electricity bill.",
      descriptionIt:
        "Parti da qui se non sei sicuro che il canone debba comparire sulla bolletta luce.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "understand_if_must_pay_canone_rai",
          subcategoryId: "understand_canone_rai",
          sortOrder: 10,
          titleEn: "Understand if the TV fee applies to you",
          titleIt: "Capire se il Canone TV si applica al tuo caso",
          shortEn:
            "Use this before sending any form. Many people mix up household, residence, and electricity-holder rules.",
          shortIt:
            "Usa questa guida prima di inviare moduli. Molte persone confondono nucleo familiare, residenza e intestatario della luce.",
          sections: [
            sectionChecklist(
              "start",
              "Check these points first",
              "Controlla prima questi punti",
              [
                "Who is the holder of the domestic resident electricity contract.",
                "Whether a TV set is actually held in the family household.",
                "Whether another member of the same family household is already paying.",
                "Whether you are looking at a new home, old charge, or refund case instead of an ordinary case.",
              ],
              [
                "Chi e intestatario dell'utenza elettrica domestica residente.",
                "Se nel nucleo familiare esiste davvero un apparecchio TV detenuto.",
                "Se un altro componente dello stesso nucleo paga gia il canone.",
                "Se stai guardando un caso di nuova casa, vecchio addebito o rimborso invece del caso ordinario.",
              ],
            ),
            sectionText(
              "common_mistake",
              "Common mistake",
              "Errore frequente",
              "Do not assume that living in the same apartment is enough. What matters is the family-household rule and how the electricity contract is registered.",
              "Non pensare che basti vivere nello stesso appartamento. Conta la regola del nucleo familiare e come e registrato il contratto luce.",
            ),
          ],
          officialLinks: [
            link(
              "RAI - official FAQ",
              "RAI - FAQ ufficiali",
              "https://www.canone.rai.it/Ordinari/FAQ.aspx",
              "RAI",
              "National",
              "Ordinary TV-fee FAQ baseline",
            ),
            link(
              "RAI - general information on TV fee",
              "RAI - informazioni generali Canone TV",
              "https://www.canone.rai.it/Ordinari/ilCanoneOrdinari.aspx",
              "RAI",
              "National",
              "General rules and high-level explanations",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "no_tv_declaration",
      sortOrder: 20,
      titleEn: "I do not have a TV and need the declaration",
      titleIt: "Non ho TV e devo fare la dichiarazione",
      descriptionEn:
        "Use this for the non-detention declaration when your case truly matches it.",
      descriptionIt:
        "Usa questo percorso per la dichiarazione di non detenzione quando il tuo caso rientra davvero.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "submit_no_tv_declaration",
          subcategoryId: "no_tv_declaration",
          sortOrder: 10,
          titleEn: "Send the no-TV declaration correctly",
          titleIt: "Inviare correttamente la dichiarazione di non detenzione",
          shortEn:
            "Use this if no TV set is held in the household and you need to avoid or stop the charge.",
          shortIt:
            "Usa questa guida se nel nucleo familiare non e detenuto alcun televisore e devi evitare o fermare l'addebito.",
          sections: [
            sectionChecklist(
              "before",
              "Before sending it",
              "Prima di inviarla",
              [
                "Make sure the declaration is true for the whole family household.",
                "Check whether the timing is for the full year or only the second semester.",
                "Keep a copy and proof of submission.",
              ],
              [
                "Assicurati che la dichiarazione sia vera per tutto il nucleo familiare.",
                "Controlla se la tempistica vale per l'intero anno o solo per il secondo semestre.",
                "Conserva copia e prova dell'invio.",
              ],
            ),
            sectionText(
              "warning",
              "Do not use it for the wrong problem",
              "Non usarla per il problema sbagliato",
              "If another household member already pays, or the issue is a past wrong charge, you may need a different quadro or a refund path instead.",
              "Se paga gia un altro componente del nucleo o il problema e un vecchio addebito errato, potresti aver bisogno di un quadro diverso o di un rimborso.",
            ),
          ],
          officialLinks: [
            link(
              "RAI FAQ - no-TV declaration",
              "RAI FAQ - dichiarazione di non detenzione",
              "https://www.canone.rai.it/Ordinari/RisposteFAQ.aspx?ID=107",
              "RAI",
              "National",
              "No-TV declaration logic and common cases",
            ),
            link(
              "Agenzia Entrate - TV fee citizen page",
              "Agenzia Entrate - pagina cittadino Canone TV",
              "https://www.agenziaentrate.gov.it/portale/cittadini/agevolazioni/canone-tv",
              "Agenzia delle Entrate",
              "National",
              "Official tax-agency forms and submission channels",
            ),
          ],
          contacts: [canoneContacts.raiWeb, canoneContacts.adeWeb],
        }),
      ],
    }),
    subcategory({
      id: "same_household_duplicate_charge",
      sortOrder: 30,
      titleEn: "Another person in my household already pays",
      titleIt: "Un'altra persona del mio nucleo paga gia",
      descriptionEn:
        "Use this when the family-household rule matters and a duplicate charge is appearing.",
      descriptionIt:
        "Usa questo percorso quando conta la regola del nucleo familiare e compare un doppio addebito.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "another_household_member_pays",
          subcategoryId: "same_household_duplicate_charge",
          sortOrder: 10,
          titleEn: "Same household or duplicate charge",
          titleIt: "Stesso nucleo o doppio addebito",
          shortEn:
            "Use this if one family-household member already pays and the charge appears again on another electricity bill.",
          shortIt:
            "Usa questa guida se un componente del nucleo familiare paga gia e l'addebito compare di nuovo su un'altra bolletta luce.",
          sections: [
            sectionChecklist(
              "need",
              "Prepare these details",
              "Prepara questi dati",
              [
                "Who is already paying the fee.",
                "Which electricity contract is receiving the extra charge.",
                "Proof that the people involved are in the same family household if relevant.",
              ],
              [
                "Chi paga gia il canone.",
                "Quale contratto luce riceve l'addebito in piu.",
                "Prova che le persone coinvolte appartengono allo stesso nucleo familiare, se rilevante.",
              ],
            ),
            sectionText(
              "torino",
              "Practical note",
              "Nota pratica",
              "If you moved inside Torino or changed the electricity holder recently, the duplicate can appear because old and new contract data did not line up in time.",
              "Se ti sei spostato dentro Torino o hai cambiato intestatario luce di recente, il doppio addebito puo comparire perche i dati vecchi e nuovi non si sono allineati in tempo.",
            ),
          ],
          officialLinks: [
            link(
              "RAI FAQ - same household and quadro B",
              "RAI FAQ - stesso nucleo e quadro B",
              "https://www.canone.rai.it/Ordinari/RisposteFAQ.aspx?ID=107",
              "RAI",
              "National",
              "Same-household duplicate-charge FAQ",
            ),
            link(
              "RAI FAQ - refund path",
              "RAI FAQ - rimborso",
              "https://www.canone.rai.it/Ordinari/risposteFAQ.aspx?id=123",
              "RAI",
              "National",
              "Related refund logic when duplicate charges were already paid",
            ),
          ],
          relatedProcedures: [
            related(
              "canone_rai",
              "Ask for a refund",
              "Chiedere un rimborso",
              "refund_wrong_charge",
              "request_canone_rai_refund",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "over_75_exemption",
      sortOrder: 40,
      titleEn: "I need the over-75 exemption",
      titleIt: "Mi serve l'esenzione over 75",
      descriptionEn:
        "Use this if the user may qualify for the age-based exemption and wants the exact path.",
      descriptionIt:
        "Usa questo percorso se la persona puo avere diritto all'esenzione per eta e vuole il percorso giusto.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "apply_over_75_exemption",
          subcategoryId: "over_75_exemption",
          sortOrder: 10,
          titleEn: "Apply for the over-75 exemption",
          titleIt: "Richiedere l'esenzione over 75",
          shortEn:
            "Use this if the age and income conditions may fit and you need to avoid or stop the charge.",
          shortIt:
            "Usa questa guida se eta e reddito possono rientrare e devi evitare o fermare l'addebito.",
          sections: [
            sectionChecklist(
              "check",
              "Check before sending",
              "Controlla prima di inviare",
              [
                "Age condition.",
                "Income condition for the exemption year.",
                "Whether the charge already appeared and you therefore also need the refund path.",
              ],
              [
                "Requisito di eta.",
                "Requisito di reddito per l'anno di riferimento.",
                "Se l'addebito e gia comparso e quindi serve anche il percorso rimborso.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "People often look only at age and forget the income rule. Check both before sending the declaration.",
              "Spesso si guarda solo l'eta e si dimentica il requisito di reddito. Controlla entrambi prima di inviare la dichiarazione.",
            ),
          ],
          officialLinks: [
            link(
              "RAI - TV fee information and exemptions",
              "RAI - Canone TV informazioni ed esenzioni",
              "https://www.canone.rai.it/Ordinari/ilCanoneOrdinari.aspx",
              "RAI",
              "National",
              "General exemption information",
            ),
            link(
              "Agenzia Entrate - TV fee citizen page",
              "Agenzia Entrate - pagina cittadino Canone TV",
              "https://www.agenziaentrate.gov.it/portale/cittadini/agevolazioni/canone-tv",
              "Agenzia delle Entrate",
              "National",
              "Official citizen path for forms and fiscal handling",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "diplomatic_military_exemption",
      sortOrder: 50,
      titleEn: "I need a diplomatic or military exemption",
      titleIt: "Mi serve l'esenzione diplomatici o militari",
      descriptionEn:
        "Use this when the exemption reason is special and should not be mixed with ordinary cases.",
      descriptionIt:
        "Usa questo percorso quando il motivo di esenzione e speciale e non va confuso con i casi ordinari.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "apply_diplomatic_military_exemption",
          subcategoryId: "diplomatic_military_exemption",
          sortOrder: 10,
          titleEn: "Apply for diplomatic or military exemption",
          titleIt: "Richiedere esenzione diplomatici o militari",
          shortEn:
            "Use this if your case falls in the special exempt categories and you need the official rule set.",
          shortIt:
            "Usa questa guida se il tuo caso rientra nelle categorie speciali esenti e devi seguire le regole ufficiali.",
          sections: [
            sectionText(
              "rule",
              "Use the exact special rule",
              "Usa la regola speciale corretta",
              "Do not reuse ordinary no-TV or over-75 logic for these cases. The exemption reason must match the official category.",
              "Non riutilizzare la logica ordinaria della non detenzione o dell'over 75 per questi casi. Il motivo di esenzione deve corrispondere alla categoria ufficiale.",
            ),
          ],
          officialLinks: [
            link(
              "RAI - official FAQ",
              "RAI - FAQ ufficiali",
              "https://www.canone.rai.it/Ordinari/FAQ.aspx",
              "RAI",
              "National",
              "Official TV-fee FAQ including special exemptions",
            ),
            link(
              "Agenzia Entrate - TV fee citizen page",
              "Agenzia Entrate - pagina cittadino Canone TV",
              "https://www.agenziaentrate.gov.it/portale/cittadini/agevolazioni/canone-tv",
              "Agenzia delle Entrate",
              "National",
              "Official forms and guidance",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "refund_wrong_charge",
      sortOrder: 60,
      titleEn: "I already paid and the charge was wrong",
      titleIt: "Ho gia pagato e l'addebito era sbagliato",
      descriptionEn:
        "Use this when the fee was already charged or paid and you now need a refund path.",
      descriptionIt:
        "Usa questo percorso quando il canone e gia stato addebitato o pagato e ora ti serve il rimborso.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "request_canone_rai_refund",
          subcategoryId: "refund_wrong_charge",
          sortOrder: 10,
          titleEn: "Ask for a TV-fee refund",
          titleIt: "Chiedere il rimborso del Canone TV",
          shortEn:
            "Use this if the charge was wrong and you need money back, not only a future correction.",
          shortIt:
            "Usa questa guida se l'addebito era sbagliato e devi ottenere il rimborso, non solo evitare futuri addebiti.",
          sections: [
            sectionChecklist(
              "keep",
              "Keep these proofs",
              "Conserva queste prove",
              [
                "Electricity bill showing the charge.",
                "Payment proof if already paid.",
                "Reason why the charge was wrong.",
                "Any declaration or form already sent.",
              ],
              [
                "Bolletta luce con l'addebito.",
                "Prova di pagamento se gia pagato.",
                "Motivo per cui l'addebito era sbagliato.",
                "Eventuale dichiarazione o modulo gia inviato.",
              ],
            ),
            sectionText(
              "written",
              "Use the correct refund route",
              "Usa il percorso rimborso corretto",
              "Do not assume that sending the ordinary declaration automatically returns money already charged. Past wrong charges usually need the refund path too.",
              "Non pensare che inviare la dichiarazione ordinaria restituisca automaticamente somme gia addebitate. Gli addebiti passati richiedono spesso anche il percorso rimborso.",
            ),
          ],
          officialLinks: [
            link(
              "RAI - refund FAQ",
              "RAI - FAQ rimborso",
              "https://www.canone.rai.it/Ordinari/risposteFAQ.aspx?id=123",
              "RAI",
              "National",
              "Official refund FAQ and logic",
            ),
            link(
              "RAI - contact TV fee office",
              "RAI - contatti Ufficio Canone TV",
              "https://www.canone.rai.it/Ordinari/ScriveteciSez.aspx",
              "RAI",
              "National",
              "Official RAI contact page for TV fee assistance",
            ),
          ],
          contacts: [canoneContacts.raiWeb, canoneContacts.adeWeb],
        }),
      ],
    }),
    subcategory({
      id: "moving_new_home",
      sortOrder: 70,
      titleEn: "I moved or opened a new electricity contract",
      titleIt: "Mi sono trasferito o ho aperto una nuova utenza luce",
      descriptionEn:
        "Use this when the home changed and you want to understand if the TV fee will appear automatically.",
      descriptionIt:
        "Usa questo percorso quando cambia la casa e vuoi capire se il canone apparira automaticamente.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "canone_on_new_electricity_contract",
          subcategoryId: "moving_new_home",
          sortOrder: 10,
          titleEn: "New home and electricity contract",
          titleIt: "Nuova casa e contratto luce",
          shortEn:
            "Use this if you moved in Torino and a new resident electricity contract is involved.",
          shortIt:
            "Usa questa guida se ti sei spostato a Torino ed e coinvolta una nuova utenza elettrica residente.",
          sections: [
            sectionChecklist(
              "check",
              "Check these points",
              "Controlla questi punti",
              [
                "Whether the contract is domestic resident.",
                "Whether someone in the same household is already paying elsewhere.",
                "Whether you need a no-TV declaration instead of waiting.",
              ],
              [
                "Se il contratto e domestico residente.",
                "Se qualcuno dello stesso nucleo paga gia altrove.",
                "Se devi fare dichiarazione di non detenzione invece di aspettare.",
              ],
            ),
            sectionText(
              "timing",
              "Do not wait blindly",
              "Non aspettare alla cieca",
              "If the case is delicate, check it early. A move, a new holder, and a new electricity contract can create confusion and later refund work.",
              "Se il caso e delicato, controllalo presto. Trasloco, nuovo intestatario e nuova utenza possono creare confusione e poi costringerti al rimborso.",
            ),
          ],
          officialLinks: [
            link(
              "RAI FAQ - new supply and no-TV declaration",
              "RAI FAQ - nuova utenza e dichiarazione non detenzione",
              "https://www.canone.rai.it/Ordinari/RisposteFAQ.aspx?ID=107",
              "RAI",
              "National",
              "New-home and no-TV FAQ context",
            ),
            link(
              "RAI - official FAQ",
              "RAI - FAQ ufficiali",
              "https://www.canone.rai.it/Ordinari/FAQ.aspx",
              "RAI",
              "National",
              "Baseline FAQ for move-related cases",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "choose_right_form",
      sortOrder: 80,
      titleEn: "I do not know which form or quadro to use",
      titleIt: "Non so quale modulo o quadro usare",
      descriptionEn:
        "Use this if the case is not ordinary and you need to avoid sending the wrong model.",
      descriptionIt:
        "Usa questo percorso se il caso non e ordinario e vuoi evitare di inviare il modello sbagliato.",
      procedures: [
        procedure({
          categoryId: "canone_rai",
          id: "choose_canone_rai_form",
          subcategoryId: "choose_right_form",
          sortOrder: 10,
          titleEn: "Choose the right TV-fee form",
          titleIt: "Scegliere il modulo corretto Canone TV",
          shortEn:
            "Use this if your doubt is mainly administrative: which form, which quadro, and which reason actually fits your case.",
          shortIt:
            "Usa questa guida se il dubbio e soprattutto amministrativo: quale modulo, quale quadro e quale motivo corrisponde davvero al tuo caso.",
          sections: [
            sectionChecklist(
              "decide",
              "First decide what kind of problem it is",
              "Decidi prima che tipo di problema hai",
              [
                "No TV held in the household.",
                "Same family household already paying.",
                "Exemption case.",
                "Refund for a wrong past charge.",
              ],
              [
                "Nessun televisore detenuto nel nucleo.",
                "Stesso nucleo familiare con pagamento gia presente.",
                "Caso di esenzione.",
                "Rimborso per vecchio addebito errato.",
              ],
            ),
            sectionText(
              "avoid",
              "Avoid mixing routes",
              "Evita di mescolare i percorsi",
              "If you choose the wrong route, you may delay the correction and then need an extra refund request later.",
              "Se scegli il percorso sbagliato puoi ritardare la correzione e poi dover chiedere un rimborso extra dopo.",
            ),
          ],
          officialLinks: [
            link(
              "RAI - official FAQ",
              "RAI - FAQ ufficiali",
              "https://www.canone.rai.it/Ordinari/FAQ.aspx",
              "RAI",
              "National",
              "High-level FAQ to classify the case",
            ),
            link(
              "Agenzia Entrate - TV fee citizen page",
              "Agenzia Entrate - pagina cittadino Canone TV",
              "https://www.agenziaentrate.gov.it/portale/cittadini/agevolazioni/canone-tv",
              "Agenzia delle Entrate",
              "National",
              "Official forms and instructions",
            ),
          ],
          relatedProcedures: [
            related(
              "canone_rai",
              "No-TV declaration",
              "Dichiarazione di non detenzione",
              "no_tv_declaration",
              "submit_no_tv_declaration",
            ),
          ],
        }),
      ],
    }),
  ],
});

const telecomCategory = (existing = {}) => ({
  id: "telecom_internet_mobile",
  icon: existing.icon ?? "wifi",
  sortOrder: existing.sortOrder ?? 6,
  isPremiumOnly: false,
  hasPremiumContent: true,
  title: t("Telecom & Internet", "Telefono e internet"),
  description: t(
    "Torino telecom help: choose the exact line, mobile, activation, billing, or scam problem and start from the right route.",
    "Telefono e internet a Torino: scegli il problema giusto tra linea, mobile, attivazione, bolletta o truffa e parti dal percorso corretto.",
  ),
  contacts: [
    telecomContacts.agcomContact,
    telecomContacts.conciliaWeb,
    telecomContacts.nemesys,
  ],
  officialLinks: [
    link(
      "AGCOM - portability and migration",
      "AGCOM - portabilita e migrazione",
      "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione",
      "AGCOM",
      "National",
      "Portability and migration rules",
    ),
    link(
      "ConciliaWeb",
      "ConciliaWeb",
      "https://conciliaweb.agcom.it/conciliaweb/",
      "AGCOM",
      "National",
      "Official telecom complaint and conciliation platform",
    ),
  ],
  subcategories: [
    subcategory({
      id: "understand_telecom_basics",
      sortOrder: 10,
      titleEn: "I do not understand the telecom words",
      titleIt: "Non capisco le parole del contratto telecom",
      descriptionEn:
        "Start here if you need to decode migration code, portability, modem return, or certified speed test terms.",
      descriptionIt:
        "Parti da qui se devi capire codice migrazione, portabilita, restituzione modem o test certificato della velocita.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "telecom_words_you_must_know",
          subcategoryId: "understand_telecom_basics",
          sortOrder: 10,
          titleEn: "Telecom words you need before doing anything",
          titleIt: "Parole telecom da capire prima di fare qualsiasi cosa",
          shortEn:
            "Use this before signing, cancelling, switching, or complaining.",
          shortIt:
            "Usa questa guida prima di firmare, disdire, cambiare operatore o fare reclamo.",
          sections: [
            sectionChecklist(
              "terms",
              "Know these terms",
              "Conosci questi termini",
              [
                "Portability: keep your mobile number when changing operator.",
                "Migration code: fixed-line code often needed to switch internet or landline.",
                "Recesso: cancellation or withdrawal path.",
                "Ne.Me.Sys: certified AGCOM speed test for serious slow-line complaints.",
              ],
              [
                "Portabilita: mantieni il numero mobile cambiando operatore.",
                "Codice migrazione: codice linea fissa spesso necessario per cambiare internet o telefono.",
                "Recesso: percorso di disdetta o recesso.",
                "Ne.Me.Sys: test AGCOM certificato per reclami seri su linea lenta.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "AGCOM - portability and migration",
              "AGCOM - portabilita e migrazione",
              "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione",
              "AGCOM",
              "National",
              "Definitions and rights for portability and migration",
            ),
            link(
              "MisuraInternet Ne.Me.Sys",
              "MisuraInternet Ne.Me.Sys",
              "https://misurainternet.it/info_nemesys/",
              "AGCOM",
              "National",
              "Certified internet-speed test tool",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "choose_best_operator",
      sortOrder: 20,
      titleEn: "I need to choose an operator without getting trapped",
      titleIt: "Devo scegliere un operatore senza farmi fregare",
      descriptionEn:
        "Compare offers, choose channel wisely, and avoid rushed decisions.",
      descriptionIt:
        "Confronta offerte, scegli il canale giusto ed evita decisioni affrettate.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "compare_operators_before_signing",
          subcategoryId: "choose_best_operator",
          sortOrder: 10,
          titleEn: "Compare operators before signing",
          titleIt: "Confrontare operatori prima di firmare",
          shortEn:
            "Use this if you only know the monthly price and not the real contract conditions.",
          shortIt:
            "Usa questa guida se conosci solo il prezzo mensile ma non le vere condizioni del contratto.",
          sections: [
            sectionChecklist(
              "check",
              "Check these points",
              "Controlla questi punti",
              [
                "Activation cost and whether it is spread over many months.",
                "Minimum contract period and cancellation costs.",
                "Modem or equipment conditions.",
                "Whether the speed promise is realistic for your address.",
              ],
              [
                "Costo di attivazione e se viene spalmato su molti mesi.",
                "Durata minima e costi di disdetta.",
                "Condizioni del modem o di altri apparati.",
                "Se la velocita promessa e realistica per il tuo indirizzo.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "MisuraInternet Ne.Me.Sys",
              "MisuraInternet Ne.Me.Sys",
              "https://misurainternet.it/info_nemesys/",
              "AGCOM",
              "National",
              "Check certified speed tools and line-performance context",
            ),
          ],
        }),
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "operator_store_or_online_choice",
          subcategoryId: "choose_best_operator",
          sortOrder: 20,
          titleEn: "Store, online, or phone sale?",
          titleIt: "Negozio, online o vendita telefonica?",
          shortEn:
            "Use this if the same offer looks different depending on where you buy it.",
          shortIt:
            "Usa questa guida se la stessa offerta sembra diversa a seconda di dove la compri.",
          sections: [
            sectionText(
              "practical",
              "Practical rule",
              "Regola pratica",
              "If the case is simple, online can be faster. If the case is messy, an operator store or a written channel can leave a clearer paper trail than a rushed phone sale.",
              "Se il caso e semplice, l'online puo essere piu rapido. Se il caso e confuso, un negozio o un canale scritto lascia spesso una traccia migliore di una vendita telefonica affrettata.",
            ),
          ],
          officialLinks: [
            link(
              "AGCOM contact center",
              "Contact center AGCOM",
              "https://www.agcom.it/agcom-per-te/contact-center",
              "AGCOM",
              "National",
              "Consumer guidance contact channel",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "operator_directory",
      sortOrder: 30,
      titleEn: "I just need the right operator support channel",
      titleIt: "Mi serve solo il canale giusto dell'operatore",
      descriptionEn:
        "Find store locators and official support pages without guessing.",
      descriptionIt:
        "Trova localizzatori negozi e pagine supporto ufficiali senza andare a caso.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "select_operator_support",
          subcategoryId: "operator_directory",
          sortOrder: 10,
          titleEn: "Choose the right support page or store",
          titleIt: "Scegliere la pagina assistenza o il negozio giusto",
          shortEn:
            "Use this if you already know the operator and only need the official support route.",
          shortIt:
            "Usa questa guida se sai gia l'operatore e ti serve solo il canale ufficiale corretto.",
          sections: [
            sectionChecklist(
              "tip",
              "Best use",
              "Uso migliore",
              [
                "Use support pages for routine account or troubleshooting issues.",
                "Use store locators when you need identity checks, SIM replacement, or in-person clarification.",
              ],
              [
                "Usa le pagine assistenza per problemi ordinari di account o linea.",
                "Usa i localizzatori negozi quando servono controlli identita, sostituzione SIM o chiarimenti di persona.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "TIM support",
              "Assistenza TIM",
              "https://www.tim.it/assistenza",
              "TIM",
              "National",
              "Official TIM support page",
            ),
            link(
              "Vodafone support",
              "Assistenza Vodafone",
              "https://www.vodafone.it/privati/supporto.html",
              "Vodafone",
              "National",
              "Official Vodafone support page",
            ),
            link(
              "WINDTRE support",
              "Assistenza WINDTRE",
              "https://www.windtre.it/supporto/",
              "WINDTRE",
              "National",
              "Official WINDTRE support page",
            ),
            link(
              "Iliad support",
              "Assistenza Iliad",
              "https://www.iliad.it/supporto/",
              "Iliad",
              "National",
              "Official Iliad support page",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "activate_service",
      sortOrder: 40,
      titleEn: "I need to activate home internet or mobile service",
      titleIt: "Devo attivare internet casa o una linea mobile",
      descriptionEn:
        "Use this when the line is new and you want the right documents and timing expectations.",
      descriptionIt:
        "Usa questo percorso quando la linea e nuova e vuoi documenti e tempi realistici.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "home_internet_activation",
          subcategoryId: "activate_service",
          sortOrder: 10,
          titleEn: "Activate home internet",
          titleIt: "Attivare internet casa",
          shortEn:
            "Use this when you are starting a new home internet service and need to avoid activation confusion.",
          shortIt:
            "Usa questa guida quando stai attivando una nuova linea internet casa e vuoi evitare confusione sulla pratica.",
          sections: [
            sectionChecklist(
              "prepare",
              "Prepare these details",
              "Prepara questi dati",
              [
                "Exact address and apartment details.",
                "Identity document and codice fiscale.",
                "Whether there is already an old line or modem in the home.",
                "Whether you need a completely new line or a migration from another operator.",
              ],
              [
                "Indirizzo esatto e dettagli dell'appartamento.",
                "Documento d'identita e codice fiscale.",
                "Se in casa esiste gia una vecchia linea o un modem precedente.",
                "Se ti serve una linea completamente nuova o una migrazione da altro operatore.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "AGCOM - portability and migration",
              "AGCOM - portabilita e migrazione",
              "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione",
              "AGCOM",
              "National",
              "Understand whether the case is activation or migration",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "switch_provider_portability",
      sortOrder: 50,
      titleEn: "I need portability or a provider switch",
      titleIt: "Mi serve portabilita o cambio operatore",
      descriptionEn:
        "Mobile number portability and fixed-line migration without losing control of the case.",
      descriptionIt:
        "Portabilita del numero mobile e migrazione della linea fissa senza perdere il controllo della pratica.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "mobile_number_portability",
          subcategoryId: "switch_provider_portability",
          sortOrder: 10,
          titleEn: "Mobile number portability",
          titleIt: "Portabilita del numero mobile",
          shortEn:
            "Use this when you want to keep the mobile number while changing operator.",
          shortIt:
            "Usa questa guida quando vuoi mantenere il numero mobile cambiando operatore.",
          sections: [
            sectionChecklist(
              "need",
              "Have these details ready",
              "Tieni pronti questi dati",
              [
                "Current number.",
                "SIM serial if requested.",
                "Identity data matching the current line holder.",
              ],
              [
                "Numero attuale.",
                "Seriale SIM se richiesto.",
                "Dati identita coerenti con l'intestatario attuale della linea.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "AGCOM - mobile number portability",
              "AGCOM - portabilita numero mobile",
              "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione/numerazioni-mobili-portabilita-e-cambio-sim",
              "AGCOM",
              "National",
              "Official mobile portability rules",
            ),
          ],
        }),
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "fixed_line_migration_code",
          subcategoryId: "switch_provider_portability",
          sortOrder: 20,
          titleEn: "Fixed line migration code",
          titleIt: "Codice migrazione linea fissa",
          shortEn:
            "Use this when changing landline or internet operator and the migration code becomes the blocking point.",
          shortIt:
            "Usa questa guida quando cambi operatore fisso o internet e il codice migrazione diventa il punto che blocca tutto.",
          sections: [
            sectionText(
              "where",
              "Where to find it",
              "Dove trovarlo",
              "It is usually on the bill or official customer area. Do not rely on a phone operator reading it too fast to you unless you can verify it later.",
              "Di solito e in bolletta o nell'area clienti ufficiale. Non affidarti solo a un operatore telefonico che te lo legge velocemente se poi non puoi verificarlo.",
            ),
          ],
          officialLinks: [
            link(
              "AGCOM - portability and migration",
              "AGCOM - portabilita e migrazione",
              "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione",
              "AGCOM",
              "National",
              "Official rules for fixed-line migration",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "cancel_contract",
      sortOrder: 60,
      titleEn: "I need to cancel the contract cleanly",
      titleIt: "Devo disdire il contratto senza problemi",
      descriptionEn:
        "Use this if you want the line closed without extra confusion over equipment and final charges.",
      descriptionIt:
        "Usa questo percorso se vuoi chiudere la linea senza confusione su apparati e addebiti finali.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "internet_phone_cancellation",
          subcategoryId: "cancel_contract",
          sortOrder: 10,
          titleEn: "Cancel internet or phone contract",
          titleIt: "Disdire internet o telefono",
          shortEn:
            "Use this before the moving date or cancellation date so you do not leave loose ends.",
          shortIt:
            "Usa questa guida prima della data di trasloco o disdetta per non lasciare pratiche aperte.",
          sections: [
            sectionChecklist(
              "close",
              "Close the file properly",
              "Chiudi bene la pratica",
              [
                "Keep proof of the cancellation request.",
                "Check whether modem return is required.",
                "Keep the final bill and verify that the line really closed.",
              ],
              [
                "Conserva prova della richiesta di disdetta.",
                "Controlla se e prevista restituzione modem.",
                "Conserva la bolletta finale e verifica che la linea sia davvero chiusa.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "AGCOM - portability and migration",
              "AGCOM - portabilita e migrazione",
              "https://www.agcom.it/competenze/comunicazioni-elettroniche/reti/numerazione/portabilita-del-numero-e-migrazione",
              "AGCOM",
              "National",
              "Regulatory baseline for telecom switching and closure context",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "modem_equipment",
      sortOrder: 70,
      titleEn: "The operator is asking for modem or equipment money",
      titleIt: "L'operatore chiede soldi per modem o apparati",
      descriptionEn:
        "Use this when the closure is done but the fight is really about returned hardware or extra charges.",
      descriptionIt:
        "Usa questo percorso quando la linea e chiusa ma il problema vero riguarda modem restituito o addebiti extra.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "modem_return_or_charge_dispute",
          subcategoryId: "modem_equipment",
          sortOrder: 10,
          titleEn: "Modem return or equipment charge dispute",
          titleIt: "Restituzione modem o contestazione apparati",
          shortEn:
            "Use this if the operator says the modem was not returned or charges more than expected.",
          shortIt:
            "Usa questa guida se l'operatore dice che il modem non e stato restituito o addebita piu del previsto.",
          sections: [
            sectionChecklist(
              "proof",
              "Best proof",
              "Prove migliori",
              [
                "Return receipt or courier proof.",
                "Photos of the parcel contents if available.",
                "Operator instructions that told you where and how to return it.",
              ],
              [
                "Ricevuta di reso o prova del corriere.",
                "Foto del contenuto del pacco se disponibili.",
                "Istruzioni dell'operatore che dicevano dove e come restituirlo.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ConciliaWeb",
              "ConciliaWeb",
              "https://conciliaweb.agcom.it/conciliaweb/",
              "AGCOM",
              "National",
              "Escalation route if the equipment dispute is unresolved",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "wrong_bill_refunds",
      sortOrder: 80,
      titleEn: "My bill is wrong and I need money back",
      titleIt: "La bolletta e sbagliata e devo riavere soldi",
      descriptionEn:
        "Use this for wrong telecom charges, missing discounts, and refund requests.",
      descriptionIt:
        "Usa questo percorso per addebiti telecom sbagliati, sconti mancanti e richieste di rimborso.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "wrong_bill_complaint",
          subcategoryId: "wrong_bill_refunds",
          sortOrder: 10,
          titleEn: "Wrong telecom bill complaint",
          titleIt: "Reclamo per bolletta telecom sbagliata",
          shortEn:
            "Use this if the amount or charge is wrong and a simple call is not enough.",
          shortIt:
            "Usa questa guida se importo o addebito sono sbagliati e una telefonata non basta.",
          sections: [
            sectionChecklist(
              "send",
              "Send a written file with",
              "Invia un reclamo scritto con",
              [
                "Bill number and date.",
                "Short explanation of the wrong charge.",
                "What exact correction or refund you want.",
                "Attachments proving your version.",
              ],
              [
                "Numero e data bolletta.",
                "Breve spiegazione dell'addebito errato.",
                "Quale correzione o rimborso chiedi esattamente.",
                "Allegati che provano la tua versione.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ConciliaWeb",
              "ConciliaWeb",
              "https://conciliaweb.agcom.it/conciliaweb/",
              "AGCOM",
              "National",
              "Official escalation route for telecom disputes",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "service_not_working",
      sortOrder: 90,
      titleEn: "My line is not working and support keeps wasting time",
      titleIt: "La linea non funziona e l'assistenza fa perdere tempo",
      descriptionEn:
        "Use this when the service fault is real and ordinary support is going nowhere.",
      descriptionIt:
        "Usa questo percorso quando il guasto e reale e l'assistenza ordinaria non porta da nessuna parte.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "service_not_working_complaint",
          subcategoryId: "service_not_working",
          sortOrder: 10,
          titleEn: "Service not working complaint",
          titleIt: "Reclamo per servizio non funzionante",
          shortEn:
            "Use this when the line fails repeatedly or support closes tickets without solving the fault.",
          shortIt:
            "Usa questa guida quando la linea cade spesso o l'assistenza chiude ticket senza risolvere il guasto.",
          sections: [
            sectionChecklist(
              "track",
              "Track these details",
              "Traccia questi dettagli",
              [
                "Outage dates and times.",
                "Ticket numbers.",
                "Whether the whole building or only your line is affected.",
                "Any promised intervention that never happened.",
              ],
              [
                "Date e orari dei disservizi.",
                "Numeri ticket.",
                "Se il problema riguarda tutto il palazzo o solo la tua linea.",
                "Eventuali interventi promessi ma mai eseguiti.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ConciliaWeb user area",
              "Area utente ConciliaWeb",
              "https://conciliaweb.agcom.it/conciliaweb/cliente/index.htm?lang=it",
              "AGCOM",
              "National",
              "Telecom complaint escalation and temporary measures context",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "slow_internet_speed",
      sortOrder: 100,
      titleEn: "The internet is too slow and I need real proof",
      titleIt: "Internet e troppo lento e mi serve una prova seria",
      descriptionEn:
        "Use this when speed complaints need more than ordinary screenshots.",
      descriptionIt:
        "Usa questo percorso quando il reclamo sulla velocita richiede piu di semplici screenshot.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "certified_speed_test_nemesys",
          subcategoryId: "slow_internet_speed",
          sortOrder: 10,
          titleEn: "Certified speed test with Ne.Me.Sys",
          titleIt: "Test velocita certificato con Ne.Me.Sys",
          shortEn:
            "Use this when a serious slow-line dispute needs the AGCOM-certified test path.",
          shortIt:
            "Usa questa guida quando una contestazione seria sulla lentezza richiede il test certificato AGCOM.",
          sections: [
            sectionText(
              "why",
              "Why use it",
              "Perche usarlo",
              "Ordinary speed-test screenshots are often too weak for a serious dispute. Ne.Me.Sys is the formal route AGCOM uses for certified measurement.",
              "Gli screenshot dei comuni speed test sono spesso troppo deboli per una contestazione seria. Ne.Me.Sys e il percorso formale AGCOM per la misurazione certificata.",
            ),
          ],
          officialLinks: [
            link(
              "MisuraInternet Ne.Me.Sys",
              "MisuraInternet Ne.Me.Sys",
              "https://misurainternet.it/info_nemesys/",
              "AGCOM",
              "National",
              "Certified speed-test path for telecom disputes",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "contract_not_requested",
      sortOrder: 110,
      titleEn: "They activated something I did not ask for",
      titleIt: "Hanno attivato qualcosa che non ho chiesto",
      descriptionEn:
        "Use this for suspicious phone sales, fake confirmations, or contracts you did not really want.",
      descriptionIt:
        "Usa questo percorso per vendite telefoniche sospette, conferme false o contratti che non volevi davvero.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "contract_not_requested_phone_scam",
          subcategoryId: "contract_not_requested",
          sortOrder: 10,
          titleEn: "Contract not requested or phone scam",
          titleIt: "Contratto non richiesto o truffa telefonica",
          shortEn:
            "Use this if you discover an activation or switch you never intended to confirm.",
          shortIt:
            "Usa questa guida se scopri un'attivazione o un cambio che non volevi davvero confermare.",
          sections: [
            sectionChecklist(
              "save",
              "Save these things fast",
              "Conserva subito queste cose",
              [
                "SMS or email confirmations.",
                "Call date and any known number.",
                "Contract summary if one arrived.",
                "Bills or activation notices showing what happened.",
              ],
              [
                "Conferme via SMS o email.",
                "Data chiamata ed eventuale numero noto.",
                "Riepilogo contrattuale se arrivato.",
                "Bolletta o avvisi di attivazione che mostrano cosa e successo.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ConciliaWeb",
              "ConciliaWeb",
              "https://conciliaweb.agcom.it/conciliaweb/",
              "AGCOM",
              "National",
              "Official dispute route for unauthorized telecom activations",
            ),
            link(
              "AGCOM - conciliation procedure",
              "AGCOM - procedura di conciliazione",
              "https://www.agcom.it/competenze/consumatori/controversie-tra-utenti-finali-e-fornitori-di-servizi-di-comunicazioni-2023/procedura-di-conciliazione",
              "AGCOM",
              "National",
              "Formal consumer-dispute procedure",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "complaints_conciliaweb",
      sortOrder: 120,
      titleEn: "I already complained and now I need AGCOM / ConciliaWeb",
      titleIt: "Ho gia reclamato e ora mi serve AGCOM / ConciliaWeb",
      descriptionEn:
        "Use this when you need the next official step after operator support failed.",
      descriptionIt:
        "Usa questo percorso quando ti serve il passo ufficiale successivo dopo il fallimento dell'assistenza operatore.",
      procedures: [
        procedure({
          categoryId: "telecom_internet_mobile",
          id: "agcom_corecom_conciliaweb_escalation",
          subcategoryId: "complaints_conciliaweb",
          sortOrder: 10,
          titleEn: "AGCOM / ConciliaWeb escalation",
          titleIt: "Escalation AGCOM / ConciliaWeb",
          shortEn:
            "Use this when you already have the complaint file and need the formal telecom dispute route.",
          shortIt:
            "Usa questa guida quando hai gia il fascicolo del reclamo e ti serve il percorso formale della controversia telecom.",
          sections: [
            sectionChecklist(
              "file",
              "Build the file first",
              "Prepara prima il fascicolo",
              [
                "Complaint copy.",
                "Proof of sending.",
                "Operator answer, if any.",
                "Bills, screenshots, ticket numbers, and technical proofs.",
              ],
              [
                "Copia del reclamo.",
                "Prova di invio.",
                "Risposta dell'operatore, se c'e.",
                "Bolletta, screenshot, numeri ticket e prove tecniche.",
              ],
            ),
            sectionText(
              "premium",
              "Premium help",
              "Aiuto premium",
              "Premium can help turn a messy timeline into a cleaner escalation file before you upload it.",
              "Premium puo aiutarti a trasformare una cronologia confusa in un fascicolo piu pulito prima del caricamento.",
              { isPremiumOnly: true },
            ),
          ],
          officialLinks: [
            link(
              "ConciliaWeb",
              "ConciliaWeb",
              "https://conciliaweb.agcom.it/conciliaweb/",
              "AGCOM",
              "National",
              "Official telecom conciliation platform",
            ),
            link(
              "AGCOM - conciliation procedure",
              "AGCOM - procedura di conciliazione",
              "https://www.agcom.it/competenze/consumatori/controversie-tra-utenti-finali-e-fornitori-di-servizi-di-comunicazioni-2023/procedura-di-conciliazione",
              "AGCOM",
              "National",
              "Official explanation of the conciliation route",
            ),
          ],
          contacts: [telecomContacts.agcomContact, telecomContacts.conciliaWeb],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Premium can organize the complaint timeline, attachments, and ConciliaWeb upload checklist.",
          premiumTeaserIt:
            "Premium puo organizzare cronologia reclamo, allegati e checklist per ConciliaWeb.",
        }),
      ],
    }),
  ],
});

for (const catalogPath of catalogPaths) {
  const raw = fs.readFileSync(catalogPath, "utf8");
  const catalog = JSON.parse(raw);

  const canoneIndex = catalog.categories.findIndex(
    (category) => category.id === "canone_rai",
  );
  if (canoneIndex === -1) {
    throw new Error(`canone_rai not found in ${catalogPath}`);
  }
  catalog.categories[canoneIndex] = canoneRaiCategory(
    catalog.categories[canoneIndex],
  );

  const telecomIndex = catalog.categories.findIndex(
    (category) => category.id === "telecom_internet_mobile",
  );
  if (telecomIndex === -1) {
    throw new Error(`telecom_internet_mobile not found in ${catalogPath}`);
  }
  catalog.categories[telecomIndex] = telecomCategory(
    catalog.categories[telecomIndex],
  );

  fs.writeFileSync(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`);
  console.log(`Rewrote Torino canone_rai and telecom_internet_mobile in ${catalogPath}`);
}
