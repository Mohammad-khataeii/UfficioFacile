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
  categoryId: "housing_rent",
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
  categoryId: "housing_rent",
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
  sportelloCasaPhone: contact(
    "Comune di Torino - Sportello Casa phone",
    "Comune di Torino - telefono Sportello Casa",
    "011 011 24300",
    "phone",
  ),
  sportelloCasaEmail: contact(
    "Comune di Torino - Sportello Casa email",
    "Comune di Torino - email Sportello Casa",
    "informacasa@comune.torino.it",
    "email",
  ),
  sportelloCasaAddress: contact(
    "Comune di Torino - Sportello Casa",
    "Comune di Torino - Sportello Casa",
    "Via Palazzo di Citta 9/A, Torino",
    "address",
  ),
  emergenzaAddress: contact(
    "Comune di Torino - emergency housing office",
    "Comune di Torino - ufficio emergenza abitativa",
    "Via Orvieto 1/20/A, Torino",
    "address",
  ),
  asloAddress: contact(
    "Comune di Torino - ASLo office",
    "Comune di Torino - ufficio ASLo",
    "Via Orvieto 1/20/A, Torino",
    "address",
  ),
  entrate: contact(
    "Agenzia delle Entrate - rental contracts",
    "Agenzia delle Entrate - contratti di locazione",
    "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/locazione-immobili",
    "website",
  ),
  sunia: contact(
    "SUNIA Piemonte - Torino",
    "SUNIA Piemonte - Torino",
    "https://www.sunia.it/piemonte/",
    "website",
  ),
};

const housingCategory = {
  id: "housing_rent",
  icon: "home_work_outlined",
  sortOrder: 2,
  isPremiumOnly: false,
  hasPremiumContent: true,
  title: t("Housing / Rent", "Casa / Affitto"),
  description: t(
    "Torino rent help: choose the exact problem and start from the right office, document, or contract step.",
    "Affitto a Torino: scegli il problema giusto e parti dall'ufficio, dal documento o dal passaggio corretto.",
  ),
  subcategories: [
    subcategory({
      id: "understand_rent_contracts_italy",
      sortOrder: 10,
      titleEn: "I need to understand which rent contract makes sense",
      titleIt: "Devo capire quale contratto di affitto ha senso",
      descriptionEn:
        "Main contract types, Torino agreed-rent contracts, and the words you need before saying yes.",
      descriptionIt:
        "Tipi di contratto, canone concordato a Torino e parole utili prima di dire si.",
      procedures: [
        procedure({
          id: "main_rent_contract_types",
          subcategoryId: "understand_rent_contracts_italy",
          sortOrder: 10,
          titleEn: "Main rent contract types in Torino",
          titleIt: "Tipi principali di contratto a Torino",
          shortEn:
            "Use this before signing if you are trying to understand 4+4, 3+2, student contracts, transitory contracts, or a room arrangement.",
          shortIt:
            "Usa questa guida prima di firmare se stai cercando di capire 4+4, 3+2, contratto studenti, transitorio o una stanza.",
          sections: [
            sectionChecklist(
              "compare",
              "Quick comparison",
              "Confronto rapido",
              [
                "4+4: standard residential contract if you need ordinary stability.",
                "3+2 agreed-rent: often useful in Torino when the rent follows the local territorial agreement.",
                "Student contract: only if the student conditions are real and documented.",
                "Transitory contract: only if there is a real temporary reason. It is not a shortcut for everything.",
                "Single room or bed: still check whether you are getting a real written contract and proper registration.",
              ],
              [
                "4+4: contratto abitativo ordinario se ti serve stabilita normale.",
                "3+2 a canone concordato: spesso utile a Torino se il canone segue l'accordo territoriale locale.",
                "Contratto studenti: solo se le condizioni studente sono reali e documentabili.",
                "Contratto transitorio: solo se c'e una vera ragione temporanea. Non e una scorciatoia per tutto.",
                "Stanza o posto letto: controlla comunque contratto scritto e registrazione vera.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not choose a contract only because the landlord says it is easier. The right contract depends on your real use of the house, your timing, and whether you need residency or administrative stability.",
              "Non scegliere un contratto solo perche il proprietario dice che e piu comodo. Il contratto giusto dipende dall'uso reale della casa, dai tuoi tempi e dal fatto che ti serva residenza o stabilita amministrativa.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - agreed-rent contracts and territorial agreements",
              "Comune di Torino - contratti a canone concordato e accordi territoriali",
              "https://www.comune.torino.it/schede-informative/contratti-locazione-convenzionati-accordi-territoriali",
              "Comune di Torino",
              "Torino",
              "Torino-specific agreed-rent framework",
            ),
            link(
              "Agenzia delle Entrate - rental contracts",
              "Agenzia delle Entrate - contratti di locazione",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/locazione-immobili",
              "Agenzia delle Entrate",
              "National",
              "Legal baseline for rental contracts and taxes",
            ),
          ],
          relatedProcedures: [
            related(
              "Check a contract before signing",
              "Controllare il contratto prima di firmare",
              "before_signing",
              "check_contract_before_signing",
            ),
          ],
        }),
        procedure({
          id: "canone_concordato_torino",
          subcategoryId: "understand_rent_contracts_italy",
          sortOrder: 20,
          titleEn: "Canone concordato in Torino: when it matters",
          titleIt: "Canone concordato a Torino: quando conta davvero",
          shortEn:
            "Use this if the landlord mentions agreed rent, lower taxes, or a contract based on Torino territorial agreements.",
          shortIt:
            "Usa questa guida se il proprietario parla di canone concordato, tasse ridotte o contratto basato sugli accordi territoriali di Torino.",
          sections: [
            sectionText(
              "when",
              "Use this when",
              "Usa questo percorso quando",
              "The contract is presented as 3+2 or another agreed-rent model and you want to know whether the claimed price and paperwork really fit Torino rules.",
              "Il contratto viene presentato come 3+2 o altro modello a canone concordato e vuoi capire se prezzo e documenti rispettano davvero le regole di Torino.",
            ),
            sectionChecklist(
              "what_to_check",
              "Check these points",
              "Controlla questi punti",
              [
                "Whether the rent is calculated under the Torino territorial agreement.",
                "Whether the contract text says canone concordato clearly.",
                "Whether the landlord has the supporting attestation if it is required for tax benefits or disputes.",
              ],
              [
                "Se il canone e calcolato secondo l'accordo territoriale di Torino.",
                "Se il testo del contratto dice chiaramente canone concordato.",
                "Se il proprietario ha l'attestazione di supporto quando serve per agevolazioni fiscali o contestazioni.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - agreed-rent contracts and territorial agreements",
              "Comune di Torino - contratti a canone concordato e accordi territoriali",
              "https://www.comune.torino.it/schede-informative/contratti-locazione-convenzionati-accordi-territoriali",
              "Comune di Torino",
              "Torino",
              "Torino agreed-rent framework and local references",
            ),
          ],
          contacts: [
            commonContacts.sportelloCasaPhone,
            commonContacts.sportelloCasaEmail,
          ],
        }),
        procedure({
          id: "tenant_basic_dictionary",
          subcategoryId: "understand_rent_contracts_italy",
          sortOrder: 30,
          titleEn: "Tenant dictionary: words that matter before you sign",
          titleIt: "Dizionario dell'inquilino: parole che contano prima di firmare",
          shortEn:
            "Use this if the contract talks about deposito, cedolare secca, spese, subentro, transitorio, or other words you do not want to misunderstand.",
          shortIt:
            "Usa questa guida se il contratto parla di deposito, cedolare secca, spese, subentro, transitorio o altre parole che non vuoi capire male.",
          sections: [
            sectionChecklist(
              "terms",
              "Key words",
              "Parole chiave",
              [
                "Deposito cauzionale: the money held as security, not an extra monthly rent.",
                "Cedolare secca: tax regime chosen by the landlord, not a reason to skip registration.",
                "Spese condominiali: separate building expenses, often partly recoverable from the tenant.",
                "Subentro / cessione: change of people on the contract, not an informal roommate swap.",
                "Transitorio: a contract that needs a real temporary reason.",
              ],
              [
                "Deposito cauzionale: somma trattenuta come garanzia, non affitto extra mensile.",
                "Cedolare secca: regime fiscale scelto dal proprietario, non motivo per saltare la registrazione.",
                "Spese condominiali: spese del palazzo separate, spesso in parte ribaltate sull'inquilino.",
                "Subentro / cessione: cambio delle persone nel contratto, non semplice scambio informale di coinquilino.",
                "Transitorio: contratto che ha bisogno di una vera ragione temporanea.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - rental contracts",
              "Agenzia delle Entrate - contratti di locazione",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/locazione-immobili",
              "Agenzia delle Entrate",
              "National",
              "Basic official contract and tax vocabulary context",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "before_signing",
      sortOrder: 20,
      titleEn: "I need to check a contract before signing",
      titleIt: "Devo controllare il contratto prima di firmare",
      descriptionEn:
        "Red flags before signature, room rentals, deposits, and what must be written clearly.",
      descriptionIt:
        "Campanelli d'allarme prima della firma, affitto stanza, deposito e punti che devono essere scritti chiaramente.",
      procedures: [
        procedure({
          id: "check_contract_before_signing",
          subcategoryId: "before_signing",
          sortOrder: 10,
          titleEn: "Check the contract before signing",
          titleIt: "Controllare il contratto prima di firmare",
          shortEn:
            "Use this if you already have a draft contract, message, or landlord proposal and want to check the risky parts before you commit.",
          shortIt:
            "Usa questa guida se hai gia una bozza, un messaggio o una proposta del proprietario e vuoi controllare i punti rischiosi prima di impegnarti.",
          sections: [
            sectionChecklist(
              "checklist",
              "Check these points before you sign",
              "Controlla questi punti prima di firmare",
              [
                "Who exactly is landlord and who exactly is tenant.",
                "Full address and correct unit details.",
                "Contract type and duration.",
                "Monthly rent, separate charges, and deposit amount.",
                "Who pays utilities, internet, and condominium extras.",
                "How early notice works if you leave.",
                "Whether registration is explicitly planned.",
              ],
              [
                "Chi e esattamente il proprietario e chi e esattamente l'inquilino.",
                "Indirizzo completo e dati corretti dell'unita.",
                "Tipo di contratto e durata.",
                "Canone mensile, spese separate e importo del deposito.",
                "Chi paga utenze, internet ed extra condominiali.",
                "Come funziona il preavviso se lasci l'immobile.",
                "Se la registrazione e prevista in modo esplicito.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not rely only on chat messages and verbal promises. If a promise matters, put it into the written contract or an attachment signed by both sides.",
              "Non affidarti solo a chat e promesse verbali. Se una promessa conta davvero, mettila nel contratto scritto o in un allegato firmato da entrambe le parti.",
            ),
            sectionText(
              "premium",
              "Premium help",
              "Aiuto premium",
              "Premium can turn your draft into a risk checklist: what is missing, what is vague, what should be corrected before you sign, and a ready Italian message to send back.",
              "Premium puo trasformare la bozza in una checklist rischi: cosa manca, cosa e vago, cosa va corretto prima della firma e un messaggio in italiano pronto da inviare.",
              { isPremiumOnly: true },
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - agreed-rent contracts and territorial agreements",
              "Comune di Torino - contratti a canone concordato e accordi territoriali",
              "https://www.comune.torino.it/schede-informative/contratti-locazione-convenzionati-accordi-territoriali",
              "Comune di Torino",
              "Torino",
              "Torino contract framework before signing",
            ),
          ],
        }),
        procedure({
          id: "room_or_bed_without_contract",
          subcategoryId: "before_signing",
          sortOrder: 20,
          titleEn: "Room or bed offered without a real contract",
          titleIt: "Stanza o posto letto offerti senza vero contratto",
          shortEn:
            "Use this if someone wants rent, deposit, or copies of documents before giving you a proper written contract.",
          shortIt:
            "Usa questa guida se qualcuno vuole affitto, deposito o copie documenti prima di darti un contratto scritto vero.",
          sections: [
            sectionText(
              "warning",
              "Why this is risky",
              "Perche e rischioso",
              "If there is no real written contract, registration may never happen, the deposit can become hard to recover, and your housing proof may be useless for residence or permit needs.",
              "Se non c'e un vero contratto scritto, la registrazione potrebbe non avvenire mai, il deposito puo diventare difficile da recuperare e la prova dell'alloggio puo essere inutile per residenza o permesso.",
            ),
            sectionChecklist(
              "what_to_ask",
              "Ask for this first",
              "Chiedi prima questo",
              [
                "Draft contract text.",
                "Who will register it and when.",
                "Written receipt if any deposit is paid.",
                "Clear address and room description.",
              ],
              [
                "Bozza del contratto.",
                "Chi lo registrera e quando.",
                "Ricevuta scritta se versi un deposito.",
                "Indirizzo chiaro e descrizione della stanza.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "TorinoGiovani - rent contracts and housing for young people",
              "TorinoGiovani - contratti di affitto e casa per giovani",
              "https://www.torinogiovani.it/casa/contratti-di-locazione",
              "Comune di Torino / TorinoGiovani",
              "Torino",
              "Youth-facing Torino housing guidance",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "contract_registration",
      sortOrder: 30,
      titleEn: "I need to register or verify the contract",
      titleIt: "Devo registrare o verificare il contratto",
      descriptionEn:
        "Registration, online checks, and what to do if the rent looks unregistered.",
      descriptionIt:
        "Registrazione, controlli online e cosa fare se l'affitto sembra non registrato.",
      procedures: [
        procedure({
          id: "check_contract_registration",
          subcategoryId: "contract_registration",
          sortOrder: 10,
          titleEn: "Register or verify a rent contract",
          titleIt: "Registrare o verificare un contratto di affitto",
          shortEn:
            "Use this if you need to understand whether the rental contract was registered correctly or you need the official registration path.",
          shortIt:
            "Usa questa guida se devi capire se il contratto e registrato correttamente o ti serve il percorso ufficiale di registrazione.",
          sections: [
            sectionChecklist(
              "what_to_check",
              "Check these points",
              "Controlla questi punti",
              [
                "Written contract exists.",
                "Registration date exists.",
                "You know who filed the registration.",
                "The registered details match the real people, address, and rent.",
              ],
              [
                "Esiste un contratto scritto.",
                "Esiste una data di registrazione.",
                "Sai chi ha fatto la registrazione.",
                "I dati registrati coincidono con persone, indirizzo e canone reali.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Use the Agenzia delle Entrate rental area or ask the landlord for the registration reference. If the numbers or names do not match reality, fix the discrepancy before relying on the contract for residence or disputes.",
              "Usa l'area locazioni dell'Agenzia delle Entrate o chiedi al proprietario il riferimento di registrazione. Se numeri o nomi non coincidono con la realta, correggi prima la discrepanza di usare il contratto per residenza o contenzioso.",
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - RLI web and online rental services",
              "Agenzia delle Entrate - RLI web e servizi online locazioni",
              "https://www1.agenziaentrate.gov.it/servizi/locazione/result.htm",
              "Agenzia delle Entrate",
              "National",
              "Online rental registration and lookup entry point",
            ),
            link(
              "Agenzia delle Entrate - subsequent steps for registered rental contracts",
              "Agenzia delle Entrate - adempimenti successivi ai contratti registrati",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/adempimenti-successivi-registrazione-contratti-di-locazione-e-affitto",
              "Agenzia delle Entrate",
              "National",
              "Changes, renewal, transfer, and termination after registration",
            ),
          ],
        }),
        procedure({
          id: "unregistered_contract_or_black_rent",
          subcategoryId: "contract_registration",
          sortOrder: 20,
          titleEn: "The rent looks unregistered or unclear",
          titleIt: "L'affitto sembra in nero o poco chiaro",
          shortEn:
            "Use this if you pay rent but still do not have a proper registered contract or the landlord avoids the topic.",
          shortIt:
            "Usa questa guida se paghi l'affitto ma non hai ancora un contratto registrato vero oppure il proprietario evita l'argomento.",
          sections: [
            sectionChecklist(
              "proof",
              "Keep this proof",
              "Conserva queste prove",
              [
                "Chats and emails about rent and deposit.",
                "Bank transfers or payment receipts.",
                "Draft contract if one exists.",
                "Address and identity details of the other side if you have them.",
              ],
              [
                "Chat ed email su affitto e deposito.",
                "Bonifici o ricevute di pagamento.",
                "Bozza del contratto se esiste.",
                "Indirizzo e dati identita della controparte se li hai.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Do not just keep paying and hoping the situation becomes regular. First collect proof, then get formal advice before sending complaints or taking tax or legal steps.",
              "Non continuare semplicemente a pagare sperando che la situazione si regolarizzi da sola. Prima raccogli le prove, poi fatti consigliare in modo formale prima di inviare contestazioni o muovere passi fiscali o legali.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa",
              "Comune di Torino - Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "First local orientation point for housing problems",
            ),
            link(
              "Agenzia delle Entrate - rental contracts",
              "Agenzia delle Entrate - contratti di locazione",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/locazione-immobili",
              "Agenzia delle Entrate",
              "National",
              "Official contract and registration baseline",
            ),
          ],
          contacts: [
            commonContacts.sportelloCasaPhone,
            commonContacts.sportelloCasaEmail,
          ],
          relatedProcedures: [
            related(
              "Tenant unions and formal help",
              "Sindacati inquilini e aiuto formale",
              "tenant_union_support",
              "tenant_union_appointment",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "change_contract",
      sortOrder: 40,
      titleEn: "I need to change names or terms on the contract",
      titleIt: "Devo cambiare nomi o termini del contratto",
      descriptionEn:
        "Add or remove tenants, replace a roommate, renew, or convert the contract correctly.",
      descriptionIt:
        "Aggiungi o togli intestatari, sostituisci un coinquilino, rinnova o converti il contratto correttamente.",
      procedures: [
        procedure({
          id: "add_or_remove_tenant",
          subcategoryId: "change_contract",
          sortOrder: 10,
          titleEn: "Add or remove a tenant",
          titleIt: "Aggiungere o togliere un intestatario",
          shortEn:
            "Use this if a new roommate enters, someone leaves, or the names on the contract no longer match reality.",
          shortIt:
            "Usa questa guida se entra un nuovo coinquilino, qualcuno esce o i nomi nel contratto non corrispondono piu alla realta.",
          sections: [
            sectionText(
              "warning",
              "Important warning",
              "Avviso importante",
              "A roommate swap is not safe if it stays only verbal. If the names change in real life, update the registered contract route too.",
              "Lo scambio di coinquilino non e sicuro se resta solo verbale. Se i nomi cambiano nella realta, aggiorna anche il percorso del contratto registrato.",
            ),
            sectionChecklist(
              "documents",
              "What you usually need",
              "Cosa serve di solito",
              [
                "Current contract.",
                "Identity details of old and new tenants.",
                "Written agreement between the parties.",
                "Registration follow-up through Agenzia delle Entrate if required.",
              ],
              [
                "Contratto attuale.",
                "Dati identita dei vecchi e nuovi intestatari.",
                "Accordo scritto tra le parti.",
                "Adempimento successivo presso Agenzia delle Entrate se richiesto.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - subsequent steps for registered rental contracts",
              "Agenzia delle Entrate - adempimenti successivi ai contratti registrati",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/adempimenti-successivi-registrazione-contratti-di-locazione-e-affitto",
              "Agenzia delle Entrate",
              "National",
              "Changes after contract registration",
            ),
          ],
        }),
        procedure({
          id: "renew_or_convert_contract",
          subcategoryId: "change_contract",
          sortOrder: 20,
          titleEn: "Renew, extend, or convert the contract",
          titleIt: "Rinnovare, prorogare o convertire il contratto",
          shortEn:
            "Use this if the rental relationship continues but the contract type, duration, or status needs to change.",
          shortIt:
            "Usa questa guida se il rapporto continua ma tipo, durata o stato del contratto devono cambiare.",
          sections: [
            sectionText(
              "when",
              "Use this when",
              "Usa questo percorso quando",
              "The contract is ending, you want to continue the rent, or you need to move from one formal setup to another instead of starting from zero.",
              "Il contratto sta finendo, vuoi continuare l'affitto oppure devi passare da un assetto formale a un altro senza ripartire da zero.",
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - subsequent steps for registered rental contracts",
              "Agenzia delle Entrate - adempimenti successivi ai contratti registrati",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/adempimenti-successivi-registrazione-contratti-di-locazione-e-affitto",
              "Agenzia delle Entrate",
              "National",
              "Renewal, extension, and conversion steps",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "end_contract",
      sortOrder: 50,
      titleEn: "I need to leave the house or close the contract",
      titleIt: "Devo lasciare la casa o chiudere il contratto",
      descriptionEn:
        "Notice periods, early exit, keys, meter readings, and the safe closure path.",
      descriptionIt:
        "Preavviso, uscita anticipata, chiavi, letture contatori e chiusura sicura del rapporto.",
      procedures: [
        procedure({
          id: "end_contract_early",
          subcategoryId: "end_contract",
          sortOrder: 10,
          titleEn: "End the contract early",
          titleIt: "Chiudere il contratto in anticipo",
          shortEn:
            "Use this if you need to leave before the ordinary end date and want to avoid a messy deposit or rent dispute later.",
          shortIt:
            "Usa questa guida se devi andare via prima della scadenza ordinaria e vuoi evitare poi problemi su deposito o canoni.",
          sections: [
            sectionChecklist(
              "steps",
              "What to do",
              "Cosa fare",
              [
                "Read the notice clause in the contract.",
                "Send written notice with proof.",
                "Agree on final date, keys, inventory, and utility readings.",
                "Check who files the final registration step if required.",
              ],
              [
                "Leggi la clausola di preavviso nel contratto.",
                "Invia disdetta scritta con prova.",
                "Concorda data finale, chiavi, inventario e letture utenze.",
                "Controlla chi presenta l'adempimento finale se richiesto.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not rely only on a call or chat for a major exit. Keep a written notice trail and a clear handover record.",
              "Non affidarti solo a una chiamata o chat per un'uscita importante. Tieni traccia della disdetta scritta e un verbale di riconsegna chiaro.",
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - subsequent steps for registered rental contracts",
              "Agenzia delle Entrate - adempimenti successivi ai contratti registrati",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/adempimenti-successivi-registrazione-contratti-di-locazione-e-affitto",
              "Agenzia delle Entrate",
              "National",
              "Termination and post-registration steps",
            ),
          ],
          relatedProcedures: [
            related(
              "Deposit return",
              "Restituzione del deposito",
              "deposit_handover",
              "deposit_return",
            ),
          ],
        }),
        procedure({
          id: "notice_and_keys_handover",
          subcategoryId: "end_contract",
          sortOrder: 20,
          titleEn: "Final notice, keys, and closure proof",
          titleIt: "Disdetta finale, chiavi e prova di chiusura",
          shortEn:
            "Use this if you want a clean written closure of the rental relationship when you leave the property.",
          shortIt:
            "Usa questa guida se vuoi una chiusura scritta pulita del rapporto quando lasci l'immobile.",
          sections: [
            sectionChecklist(
              "proof",
              "Keep this proof",
              "Conserva queste prove",
              [
                "Written notice.",
                "Signed handover note or inventory.",
                "Photos of the property at exit.",
                "Meter readings and utility account status.",
                "Receipt for keys returned.",
              ],
              [
                "Disdetta scritta.",
                "Verbale o inventario di riconsegna firmato.",
                "Foto dell'immobile all'uscita.",
                "Letture contatori e stato delle utenze.",
                "Ricevuta della consegna chiavi.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - rental contracts",
              "Agenzia delle Entrate - contratti di locazione",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/locazione-immobili",
              "Agenzia delle Entrate",
              "National",
              "Official baseline for rental contract closure context",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "deposit_handover",
      sortOrder: 60,
      titleEn: "I need my deposit back and a safe handover",
      titleIt: "Mi servono deposito, riconsegna e chiusura sicura",
      descriptionEn:
        "Deposit return, photos, written handover proof, and meter readings.",
      descriptionIt:
        "Restituzione deposito, foto, prova scritta di riconsegna e letture contatori.",
      procedures: [
        procedure({
          id: "deposit_return",
          subcategoryId: "deposit_handover",
          sortOrder: 10,
          titleEn: "Get the deposit back",
          titleIt: "Riavere il deposito",
          shortEn:
            "Use this if you left the house or are about to leave and want to protect the deposit return.",
          shortIt:
            "Usa questa guida se hai lasciato o stai per lasciare la casa e vuoi proteggere la restituzione del deposito.",
          sections: [
            sectionChecklist(
              "before_you_leave",
              "Before you leave",
              "Prima di lasciare la casa",
              [
                "Take dated photos of every room.",
                "Record meter readings.",
                "Do a written handover note with keys returned.",
                "Keep proof of rent and bill payments.",
              ],
              [
                "Fai foto datate di tutte le stanze.",
                "Annota le letture dei contatori.",
                "Fai un verbale scritto di riconsegna con consegna chiavi.",
                "Conserva prova dei canoni e delle bollette pagate.",
              ],
            ),
            sectionText(
              "if_they_delay",
              "If the landlord delays",
              "Se il proprietario ritarda",
              "Ask in writing which exact damage or unpaid amount justifies the delay. Do not accept vague statements like \"I will check later\" without proof.",
              "Chiedi per iscritto quale danno preciso o quale importo non pagato giustifica il ritardo. Non accettare frasi vaghe come \"controllo poi\" senza prove.",
            ),
            sectionText(
              "premium",
              "Premium help",
              "Aiuto premium",
              "Premium can turn your photos, bills, and handover facts into a clean Italian deposit-return message or formal reminder.",
              "Premium puo trasformare foto, bollette e fatti della riconsegna in un messaggio chiaro in italiano per il deposito o in un sollecito formale.",
              { isPremiumOnly: true },
            ),
          ],
          officialLinks: [
            link(
              "Law 392/1978",
              "Legge 392/1978",
              "https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:1978-07-27;392",
              "Normattiva",
              "National",
              "Legal base often cited in deposit disputes",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Get a Torino-ready deposit return checklist and a clean written reminder before the dispute gets messy.",
          premiumTeaserIt:
            "Ottieni una checklist chiara per il deposito e un sollecito scritto pronto prima che la contestazione diventi confusa.",
        }),
        procedure({
          id: "handover_inventory_and_meter_readings",
          subcategoryId: "deposit_handover",
          sortOrder: 20,
          titleEn: "Handover inventory and meter readings",
          titleIt: "Verbale di riconsegna e letture contatori",
          shortEn:
            "Use this if you want proof that the apartment condition and utilities were checked at the end.",
          shortIt:
            "Usa questa guida se vuoi una prova chiara che stato dell'appartamento e utenze siano stati verificati alla fine.",
          sections: [
            sectionChecklist(
              "include",
              "Include these items",
              "Inserisci questi elementi",
              [
                "Date and time of handover.",
                "Who was present.",
                "Keys returned.",
                "Photos or reference to attached photos.",
                "Gas, electricity, and water meter readings if relevant.",
                "Short note on visible damage or absence of damage.",
              ],
              [
                "Data e ora della riconsegna.",
                "Chi era presente.",
                "Chiavi restituite.",
                "Foto o riferimento alle foto allegate.",
                "Letture di gas, luce e acqua se rilevanti.",
                "Breve nota su danni visibili o assenza di danni.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa",
              "Comune di Torino - Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Local orientation if the handover becomes disputed",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "repairs_maintenance",
      sortOrder: 70,
      titleEn: "I need repairs or the landlord to act",
      titleIt: "Mi servono riparazioni o una risposta del proprietario",
      descriptionEn:
        "Normal repairs, urgent dangers, damp, broken systems, and written requests that create proof.",
      descriptionIt:
        "Riparazioni ordinarie, urgenze, muffa, impianti rotti e richieste scritte che lasciano prova.",
      procedures: [
        procedure({
          id: "landlord_repair_request",
          subcategoryId: "repairs_maintenance",
          sortOrder: 10,
          titleEn: "Ask the landlord for repairs",
          titleIt: "Chiedere al proprietario le riparazioni",
          shortEn:
            "Use this if something in the house needs repair and you want to ask clearly, with written proof and useful details.",
          shortIt:
            "Usa questa guida se qualcosa in casa richiede riparazione e vuoi chiederla in modo chiaro, con prova scritta e dettagli utili.",
          sections: [
            sectionChecklist(
              "write",
              "Your message should include",
              "Il messaggio dovrebbe includere",
              [
                "What is broken.",
                "When the problem started.",
                "Whether it is urgent or dangerous.",
                "Photos or video if helpful.",
                "What rooms or systems are affected.",
              ],
              [
                "Che cosa e rotto.",
                "Da quando esiste il problema.",
                "Se e urgente o pericoloso.",
                "Foto o video se utili.",
                "Quali stanze o impianti sono coinvolti.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not rely only on a voice note or phone call. Send a written message so there is a timestamp and a clear request history.",
              "Non affidarti solo a nota vocale o telefonata. Invia un messaggio scritto cosi resta una data e una storia chiara della richiesta.",
            ),
          ],
          officialLinks: [
            link(
              "Civil Code article 1576",
              "Codice civile articolo 1576",
              "https://www.codice-civile-online.it/codice-civile/articolo-1576-del-codice-civile",
              "Codice Civile Online",
              "National",
              "Baseline rule on lessor repair duties",
            ),
            link(
              "Civil Code article 1609",
              "Codice civile articolo 1609",
              "https://www.codice-civile-online.it/codice-civile/articolo-1609-del-codice-civile",
              "Codice Civile Online",
              "National",
              "Baseline rule on small maintenance by tenant",
            ),
          ],
        }),
        procedure({
          id: "dangerous_house_conditions",
          subcategoryId: "repairs_maintenance",
          sortOrder: 20,
          titleEn: "Dangerous conditions: water, gas, mold, heating, or electricity",
          titleIt: "Condizioni pericolose: acqua, gas, muffa, riscaldamento o elettricita",
          shortEn:
            "Use this if the problem is urgent, risky, or makes the home unsafe to stay in normally.",
          shortIt:
            "Usa questa guida se il problema e urgente, rischioso o rende la casa non sicura per la vita normale.",
          sections: [
            sectionText(
              "urgent",
              "Act fast",
              "Agisci in fretta",
              "If there is real danger, protect people first and use the emergency or technical channel that fits the problem. Then document everything for the housing dispute side.",
              "Se c'e un pericolo reale, proteggi prima le persone e usa il canale tecnico o di emergenza adatto al problema. Poi documenta tutto per la parte di contestazione abitativa.",
            ),
            sectionChecklist(
              "proof",
              "Keep this proof",
              "Conserva queste prove",
              [
                "Photos and videos.",
                "Dates and times.",
                "Any technician visit report.",
                "Written notice to landlord or building manager.",
              ],
              [
                "Foto e video.",
                "Date e orari.",
                "Eventuale verbale del tecnico.",
                "Avviso scritto a proprietario o amministratore.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa",
              "Comune di Torino - Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Housing orientation after the urgent phase",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "expenses_bills",
      sortOrder: 80,
      titleEn: "I need help with charges, utilities, or extra costs",
      titleIt: "Mi serve aiuto con spese, utenze o costi extra",
      descriptionEn:
        "Condominium charges, unexplained requests, and what to ask before paying.",
      descriptionIt:
        "Spese condominiali, richieste poco chiare e cosa chiedere prima di pagare.",
      procedures: [
        procedure({
          id: "wrong_condominium_expenses",
          subcategoryId: "expenses_bills",
          sortOrder: 10,
          titleEn: "Condominium expenses look wrong",
          titleIt: "Le spese condominiali sembrano sbagliate",
          shortEn:
            "Use this if the landlord or agency asks for extra building charges and you do not understand what they are or why you owe them.",
          shortIt:
            "Usa questa guida se proprietario o agenzia chiedono spese condominiali extra e non capisci bene cosa siano o perche dovresti pagarle.",
          sections: [
            sectionChecklist(
              "ask_for",
              "Ask for this first",
              "Chiedi prima questo",
              [
                "Written breakdown of the charges.",
                "Which period they refer to.",
                "Whether they are ordinary tenant charges or owner-only charges.",
                "Whether the amount was already included elsewhere.",
              ],
              [
                "Ripartizione scritta delle spese.",
                "A quale periodo si riferiscono.",
                "Se sono spese ordinarie da inquilino o spese che restano al proprietario.",
                "Se l'importo era gia incluso altrove.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not pay an unexplained lump sum just to keep peace. Ask for the breakdown first and keep the answer in writing.",
              "Non pagare una cifra generica non spiegata solo per quieto vivere. Chiedi prima il dettaglio e conserva la risposta per iscritto.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - agreed-rent contracts and territorial agreements",
              "Comune di Torino - contratti a canone concordato e accordi territoriali",
              "https://www.comune.torino.it/schede-informative/contratti-locazione-convenzionati-accordi-territoriali",
              "Comune di Torino",
              "Torino",
              "Useful baseline when reviewing rent and extra charges",
            ),
          ],
        }),
        procedure({
          id: "landlord_asks_unexplained_charges",
          subcategoryId: "expenses_bills",
          sortOrder: 20,
          titleEn: "The landlord asks for extra money without clear proof",
          titleIt: "Il proprietario chiede soldi extra senza prove chiare",
          shortEn:
            "Use this if you receive informal requests for cash, utility balances, repairs, or cleaning costs without a clear breakdown.",
          shortIt:
            "Usa questa guida se ricevi richieste informali di contanti, conguagli utenze, riparazioni o pulizie senza un dettaglio chiaro.",
          sections: [
            sectionChecklist(
              "proof",
              "Ask for proof",
              "Chiedi le prove",
              [
                "Bills or invoices.",
                "Meter readings if utilities are involved.",
                "Photos if damage or cleaning is claimed.",
                "Written explanation of who owes what and why.",
              ],
              [
                "Bollette o fatture.",
                "Letture contatori se sono coinvolte le utenze.",
                "Foto se vengono contestati danni o pulizie.",
                "Spiegazione scritta di chi deve cosa e perche.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa",
              "Comune di Torino - Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Local orientation for disputed housing charges",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "rent_delay_eviction",
      sortOrder: 90,
      titleEn: "I am late with rent or at risk of eviction",
      titleIt: "Sono in ritardo con l'affitto o rischio sfratto",
      descriptionEn:
        "Payment-plan steps, court-paper urgency, FIMI, and where Torino support starts.",
      descriptionIt:
        "Piano di rientro, urgenza dei documenti del tribunale, FIMI e da dove parte l'aiuto a Torino.",
      procedures: [
        procedure({
          id: "rent_payment_delay_payment_plan",
          subcategoryId: "rent_delay_eviction",
          sortOrder: 10,
          titleEn: "You are late with rent and need a payment plan",
          titleIt: "Sei in ritardo con l'affitto e ti serve un piano di rientro",
          shortEn:
            "Use this if you are already late or know you will miss rent soon and want to reduce the damage before the situation becomes legal.",
          shortIt:
            "Usa questa guida se sei gia in ritardo o sai che salterai presto l'affitto e vuoi limitare il danno prima che la situazione diventi legale.",
          sections: [
            sectionChecklist(
              "do_now",
              "Do this now",
              "Fallo subito",
              [
                "Calculate exactly how much is missing.",
                "Write a short factual message before silence becomes the main problem.",
                "Propose realistic dates, not promises you cannot keep.",
                "Keep proof of what you paid and when.",
              ],
              [
                "Calcola con precisione quanto manca.",
                "Scrivi un messaggio breve e fattuale prima che il silenzio diventi il problema principale.",
                "Proponi date realistiche, non promesse che non puoi mantenere.",
                "Conserva prova di quanto hai pagato e quando.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not disappear and do not promise impossible dates. A credible written proposal is much better than vague reassurances.",
              "Non sparire e non promettere date impossibili. Una proposta scritta credibile vale piu di rassicurazioni vaghe.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa phone line",
              "Comune di Torino - numero unico Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "First Torino housing support line",
            ),
          ],
          contacts: [
            commonContacts.sportelloCasaPhone,
            commonContacts.sportelloCasaEmail,
          ],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Premium can turn the numbers into a clean Italian payment-plan message and a damage-control checklist.",
          premiumTeaserIt:
            "Premium puo trasformare i numeri in un messaggio chiaro in italiano per il piano di rientro e in una checklist di contenimento del danno.",
        }),
        procedure({
          id: "eviction_notice_or_court_papers",
          subcategoryId: "rent_delay_eviction",
          sortOrder: 20,
          titleEn: "You received an eviction notice or court papers",
          titleIt: "Hai ricevuto sfratto o atti del tribunale",
          shortEn:
            "Use this if the problem has already moved from simple rent delay to formal legal documents.",
          shortIt:
            "Usa questa guida se il problema e gia passato dal semplice ritardo a documenti formali del tribunale.",
          sections: [
            sectionText(
              "urgent",
              "This is urgent",
              "Questa situazione e urgente",
              "Do not wait until the last week. Save the full document, check the date, and ask for formal support immediately.",
              "Non aspettare l'ultima settimana. Conserva il documento completo, controlla la data e chiedi subito supporto formale.",
            ),
            sectionChecklist(
              "keep",
              "Keep these documents together",
              "Tieni insieme questi documenti",
              [
                "Court papers or notice.",
                "Contract.",
                "Payment proof.",
                "Any messages about payment-plan attempts.",
              ],
              [
                "Atto del tribunale o intimazione.",
                "Contratto.",
                "Prove di pagamento.",
                "Eventuali messaggi su tentativi di piano di rientro.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Tribunale di Torino - eviction office information",
              "Tribunale di Torino - informazioni sfratti",
              "https://www.tribunale.torino.giustizia.it/it/Content/Index/44274",
              "Tribunale di Torino",
              "Torino",
              "Court-side eviction reference point",
            ),
            link(
              "Comune di Torino - Sportello Casa phone line",
              "Comune di Torino - numero unico Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Local housing-support entry point",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
        procedure({
          id: "fimi_salvasfratti",
          subcategoryId: "rent_delay_eviction",
          sortOrder: 30,
          titleEn: "Check Torino support like FIMI / anti-eviction funds",
          titleIt: "Verifica FIMI e altri sostegni anti-sfratto a Torino",
          shortEn:
            "Use this if you are in housing distress and need to understand whether a Torino fund or support route may help.",
          shortIt:
            "Usa questa guida se sei in difficolta abitativa e devi capire se un fondo o sostegno di Torino puo aiutarti.",
          sections: [
            sectionText(
              "what_it_is",
              "What this can do",
              "A cosa serve",
              "These support routes do not erase the problem automatically. They can help only if your case fits the local rules and you move before the deadlines pass.",
              "Questi sostegni non cancellano il problema automaticamente. Possono aiutare solo se il tuo caso rientra nelle regole locali e ti muovi prima che scadano i tempi.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Fondo Inquilini Morosi Incolpevoli (FIMI)",
              "Comune di Torino - Fondo Inquilini Morosi Incolpevoli (FIMI)",
              "https://www.comune.torino.it/servizi/fondo-inquilini-morosi-incolpevoli-fimi/",
              "Comune di Torino",
              "Torino",
              "Morosita incolpevole support route",
            ),
            link(
              "Comune di Torino - Sportello Casa phone line",
              "Comune di Torino - numero unico Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "First support contact before missing deadlines",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "emergency_housing",
      sortOrder: 100,
      titleEn: "I need urgent housing help from Torino",
      titleIt: "Mi serve aiuto urgente per la casa a Torino",
      descriptionEn:
        "Emergency housing procedure, local support offices, and rent-support funds.",
      descriptionIt:
        "Procedura di emergenza abitativa, uffici comunali e fondi di sostegno all'affitto.",
      procedures: [
        procedure({
          id: "emergency_housing_comune_support",
          subcategoryId: "emergency_housing",
          sortOrder: 10,
          titleEn: "Emergency housing support from the Comune",
          titleIt: "Supporto del Comune per emergenza abitativa",
          shortEn:
            "Use this if the housing problem is urgent and you need to understand Torino's formal emergency-housing route.",
          shortIt:
            "Usa questa guida se il problema abitativo e urgente e devi capire il percorso formale di emergenza abitativa del Comune di Torino.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "The ordinary rental timeline is no longer enough because you are facing imminent loss of housing or another serious emergency condition recognized by the local process.",
              "La normale gestione dell'affitto non basta piu perche stai affrontando una perdita imminente dell'alloggio o un'altra condizione grave riconosciuta dalla procedura locale.",
            ),
            sectionChecklist(
              "bring",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Identity document.",
                "Housing loss proof or urgent notice.",
                "Income and household documents if requested.",
                "Any court or landlord documents.",
              ],
              [
                "Documento di identita.",
                "Prova della perdita dell'alloggio o avviso urgente.",
                "Documenti di reddito e nucleo se richiesti.",
                "Eventuali atti del tribunale o del proprietario.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - emergency housing application",
              "Comune di Torino - domanda di emergenza abitativa",
              "https://www.comune.torino.it/servizi/domanda-emergenza-abitativa",
              "Comune di Torino",
              "Torino",
              "Application route for emergency housing",
            ),
            link(
              "Comune di Torino - emergency housing office",
              "Comune di Torino - ufficio emergenza abitativa",
              "https://www.comune.torino.it/amministrazione/ufficio-emergenza-abitativa",
              "Comune di Torino",
              "Torino",
              "Office details and competence",
            ),
          ],
          contacts: [commonContacts.emergenzaAddress],
        }),
        procedure({
          id: "rent_support_fund",
          subcategoryId: "emergency_housing",
          sortOrder: 20,
          titleEn: "Check rent-support funds and local housing aid",
          titleIt: "Verificare fondo sostegno affitto e aiuti locali",
          shortEn:
            "Use this if the main problem is staying in the home financially, not only finding a new home immediately.",
          shortIt:
            "Usa questa guida se il problema principale e restare nell'alloggio sul piano economico, non solo trovare una nuova casa subito.",
          sections: [
            sectionText(
              "why_check",
              "Why this matters",
              "Perche controllarlo",
              "Some Torino support routes focus on keeping the household in place or reducing the rent pressure, rather than moving directly into an emergency-housing path.",
              "Alcuni sostegni torinesi puntano a mantenere il nucleo nell'alloggio o a ridurre la pressione dell'affitto, invece di spostarlo subito su un percorso di emergenza abitativa.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - National Fund for Access to Rental Housing",
              "Comune di Torino - Fondo nazionale sostegno accesso alle abitazioni in locazione",
              "https://www.comune.torino.it/servizi/fondo-nazionale-sostegno-accesso-alle-abitazioni-locazione/",
              "Comune di Torino",
              "Torino",
              "Rent-support fund route",
            ),
            link(
              "Comune di Torino - Sportello Casa phone line",
              "Comune di Torino - numero unico Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Orientation on which housing aid fits your case",
            ),
          ],
          contacts: [commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
    subcategory({
      id: "student_rent",
      sortOrder: 110,
      titleEn: "I am a student renting in Torino",
      titleIt: "Sono studente e affitto a Torino",
      descriptionEn:
        "Student contracts, rooms, roommates, and how not to accept weak housing proof.",
      descriptionIt:
        "Contratti studenti, stanze, coinquilini e come non accettare prove di alloggio deboli.",
      procedures: [
        procedure({
          id: "student_rental_contract_basics",
          subcategoryId: "student_rent",
          sortOrder: 10,
          titleEn: "Student rent basics in Torino",
          titleIt: "Basi dell'affitto studenti a Torino",
          shortEn:
            "Use this if you are a student renting a room or apartment in Torino and want the contract to be usable in real life, not only cheap on paper.",
          shortIt:
            "Usa questa guida se sei studente e affitti stanza o appartamento a Torino e vuoi un contratto utile nella vita reale, non solo economico sulla carta.",
          sections: [
            sectionChecklist(
              "check",
              "Check these points",
              "Controlla questi punti",
              [
                "Is it really a student contract or only called that informally?",
                "Will the contract be registered?",
                "Do you have written proof of room, address, and rent?",
                "If you need administrative proof, is the arrangement strong enough for that purpose?",
              ],
              [
                "E davvero un contratto studenti oppure viene chiamato cosi solo informalmente?",
                "Il contratto verra registrato?",
                "Hai prova scritta di stanza, indirizzo e canone?",
                "Se ti serve prova amministrativa, l'accordo e abbastanza forte per quello scopo?",
              ],
            ),
          ],
          officialLinks: [
            link(
              "TorinoGiovani - rent contracts",
              "TorinoGiovani - contratti di locazione",
              "https://www.torinogiovani.it/casa/contratti-di-locazione",
              "Comune di Torino / TorinoGiovani",
              "Torino",
              "Student-facing Torino rent guidance",
            ),
            link(
              "EDISU Piemonte - off-campus housing and contracts",
              "EDISU Piemonte - alloggi fuori sede e contratti",
              "https://www.edisu.piemonte.it/it/servizi-abitativi/cerco-alloggio",
              "EDISU Piemonte",
              "Piemonte",
              "Student housing search and contract guidance",
            ),
          ],
          relatedProcedures: [
            related(
              "Room or bed without a real contract",
              "Stanza o posto letto senza vero contratto",
              "before_signing",
              "room_or_bed_without_contract",
            ),
          ],
        }),
        procedure({
          id: "student_room_replacement_or_subletting",
          subcategoryId: "student_rent",
          sortOrder: 20,
          titleEn: "Replace a roommate or sublet safely",
          titleIt: "Sostituire un coinquilino o subaffittare in modo sicuro",
          shortEn:
            "Use this if one student leaves, another enters, or someone suggests informal subletting.",
          shortIt:
            "Usa questa guida se uno studente esce, un altro entra o qualcuno propone un subaffitto informale.",
          sections: [
            sectionText(
              "warning",
              "Important warning",
              "Avviso importante",
              "Do not treat a roommate change as only a WhatsApp agreement if the registered contract still shows the old person.",
              "Non trattare il cambio coinquilino come semplice accordo WhatsApp se il contratto registrato mostra ancora la persona vecchia.",
            ),
          ],
          officialLinks: [
            link(
              "TorinoGiovani - rent contracts",
              "TorinoGiovani - contratti di locazione",
              "https://www.torinogiovani.it/casa/contratti-di-locazione",
              "Comune di Torino / TorinoGiovani",
              "Torino",
              "Student-facing contract orientation",
            ),
            link(
              "Agenzia delle Entrate - subsequent steps for registered rental contracts",
              "Agenzia delle Entrate - adempimenti successivi ai contratti registrati",
              "https://www.agenziaentrate.gov.it/portale/web/guest/schede/fabbricatiterreni/adempimenti-successivi-registrazione-contratti-di-locazione-e-affitto",
              "Agenzia delle Entrate",
              "National",
              "Formal follow-up after a real contract change",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "tenant_union_support",
      sortOrder: 120,
      titleEn: "I need formal tenant help",
      titleIt: "Mi serve aiuto formale come inquilino",
      descriptionEn:
        "Tenant unions, Comune housing orientation, and social-rental support routes in Torino.",
      descriptionIt:
        "Sindacati inquilini, orientamento del Comune e percorsi di locazione sociale a Torino.",
      procedures: [
        procedure({
          id: "tenant_union_appointment",
          subcategoryId: "tenant_union_support",
          sortOrder: 10,
          titleEn: "Book tenant-union or formal housing help",
          titleIt: "Prenotare supporto sindacale o aiuto formale abitativo",
          shortEn:
            "Use this if the problem is moving beyond simple information and you need someone to read documents, letters, or disputes with you.",
          shortIt:
            "Usa questa guida se il problema supera la semplice informazione e ti serve qualcuno che legga con te documenti, lettere o contestazioni.",
          sections: [
            sectionChecklist(
              "bring",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Contract.",
                "Messages or letters.",
                "Payment proof.",
                "Photos if the problem is about damage or repairs.",
                "Any court or Comune document.",
              ],
              [
                "Contratto.",
                "Messaggi o lettere.",
                "Prove di pagamento.",
                "Foto se il problema riguarda danni o riparazioni.",
                "Eventuali atti del tribunale o del Comune.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - Sportello Casa phone line",
              "Comune di Torino - numero unico Sportello Casa",
              "https://www.comune.torino.it/novita/avvisi/numero-telefonico-unico-dello-sportello-casa",
              "Comune di Torino",
              "Torino",
              "Comune housing orientation",
            ),
            link(
              "SUNIA Piemonte",
              "SUNIA Piemonte",
              "https://www.sunia.it/piemonte/",
              "SUNIA",
              "Piemonte",
              "Tenant union support",
            ),
          ],
          contacts: [
            commonContacts.sportelloCasaPhone,
            commonContacts.sunia,
          ],
        }),
        procedure({
          id: "aslo_locare_support",
          subcategoryId: "tenant_union_support",
          sortOrder: 20,
          titleEn: "ASLo and social-rental support in Torino",
          titleIt: "ASLo e supporto di locazione sociale a Torino",
          shortEn:
            "Use this if you need Torino's social-rental orientation and want to understand whether a supported housing route fits better than an ordinary market lease.",
          shortIt:
            "Usa questa guida se ti serve orientamento sulla locazione sociale a Torino e vuoi capire se un percorso supportato e piu adatto del mercato libero.",
          sections: [
            sectionText(
              "what_it_is",
              "What this can do",
              "A cosa serve",
              "ASLo is not the same as emergency housing. It is a social-rental support route and can be relevant when the ordinary private market is blocked but your case is not yet in the emergency-office lane.",
              "ASLo non e la stessa cosa dell'emergenza abitativa. E un percorso di locazione sociale e puo essere utile quando il mercato privato ordinario si blocca ma il tuo caso non e ancora nel binario dell'ufficio emergenza.",
            ),
          ],
          officialLinks: [
            link(
              "Comune di Torino - ASLo (Agenzia Sociale per la Locazione)",
              "Comune di Torino - ASLo (Agenzia Sociale per la Locazione)",
              "https://www.comune.torino.it/servizi/aslo-agenzia-sociale-la-locazione/",
              "Comune di Torino",
              "Torino",
              "Social rental support route",
            ),
          ],
          contacts: [commonContacts.asloAddress, commonContacts.sportelloCasaPhone],
        }),
      ],
    }),
  ],
};

for (const catalogPath of catalogPaths) {
  const raw = fs.readFileSync(catalogPath, "utf8");
  const catalog = JSON.parse(raw);
  const categories = Array.isArray(catalog.categories) ? catalog.categories : [];
  const index = categories.findIndex((category) => category.id === "housing_rent");
  if (index === -1) {
    throw new Error(`Missing housing_rent category in ${catalogPath}`);
  }
  categories[index] = housingCategory;
  catalog.categories = categories;
  fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2) + "\n");
  console.log(`Updated ${catalogPath}`);
}
