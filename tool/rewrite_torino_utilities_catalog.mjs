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

const related = (titleEn, titleIt, subcategoryId, procedureId) => ({
  title: t(titleEn, titleIt),
  categoryId: "utilities_electricity_gas",
  subcategoryId,
  procedureId,
});

const procedure = ({
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
  categoryId: "utilities_electricity_gas",
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

const commonContacts = {
  sportelloPhone: contact(
    "Sportello per il consumatore Energia e Ambiente",
    "Sportello per il consumatore Energia e Ambiente",
    "800 166 654",
    "phone",
  ),
  sportelloHours: contact(
    "Sportello opening hours",
    "Orari Sportello",
    "Monday to Friday, 08:00-18:00, except holidays",
    "hours",
  ),
  areraEmail: contact("ARERA email", "Email ARERA", "info@arera.it", "email"),
  areraPec: contact(
    "ARERA PEC",
    "PEC ARERA",
    "protocollo@pec.arera.it",
    "pec",
  ),
  iretiElectricEmergency: contact(
    "Ireti electricity emergency",
    "Pronto intervento elettrico Ireti",
    "800 910 101",
    "phone",
  ),
  iretiElectricSupport: contact(
    "Ireti electricity technical support",
    "Supporto tecnico elettrico Ireti",
    "800 977 908",
    "phone",
  ),
  iretiGasEmergency: contact(
    "Ireti gas emergency",
    "Pronto intervento gas Ireti",
    "800 010 020",
    "phone",
  ),
  smatHelp: contact(
    "SMAT customer support",
    "Assistenza utenti SMAT",
    "800 010 010",
    "phone",
  ),
  smatEmergency: contact(
    "SMAT water emergency in Torino",
    "Pronto intervento acqua SMAT a Torino",
    "800 060 060",
    "phone",
  ),
  smatContractsEmail: contact(
    "SMAT contracts email",
    "Email contratti SMAT",
    "contratti@smatorino.it",
    "email",
  ),
  smatVolturaEmail: contact(
    "SMAT voltura email",
    "Email voltura SMAT",
    "voltura@smatorino.it",
    "email",
  ),
  smatAddress: contact(
    "SMAT main office",
    "Sede principale SMAT",
    "Corso XI Febbraio 14, 10152 Torino",
    "address",
  ),
};

const utilitiesCategory = (existing = {}) => ({
  id: "utilities_electricity_gas",
  icon: existing.icon ?? "electric_bolt",
  sortOrder: existing.sortOrder ?? 4,
  isPremiumOnly: false,
  hasPremiumContent: true,
  title: t(
    "Bills & Utilities",
    "Bollette e utenze",
    { fr: "Factures et services", fa: "قبض‌ها و خدمات" },
  ),
  description: t(
    "Torino utilities help: start from the exact bill, move-in, outage, water, or complaint problem.",
    "Utenze a Torino: parti dal problema giusto tra bollette, trasloco, guasti, acqua e reclami.",
    {
      fr: "Aide utilities à Turin : partez du vrai problème de facture, déménagement, panne, eau ou réclamation.",
      fa: "امور قبوض و خدمات در تورین: از مشکل دقیق خود در قبض، اسباب‌کشی، قطعی، آب یا شکایت شروع کن.",
    },
  ),
  contacts: [
    commonContacts.sportelloPhone,
    commonContacts.sportelloHours,
    commonContacts.iretiElectricEmergency,
    commonContacts.iretiGasEmergency,
    commonContacts.smatHelp,
    commonContacts.smatEmergency,
  ],
  officialLinks: [
    link(
      "ARERA - new electricity and gas bill format",
      "ARERA - nuova bolletta luce e gas",
      "https://www.arera.it/nuova-bolletta",
      "ARERA",
      "National",
      "Understand the current bill layout",
    ),
    link(
      "ARERA - Portale Consumi",
      "ARERA - Portale Consumi",
      "https://www.arera.it/consumatori/il-portale-consumi",
      "ARERA",
      "National",
      "Check historical electricity and gas consumption",
    ),
    link(
      "Portale Offerte - compare electricity and gas offers",
      "Portale Offerte - confronta offerte luce e gas",
      "https://www.ilportaleofferte.it/portaleOfferte/it/confronta_offerte.page",
      "Portale Offerte",
      "National",
      "Compare verified offers before switching",
    ),
    link(
      "SMAT - customer services",
      "SMAT - servizi all'utenza",
      "https://www.smatorino.it/servizi-allutenza/",
      "SMAT",
      "Torino",
      "Torino water-service pages and practical modules",
    ),
  ],
  subcategories: [
    subcategory({
      id: "understand_bill_codes",
      sortOrder: 10,
      titleEn: "I need to understand the bill and the codes",
      titleIt: "Devo capire la bolletta e i codici",
      descriptionEn:
        "Start here if you do not know what you are paying, where the key codes are, or which portal to use.",
      descriptionIt:
        "Parti da qui se non capisci cosa stai pagando, dove trovare i codici o quale portale usare.",
      procedures: [
        procedure({
          id: "read_utility_bill",
          subcategoryId: "understand_bill_codes",
          sortOrder: 10,
          titleEn: "Read your electricity or gas bill",
          titleIt: "Leggere la bolletta luce o gas",
          shortEn:
            "Use this if the total looks strange or you do not know which part is energy, transport, taxes, or a correction.",
          shortIt:
            "Usa questa guida se il totale sembra strano o non capisci quale parte riguarda energia, trasporto, imposte o conguagli.",
          sections: [
            sectionChecklist(
              "check_first",
              "Check these parts first",
              "Controlla prima queste parti",
              [
                "Front page total and due date.",
                "Billing period and whether it includes old months or a conguaglio.",
                "Consumption section: actual reading, estimated reading, or self-reading.",
                "Bonus, one-off charges, and previous unpaid balances.",
              ],
              [
                "Totale in prima pagina e scadenza.",
                "Periodo fatturato e presenza di mesi vecchi o conguaglio.",
                "Sezione consumi: lettura reale, stimata o autolettura.",
                "Bonus, addebiti una tantum e vecchi insoluti.",
              ],
            ),
            sectionText(
              "when_escalate",
              "When to stop and complain",
              "Quando fermarti e contestare",
              "If the bill uses estimated readings for too long, includes a period when you did not live there, or charges a service you never activated, keep the bill and start a written complaint.",
              "Se la bolletta usa letture stimate troppo a lungo, include un periodo in cui non vivevi li o addebita un servizio mai attivato, conserva la bolletta e prepara un reclamo scritto.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - new bill format",
              "ARERA - nuova bolletta",
              "https://www.arera.it/nuova-bolletta",
              "ARERA",
              "National",
              "Understand the current regulated bill structure",
            ),
          ],
          relatedProcedures: [
            related(
              "Check a high bill",
              "Controllare una bolletta troppo alta",
              "high_wrong_bills",
              "high_bill_check",
            ),
          ],
        }),
        procedure({
          id: "key_bill_codes_pod_pdr",
          subcategoryId: "understand_bill_codes",
          sortOrder: 20,
          titleEn: "Find POD, PDR, customer code, and meter data",
          titleIt: "Trovare POD, PDR, codice cliente e dati contatore",
          shortEn:
            "Use this before voltura, subentro, switching, complaints, or outage reports.",
          shortIt:
            "Usa questa guida prima di voltura, subentro, cambio fornitore, reclami o segnalazioni guasti.",
          sections: [
            sectionChecklist(
              "codes",
              "What each code is for",
              "A cosa serve ogni codice",
              [
                "POD identifies the electricity supply point.",
                "PDR identifies the gas supply point.",
                "Customer code or contract code helps the supplier find your account.",
                "Meter number is useful when the address has many meters.",
              ],
              [
                "Il POD identifica il punto di fornitura elettrica.",
                "Il PDR identifica il punto di fornitura gas.",
                "Codice cliente o contratto serve al fornitore per trovare la tua pratica.",
                "Il numero contatore aiuta quando all'indirizzo ci sono piu contatori.",
              ],
            ),
            sectionText(
              "torino_note",
              "Torino practical note",
              "Nota pratica Torino",
              "If you are moving into an apartment in Torino, ask the old tenant or landlord for the last bill before you start any request. It makes voltura or subentro much faster.",
              "Se entri in un alloggio a Torino, chiedi al vecchio inquilino o al proprietario l'ultima bolletta prima di fare richieste. Accelera molto voltura o subentro.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - electricity bill supply data and POD",
              "ARERA - dati fornitura elettrica e POD",
              "https://www.arera.it/bolletta/bolletta-dellelettricita/dati-della-fornitura",
              "ARERA",
              "National",
              "Find POD and electricity supply data on the bill",
            ),
            link(
              "ARERA - gas bill supply data and PDR",
              "ARERA - dati fornitura gas e PDR",
              "https://www.arera.it/bolletta/bolletta-del-gas/dati-della-fornitura",
              "ARERA",
              "National",
              "Find PDR and gas supply data on the bill",
            ),
          ],
        }),
        procedure({
          id: "water_bill_codes_smat",
          subcategoryId: "understand_bill_codes",
          sortOrder: 30,
          titleEn: "Read a SMAT water bill in Torino",
          titleIt: "Leggere la bolletta acqua SMAT a Torino",
          shortEn:
            "Use this if the problem is water, a missed bill, a recapito change, or a suspected hidden leak.",
          shortIt:
            "Usa questa guida se il problema riguarda l'acqua, una bolletta non ricevuta, il cambio recapito o una perdita occulta.",
          sections: [
            sectionChecklist(
              "look_for",
              "Look for these codes",
              "Cerca questi codici",
              [
                "Customer code and contract code.",
                "Service address and mailing address.",
                "Meter reading details and whether SMAT used actual or estimated consumption.",
                "PagoPA / CBILL references for payment.",
              ],
              [
                "Codice cliente e codice contratto.",
                "Indirizzo della fornitura e indirizzo di recapito.",
                "Dettaglio letture e se SMAT ha usato consumi reali o stimati.",
                "Riferimenti PagoPA / CBILL per il pagamento.",
              ],
            ),
            sectionText(
              "smat_portal",
              "Fastest Torino path",
              "Percorso piu rapido a Torino",
              "If you already have the SMAT online account, check the bill and payment history there first. It is often faster than waiting for a paper copy or support reply.",
              "Se hai gia l'account SMAT online, controlla li la bolletta e lo storico pagamenti. Di solito e piu rapido che aspettare una copia cartacea o una risposta dell'assistenza.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Check water bills, payments, readings, and service requests online",
            ),
            link(
              "SMAT - customer services",
              "SMAT - servizi all'utenza",
              "https://www.smatorino.it/servizi-allutenza/",
              "SMAT",
              "Torino",
              "Understand water-bill services and user tools",
            ),
          ],
          contacts: [
            commonContacts.smatHelp,
            commonContacts.smatContractsEmail,
          ],
        }),
      ],
    }),
    subcategory({
      id: "move_in_activation",
      sortOrder: 20,
      titleEn: "I am moving house and need utilities on",
      titleIt: "Mi trasferisco e devo attivare le utenze",
      descriptionEn:
        "Voltura, subentro, first activation, and Torino water requests without mixing them up.",
      descriptionIt:
        "Voltura, subentro, prima attivazione e pratiche acqua a Torino senza confonderle.",
      procedures: [
        procedure({
          id: "moving_utilities_decision",
          subcategoryId: "move_in_activation",
          sortOrder: 10,
          titleEn: "Voltura, subentro, or first activation?",
          titleIt: "Voltura, subentro o prima attivazione?",
          shortEn:
            "Use this before contacting anyone. Choosing the wrong request wastes time.",
          shortIt:
            "Usa questa guida prima di contattare qualcuno. Scegliere la pratica sbagliata fa perdere tempo.",
          sections: [
            sectionChecklist(
              "decision",
              "Choose the right path",
              "Scegli il percorso giusto",
              [
                "Supply still active and you only change the name: voltura.",
                "Meter exists but supply is closed: subentro.",
                "No meter or no service has ever been activated for that unit: first activation or new connection.",
                "Water in Torino usually follows a separate SMAT path, even if electricity and gas are handled elsewhere.",
              ],
              [
                "Fornitura ancora attiva e cambi solo intestatario: voltura.",
                "Contatore esistente ma fornitura chiusa: subentro.",
                "Nessun contatore o nessuna fornitura mai attivata in quell'unita: prima attivazione o nuovo allaccio.",
                "L'acqua a Torino segue spesso un percorso SMAT separato, anche se luce e gas passano altrove.",
              ],
            ),
            sectionText(
              "before_calling",
              "Before calling",
              "Prima di chiamare",
              "Collect the exact address, apartment details, the last bill if possible, and proof that you can use the property. In Torino apartment blocks, wrong stair or interior numbers slow down requests a lot.",
              "Raccogli indirizzo esatto, dettagli dell'interno, ultima bolletta se possibile e prova che puoi usare l'immobile. Nei condomini di Torino sbagliare scala o interno rallenta molto la pratica.",
            ),
          ],
          officialLinks: [
            link(
              "Ireti - service requests and POD guidance",
              "Ireti - richiesta servizi e guida POD",
              "https://www.ireti.it/servizi/distribuzione-energia-elettrica/clienti-finali/prestazioni/richiesta-servizi.html",
              "Ireti",
              "Torino",
              "Understand distributor-side request data for electricity in Torino",
            ),
            link(
              "SMAT - aqueduct administrative forms",
              "SMAT - pratiche amministrative acquedotto",
              "https://www.smatorino.it/pratiche-amministrative-e-modulistica-servizio-acquedotto/",
              "SMAT",
              "Torino",
              "Torino water activation, voltura, and contract forms",
            ),
          ],
        }),
        procedure({
          id: "voltura",
          subcategoryId: "move_in_activation",
          sortOrder: 20,
          titleEn: "Voltura for electricity or gas",
          titleIt: "Voltura luce o gas",
          shortEn:
            "Use this when the supply is still active and you want the contract in your name without cutting the service.",
          shortIt:
            "Usa questa guida quando la fornitura e ancora attiva e vuoi il contratto a tuo nome senza staccare il servizio.",
          sections: [
            sectionChecklist(
              "need",
              "Prepare these details",
              "Prepara questi dati",
              [
                "Last bill with POD or PDR.",
                "Identity document and codice fiscale.",
                "Address, apartment details, and date you took the home.",
                "Rental contract, hospitality declaration, or purchase deed if available.",
              ],
              [
                "Ultima bolletta con POD o PDR.",
                "Documento di identita e codice fiscale.",
                "Indirizzo, dettagli dell'interno e data di ingresso nell'alloggio.",
                "Contratto di affitto, dichiarazione di ospitalita o rogito se disponibili.",
              ],
            ),
            sectionText(
              "warning",
              "Do not use this if",
              "Non usare questa pratica se",
              "If the supplier says the point is closed, sealed, or inactive, you probably need subentro instead.",
              "Se il fornitore dice che il punto e chiuso, sigillato o inattivo, probabilmente ti serve il subentro.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - electricity bill supply data",
              "ARERA - dati fornitura elettrica",
              "https://www.arera.it/bolletta/bolletta-dellelettricita/dati-della-fornitura",
              "ARERA",
              "National",
              "Find electricity data needed for a voltura",
            ),
            link(
              "ARERA - gas bill supply data",
              "ARERA - dati fornitura gas",
              "https://www.arera.it/bolletta/bolletta-del-gas/dati-della-fornitura",
              "ARERA",
              "National",
              "Find gas data needed for a voltura",
            ),
          ],
          relatedProcedures: [
            related(
              "SMAT water activation or voltura",
              "Attivazione o voltura acqua SMAT",
              "move_in_activation",
              "smat_water_activation_or_voltura",
            ),
          ],
        }),
        procedure({
          id: "subentro",
          subcategoryId: "move_in_activation",
          sortOrder: 30,
          titleEn: "Subentro for electricity or gas",
          titleIt: "Subentro luce o gas",
          shortEn:
            "Use this when the meter exists but the supply is no longer active.",
          shortIt:
            "Usa questa guida quando il contatore esiste ma la fornitura non e piu attiva.",
          sections: [
            sectionChecklist(
              "steps",
              "What to expect",
              "Cosa aspettarti",
              [
                "Supplier opens the contract again for your name.",
                "Gas can take longer because safety checks may be needed.",
                "If you need heating or hot water soon, do not wait until the last day after moving in.",
              ],
              [
                "Il fornitore riapre il contratto a tuo nome.",
                "Il gas puo richiedere piu tempo per eventuali controlli di sicurezza.",
                "Se ti servono presto riscaldamento o acqua calda, non aspettare l'ultimo giorno dopo il trasloco.",
              ],
            ),
            sectionText(
              "proof",
              "Keep proof of the request",
              "Conserva la prova della richiesta",
              "Save the request number, date, and promised activation window. If the activation keeps slipping, you need those details for a complaint.",
              "Salva numero pratica, data e finestra promessa di attivazione. Se l'attivazione slitta, ti servono per il reclamo.",
            ),
          ],
          officialLinks: [
            link(
              "Ireti - service requests and POD guidance",
              "Ireti - richiesta servizi e guida POD",
              "https://www.ireti.it/servizi/distribuzione-energia-elettrica/clienti-finali/prestazioni/richiesta-servizi.html",
              "Ireti",
              "Torino",
              "Understand electricity distributor-side request data in Torino",
            ),
            link(
              "ARERA - Portale Consumi",
              "ARERA - Portale Consumi",
              "https://www.arera.it/consumatori/il-portale-consumi",
              "ARERA",
              "National",
              "Check historical electricity or gas data when useful",
            ),
          ],
        }),
        procedure({
          id: "first_activation",
          subcategoryId: "move_in_activation",
          sortOrder: 40,
          titleEn: "First activation or new connection",
          titleIt: "Prima attivazione o nuovo allaccio",
          shortEn:
            "Use this when there is no working supply for that unit and the request is more than a simple name change.",
          shortIt:
            "Usa questa guida quando non c'e una fornitura funzionante per quell'unita e la pratica non e un semplice cambio nome.",
          sections: [
            sectionChecklist(
              "bring",
              "Usually needed",
              "Di solito serve",
              [
                "Exact property address and apartment details.",
                "Owner or user identity data.",
                "Technical details if the supplier or distributor asks for them.",
                "Extra time for estimates, distributor work, or appointments.",
              ],
              [
                "Indirizzo esatto dell'immobile e dettagli dell'unita.",
                "Dati di identita del proprietario o utilizzatore.",
                "Dettagli tecnici se richiesti da fornitore o distributore.",
                "Tempo extra per preventivi, lavori del distributore o appuntamenti.",
              ],
            ),
            sectionText(
              "torino",
              "Torino note",
              "Nota Torino",
              "In older Torino buildings, confirm early whether the unit already has a meter and whether power upgrades or internal building work are needed. That changes timing and cost.",
              "Negli edifici piu vecchi di Torino, verifica subito se l'unita ha gia un contatore e se servono aumenti di potenza o lavori interni. Questo cambia tempi e costi.",
            ),
          ],
          officialLinks: [
            link(
              "Ireti - service requests and POD guidance",
              "Ireti - richiesta servizi e guida POD",
              "https://www.ireti.it/servizi/distribuzione-energia-elettrica/clienti-finali/prestazioni/richiesta-servizi.html",
              "Ireti",
              "Torino",
              "Understand electricity distributor requests for activation or works",
            ),
          ],
          contacts: [commonContacts.iretiElectricSupport],
        }),
        procedure({
          id: "smat_water_activation_or_voltura",
          subcategoryId: "move_in_activation",
          sortOrder: 50,
          titleEn: "SMAT water activation or voltura in Torino",
          titleIt: "Attivazione o voltura acqua SMAT a Torino",
          shortEn:
            "Use this for Torino water service when you move in, change holder, or need the contract updated.",
          shortIt:
            "Usa questa guida per l'acqua SMAT a Torino quando entri in casa, cambi intestatario o devi aggiornare il contratto.",
          sections: [
            sectionChecklist(
              "smat_steps",
              "Best practical route",
              "Percorso pratico migliore",
              [
                "Download the right SMAT form first.",
                "Use the online desk if you can, especially for voltura and bill-address updates.",
                "If you send by email, keep the sent copy and attachments.",
                "If something is urgent, call support and ask whether the request is complete before waiting.",
              ],
              [
                "Scarica prima il modulo SMAT giusto.",
                "Usa lo sportello online se possibile, soprattutto per voltura e cambio recapito bolletta.",
                "Se invii via email, conserva copia inviata e allegati.",
                "Se hai urgenza, chiama l'assistenza e chiedi se la pratica e completa prima di aspettare.",
              ],
            ),
            sectionText(
              "where",
              "Where to send it",
              "Dove inviarla",
              "SMAT lists email channels for contracts and voltura and also accepts in-person or postal submission. Use the exact module for the service you need.",
              "SMAT indica canali email per contratti e voltura e accetta anche consegna a sportello o posta. Usa il modulo esatto per la pratica che ti serve.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - aqueduct administrative forms",
              "SMAT - pratiche amministrative acquedotto",
              "https://www.smatorino.it/pratiche-amministrative-e-modulistica-servizio-acquedotto/",
              "SMAT",
              "Torino",
              "Download Torino water forms for activation, voltura, and contract changes",
            ),
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Handle water account actions online",
            ),
          ],
          contacts: [
            commonContacts.smatHelp,
            commonContacts.smatContractsEmail,
            commonContacts.smatVolturaEmail,
            commonContacts.smatAddress,
          ],
        }),
      ],
    }),
    subcategory({
      id: "supplier_distributor_contacts",
      sortOrder: 30,
      titleEn: "I do not know who I should call",
      titleIt: "Non so chi devo contattare",
      descriptionEn:
        "Supplier, distributor, SMAT, and emergency numbers for Torino-area utility problems.",
      descriptionIt:
        "Fornitore, distributore, SMAT e numeri di emergenza per i problemi utenze nell'area di Torino.",
      procedures: [
        procedure({
          id: "who_to_contact_supplier_or_distributor",
          subcategoryId: "supplier_distributor_contacts",
          sortOrder: 10,
          titleEn: "Supplier or distributor?",
          titleIt: "Fornitore o distributore?",
          shortEn:
            "Use this when the phone number on the bill and the real problem do not seem to match.",
          shortIt:
            "Usa questa guida quando il numero sulla bolletta e il problema reale non sembrano coincidere.",
          sections: [
            sectionChecklist(
              "routing",
              "Call the supplier when",
              "Chiama il fornitore quando",
              [
                "The bill is wrong.",
                "You need a payment plan, refund, or contract change.",
                "You are switching, doing voltura, or checking commercial conditions.",
              ],
              [
                "La bolletta e sbagliata.",
                "Ti serve rateizzazione, rimborso o modifica contrattuale.",
                "Stai cambiando fornitore, facendo voltura o controllando condizioni commerciali.",
              ],
            ),
            sectionChecklist(
              "routing2",
              "Call the distributor or emergency line when",
              "Chiama il distributore o il pronto intervento quando",
              [
                "There is an outage, burning smell, spark, or gas leak.",
                "The meter is faulty or inaccessible for a technical intervention.",
                "The supplier tells you the issue is technical and not commercial.",
              ],
              [
                "C'e blackout, odore di bruciato, scintille o fuga di gas.",
                "Il contatore ha un guasto o serve un intervento tecnico.",
                "Il fornitore ti dice che il problema e tecnico e non commerciale.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ARERA - electricity bill supply data",
              "ARERA - dati fornitura elettrica",
              "https://www.arera.it/bolletta/bolletta-dellelettricita/dati-della-fornitura",
              "ARERA",
              "National",
              "Find who manages the electricity supply details on the bill",
            ),
            link(
              "ARERA - gas bill supply data",
              "ARERA - dati fornitura gas",
              "https://www.arera.it/bolletta/bolletta-del-gas/dati-della-fornitura",
              "ARERA",
              "National",
              "Find who manages the gas supply details on the bill",
            ),
          ],
        }),
        procedure({
          id: "torino_distributor_emergency_contacts",
          subcategoryId: "supplier_distributor_contacts",
          sortOrder: 20,
          titleEn: "Torino distributor and water emergency contacts",
          titleIt: "Contatti distributore e acqua a Torino",
          shortEn:
            "Keep these numbers ready for outage, gas smell, meter emergency, or water leak cases.",
          shortIt:
            "Tieni pronti questi numeri per blackout, odore di gas, emergenza contatore o perdita acqua.",
          sections: [
            sectionChecklist(
              "numbers",
              "Main Torino numbers",
              "Numeri principali a Torino",
              [
                "Ireti electricity emergency: 800 910 101.",
                "Ireti gas emergency: 800 010 020.",
                "SMAT water emergency in Torino: 800 060 060.",
                "SMAT customer support for ordinary user issues: 800 010 010.",
              ],
              [
                "Pronto intervento elettrico Ireti: 800 910 101.",
                "Pronto intervento gas Ireti: 800 010 020.",
                "Pronto intervento acqua SMAT a Torino: 800 060 060.",
                "Assistenza utenti SMAT per problemi ordinari: 800 010 010.",
              ],
            ),
            sectionText(
              "tell_them",
              "Say this first",
              "Di' subito questo",
              "Give the exact address, stair, floor, apartment, your callback number, and whether the problem affects only your home or the whole building.",
              "Dai subito indirizzo esatto, scala, piano, interno, numero richiamabile e se il problema riguarda solo casa tua o tutto il palazzo.",
            ),
          ],
          officialLinks: [
            link(
              "Ireti - support and emergency contacts",
              "Ireti - supporto e contatti di pronto intervento",
              "https://www.ireti.it/supporto.html",
              "Ireti",
              "Torino",
              "Torino-area electricity and gas emergency numbers",
            ),
            link(
              "SMAT - green numbers",
              "SMAT - numeri verdi",
              "https://www.smatorino.it/numeri-verdi/",
              "SMAT",
              "Torino",
              "Torino water assistance and emergency numbers",
            ),
          ],
          contacts: [
            commonContacts.iretiElectricEmergency,
            commonContacts.iretiGasEmergency,
            commonContacts.smatEmergency,
            commonContacts.smatHelp,
          ],
        }),
      ],
    }),
    subcategory({
      id: "compare_switch_offers",
      sortOrder: 40,
      titleEn: "I want to compare or switch offers safely",
      titleIt: "Voglio confrontare o cambiare offerta in sicurezza",
      descriptionEn:
        "Use official comparison tools first, then decide if the switch is worth it.",
      descriptionIt:
        "Usa prima gli strumenti ufficiali di confronto, poi decidi se il cambio conviene davvero.",
      procedures: [
        procedure({
          id: "compare_offers_safely",
          subcategoryId: "compare_switch_offers",
          sortOrder: 10,
          titleEn: "Compare offers safely",
          titleIt: "Confrontare offerte in sicurezza",
          shortEn:
            "Use official portals before accepting a call-center or door-to-door offer.",
          shortIt:
            "Usa i portali ufficiali prima di accettare un'offerta da call center o porta a porta.",
          sections: [
            sectionChecklist(
              "how",
              "Best order",
              "Ordine migliore",
              [
                "Check your real consumption first on the bill or Portale Consumi.",
                "Compare with Portale Offerte, not only with the salesperson's screenshot.",
                "Read whether the price is fixed or variable and for how long.",
                "Check extra services, penalties, and whether the offer includes add-ons you do not need.",
              ],
              [
                "Controlla prima i consumi reali su bolletta o Portale Consumi.",
                "Confronta con Portale Offerte, non solo con lo screenshot del venditore.",
                "Leggi se il prezzo e fisso o variabile e per quanto tempo.",
                "Controlla servizi extra, penali e se l'offerta include accessori che non ti servono.",
              ],
            ),
            sectionText(
              "price_only",
              "Do not rank only by price",
              "Non guardare solo il prezzo",
              "A very cheap headline price can hide a short promotional period, weak customer support, or terms that become worse after a few months.",
              "Un prezzo iniziale molto basso puo nascondere promozioni brevi, assistenza debole o condizioni peggiori dopo pochi mesi.",
            ),
          ],
          officialLinks: [
            link(
              "Portale Offerte - compare offers",
              "Portale Offerte - confronta offerte",
              "https://www.ilportaleofferte.it/portaleOfferte/it/confronta_offerte.page",
              "Portale Offerte",
              "National",
              "Official comparison of electricity and gas offers",
            ),
            link(
              "ARERA - Portale Consumi",
              "ARERA - Portale Consumi",
              "https://www.arera.it/consumatori/il-portale-consumi",
              "ARERA",
              "National",
              "Check historical consumption before comparing offers",
            ),
          ],
        }),
        procedure({
          id: "switch_supplier",
          subcategoryId: "compare_switch_offers",
          sortOrder: 20,
          titleEn: "Switch supplier without confusion",
          titleIt: "Cambiare fornitore senza confusione",
          shortEn:
            "Use this if you want to switch supplier but do not want to accidentally start the wrong practice.",
          shortIt:
            "Usa questa guida se vuoi cambiare fornitore senza avviare per errore la pratica sbagliata.",
          sections: [
            sectionChecklist(
              "switch",
              "Before confirming the switch",
              "Prima di confermare il cambio",
              [
                "Verify the offer on Portale Offerte if possible.",
                "Check who the current holder is and that the supply is already in the correct name.",
                "Keep the offer sheet, contract summary, and any confirmation email or recording details.",
              ],
              [
                "Verifica l'offerta sul Portale Offerte se possibile.",
                "Controlla chi e l'intestatario attuale e che la fornitura sia gia nel nome corretto.",
                "Conserva scheda offerta, riepilogo contrattuale ed eventuale email o dettagli della conferma.",
              ],
            ),
            sectionText(
              "avoid_mixup",
              "Avoid this mix-up",
              "Evita questa confusione",
              "Switching supplier is not the same as voltura or subentro. If the name or service status is wrong, fix that first.",
              "Il cambio fornitore non e la stessa cosa di voltura o subentro. Se il nome o lo stato della fornitura non sono corretti, sistema prima quello.",
            ),
          ],
          officialLinks: [
            link(
              "Portale Offerte - compare offers",
              "Portale Offerte - confronta offerte",
              "https://www.ilportaleofferte.it/portaleOfferte/it/confronta_offerte.page",
              "Portale Offerte",
              "National",
              "Compare before switching",
            ),
            link(
              "Portale Offerte - switching information",
              "Portale Offerte - informazioni sul cambio venditore",
              "https://www.ilportaleofferte.it/portaleOfferte/it/content_detail.page?contentId=CNG463",
              "Portale Offerte",
              "National",
              "Read how switching works",
            ),
          ],
          relatedProcedures: [
            related(
              "Voltura, subentro, or first activation?",
              "Voltura, subentro o prima attivazione?",
              "move_in_activation",
              "moving_utilities_decision",
            ),
          ],
        }),
        procedure({
          id: "suspicious_utility_sales_calls",
          subcategoryId: "compare_switch_offers",
          sortOrder: 30,
          titleEn: "Suspicious call-center or door-to-door offer",
          titleIt: "Offerta sospetta da call center o porta a porta",
          shortEn:
            "Use this if someone pressures you to switch immediately or says your contract is about to end.",
          shortIt:
            "Usa questa guida se qualcuno ti spinge a cambiare subito o dice che il tuo contratto sta per finire.",
          sections: [
            sectionChecklist(
              "red_flags",
              "Red flags",
              "Segnali di rischio",
              [
                "They ask you to read codes from the bill before explaining who they are.",
                "They say the switch is mandatory or urgent without showing the exact offer sheet.",
                "They avoid sending the conditions in writing.",
              ],
              [
                "Ti chiedono di leggere i codici in bolletta prima di spiegare bene chi sono.",
                "Dicono che il cambio e obbligatorio o urgente senza mostrare la scheda offerta esatta.",
                "Evitano di inviarti condizioni scritte.",
              ],
            ),
            sectionText(
              "safe_move",
              "Safer move",
              "Mossa piu sicura",
              "Do not confirm on the spot. Check the offer independently and keep a screenshot or written record of what was proposed.",
              "Non confermare sul momento. Controlla l'offerta in modo indipendente e conserva screenshot o traccia scritta di cio che ti e stato proposto.",
            ),
          ],
          officialLinks: [
            link(
              "Portale Offerte - official offer comparison",
              "Portale Offerte - confronto ufficiale offerte",
              "https://www.ilportaleofferte.it/portaleOfferte/",
              "Portale Offerte",
              "National",
              "Verify whether the offer really exists and how it compares",
            ),
            link(
              "ARERA - energy vigilance and consumer warnings",
              "ARERA - vigilanza energetica e avvisi ai consumatori",
              "https://www.arera.it/vigilanza-energetica",
              "ARERA",
              "National",
              "Consumer warnings and market context",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "high_wrong_bills",
      sortOrder: 50,
      titleEn: "My bill is too high or wrong",
      titleIt: "La bolletta e troppo alta o sbagliata",
      descriptionEn:
        "Check high charges, estimated readings, wrong services, and Torino water hidden-leak cases.",
      descriptionIt:
        "Controlla importi alti, letture stimate, servizi sbagliati e casi acqua con perdita occulta a Torino.",
      procedures: [
        procedure({
          id: "high_bill_check",
          subcategoryId: "high_wrong_bills",
          sortOrder: 10,
          titleEn: "Check a high electricity or gas bill",
          titleIt: "Controllare una bolletta luce o gas troppo alta",
          shortEn:
            "Use this before sending a complaint so you can point to the right problem.",
          shortIt:
            "Usa questa guida prima di fare reclamo, cosi punti subito al problema giusto.",
          sections: [
            sectionChecklist(
              "causes",
              "Check these common causes",
              "Controlla queste cause frequenti",
              [
                "Estimated reading replaced later by a big conguaglio.",
                "Different billing period or season compared with older bills.",
                "Wrong tariff, power, or contract conditions after a switch.",
                "Unpaid previous balance or one-off charge added to the new bill.",
              ],
              [
                "Lettura stimata sostituita poi da un grande conguaglio.",
                "Periodo fatturato o stagione diversa rispetto alle vecchie bollette.",
                "Tariffa, potenza o condizioni contrattuali errate dopo un cambio.",
                "Vecchio insoluto o addebito una tantum aggiunto alla nuova bolletta.",
              ],
            ),
            sectionText(
              "proof",
              "Best proof to collect",
              "Prove migliori da raccogliere",
              "Keep the new bill, at least one older bill, photos of the meter if relevant, and any self-reading you sent.",
              "Conserva la nuova bolletta, almeno una vecchia, foto del contatore se utili ed eventuale autolettura inviata.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - new bill format",
              "ARERA - nuova bolletta",
              "https://www.arera.it/nuova-bolletta",
              "ARERA",
              "National",
              "Understand line items and consumption sections",
            ),
            link(
              "ARERA - Portale Consumi",
              "ARERA - Portale Consumi",
              "https://www.arera.it/consumatori/il-portale-consumi",
              "ARERA",
              "National",
              "Check historical consumption and readings",
            ),
          ],
        }),
        procedure({
          id: "meter_reading_correction",
          subcategoryId: "high_wrong_bills",
          sortOrder: 20,
          titleEn: "Correct a wrong reading or estimated consumption",
          titleIt: "Correggere una lettura errata o stimata",
          shortEn:
            "Use this when the bill is based on the wrong meter reading or on estimates that no longer match reality.",
          shortIt:
            "Usa questa guida quando la bolletta si basa su una lettura sbagliata o su stime che non corrispondono piu ai consumi reali.",
          sections: [
            sectionChecklist(
              "actions",
              "What to do",
              "Cosa fare",
              [
                "Photograph the meter clearly.",
                "Write down the reading date and value.",
                "Send the correction through the supplier channel or official self-reading path.",
                "Keep proof in case the next bill ignores the correction.",
              ],
              [
                "Fotografa chiaramente il contatore.",
                "Scrivi data e valore della lettura.",
                "Invia la correzione tramite il canale del fornitore o il percorso ufficiale di autolettura.",
                "Conserva prova nel caso la bolletta successiva ignori la correzione.",
              ],
            ),
            sectionText(
              "torino",
              "Torino practical note",
              "Nota pratica Torino",
              "In buildings with many meters, double-check the meter number before sending the reading. Sending the right number with the wrong meter is a common mistake.",
              "Negli edifici con molti contatori, controlla bene il numero del contatore prima di inviare la lettura. Inviare il numero giusto con il contatore sbagliato e un errore comune.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - electricity supply data",
              "ARERA - dati fornitura elettrica",
              "https://www.arera.it/bolletta/bolletta-dellelettricita/dati-della-fornitura",
              "ARERA",
              "National",
              "Check electricity bill data and meter references",
            ),
            link(
              "ARERA - gas supply data",
              "ARERA - dati fornitura gas",
              "https://www.arera.it/bolletta/bolletta-del-gas/dati-della-fornitura",
              "ARERA",
              "National",
              "Check gas bill data and meter references",
            ),
          ],
        }),
        procedure({
          id: "wrong_water_bill_or_hidden_leak",
          subcategoryId: "high_wrong_bills",
          sortOrder: 30,
          titleEn: "Wrong SMAT water bill or hidden leak",
          titleIt: "Bolletta acqua SMAT sbagliata o perdita occulta",
          shortEn:
            "Use this if the water bill suddenly exploded or you suspect a hidden leak after the meter.",
          shortIt:
            "Usa questa guida se la bolletta acqua e esplosa all'improvviso o sospetti una perdita occulta dopo il contatore.",
          sections: [
            sectionChecklist(
              "urgent",
              "Do this fast",
              "Fallo subito",
              [
                "Check whether the meter is still moving when all taps are closed.",
                "Repair the loss and keep the repair proof.",
                "Keep the bill and the date you noticed the problem.",
                "Use the SMAT hidden-leak protection path if the case matches their conditions.",
              ],
              [
                "Controlla se il contatore continua a girare con tutti i rubinetti chiusi.",
                "Ripara la perdita e conserva la prova della riparazione.",
                "Conserva la bolletta e la data in cui hai notato il problema.",
                "Usa il percorso SMAT per perdita occulta se il caso rientra nelle condizioni previste.",
              ],
            ),
            sectionText(
              "not_all",
              "Important limit",
              "Limite importante",
              "Not every high water bill is automatically treated as a protected hidden leak. You usually need both abnormal consumption and proof that the leak was repaired.",
              "Non ogni bolletta acqua alta viene trattata automaticamente come perdita occulta tutelata. Di solito servono sia consumo anomalo sia prova della riparazione.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - what to do in case of hidden leak",
              "SMAT - cosa fare in caso di perdita occulta",
              "https://www.smatorino.it/cosa-fare-in-caso-di-perdita-occulta/",
              "SMAT",
              "Torino",
              "Official Torino water hidden-leak protection route",
            ),
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Submit communications and check account details",
            ),
          ],
          contacts: [commonContacts.smatHelp, commonContacts.smatEmergency],
        }),
      ],
    }),
    subcategory({
      id: "water_smat_torino",
      sortOrder: 60,
      titleEn: "My Torino water problem is separate from gas and electricity",
      titleIt: "Il mio problema acqua a Torino e separato da luce e gas",
      descriptionEn:
        "SMAT-specific routes for water payment, recapito changes, online desk, and ordinary support.",
      descriptionIt:
        "Percorsi SMAT per pagamento acqua, cambio recapito, sportello online e supporto ordinario.",
      procedures: [
        procedure({
          id: "smat_pay_water_bill",
          subcategoryId: "water_smat_torino",
          sortOrder: 10,
          titleEn: "Pay a SMAT water bill",
          titleIt: "Pagare una bolletta acqua SMAT",
          shortEn:
            "Use this if you need the exact official payment path and do not want to pay through a random third party.",
          shortIt:
            "Usa questa guida se ti serve il percorso ufficiale di pagamento e non vuoi pagare tramite canali casuali.",
          sections: [
            sectionChecklist(
              "methods",
              "Official payment routes",
              "Canali ufficiali di pagamento",
              [
                "Use the PagoPA / CBILL references on the bill.",
                "Use the SMAT online desk if you want to pay by card online.",
                "For physical payment, follow the official SMAT bill instructions.",
              ],
              [
                "Usa i riferimenti PagoPA / CBILL presenti in bolletta.",
                "Usa lo sportello online SMAT se vuoi pagare con carta online.",
                "Per il pagamento fisico, segui le istruzioni ufficiali SMAT riportate in bolletta.",
              ],
            ),
            sectionText(
              "avoid",
              "Avoid this mistake",
              "Evita questo errore",
              "Do not pay from an old bill if the reference code has changed after corrections or re-issue.",
              "Non pagare da una vecchia bolletta se il codice di riferimento e cambiato dopo correzioni o riemissione.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - payment methods for the bill",
              "SMAT - modalita di pagamento della bolletta",
              "https://www.smatorino.it/modalita-pagamento-bolletta/",
              "SMAT",
              "Torino",
              "Official water-bill payment methods in Torino",
            ),
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Online bill payment and account actions",
            ),
          ],
        }),
        procedure({
          id: "smat_change_bill_address_or_messages",
          subcategoryId: "water_smat_torino",
          sortOrder: 20,
          titleEn: "Change the bill address or send a SMAT request",
          titleIt: "Cambiare recapito bolletta o inviare una richiesta a SMAT",
          shortEn:
            "Use this if paper bills go to the wrong address or you need to send a water-service request in writing.",
          shortIt:
            "Usa questa guida se le bollette arrivano all'indirizzo sbagliato o devi inviare una richiesta scritta a SMAT.",
          sections: [
            sectionChecklist(
              "docs",
              "Prepare these details",
              "Prepara questi dati",
              [
                "Customer code and contract code.",
                "Current service address.",
                "New mailing address or email if the issue is recapito.",
                "Short written explanation and attachments if you are sending a request or complaint.",
              ],
              [
                "Codice cliente e codice contratto.",
                "Indirizzo attuale della fornitura.",
                "Nuovo recapito o email se il problema e il recapito bolletta.",
                "Breve spiegazione scritta e allegati se stai inviando una richiesta o reclamo.",
              ],
            ),
            sectionText(
              "best_route",
              "Best route",
              "Percorso migliore",
              "If you already use the SMAT online desk, start there. If not, use the official administrative forms and keep the sent copy.",
              "Se usi gia lo sportello online SMAT, parti da li. Altrimenti usa la modulistica ufficiale e conserva la copia inviata.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - aqueduct administrative forms",
              "SMAT - pratiche amministrative acquedotto",
              "https://www.smatorino.it/pratiche-amministrative-e-modulistica-servizio-acquedotto/",
              "SMAT",
              "Torino",
              "Official forms for recapito changes and administrative requests",
            ),
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Online request and account tools",
            ),
          ],
          contacts: [commonContacts.smatContractsEmail, commonContacts.smatAddress],
        }),
      ],
    }),
    subcategory({
      id: "payments_refunds_bonus",
      sortOrder: 70,
      titleEn: "I need a payment plan, refund, or bonus",
      titleIt: "Mi serve rateizzazione, rimborso o bonus",
      descriptionEn:
        "Ordinary payment trouble, wrong charges, and bonus-sociale problems.",
      descriptionIt:
        "Difficolta di pagamento, addebiti sbagliati e problemi con il bonus sociale.",
      procedures: [
        procedure({
          id: "payment_plan_request",
          subcategoryId: "payments_refunds_bonus",
          sortOrder: 10,
          titleEn: "Ask for a payment plan",
          titleIt: "Chiedere la rateizzazione",
          shortEn:
            "Use this before missing the deadline if the total is too high for one payment.",
          shortIt:
            "Usa questa guida prima della scadenza se il totale e troppo alto da pagare in una volta sola.",
          sections: [
            sectionChecklist(
              "prepare",
              "Prepare before calling",
              "Prepara prima di chiamare",
              [
                "Bill number and due date.",
                "Reason you cannot pay in one solution.",
                "Whether this is a conguaglio, correction, or ordinary bill.",
                "Any proof that you already contacted the supplier.",
              ],
              [
                "Numero bolletta e scadenza.",
                "Motivo per cui non riesci a pagare in una sola soluzione.",
                "Se si tratta di conguaglio, correzione o bolletta ordinaria.",
                "Eventuali prove dei contatti gia avuti con il fornitore.",
              ],
            ),
            sectionText(
              "do_not_wait",
              "Do not wait after the deadline",
              "Non aspettare dopo la scadenza",
              "A late request is usually weaker than an early one made before suspension or morosity steps start.",
              "Una richiesta tardiva e di solito piu debole di una fatta prima che partano sospensione o morosita.",
            ),
          ],
          officialLinks: [
            link(
              "Sportello - services overview",
              "Sportello - panoramica servizi",
              "https://www.sportelloperilconsumatore.it/lo-sportello/i-servizi",
              "Sportello per il consumatore Energia e Ambiente",
              "National",
              "Consumer-assistance services for energy, gas, water, and teleheating",
            ),
          ],
          contacts: [commonContacts.sportelloPhone],
        }),
        procedure({
          id: "wrong_charge_refund",
          subcategoryId: "payments_refunds_bonus",
          sortOrder: 20,
          titleEn: "Ask for a refund of a wrong charge",
          titleIt: "Chiedere rimborso per addebito sbagliato",
          shortEn:
            "Use this if you paid first and only later realized the bill or charge was wrong.",
          shortIt:
            "Usa questa guida se hai pagato e solo dopo ti sei accorto che la bolletta o l'addebito erano sbagliati.",
          sections: [
            sectionChecklist(
              "keep",
              "Keep these proofs",
              "Conserva queste prove",
              [
                "Paid bill or payment receipt.",
                "Written explanation of why the charge was wrong.",
                "Any corrected bill, supplier answer, or technical note.",
              ],
              [
                "Bolletta pagata o ricevuta di pagamento.",
                "Spiegazione scritta del motivo per cui l'addebito era sbagliato.",
                "Eventuale bolletta corretta, risposta del fornitore o nota tecnica.",
              ],
            ),
            sectionText(
              "written",
              "Ask in writing",
              "Chiedilo per iscritto",
              "A phone call alone is weak. Ask for the refund through a written channel and keep proof of sending.",
              "Una telefonata da sola e debole. Chiedi il rimborso per iscritto e conserva la prova dell'invio.",
            ),
          ],
          officialLinks: [
            link(
              "Sportello - services overview",
              "Sportello - panoramica servizi",
              "https://www.sportelloperilconsumatore.it/lo-sportello/i-servizi",
              "Sportello per il consumatore Energia e Ambiente",
              "National",
              "Understand available consumer-protection services",
            ),
            link(
              "ARERA - conciliation service",
              "ARERA - servizio conciliazione",
              "https://www.arera.it/consumatori/conciliazione",
              "ARERA",
              "National",
              "Escalate if refund requests fail",
            ),
          ],
        }),
        procedure({
          id: "wrong_address_or_bill_not_received",
          subcategoryId: "payments_refunds_bonus",
          sortOrder: 30,
          titleEn: "Bill not received or sent to the wrong address",
          titleIt: "Bolletta non ricevuta o inviata all'indirizzo sbagliato",
          shortEn:
            "Use this if you discover the bill too late because the recapito was wrong.",
          shortIt:
            "Usa questa guida se scopri la bolletta troppo tardi perche il recapito era sbagliato.",
          sections: [
            sectionChecklist(
              "fix",
              "Fix both parts",
              "Sistema entrambe le cose",
              [
                "Update the mailing address or email.",
                "Ask for a copy of the missed bill.",
                "If penalties were added because of the wrong recapito, contest them with proof.",
              ],
              [
                "Aggiorna recapito postale o email.",
                "Chiedi copia della bolletta non ricevuta.",
                "Se sono state aggiunte penali per il recapito errato, contestale con le prove.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "SMAT - aqueduct administrative forms",
              "SMAT - pratiche amministrative acquedotto",
              "https://www.smatorino.it/pratiche-amministrative-e-modulistica-servizio-acquedotto/",
              "SMAT",
              "Torino",
              "Water-bill recapito change forms",
            ),
            link(
              "SMAT - online desk",
              "SMAT - sportello online",
              "https://www.smatorino.it/lo-sportello-on-line/",
              "SMAT",
              "Torino",
              "Water-account recapito and bill access",
            ),
          ],
          contacts: [commonContacts.smatContractsEmail],
        }),
        procedure({
          id: "bonus_sociale_missing_or_wrong",
          subcategoryId: "payments_refunds_bonus",
          sortOrder: 40,
          titleEn: "Bonus sociale missing or wrong",
          titleIt: "Bonus sociale mancante o sbagliato",
          shortEn:
            "Use this if you expected the discount in the bill and it did not appear or looks wrong.",
          shortIt:
            "Usa questa guida se ti aspettavi lo sconto in bolletta e non compare oppure sembra sbagliato.",
          sections: [
            sectionChecklist(
              "check",
              "Check before escalating",
              "Controlla prima di contestare",
              [
                "Whether your ISEE or eligible condition is current.",
                "Whether the bill holder and household details are aligned.",
                "Which utility is missing the bonus: electricity, gas, or water.",
              ],
              [
                "Che ISEE o condizione agevolata siano attivi e corretti.",
                "Che intestatario bolletta e nucleo familiare siano coerenti.",
                "Quale utenza manca del bonus: luce, gas o acqua.",
              ],
            ),
            sectionText(
              "where_help",
              "Where to get help",
              "Dove farti aiutare",
              "If you are not sure whether the bonus should have appeared, use ARERA pages first and then ask CAF or the competent office for your exact case.",
              "Se non sei sicuro che il bonus dovesse comparire, consulta prima le pagine ARERA e poi chiedi a CAF o all'ufficio competente per il tuo caso.",
            ),
          ],
          officialLinks: [
            link(
              "ARERA - bonus sociale",
              "ARERA - bonus sociale",
              "https://www.arera.it/consumatori/bonus-sociale",
              "ARERA",
              "National",
              "Overview of social bonus rights and channels",
            ),
            link(
              "ARERA - social bonus for economic hardship",
              "ARERA - bonus sociale per disagio economico",
              "https://www.arera.it/consumatori/bonus-sociale/bonus-sociale-per-disagio-economico",
              "ARERA",
              "National",
              "Economic-hardship bonus rules",
            ),
            link(
              "ARERA - social bonus requirements",
              "ARERA - requisiti bonus sociale",
              "https://www.arera.it/consumatori/bonus-sociale/bonus-sociale-per-disagio-economico/quali-sono-i-requisiti",
              "ARERA",
              "National",
              "Eligibility requirements for the bonus",
            ),
          ],
          contacts: [commonContacts.sportelloPhone],
        }),
      ],
    }),
    subcategory({
      id: "emergencies_outages",
      sortOrder: 80,
      titleEn: "I have an outage, gas smell, or water emergency",
      titleIt: "Ho un blackout, odore di gas o emergenza acqua",
      descriptionEn:
        "Emergency routing for Torino-area electricity, gas, and water safety problems.",
      descriptionIt:
        "Instradamento di emergenza per problemi di sicurezza su elettricita, gas e acqua nell'area di Torino.",
      procedures: [
        procedure({
          id: "gas_or_electricity_emergency_fault",
          subcategoryId: "emergencies_outages",
          sortOrder: 10,
          titleEn: "Gas smell, sparks, or electricity emergency",
          titleIt: "Odore di gas, scintille o emergenza elettrica",
          shortEn:
            "Use this for immediate safety issues, not for billing or ordinary supplier questions.",
          shortIt:
            "Usa questa guida per problemi di sicurezza immediati, non per bollette o domande commerciali ordinarie.",
          sections: [
            sectionChecklist(
              "first",
              "First actions",
              "Prime azioni",
              [
                "If there is gas smell, avoid flames or electrical switches and ventilate if safe.",
                "If there are sparks or burning smell, keep distance and call the emergency line.",
                "Have the address and exact point of the problem ready.",
              ],
              [
                "Se senti odore di gas, evita fiamme e interruttori elettrici e arieggia se e sicuro farlo.",
                "Se vedi scintille o senti odore di bruciato, stai a distanza e chiama il pronto intervento.",
                "Tieni pronti indirizzo e punto esatto del problema.",
              ],
            ),
            sectionText(
              "not_supplier",
              "Do not waste time with commercial support",
              "Non perdere tempo con il supporto commerciale",
              "For a real safety case, call the emergency number first. Billing and contract channels come later.",
              "Per un caso reale di sicurezza, chiama prima il pronto intervento. Bollette e contratti vengono dopo.",
            ),
          ],
          officialLinks: [
            link(
              "Ireti - support and emergency contacts",
              "Ireti - supporto e contatti di pronto intervento",
              "https://www.ireti.it/supporto.html",
              "Ireti",
              "Torino",
              "Electricity and gas emergency contacts for Torino-area networks",
            ),
            link(
              "Ireti - electricity distribution support",
              "Ireti - supporto distribuzione energia elettrica",
              "https://www.ireti.it/servizi/distribuzione-energia-elettrica.html",
              "Ireti",
              "Torino",
              "Electricity outage and technical support details",
            ),
          ],
          contacts: [
            commonContacts.iretiElectricEmergency,
            commonContacts.iretiGasEmergency,
          ],
        }),
        procedure({
          id: "water_emergency_or_no_water",
          subcategoryId: "emergencies_outages",
          sortOrder: 20,
          titleEn: "Water leak, no water, or urgent SMAT problem",
          titleIt: "Perdita acqua, mancanza acqua o problema urgente SMAT",
          shortEn:
            "Use this when the problem is on Torino water service and needs immediate practical action.",
          shortIt:
            "Usa questa guida quando il problema riguarda l'acqua a Torino e serve un'azione pratica immediata.",
          sections: [
            sectionChecklist(
              "what",
              "Say this when you call",
              "Di' questo quando chiami",
              [
                "Exact address and whether the whole building is affected.",
                "If water is leaking inside the apartment, from the common area, or from the street.",
                "Whether the meter area is accessible.",
              ],
              [
                "Indirizzo esatto e se il problema riguarda tutto il palazzo.",
                "Se l'acqua esce dentro l'appartamento, dalle parti comuni o dalla strada.",
                "Se la zona contatore e accessibile.",
              ],
            ),
            sectionText(
              "limit",
              "Know the limit",
              "Conosci il limite",
              "SMAT emergency service covers network-side urgency. Internal private plumbing inside the home can still require your own plumber.",
              "Il pronto intervento SMAT copre l'urgenza lato rete. L'impianto privato interno alla casa puo comunque richiedere il tuo idraulico.",
            ),
          ],
          officialLinks: [
            link(
              "SMAT - emergency service",
              "SMAT - servizio di pronto intervento",
              "https://www.smatorino.it/servizio-di-pronto-intervento/",
              "SMAT",
              "Torino",
              "Torino water emergency service",
            ),
            link(
              "SMAT - green numbers",
              "SMAT - numeri verdi",
              "https://www.smatorino.it/numeri-verdi/",
              "SMAT",
              "Torino",
              "Torino water emergency and assistance numbers",
            ),
          ],
          contacts: [commonContacts.smatEmergency, commonContacts.smatHelp],
        }),
      ],
    }),
    subcategory({
      id: "complaints_conciliation",
      sortOrder: 90,
      titleEn: "The supplier ignored me or the answer is not enough",
      titleIt: "Il fornitore mi ignora o la risposta non basta",
      descriptionEn:
        "Written complaint, Sportello support, and ARERA conciliation when ordinary support failed.",
      descriptionIt:
        "Reclamo scritto, Sportello e conciliazione ARERA quando l'assistenza ordinaria non basta.",
      procedures: [
        procedure({
          id: "wrong_bill_complaint",
          subcategoryId: "complaints_conciliation",
          sortOrder: 10,
          titleEn: "Send a written complaint that is actually usable",
          titleIt: "Inviare un reclamo scritto davvero utile",
          shortEn:
            "Use this when a phone call is not enough and you need a real written trail.",
          shortIt:
            "Usa questa guida quando la telefonata non basta e ti serve una vera traccia scritta.",
          sections: [
            sectionChecklist(
              "include",
              "Include these points",
              "Inserisci questi punti",
              [
                "Your holder details and supply code.",
                "Bill number or request number.",
                "Short timeline of what happened.",
                "What exact correction, refund, or action you want.",
                "Attachments: bill, payment proof, meter photo, old bills, earlier emails.",
              ],
              [
                "Dati intestatario e codice fornitura.",
                "Numero bolletta o numero pratica.",
                "Breve cronologia di cosa e successo.",
                "Quale correzione, rimborso o azione chiedi esattamente.",
                "Allegati: bolletta, prova pagamento, foto contatore, vecchie bollette, email precedenti.",
              ],
            ),
            sectionText(
              "proof",
              "Keep proof of sending",
              "Conserva la prova di invio",
              "You will need it if the supplier does not answer in time or the answer is incomplete and you move to conciliation.",
              "Ti servira se il fornitore non risponde nei tempi o risponde in modo incompleto e passi alla conciliazione.",
            ),
          ],
          officialLinks: [
            link(
              "Sportello - services overview",
              "Sportello - panoramica servizi",
              "https://www.sportelloperilconsumatore.it/lo-sportello/i-servizi",
              "Sportello per il consumatore Energia e Ambiente",
              "National",
              "Consumer assistance for complaints and disputes",
            ),
            link(
              "ARERA - conciliation service",
              "ARERA - servizio conciliazione",
              "https://www.arera.it/consumatori/conciliazione",
              "ARERA",
              "National",
              "Escalation path after the written complaint stage",
            ),
          ],
          contacts: [
            commonContacts.sportelloPhone,
            commonContacts.areraEmail,
            commonContacts.areraPec,
          ],
        }),
        procedure({
          id: "arera_complaint_and_conciliation",
          subcategoryId: "complaints_conciliation",
          sortOrder: 20,
          titleEn: "Use Sportello or ARERA conciliation",
          titleIt: "Usare Sportello o conciliazione ARERA",
          shortEn:
            "Use this when you already complained in writing and the answer is missing or not enough.",
          shortIt:
            "Usa questa guida quando hai gia reclamato per iscritto e la risposta manca oppure non basta.",
          sections: [
            sectionChecklist(
              "ready",
              "Be ready with",
              "Tieniti pronto con",
              [
                "Copy of the written complaint.",
                "Proof of sending and date.",
                "Supplier answer, if any.",
                "Bills, receipts, and attachments already used.",
              ],
              [
                "Copia del reclamo scritto.",
                "Prova di invio e data.",
                "Risposta del fornitore, se c'e.",
                "Bolletta, ricevute e allegati gia usati.",
              ],
            ),
            sectionText(
              "why",
              "Why this matters",
              "Perche serve",
              "Conciliazione is the serious next step before court for many regulated utility disputes. If your file is messy, you lose time. Build the timeline first.",
              "La conciliazione e il passaggio serio prima del giudice per molte controversie sulle utenze regolate. Se il fascicolo e confuso, perdi tempo. Costruisci prima la cronologia.",
            ),
          ],
          officialLinks: [
            link(
              "Sportello - conciliation service",
              "Sportello - servizio conciliazione",
              "https://www.sportelloperilconsumatore.it/lo-sportello/i-servizi/servizio-conciliazione",
              "Sportello per il consumatore Energia e Ambiente",
              "National",
              "Official conciliation portal and guidance",
            ),
            link(
              "ARERA - conciliation service",
              "ARERA - servizio conciliazione",
              "https://www.arera.it/consumatori/conciliazione",
              "ARERA",
              "National",
              "Conciliation framework for regulated utility disputes",
            ),
          ],
          contacts: [
            commonContacts.sportelloPhone,
            commonContacts.areraEmail,
            commonContacts.areraPec,
          ],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Premium can organize the complaint timeline, attachments, and escalation summary before conciliation.",
          premiumTeaserIt:
            "Premium puo organizzare cronologia reclamo, allegati e riepilogo escalation prima della conciliazione.",
        }),
      ],
    }),
  ],
});

for (const catalogPath of catalogPaths) {
  const raw = fs.readFileSync(catalogPath, "utf8");
  const catalog = JSON.parse(raw);
  const categoryIndex = catalog.categories.findIndex(
    (category) => category.id === "utilities_electricity_gas",
  );
  if (categoryIndex === -1) {
    throw new Error(`utilities_electricity_gas not found in ${catalogPath}`);
  }

  const existingCategory = catalog.categories[categoryIndex];
  catalog.categories[categoryIndex] = utilitiesCategory(existingCategory);
  fs.writeFileSync(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`);
  console.log(`Rewrote Torino utilities category in ${catalogPath}`);
}
