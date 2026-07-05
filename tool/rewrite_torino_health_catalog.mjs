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
  categoryId: "health_asl",
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
  categoryId: "health_asl",
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
  urp: contact(
    "ASL Citta di Torino - URP",
    "ASL Citta di Torino - URP",
    "urp@aslcittaditorino.it",
    "email",
  ),
  pec: contact(
    "ASL Citta di Torino - PEC",
    "ASL Citta di Torino - PEC",
    "protocollo@pec.aslcittaditorino.it",
    "pec",
  ),
  adminCounters: contact(
    "ASL Citta di Torino - administrative counters",
    "ASL Citta di Torino - sportelli pratiche amministrative",
    "Via Juvarra 19, Corso Corsica 55, Via Monginevro 130, Via Pacchiotti 4, Via Montanaro 60, Via Cavezzale 6, Torino",
    "address",
  ),
  cupPhone: contact(
    "CUP Piemonte - booking number",
    "CUP Piemonte - numero prenotazioni",
    "800 000 500",
    "phone",
  ),
  cupEmail: contact(
    "CUP Piemonte - booking support",
    "CUP Piemonte - supporto prenotazioni",
    "assistenza.cupregionale@aslcittaditorino.it",
    "email",
  ),
  ticketRefundOffice: contact(
    "ASL Citta di Torino - ticket refund office",
    "ASL Citta di Torino - ufficio rimborso ticket",
    "Via Medail 16, Torino",
    "address",
  ),
  ticketRefundPhone: contact(
    "ASL Citta di Torino - ticket refund phone",
    "ASL Citta di Torino - telefono rimborso ticket",
    "011 4393473 / 011 4393696",
    "phone",
  ),
  ticketRefundEmail: contact(
    "ASL Citta di Torino - ticket refund email",
    "ASL Citta di Torino - email rimborso ticket",
    "recuperocreditiomv@aslcittaditorino.it",
    "email",
  ),
  vaccinationsEmail: contact(
    "ASL Citta di Torino - vaccination certificates",
    "ASL Citta di Torino - certificati vaccinali",
    "vaccinazioni@aslcittaditorino.it",
    "email",
  ),
  vaccinationsPhone: contact(
    "ASL Citta di Torino - vaccination certificates phone",
    "ASL Citta di Torino - telefono certificati vaccinali",
    "011 5663165 / 011 5663008",
    "phone",
  ),
  consultorioEmail: contact(
    "ASL Citta di Torino - consultorio giovani",
    "ASL Citta di Torino - consultorio giovani",
    "consultorio.giovani@aslcittaditorino.it",
    "email",
  ),
  waitlistEmail: contact(
    "ASL Citta di Torino - wait list support",
    "ASL Citta di Torino - supporto liste di attesa",
    "tempiattesa@aslcittaditorino.it",
    "email",
  ),
};

const healthCategory = {
  id: "health_asl",
  icon: "local_hospital",
  sortOrder: 1,
  isPremiumOnly: false,
  hasPremiumContent: true,
  title: t("Health / ASL", "Salute / ASL"),
  description: t(
    "Torino health help: start from the problem you need to solve.",
    "Pratiche salute a Torino: parti dal problema che devi risolvere.",
  ),
  subcategories: [
    subcategory({
      id: "ssn_asl_access",
      sortOrder: 10,
      titleEn: "I need to register with the health system",
      titleIt: "Devo registrarmi al sistema sanitario",
      descriptionEn:
        "SSN registration, worker and student cases, temporary healthcare, STP and ENI.",
      descriptionIt:
        "Iscrizione SSN, casi lavoro e studio, assistenza temporanea, STP ed ENI.",
      procedures: [
        procedure({
          id: "register_with_ssn",
          subcategoryId: "ssn_asl_access",
          sortOrder: 10,
          titleEn: "Register with SSN in Torino",
          titleIt: "Iscriverti al SSN a Torino",
          shortEn:
            "Use this if you live in Torino and need ordinary access to the public health system.",
          shortIt:
            "Usa questa guida se vivi a Torino e ti serve l'accesso ordinario alla sanita pubblica.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "You have the right to SSN because of residence, work, family reunification, long-term stay, asylum, or another eligible status and you need Torino ASL to register you correctly.",
              "Hai diritto al SSN per residenza, lavoro, ricongiungimento, soggiorno di lungo periodo, asilo o altro titolo valido e devi farti registrare correttamente dall'ASL di Torino.",
            ),
            sectionText(
              "when_not",
              "Do not use this when",
              "Non usare questo percorso quando",
              "You only need temporary urgent care, you are waiting for the correct permit, or you need STP/ENI. In those cases start from the dedicated foreigner route below.",
              "Ti serve solo assistenza temporanea urgente, stai aspettando il permesso giusto o devi usare STP/ENI. In quei casi parti dal percorso stranieri dedicato qui sotto.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Passport or identity card.",
                "Codice fiscale.",
                "Proof of address in Torino: residence certificate, rental contract, hospitality declaration, or another address document.",
                "Document that proves why you can register: permit, work contract, UNILAV, family document, or enrollment proof.",
                "Any old Tessera Sanitaria, ASL receipt, rejection letter, or protocol number.",
              ],
              [
                "Passaporto o carta di identita.",
                "Codice fiscale.",
                "Prova dell'indirizzo a Torino: residenza, contratto di affitto, dichiarazione di ospitalita o altro documento dell'indirizzo.",
                "Documento che prova il diritto all'iscrizione: permesso, contratto di lavoro, UNILAV, documento familiare o prova di iscrizione.",
                "Eventuale vecchia Tessera Sanitaria, ricevuta ASL, rifiuto scritto o numero di protocollo.",
              ],
            ),
            sectionChecklist(
              "steps",
              "What to do",
              "Cosa fare",
              [
                "Check first if your case is ordinary SSN registration or a foreigner/student/temporary route.",
                "If your documents are straightforward, verify whether the regional service can handle it online.",
                "If the case is foreign, document-heavy, or already refused, go to the ASL administrative counter for your district.",
                "Ask for SSN registration first. Only after that choose your family doctor or pediatrician.",
              ],
              [
                "Controlla prima se il tuo caso e un'iscrizione SSN ordinaria oppure un percorso stranieri/studenti/temporaneo.",
                "Se i documenti sono semplici, verifica se il servizio regionale lo gestisce online.",
                "Se il caso riguarda stranieri, molti documenti o un rifiuto gia ricevuto, vai allo sportello amministrativo ASL del tuo distretto.",
                "Chiedi prima l'iscrizione al SSN. Solo dopo scegli medico di base o pediatra.",
              ],
            ),
            sectionText(
              "costs",
              "Cost",
              "Costo",
              "Ordinary SSN registration itself is not a separate service fee. The real cost depends on your legal status only if the law puts you in a voluntary registration route.",
              "L'iscrizione ordinaria al SSN non ha un costo di servizio separato. Il costo reale dipende dal tuo status solo se la legge ti mette nell'iscrizione volontaria.",
            ),
            sectionText(
              "refusal",
              "If they refuse",
              "Se ti rifiutano la pratica",
              "Ask for the exact reason in writing, the missing document list, and the office protocol number. If the refusal is generic, write to URP or PEC and attach your documents plus the refusal note.",
              "Chiedi il motivo preciso per iscritto, l'elenco dei documenti mancanti e il numero di protocollo dell'ufficio. Se il rifiuto e generico, scrivi a URP o PEC allegando documenti e nota di rifiuto.",
            ),
            sectionText(
              "office_phrase",
              "What to say at the counter",
              "Cosa dire allo sportello",
              "Italian: \"Vorrei verificare il mio diritto all'iscrizione al SSN a Torino e sapere quali documenti mancano davvero.\" English: I would like to verify my right to SSN registration in Torino and know exactly which documents are still missing.",
              "Italiano: \"Vorrei verificare il mio diritto all'iscrizione al SSN a Torino e sapere quali documenti mancano davvero.\" Inglese: I would like to verify my right to SSN registration in Torino and know exactly which documents are still missing.",
            ),
          ],
          officialLinks: [
            link(
              "Regione Piemonte - SSN registration",
              "Regione Piemonte - iscrizione al SSN",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/iscrizione-al-servizio-sanitario-nazionale",
              "Regione Piemonte",
              "Piemonte",
              "Ordinary SSN registration rules",
            ),
            link(
              "ASL Citta di Torino - administrative counters",
              "ASL Citta di Torino - sportelli pratiche amministrative",
              "https://www.aslcittaditorino.it/sportelli-per-pratiche-amministrative/",
              "ASL Citta di Torino",
              "Torino",
              "District offices for registration, card and exemption work",
            ),
          ],
          contacts: [commonContacts.adminCounters, commonContacts.urp, commonContacts.pec],
          relatedProcedures: [
            related(
              "Choose or change your family doctor",
              "Scegliere o cambiare il medico di base",
              "doctor_health_card",
              "change_family_doctor",
            ),
            related(
              "Temporary healthcare domicile in Torino",
              "Assistenza temporanea o domicilio sanitario a Torino",
              "ssn_asl_access",
              "temporary_healthcare_domicile",
            ),
          ],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Get the exact Torino ASL checklist, with the right office and an Italian email or PEC draft for your status.",
          premiumTeaserIt:
            "Ottieni la checklist giusta per Torino, con lo sportello corretto e una bozza email o PEC in italiano per il tuo status.",
        }),
        procedure({
          id: "mandatory_ssn_registration_worker",
          subcategoryId: "ssn_asl_access",
          sortOrder: 20,
          titleEn: "Mandatory SSN registration for workers",
          titleIt: "Iscrizione SSN obbligatoria per lavoratori",
          shortEn:
            "Use this if you work in Italy and need to prove that your route is mandatory SSN, not private insurance or voluntary SSN.",
          shortIt:
            "Usa questa guida se lavori in Italia e devi dimostrare che il tuo percorso e l'iscrizione SSN obbligatoria, non assicurazione privata o SSN volontario.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "You have a work-based permit, subordinate or self-employed activity, or another foreigner status that gives mandatory SSN registration through work in Italy.",
              "Hai un permesso legato al lavoro, un'attivita subordinata o autonoma, o altro status stranieri che da iscrizione obbligatoria al SSN tramite lavoro in Italia.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Passport.",
                "Codice fiscale.",
                "Permesso di soggiorno or renewal receipt.",
                "Work contract, UNILAV, latest payslip, or employer declaration.",
                "Address document in Torino.",
              ],
              [
                "Passaporto.",
                "Codice fiscale.",
                "Permesso di soggiorno o ricevuta di rinnovo.",
                "Contratto di lavoro, UNILAV, ultima busta paga o dichiarazione del datore.",
                "Documento dell'indirizzo a Torino.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not pay voluntary SSN just because you are non-EU. If your permit gives mandatory registration, ask ASL to register you on that basis.",
              "Non pagare il SSN volontario solo perche sei extra-UE. Se il tuo permesso da iscrizione obbligatoria, chiedi all'ASL di registrarti su quella base.",
            ),
            sectionText(
              "refusal",
              "If they say your contract is not enough",
              "Se ti dicono che il contratto non basta",
              "Ask exactly which document is missing: UNILAV, payslip, employer letter, permit receipt, or address proof. If you already gave it, send the full packet again by PEC and ask for protocol.",
              "Chiedi esattamente quale documento manca: UNILAV, busta paga, lettera del datore, ricevuta del permesso o prova indirizzo. Se lo hai gia consegnato, invia di nuovo tutto via PEC e chiedi protocollo.",
            ),
          ],
          officialLinks: [
            link(
              "Regione Piemonte - healthcare for foreigners",
              "Regione Piemonte - assistenza sanitaria agli stranieri",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/assistenza-sanitaria-agli-stranieri",
              "Regione Piemonte",
              "Piemonte",
              "Foreign worker SSN eligibility",
            ),
            link(
              "ASL Citta di Torino - administrative counters",
              "ASL Citta di Torino - sportelli pratiche amministrative",
              "https://www.aslcittaditorino.it/sportelli-per-pratiche-amministrative/",
              "ASL Citta di Torino",
              "Torino",
              "Worker registration counter",
            ),
          ],
          contacts: [commonContacts.adminCounters, commonContacts.pec],
          relatedProcedures: [
            related(
              "Rejected SSN or ASL request",
              "Richiesta SSN o ASL respinta",
              "asl_problems",
              "asl_request_rejected",
            ),
          ],
        }),
        procedure({
          id: "temporary_healthcare_domicile",
          subcategoryId: "ssn_asl_access",
          sortOrder: 30,
          titleEn: "Temporary healthcare domicile for students or workers in Torino",
          titleIt: "Assistenza temporanea o domicilio sanitario per studenti e lavoratori a Torino",
          shortEn:
            "Use this if you live in Torino but your official residence is elsewhere and you need care here for a limited period.",
          shortIt:
            "Usa questa guida se vivi a Torino ma la tua residenza e altrove e ti serve assistenza qui per un periodo limitato.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "You are domiciled in Torino for study, work, or another temporary reason and you need a doctor or healthcare access here without moving your official residence.",
              "Sei domiciliato a Torino per studio, lavoro o altro motivo temporaneo e ti serve un medico o l'accesso sanitario qui senza spostare la residenza ufficiale.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Identity document and codice fiscale.",
                "Proof of residence elsewhere in Italy.",
                "Proof that you actually live in Torino now: rental contract, university housing, hospitality declaration, or employer note.",
                "Document that explains why you are in Torino: university enrollment, work contract, internship, or similar.",
              ],
              [
                "Documento e codice fiscale.",
                "Prova della residenza in un altro Comune italiano.",
                "Prova che vivi davvero a Torino adesso: contratto di affitto, alloggio universitario, dichiarazione di ospitalita o nota del datore.",
                "Documento che spiega perche sei a Torino: iscrizione universitaria, contratto di lavoro, tirocinio o simili.",
              ],
            ),
            sectionChecklist(
              "steps",
              "What to do",
              "Cosa fare",
              [
                "Check first whether the doctor-choice service can already handle your temporary domicile case online.",
                "If not, go to the ASL administrative counter with both residence and Torino domicile documents.",
                "Ask for temporary healthcare assistance or the route that lets you choose a doctor in Torino for the period you stay here.",
              ],
              [
                "Controlla prima se il servizio scelta medico gestisce gia online il tuo caso di domicilio temporaneo.",
                "Se non basta, vai allo sportello amministrativo ASL con documenti di residenza e domicilio torinese.",
                "Chiedi l'assistenza sanitaria temporanea o il percorso che ti permette di scegliere un medico a Torino per il periodo in cui resti qui.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Arriving with only a university badge or a verbal address is usually not enough. Torino ASL usually wants real address evidence plus the reason why you are staying here.",
              "Presentarsi solo con badge universitario o indirizzo detto a voce di solito non basta. L'ASL di Torino vuole una prova reale dell'indirizzo e del motivo per cui sei qui.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - choose or revoke family doctor or pediatrician",
              "ASL Citta di Torino - scegliere o revocare medico di famiglia o pediatra",
              "https://www.aslcittaditorino.it/come-fare-per/scegliere-o-revocare-il-medico-di-famiglia-o-il-pediatra/",
              "ASL Citta di Torino",
              "Torino",
              "Temporary domicile and doctor-choice instructions",
            ),
            link(
              "ASL Citta di Torino - administrative counters",
              "ASL Citta di Torino - sportelli pratiche amministrative",
              "https://www.aslcittaditorino.it/sportelli-per-pratiche-amministrative/",
              "ASL Citta di Torino",
              "Torino",
              "In-person temporary healthcare support",
            ),
          ],
          contacts: [commonContacts.adminCounters, commonContacts.urp],
          relatedProcedures: [
            related(
              "Choose or change your family doctor",
              "Scegliere o cambiare il medico di base",
              "doctor_health_card",
              "change_family_doctor",
            ),
          ],
        }),
        procedure({
          id: "stp_eni_access",
          subcategoryId: "ssn_asl_access",
          sortOrder: 40,
          titleEn: "STP / ENI and Centro ISI access",
          titleIt: "Accesso STP / ENI e Centro ISI",
          shortEn:
            "Use this if you do not have ordinary SSN registration and need healthcare as a foreign citizen in Torino.",
          shortIt:
            "Usa questa guida se non hai l'iscrizione ordinaria al SSN e hai bisogno di assistenza sanitaria come cittadino straniero a Torino.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "You are a non-EU person without regular SSN registration, or an EU citizen without ordinary coverage, and you need access through STP, ENI, or the ISI service.",
              "Sei una persona extra-UE senza iscrizione regolare al SSN, oppure un cittadino UE senza copertura ordinaria, e devi accedere tramite STP, ENI o servizio ISI.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Passport or any identity document you have.",
                "Any expired permit, renewal receipt, hospital note, or previous STP/ENI code.",
                "Address or hospitality information if available.",
              ],
              [
                "Passaporto o qualsiasi documento di identita disponibile.",
                "Eventuale permesso scaduto, ricevuta di rinnovo, foglio ospedaliero o vecchio codice STP/ENI.",
                "Indirizzo o informazioni di ospitalita se disponibili.",
              ],
            ),
            sectionText(
              "what_you_get",
              "What this route can cover",
              "Cosa copre questo percorso",
              "Urgent or essential care, continuity of care, pregnancy protection, vaccinations, and other services allowed by the foreigner-health rules. It is not the same as full ordinary SSN registration.",
              "Cure urgenti o essenziali, continuita terapeutica, tutela della gravidanza, vaccinazioni e altri servizi previsti dalle regole per l'assistenza agli stranieri. Non e la stessa cosa dell'iscrizione ordinaria completa al SSN.",
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not wait until the problem becomes urgent. If your permit situation is unstable or your ordinary SSN route is blocked, ask Centro ISI early.",
              "Non aspettare che il problema diventi urgente. Se la tua situazione di permesso e instabile o il percorso SSN ordinario si blocca, senti il Centro ISI subito.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - Centro ISI",
              "ASL Citta di Torino - Centro ISI",
              "https://www.aslcittaditorino.it/strutture/centro-isi-informazione-salute-immigrati-2/",
              "ASL Citta di Torino",
              "Torino",
              "STP, ENI and immigrant health service",
            ),
            link(
              "Regione Piemonte - healthcare for foreigners",
              "Regione Piemonte - assistenza sanitaria agli stranieri",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/assistenza-sanitaria-agli-stranieri",
              "Regione Piemonte",
              "Piemonte",
              "Foreign-health legal rules",
            ),
          ],
          contacts: [commonContacts.urp],
          relatedProcedures: [
            related(
              "Private insurance versus SSN",
              "Assicurazione privata o SSN",
              "insurance_finder",
              "ssn_vs_private_insurance",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "doctor_health_card",
      sortOrder: 20,
      titleEn: "I need a doctor, pediatrician, or Tessera Sanitaria",
      titleIt: "Mi servono medico, pediatra o Tessera Sanitaria",
      descriptionEn:
        "Choose or change your doctor, handle pediatrician issues, and fix health-card problems.",
      descriptionIt:
        "Scegli o cambia medico, gestisci il pediatra e risolvi i problemi della tessera sanitaria.",
      procedures: [
        procedure({
          id: "change_family_doctor",
          subcategoryId: "doctor_health_card",
          sortOrder: 10,
          titleEn: "Choose or change your family doctor",
          titleIt: "Scegliere o cambiare il medico di base",
          shortEn:
            "Use this if you are already in the SSN and need to choose, change, or revoke your medico di base in Torino.",
          shortIt:
            "Usa questa guida se sei gia nel SSN e devi scegliere, cambiare o revocare il medico di base a Torino.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "You already have ordinary SSN registration and need a new GP because you moved, your doctor retired, you want another doctor, or the online system still shows the wrong doctor.",
              "Hai gia l'iscrizione ordinaria al SSN e ti serve un nuovo medico perche ti sei trasferito, il medico e andato in pensione, vuoi cambiarlo o il sistema online mostra ancora quello sbagliato.",
            ),
            sectionChecklist(
              "documents",
              "What you usually need",
              "Cosa serve di solito",
              [
                "SPID, CIE, or TS-CNS for the online service.",
                "Codice fiscale and Tessera Sanitaria.",
                "Proof that you live in the Torino area served by the doctor if the office asks for it.",
              ],
              [
                "SPID, CIE o TS-CNS per il servizio online.",
                "Codice fiscale e Tessera Sanitaria.",
                "Prova che vivi nell'area di Torino servita dal medico se l'ufficio la chiede.",
              ],
            ),
            sectionChecklist(
              "steps",
              "What to do",
              "Cosa fare",
              [
                "Try first with the Salute Piemonte doctor-choice service.",
                "Search the doctor and check whether the list is open.",
                "If the online service blocks the change or shows no slots, use the ASL route or the district counter.",
              ],
              [
                "Prova prima con il servizio scelta medico di Salute Piemonte.",
                "Cerca il medico e controlla se ha ancora posti disponibili.",
                "Se il servizio online blocca il cambio o non mostra posti, usa il percorso ASL o lo sportello di distretto.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not choose only by name. Check district compatibility, whether the doctor still accepts patients, and whether your temporary domicile route has already been recorded.",
              "Non scegliere solo per nome. Controlla compatibilita di distretto, disponibilita reale del medico e registrazione del tuo eventuale domicilio temporaneo.",
            ),
            sectionText(
              "office_phrase",
              "What to say",
              "Cosa dire",
              "Italian: \"Il portale non mi fa scegliere il medico corretto. Vorrei verificare zona, disponibilita e mia posizione sanitaria.\" English: The portal does not let me choose the correct doctor. I want to verify my area, availability, and health registration.",
              "Italiano: \"Il portale non mi fa scegliere il medico corretto. Vorrei verificare zona, disponibilita e mia posizione sanitaria.\" Inglese: The portal does not let me choose the correct doctor. I want to verify my area, availability, and health registration.",
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - choose your GP or pediatrician",
              "Salute Piemonte - scegli medico o pediatra",
              "https://www.salutepiemonte.it/servizi/il-mio-medico?nid=75",
              "Salute Piemonte",
              "Piemonte",
              "Online doctor and pediatrician choice",
            ),
            link(
              "ASL Citta di Torino - choose or revoke family doctor or pediatrician",
              "ASL Citta di Torino - scegliere o revocare medico di famiglia o pediatra",
              "https://www.aslcittaditorino.it/come-fare-per/scegliere-o-revocare-il-medico-di-famiglia-o-il-pediatra/",
              "ASL Citta di Torino",
              "Torino",
              "Local doctor-choice instructions",
            ),
          ],
          contacts: [commonContacts.adminCounters],
          relatedProcedures: [
            related(
              "Doctor not available or outside your area",
              "Medico non disponibile o fuori zona",
              "doctor_health_card",
              "doctor_not_available",
            ),
          ],
        }),
        procedure({
          id: "choose_pediatrician",
          subcategoryId: "doctor_health_card",
          sortOrder: 20,
          titleEn: "Choose a pediatrician",
          titleIt: "Scegliere il pediatra",
          shortEn:
            "Use this if the healthcare choice is for a child and you need a pediatrician in Torino.",
          shortIt:
            "Usa questa guida se la scelta riguarda un minore e ti serve un pediatra a Torino.",
          sections: [
            sectionText(
              "who_for",
              "Use this when",
              "Usa questo percorso quando",
              "The child is already in the SSN or is being registered now and you need a pediatrician rather than an adult family doctor.",
              "Il minore e gia nel SSN oppure lo stai registrando adesso e ti serve il pediatra invece del medico di base per adulti.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Child identity document if available.",
                "Child codice fiscale and Tessera Sanitaria if already issued.",
                "Parent identity document.",
                "Residence or domicile proof if the office asks for district verification.",
              ],
              [
                "Documento del minore se disponibile.",
                "Codice fiscale e Tessera Sanitaria del minore se gia emessi.",
                "Documento del genitore.",
                "Prova di residenza o domicilio se l'ufficio la chiede per verificare il distretto.",
              ],
            ),
            sectionText(
              "delegate",
              "If one parent cannot go",
              "Se un genitore non puo andare",
              "Bring a delegation, a copy of the absent parent's document if requested, and the child's identifiers. Ask the counter first if your case needs both parents' consent.",
              "Porta delega, copia del documento del genitore assente se richiesta e dati del minore. Chiedi prima allo sportello se il tuo caso richiede il consenso di entrambi i genitori.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - choose or revoke family doctor or pediatrician",
              "ASL Citta di Torino - scegliere o revocare medico di famiglia o pediatra",
              "https://www.aslcittaditorino.it/come-fare-per/scegliere-o-revocare-il-medico-di-famiglia-o-il-pediatra/",
              "ASL Citta di Torino",
              "Torino",
              "Pediatrician choice",
            ),
            link(
              "Salute Piemonte - choose your GP or pediatrician",
              "Salute Piemonte - scegli medico o pediatra",
              "https://www.salutepiemonte.it/servizi/il-mio-medico?nid=75",
              "Salute Piemonte",
              "Piemonte",
              "Online pediatrician choice",
            ),
          ],
          contacts: [commonContacts.adminCounters],
        }),
        procedure({
          id: "doctor_not_available",
          subcategoryId: "doctor_health_card",
          sortOrder: 30,
          titleEn: "Doctor full, retired, or outside your area",
          titleIt: "Medico pieno, cessato o fuori zona",
          shortEn:
            "Use this if the doctor you want is not selectable, retired, or incompatible with your address in Torino.",
          shortIt:
            "Usa questa guida se il medico che vuoi non e selezionabile, e cessato oppure non e compatibile con il tuo indirizzo a Torino.",
          sections: [
            sectionChecklist(
              "checks",
              "Check these points first",
              "Controlla prima questi punti",
              [
                "Is your health registration active and updated for the correct address?",
                "Are you trying to choose a doctor in the right district?",
                "Has the doctor stopped accepting new patients or retired?",
                "Are you using a temporary domicile route that still needs ASL confirmation?",
              ],
              [
                "La tua posizione sanitaria e attiva e aggiornata sull'indirizzo corretto?",
                "Stai scegliendo un medico del distretto giusto?",
                "Il medico ha smesso di accettare pazienti o e andato in pensione?",
                "Stai usando un percorso di domicilio temporaneo che ha ancora bisogno della conferma ASL?",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "If the portal blocks the change, go to the ASL counter with your address proof and ask whether the problem is zone, patient cap, or a stale registration record.",
              "Se il portale blocca il cambio, vai allo sportello ASL con la prova dell'indirizzo e chiedi se il problema e la zona, il massimale del medico o una posizione sanitaria non aggiornata.",
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not keep trying random doctors online. Fix the health-position problem first, otherwise every attempt will fail.",
              "Non continuare a provare medici a caso online. Prima risolvi il problema della posizione sanitaria, altrimenti ogni tentativo fallira.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - healthcare forms",
              "ASL Citta di Torino - modulistica assistenza sanitaria",
              "https://www.aslcittaditorino.it/assistenza-sanitaria-modulistica/",
              "ASL Citta di Torino",
              "Torino",
              "Forms for doctor-choice corrections",
            ),
            link(
              "Salute Piemonte - choose your GP or pediatrician",
              "Salute Piemonte - scegli medico o pediatra",
              "https://www.salutepiemonte.it/servizi/il-mio-medico?nid=75",
              "Salute Piemonte",
              "Piemonte",
              "Online check before in-person escalation",
            ),
          ],
          contacts: [commonContacts.adminCounters, commonContacts.urp],
        }),
        procedure({
          id: "request_duplicate_tessera_sanitaria",
          subcategoryId: "doctor_health_card",
          sortOrder: 40,
          titleEn: "Duplicate or renewal of Tessera Sanitaria",
          titleIt: "Duplicato o rinnovo Tessera Sanitaria",
          shortEn:
            "Use this if your health card is lost, stolen, damaged, or expired and you need a new one.",
          shortIt:
            "Usa questa guida se la tessera sanitaria e smarrita, rubata, danneggiata o scaduta e ti serve un nuovo invio.",
          sections: [
            sectionChecklist(
              "steps",
              "What to do",
              "Cosa fare",
              [
                "Use the Agenzia delle Entrate duplicate request service if your data are already correct.",
                "If your address or health position is wrong, fix that first with ASL or tax registry support.",
                "Keep the request receipt and check where the card will be sent.",
              ],
              [
                "Usa il servizio Agenzia delle Entrate per il duplicato se i tuoi dati sono gia corretti.",
                "Se indirizzo o posizione sanitaria sono sbagliati, correggi prima quelli con ASL o anagrafe tributaria.",
                "Conserva la ricevuta della richiesta e controlla dove verra spedita la tessera.",
              ],
            ),
            sectionText(
              "cost",
              "Cost",
              "Costo",
              "The duplicate request itself is usually not a separate local fee. The important part is fixing wrong registry data before you order another card.",
              "La richiesta di duplicato di solito non ha un costo locale separato. La cosa importante e correggere i dati di anagrafe prima di ordinare un'altra tessera.",
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - request a duplicate Tessera Sanitaria",
              "Agenzia delle Entrate - richiedi il duplicato della Tessera Sanitaria",
              "https://telematici.agenziaentrate.gov.it/RichiestaDuplicatoWeb/ScegliModalita.jsp",
              "Agenzia delle Entrate",
              "National",
              "Duplicate Tessera Sanitaria request",
            ),
            link(
              "Agenzia delle Entrate - Tessera Sanitaria information",
              "Agenzia delle Entrate - informazioni Tessera Sanitaria",
              "https://www1.agenziaentrate.gov.it/web_app_entrate/tessera_sanitaria.html",
              "Agenzia delle Entrate",
              "National",
              "Health-card overview and help",
            ),
          ],
          contacts: [commonContacts.adminCounters],
        }),
        procedure({
          id: "health_card_not_received",
          subcategoryId: "doctor_health_card",
          sortOrder: 50,
          titleEn: "Health card not received or sent to the wrong address",
          titleIt: "Tessera sanitaria non arrivata o spedita all'indirizzo sbagliato",
          shortEn:
            "Use this if the Tessera Sanitaria should have arrived but did not, or it was sent to an old address.",
          shortIt:
            "Usa questa guida se la Tessera Sanitaria doveva arrivare ma non e arrivata, oppure e stata spedita a un vecchio indirizzo.",
          sections: [
            sectionChecklist(
              "checks",
              "Check these points first",
              "Controlla prima questi punti",
              [
                "Verify the address recorded for tax and health records.",
                "Check if a duplicate request was already sent.",
                "Check whether your SSN registration was still incomplete when the card was issued.",
              ],
              [
                "Verifica l'indirizzo registrato per anagrafe tributaria e posizione sanitaria.",
                "Controlla se esiste gia una richiesta di duplicato.",
                "Controlla se l'iscrizione SSN era ancora incompleta quando la tessera e stata emessa.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "If the address is wrong, correct the underlying registry first. If the address is correct, request the duplicate and keep proof of the request.",
              "Se l'indirizzo e sbagliato, correggi prima l'anagrafica di base. Se l'indirizzo e corretto, chiedi il duplicato e conserva la prova della richiesta.",
            ),
          ],
          officialLinks: [
            link(
              "Agenzia delle Entrate - request a duplicate Tessera Sanitaria",
              "Agenzia delle Entrate - richiedi il duplicato della Tessera Sanitaria",
              "https://telematici.agenziaentrate.gov.it/RichiestaDuplicatoWeb/ScegliModalita.jsp",
              "Agenzia delle Entrate",
              "National",
              "Duplicate request after wrong delivery",
            ),
            link(
              "ASL Citta di Torino - administrative counters",
              "ASL Citta di Torino - sportelli pratiche amministrative",
              "https://www.aslcittaditorino.it/sportelli-per-pratiche-amministrative/",
              "ASL Citta di Torino",
              "Torino",
              "Fix the underlying health position if the card data are wrong",
            ),
          ],
          contacts: [commonContacts.adminCounters],
        }),
      ],
    }),
    subcategory({
      id: "bookings_prescriptions_cup",
      sortOrder: 30,
      titleEn: "I need to book, change, or cancel a visit",
      titleIt: "Devo prenotare, spostare o annullare una visita",
      descriptionEn:
        "CUP Piemonte booking, cancellations, no-slot problems, and portal failures.",
      descriptionIt:
        "Prenotazioni CUP Piemonte, disdette, mancanza di posti e problemi del portale.",
      procedures: [
        procedure({
          id: "book_specialist_visit_or_exam",
          subcategoryId: "bookings_prescriptions_cup",
          sortOrder: 10,
          titleEn: "Book a visit or exam with CUP Piemonte",
          titleIt: "Prenotare visita o esame con CUP Piemonte",
          shortEn:
            "Use this if you already have a prescription and need to book through CUP in Torino or Piemonte.",
          shortIt:
            "Usa questa guida se hai gia la prescrizione e devi prenotare tramite CUP a Torino o in Piemonte.",
          sections: [
            sectionChecklist(
              "documents",
              "Keep these ready",
              "Tieni pronti questi dati",
              [
                "Prescription with priority code if required.",
                "Codice fiscale and Tessera Sanitaria.",
                "Exemption code if you have one.",
                "Mobile number and email if you book online.",
              ],
              [
                "Prescrizione con classe di priorita se prevista.",
                "Codice fiscale e Tessera Sanitaria.",
                "Codice di esenzione se lo hai.",
                "Cellulare ed email se prenoti online.",
              ],
            ),
            sectionChecklist(
              "channels",
              "Official channels",
              "Canali ufficiali",
              [
                "Online through Salute Piemonte.",
                "By phone through the regional booking number.",
                "At CUP counters if the online or phone route does not fit your case.",
              ],
              [
                "Online tramite Salute Piemonte.",
                "Per telefono tramite il numero regionale di prenotazione.",
                "Agli sportelli CUP se online o telefono non bastano per il tuo caso.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not start booking without checking the priority code on the prescription. If the class is urgent, the timetable and escalation path are different.",
              "Non iniziare a prenotare senza controllare la classe di priorita sulla prescrizione. Se la classe e urgente, cambiano tempi e percorso di escalation.",
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - book visits and exams",
              "Salute Piemonte - prenotazioni visite ed esami",
              "https://www.salutepiemonte.it/cms/servizi/prenotazioni-visite-ed-esami",
              "Salute Piemonte",
              "Piemonte",
              "Main CUP Piemonte booking page",
            ),
            link(
              "Regione Piemonte - online booking service",
              "Regione Piemonte - servizio prenotazione online",
              "https://servizi.regione.piemonte.it/catalogo/prenotazione-visite-esami",
              "Regione Piemonte",
              "Piemonte",
              "Online booking entry point",
            ),
          ],
          contacts: [commonContacts.cupPhone, commonContacts.cupEmail],
          relatedProcedures: [
            related(
              "Change or cancel a booking",
              "Spostare o annullare una prenotazione",
              "bookings_prescriptions_cup",
              "change_or_cancel_booked_visit",
            ),
          ],
        }),
        procedure({
          id: "change_or_cancel_booked_visit",
          subcategoryId: "bookings_prescriptions_cup",
          sortOrder: 20,
          titleEn: "Change or cancel a booked visit",
          titleIt: "Spostare o annullare una visita prenotata",
          shortEn:
            "Use this if you already have an appointment and need to move it, cancel it, or avoid a no-show problem.",
          shortIt:
            "Usa questa guida se hai gia un appuntamento e devi spostarlo, annullarlo o evitare il problema della mancata presenza.",
          sections: [
            sectionChecklist(
              "what_to_keep",
              "Keep these details ready",
              "Tieni pronti questi dati",
              [
                "Booking code or CUP reference.",
                "Prescription details.",
                "Patient codice fiscale.",
              ],
              [
                "Codice prenotazione o riferimento CUP.",
                "Dati della prescrizione.",
                "Codice fiscale del paziente.",
              ],
            ),
            sectionText(
              "why_fast",
              "Why you should do it early",
              "Perche farlo presto",
              "Cancel or move the booking as soon as you know you cannot go. Waiting too long can create a no-show issue or make rebooking harder.",
              "Sposta o annulla la prenotazione appena sai che non puoi andare. Aspettare troppo puo creare una mancata disdetta o rendere piu difficile riprenotare.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - how to book a visit",
              "ASL Citta di Torino - come prenotare una visita",
              "https://www.aslcittaditorino.it/come-fare-per/prenotare-una-visita/",
              "ASL Citta di Torino",
              "Torino",
              "Local booking and cancellation instructions",
            ),
            link(
              "Salute Piemonte - book visits and exams",
              "Salute Piemonte - prenotazioni visite ed esami",
              "https://www.salutepiemonte.it/cms/servizi/prenotazioni-visite-ed-esami",
              "Salute Piemonte",
              "Piemonte",
              "CUP channels for change and cancellation",
            ),
          ],
          contacts: [commonContacts.cupPhone],
        }),
        procedure({
          id: "no_appointment_available",
          subcategoryId: "bookings_prescriptions_cup",
          sortOrder: 30,
          titleEn: "No appointment available or waiting list too long",
          titleIt: "Nessun appuntamento disponibile o lista di attesa troppo lunga",
          shortEn:
            "Use this if CUP shows no slot, only very late dates, or the proposed date does not fit the prescription priority.",
          shortIt:
            "Usa questa guida se il CUP non mostra posti, propone date troppo lontane o non rispetta la priorita della prescrizione.",
          sections: [
            sectionChecklist(
              "what_to_check",
              "Check these points first",
              "Controlla prima questi punti",
              [
                "Priority class on the prescription: U, B, D, or P.",
                "Whether you searched only one facility or the whole regional network.",
                "Whether the operator can place you on the wait-list or propose another public provider.",
              ],
              [
                "Classe di priorita sulla ricetta: U, B, D o P.",
                "Se hai cercato solo una struttura o l'intera rete regionale.",
                "Se l'operatore puo metterti in lista o proporti un'altra struttura pubblica.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Ask the CUP operator to check all available public facilities in Piemonte that can legally serve your prescription. If the date still does not match the priority, save proof and contact the wait-list support.",
              "Chiedi all'operatore CUP di controllare tutte le strutture pubbliche piemontesi che possono erogare la prestazione. Se la data non rispetta ancora la priorita, conserva la prova e contatta il supporto liste di attesa.",
            ),
            sectionText(
              "proof",
              "Keep proof",
              "Conserva le prove",
              "Keep screenshots, booking refusal messages, operator names if given, and the prescription with priority class.",
              "Conserva screenshot, messaggi di indisponibilita, nome operatore se fornito e ricetta con classe di priorita.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - waiting list support",
              "ASL Citta di Torino - supporto liste di attesa",
              "https://www.aslcittaditorino.it/tempi-di-attesa-delle-prestazioni-ambulatoriali/",
              "ASL Citta di Torino",
              "Torino",
              "Escalation when timings do not match the prescription priority",
            ),
            link(
              "Salute Piemonte - book visits and exams",
              "Salute Piemonte - prenotazioni visite ed esami",
              "https://www.salutepiemonte.it/cms/servizi/prenotazioni-visite-ed-esami",
              "Salute Piemonte",
              "Piemonte",
              "CUP search across the regional network",
            ),
          ],
          contacts: [commonContacts.waitlistEmail, commonContacts.cupPhone],
        }),
        procedure({
          id: "cup_site_not_working",
          subcategoryId: "bookings_prescriptions_cup",
          sortOrder: 40,
          titleEn: "CUP site or portal is not working",
          titleIt: "Il sito CUP o il portale non funzionano",
          shortEn:
            "Use this if the online service fails, loops, or does not show the expected booking data.",
          shortIt:
            "Usa questa guida se il servizio online si blocca, va in loop o non mostra i dati di prenotazione attesi.",
          sections: [
            sectionChecklist(
              "do_this",
              "What to do",
              "Cosa fare",
              [
                "Try again from the official Salute Piemonte service, not from an unofficial search result.",
                "Check if SPID or CIE login is the real problem.",
                "If the portal still fails, switch to the CUP phone number and save a screenshot of the error.",
              ],
              [
                "Riprova dal servizio ufficiale Salute Piemonte, non da un risultato non ufficiale del motore di ricerca.",
                "Controlla se il problema reale e l'accesso con SPID o CIE.",
                "Se il portale continua a non funzionare, passa al numero CUP e salva uno screenshot dell'errore.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - book visits and exams",
              "Salute Piemonte - prenotazioni visite ed esami",
              "https://www.salutepiemonte.it/cms/servizi/prenotazioni-visite-ed-esami",
              "Salute Piemonte",
              "Piemonte",
              "Official portal to retry",
            ),
            link(
              "Salute Piemonte - contacts and support",
              "Salute Piemonte - contatti e supporto",
              "https://www.salutepiemonte.it/cms/taxonomy/term/81",
              "Salute Piemonte",
              "Piemonte",
              "Portal support references",
            ),
          ],
          contacts: [commonContacts.cupPhone, commonContacts.cupEmail],
        }),
      ],
    }),
    subcategory({
      id: "ticket_exemptions",
      sortOrder: 40,
      titleEn: "I need help with ticket, exemption, or payment",
      titleIt: "Mi serve aiuto con ticket, esenzione o pagamento",
      descriptionEn:
        "Pay the health ticket, request exemptions, fix wrong charges, and understand ER ticket rules.",
      descriptionIt:
        "Paga il ticket, chiedi esenzioni, correggi addebiti sbagliati e capisci il ticket del pronto soccorso.",
      procedures: [
        procedure({
          id: "pay_health_ticket",
          subcategoryId: "ticket_exemptions",
          sortOrder: 10,
          titleEn: "Pay the health ticket in Piemonte",
          titleIt: "Pagare il ticket sanitario in Piemonte",
          shortEn:
            "Use this if you have to pay a ticket for a visit or exam booked in Torino or Piemonte.",
          shortIt:
            "Usa questa guida se devi pagare un ticket per visita o esame prenotato a Torino o in Piemonte.",
          sections: [
            sectionChecklist(
              "channels",
              "Official channels",
              "Canali ufficiali",
              [
                "Online payment through Salute Piemonte / pagoPA.",
                "Pharmacy if the service allows pharmacy payment.",
                "Hospital or ASL payment points when the booking flow tells you to pay on site.",
              ],
              [
                "Pagamento online tramite Salute Piemonte / pagoPA.",
                "Farmacia se la prestazione ammette il pagamento in farmacia.",
                "Punti di pagamento ospedalieri o ASL quando la prenotazione ti chiede il pagamento in sede.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not pay twice. If you already paid at a pharmacy or online, keep the receipt before going to the facility.",
              "Non pagare due volte. Se hai gia pagato in farmacia o online, conserva la ricevuta prima di andare in struttura.",
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - ticket payment",
              "Salute Piemonte - pagamento ticket",
              "https://www.salutepiemonte.it/servizi/pagamento?nid=15",
              "Salute Piemonte",
              "Piemonte",
              "Online ticket payment",
            ),
            link(
              "Salute Piemonte - payment and pharmacy services",
              "Salute Piemonte - servizi pagamento e farmacia",
              "https://www.salutepiemonte.it/cms/servizi/ritiro-e-consultazione-documenti",
              "Salute Piemonte",
              "Piemonte",
              "Regional digital health service area",
            ),
          ],
          contacts: [],
        }),
        procedure({
          id: "request_chronic_disease_exemption",
          subcategoryId: "ticket_exemptions",
          sortOrder: 20,
          titleEn: "Request ticket exemption",
          titleIt: "Richiedere l'esenzione ticket",
          shortEn:
            "Use this if you need exemption because of pathology, income, disability status, or another allowed reason.",
          shortIt:
            "Usa questa guida se ti serve l'esenzione per patologia, reddito, invalidita o altro motivo previsto.",
          sections: [
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Identity document and codice fiscale.",
                "Medical certification if the exemption is based on pathology.",
                "Any previous exemption code or old certificate.",
                "Additional documents requested for income or disability-based exemptions.",
              ],
              [
                "Documento e codice fiscale.",
                "Certificazione medica se l'esenzione e per patologia.",
                "Eventuale vecchio codice esenzione o certificato precedente.",
                "Documenti aggiuntivi richiesti per esenzioni legate a reddito o invalidita.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Check first which exemption type applies. The ASL office handles the administrative registration of many exemptions, but the supporting document changes a lot depending on the legal basis.",
              "Controlla prima quale tipo di esenzione si applica. Lo sportello ASL registra amministrativamente molte esenzioni, ma il documento di base cambia molto secondo la causa giuridica.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - request ticket exemption",
              "ASL Citta di Torino - richiedere l'esenzione ticket",
              "https://www.aslcittaditorino.it/come-fare-per/richiedere-lesenzione-ticket/",
              "ASL Citta di Torino",
              "Torino",
              "Local exemption route",
            ),
            link(
              "ASL Citta di Torino - pathology exemption",
              "ASL Citta di Torino - esenzione ticket per patologia",
              "https://www.aslcittaditorino.it/prestazioni/esenzione-ticket-per-patologia-malattia/",
              "ASL Citta di Torino",
              "Torino",
              "Pathology-based exemption details",
            ),
          ],
          contacts: [commonContacts.adminCounters],
        }),
        procedure({
          id: "wrong_ticket_charge",
          subcategoryId: "ticket_exemptions",
          sortOrder: 30,
          titleEn: "Wrong ticket charge, refund, or correction",
          titleIt: "Ticket sbagliato, rimborso o correzione",
          shortEn:
            "Use this if you were charged when you should have been exempt, you paid twice, or the amount looks wrong.",
          shortIt:
            "Usa questa guida se ti hanno addebitato un ticket che non dovevi pagare, hai pagato due volte o l'importo sembra sbagliato.",
          sections: [
            sectionChecklist(
              "bring",
              "Bring these proofs",
              "Porta queste prove",
              [
                "Payment receipt.",
                "Prescription and booking reference.",
                "Exemption certificate or code if you had one.",
                "Any message that shows why the system charged you.",
              ],
              [
                "Ricevuta di pagamento.",
                "Ricetta e riferimento di prenotazione.",
                "Certificato o codice esenzione se lo avevi.",
                "Eventuale messaggio che mostra perche il sistema ti ha addebitato il ticket.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Ask first whether the problem is a missing exemption code, a duplicate payment, or a booking error. Refund and correction offices often want the full payment trail, not only the final receipt.",
              "Chiedi prima se il problema e un codice esenzione mancante, un doppio pagamento o un errore di prenotazione. Gli uffici rimborso e correzione spesso vogliono tutta la traccia del pagamento, non solo la ricevuta finale.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - request ticket refund",
              "ASL Citta di Torino - richiedere il rimborso del ticket",
              "https://www.aslcittaditorino.it/richiedere-il-rimborso-del-ticket/",
              "ASL Citta di Torino",
              "Torino",
              "Refund and correction path",
            ),
          ],
          contacts: [
            commonContacts.ticketRefundOffice,
            commonContacts.ticketRefundPhone,
            commonContacts.ticketRefundEmail,
          ],
        }),
        procedure({
          id: "emergency_room_ticket",
          subcategoryId: "ticket_exemptions",
          sortOrder: 40,
          titleEn: "Emergency room ticket and when fees may apply",
          titleIt: "Ticket del pronto soccorso e quando puo essere dovuto",
          shortEn:
            "Use this if you received or fear an ER ticket charge and want to understand when it can happen in Piemonte.",
          shortIt:
            "Usa questa guida se hai ricevuto o temi un ticket del pronto soccorso e vuoi capire quando puo scattare in Piemonte.",
          sections: [
            sectionText(
              "basic_rule",
              "Basic rule",
              "Regola di base",
              "In Piemonte, a fee can apply mainly for non-urgent access coded as white. Urgent and real emergency access follow different rules.",
              "In Piemonte un addebito puo applicarsi soprattutto agli accessi non urgenti con codice bianco. Gli accessi urgenti o di vera emergenza seguono regole diverse.",
            ),
            sectionText(
              "if_you_disagree",
              "If you disagree with the charge",
              "Se non sei d'accordo con l'addebito",
              "Ask the facility to explain the access code, the reason for the charge, and whether an exemption applied. Keep the discharge sheet and payment request.",
              "Chiedi alla struttura di spiegare il codice di accesso, il motivo dell'addebito e se si applicava un'esenzione. Conserva foglio di dimissione e richiesta di pagamento.",
            ),
          ],
          officialLinks: [
            link(
              "Regione Piemonte - emergency room white-code fee",
              "Regione Piemonte - ticket pronto soccorso codice bianco",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/ticket-pronto-soccorso-codice-bianco",
              "Regione Piemonte",
              "Piemonte",
              "Rules on ER ticket charges",
            ),
          ],
          contacts: [],
        }),
      ],
    }),
    subcategory({
      id: "digital_health_record",
      sortOrder: 50,
      titleEn: "I need Tessera Sanitaria or health documents",
      titleIt: "Mi servono Tessera Sanitaria o documenti sanitari",
      descriptionEn:
        "FSE access, referti, vaccination certificates, and copies of medical records.",
      descriptionIt:
        "Accesso al FSE, referti, certificati vaccinali e copie della documentazione sanitaria.",
      procedures: [
        procedure({
          id: "access_fascicolo_sanitario",
          subcategoryId: "digital_health_record",
          sortOrder: 10,
          titleEn: "Access the Fascicolo Sanitario Elettronico",
          titleIt: "Accedere al Fascicolo Sanitario Elettronico",
          shortEn:
            "Use this if you need the Piemonte digital health record for reports, prescriptions, and health documents.",
          shortIt:
            "Usa questa guida se ti serve il Fascicolo Sanitario Elettronico piemontese per referti, ricette e documenti sanitari.",
          sections: [
            sectionChecklist(
              "what_you_need",
              "What you need",
              "Cosa ti serve",
              [
                "SPID, CIE, or another accepted digital identity.",
                "A health position already active enough to identify you in the system.",
              ],
              [
                "SPID, CIE o altra identita digitale accettata.",
                "Una posizione sanitaria gia abbastanza attiva da farti riconoscere nel sistema.",
              ],
            ),
            sectionText(
              "if_login_fails",
              "If access fails",
              "Se l'accesso fallisce",
              "Check first whether the problem is your digital identity or your health position. If the identity works elsewhere but FSE is empty or blocked, ask health-system support.",
              "Controlla prima se il problema e l'identita digitale o la tua posizione sanitaria. Se l'identita funziona altrove ma il FSE e vuoto o bloccato, chiedi supporto sanitario.",
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - Fascicolo Sanitario Elettronico",
              "Salute Piemonte - Fascicolo Sanitario Elettronico",
              "https://www.salutepiemonte.it/cms/parole-chiave/fascicolo-sanitario-elettronico",
              "Salute Piemonte",
              "Piemonte",
              "FSE entry point and services",
            ),
            link(
              "Salute Piemonte - how to access FSE",
              "Salute Piemonte - come accedere al FSE",
              "https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico",
              "Salute Piemonte",
              "Piemonte",
              "FSE access instructions",
            ),
          ],
        }),
        procedure({
          id: "download_referti",
          subcategoryId: "digital_health_record",
          sortOrder: 20,
          titleEn: "Download referti and medical reports",
          titleIt: "Scaricare referti e risultati",
          shortEn:
            "Use this if a lab result or medical report should be available online and you need the exact Piemonte channel.",
          shortIt:
            "Usa questa guida se un referto o risultato dovrebbe essere disponibile online e ti serve il canale corretto del Piemonte.",
          sections: [
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Start from the Salute Piemonte referti area or your FSE. If the report is missing, verify first whether the facility releases it digitally or only with a separate process.",
              "Parti dall'area referti di Salute Piemonte o dal FSE. Se il referto manca, verifica prima se la struttura lo rilascia in digitale oppure con una procedura separata.",
            ),
          ],
          officialLinks: [
            link(
              "Salute Piemonte - referti",
              "Salute Piemonte - referti",
              "https://www.salutepiemonte.it/cms/parole-chiave/referti",
              "Salute Piemonte",
              "Piemonte",
              "Digital report retrieval",
            ),
            link(
              "Salute Piemonte - collect and consult documents",
              "Salute Piemonte - ritiro e consultazione documenti",
              "https://www.salutepiemonte.it/cms/servizi/ritiro-e-consultazione-documenti",
              "Salute Piemonte",
              "Piemonte",
              "Regional document retrieval service area",
            ),
          ],
        }),
        procedure({
          id: "vaccination_certificate",
          subcategoryId: "digital_health_record",
          sortOrder: 30,
          titleEn: "Get a vaccination certificate",
          titleIt: "Richiedere il certificato vaccinale",
          shortEn:
            "Use this if you need a vaccination certificate for school, work, travel, or another administrative reason in Torino.",
          shortIt:
            "Usa questa guida se ti serve un certificato vaccinale per scuola, lavoro, viaggio o altra pratica amministrativa a Torino.",
          sections: [
            sectionChecklist(
              "documents",
              "What to keep ready",
              "Cosa tenere pronto",
              [
                "Identity document.",
                "Codice fiscale.",
                "Child details if the certificate is for a minor.",
                "Exact reason if the office asks whether you need an ordinary certificate or another specific document.",
              ],
              [
                "Documento di identita.",
                "Codice fiscale.",
                "Dati del minore se il certificato riguarda un bambino.",
                "Motivo preciso se l'ufficio chiede se ti serve un certificato ordinario o un altro documento specifico.",
              ],
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - request the vaccination certificate",
              "ASL Citta di Torino - richiedere il certificato delle vaccinazioni",
              "https://www.aslcittaditorino.it/come-fare-per/richiedere-il-certificato-delle-vaccinazioni-2/",
              "ASL Citta di Torino",
              "Torino",
              "Local certificate request channel",
            ),
            link(
              "Salute Piemonte - vaccinations area",
              "Salute Piemonte - area vaccinazioni",
              "https://www.salutepiemonte.it/cms/node/384",
              "Salute Piemonte",
              "Piemonte",
              "Regional vaccination information",
            ),
          ],
          contacts: [
            commonContacts.vaccinationsEmail,
            commonContacts.vaccinationsPhone,
          ],
        }),
        procedure({
          id: "request_medical_records",
          subcategoryId: "digital_health_record",
          sortOrder: 40,
          titleEn: "Request medical records or cartella clinica",
          titleIt: "Richiedere documentazione sanitaria o cartella clinica",
          shortEn:
            "Use this if you need a copy of hospital records, discharge papers, or another formal health document from a Torino facility.",
          shortIt:
            "Usa questa guida se ti serve una copia della cartella clinica, della lettera di dimissione o di altra documentazione sanitaria di una struttura torinese.",
          sections: [
            sectionChecklist(
              "documents",
              "What you usually need",
              "Cosa serve di solito",
              [
                "Identity document.",
                "Patient details and date of service or admission.",
                "Delegation plus delegate document if another person collects it.",
              ],
              [
                "Documento di identita.",
                "Dati del paziente e data della prestazione o del ricovero.",
                "Delega piu documento del delegato se ritira un'altra persona.",
              ],
            ),
            sectionText(
              "timing",
              "Timing",
              "Tempi",
              "Timing depends on the type of document and the facility. Ask the office whether the record can be released digitally or only by formal copy request.",
              "I tempi dipendono dal tipo di documento e dalla struttura. Chiedi all'ufficio se la documentazione puo essere rilasciata in digitale oppure solo con richiesta formale di copia.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - request health documentation",
              "ASL Citta di Torino - richiedere il rilascio della documentazione sanitaria",
              "https://www.aslcittaditorino.it/richiedere-il-rilascio-della-documentazione-sanitaria/",
              "ASL Citta di Torino",
              "Torino",
              "Medical record and health-document request",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "asl_problems",
      sortOrder: 60,
      titleEn: "I need pregnancy, disability, home care, or help after a refusal",
      titleIt: "Mi servono gravidanza, invalidita, assistenza domiciliare o aiuto dopo un rifiuto",
      descriptionEn:
        "Consultorio, ADI, civil disability guidance, and how to react to a rejected ASL request.",
      descriptionIt:
        "Consultorio, ADI, invalidita civile e cosa fare dopo un rifiuto ASL.",
      procedures: [
        procedure({
          id: "consultorio_pregnancy_support",
          subcategoryId: "asl_problems",
          sortOrder: 10,
          titleEn: "Consultorio and pregnancy support",
          titleIt: "Consultorio e supporto in gravidanza",
          shortEn:
            "Use this if you need a consultorio in Torino for pregnancy, contraception, counseling, or early family support.",
          shortIt:
            "Usa questa guida se ti serve un consultorio a Torino per gravidanza, contraccezione, colloqui o sostegno familiare iniziale.",
          sections: [
            sectionText(
              "when",
              "Use this when",
              "Usa questo percorso quando",
              "You want public consultorio support for pregnancy follow-up, birth preparation, pediatric-family counseling, contraception, or a first orientation before choosing another service.",
              "Vuoi supporto consultoriale pubblico per gravidanza, accompagnamento alla nascita, colloqui familiari, contraccezione o un primo orientamento prima di scegliere un altro servizio.",
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Check the consultorio page for the district nearest to your address and contact the service directly if you need fast orientation.",
              "Controlla la pagina del consultorio piu vicino al tuo indirizzo e contatta direttamente il servizio se ti serve un orientamento rapido.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - consultori familiari e pediatrici",
              "ASL Citta di Torino - consultori familiari e pediatrici",
              "https://www.aslcittaditorino.it/strutture/consultori-familiari-e-pediatrici-sud/",
              "ASL Citta di Torino",
              "Torino",
              "Consultorio network and district access",
            ),
            link(
              "ASL Citta di Torino - birth and new parents support",
              "ASL Citta di Torino - accompagnamento alla nascita e neo genitori",
              "https://www.aslcittaditorino.it/accompagnamento-alla-nascita-e-neo-genitori/",
              "ASL Citta di Torino",
              "Torino",
              "Pregnancy and new-parent courses",
            ),
          ],
          contacts: [commonContacts.consultorioEmail],
        }),
        procedure({
          id: "home_care_adi",
          subcategoryId: "asl_problems",
          sortOrder: 20,
          titleEn: "Home care and ADI",
          titleIt: "Assistenza domiciliare e ADI",
          shortEn:
            "Use this if a person in Torino needs home healthcare because travel to services is difficult or impossible.",
          shortIt:
            "Usa questa guida se una persona a Torino ha bisogno di assistenza sanitaria a domicilio perche spostarsi e difficile o impossibile.",
          sections: [
            sectionText(
              "when",
              "Use this when",
              "Usa questo percorso quando",
              "The person has clinical, age-related, disability, or post-hospital needs that make home care more appropriate than repeated travel to outpatient services.",
              "La persona ha bisogni clinici, di eta, disabilita o post-ricovero che rendono piu adatta l'assistenza a domicilio invece degli spostamenti continui verso gli ambulatori.",
            ),
            sectionText(
              "how_it_starts",
              "How the route usually starts",
              "Come inizia di solito il percorso",
              "The route often starts from the GP, hospital discharge team, or district service that signals the home-care need. Ask which district service is competent for the address.",
              "Il percorso spesso parte dal medico di base, dalla dimissione ospedaliera o dal servizio di distretto che segnala il bisogno domiciliare. Chiedi quale servizio di distretto e competente per l'indirizzo.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - home care district service",
              "ASL Citta di Torino - cure domiciliari di distretto",
              "https://www.aslcittaditorino.it/strutture/cure-domiciliari-distretto-sud-ovest/",
              "ASL Citta di Torino",
              "Torino",
              "District home-care information",
            ),
          ],
          contacts: [commonContacts.urp],
          relatedProcedures: [
            related(
              "Choose or change your family doctor",
              "Scegliere o cambiare il medico di base",
              "doctor_health_card",
              "change_family_doctor",
            ),
          ],
        }),
        procedure({
          id: "civil_disability_invalidity",
          subcategoryId: "asl_problems",
          sortOrder: 30,
          titleEn: "Civil disability: INPS and ASL roles",
          titleIt: "Invalidita civile: ruolo di INPS e ASL",
          shortEn:
            "Use this if you need to understand how the disability path works and which part is handled by INPS versus the health commission.",
          shortIt:
            "Usa questa guida se devi capire come funziona il percorso di invalidita e quale parte gestisce INPS rispetto alla commissione sanitaria.",
          sections: [
            sectionText(
              "difference",
              "Who does what",
              "Chi fa cosa",
              "INPS receives the application and manages the administrative procedure. The health assessment is performed through the medical-legal system and commission process linked to the territory.",
              "INPS riceve la domanda e gestisce la procedura amministrativa. L'accertamento sanitario passa invece attraverso il sistema medico-legale e la commissione legata al territorio.",
            ),
            sectionChecklist(
              "start",
              "How the path starts",
              "Come inizia il percorso",
              [
                "Get the introductory medical certificate.",
                "Send the disability application to INPS within the allowed time.",
                "Keep every receipt, protocol, visit notice, and later commission result.",
              ],
              [
                "Ottieni il certificato medico introduttivo.",
                "Invia la domanda di invalidita a INPS entro i tempi previsti.",
                "Conserva ricevute, protocolli, convocazioni e poi il verbale finale.",
              ],
            ),
            sectionText(
              "mistake",
              "Common mistake",
              "Errore frequente",
              "Do not confuse the INPS online application with the later medical assessment stage. They are connected, but they are not the same step.",
              "Non confondere la domanda online INPS con la fase successiva di accertamento sanitario. Sono collegate, ma non sono lo stesso passaggio.",
            ),
          ],
          officialLinks: [
            link(
              "INPS - disability application and health assessment",
              "INPS - domanda di invalidita e accertamento sanitario",
              "https://www.inps.it/it/it/dettaglio-scheda.it.schede-servizio-strumento.schede-servizi.domanda-invalidita-civile-e-accertamento-sanitario-50004.accertamento-sanitario.html",
              "INPS",
              "National",
              "Civil disability application and health-assessment flow",
            ),
          ],
        }),
        procedure({
          id: "asl_request_rejected",
          subcategoryId: "asl_problems",
          sortOrder: 40,
          titleEn: "ASL request rejected or office gave unclear answers",
          titleIt: "Richiesta ASL respinta o risposte poco chiare dall'ufficio",
          shortEn:
            "Use this if the office refused your request, kept asking for different documents, or gave you no clear written reason.",
          shortIt:
            "Usa questa guida se l'ufficio ha respinto la pratica, continua a chiedere documenti diversi o non ti ha dato un motivo scritto chiaro.",
          sections: [
            sectionChecklist(
              "collect",
              "Collect these proofs",
              "Raccogli queste prove",
              [
                "Written refusal if available.",
                "Name of the office and date.",
                "Protocol number, receipt, or email chain.",
                "All documents already submitted.",
              ],
              [
                "Rifiuto scritto se disponibile.",
                "Nome dell'ufficio e data.",
                "Numero di protocollo, ricevuta o scambio email.",
                "Tutti i documenti gia consegnati.",
              ],
            ),
            sectionText(
              "what_to_do",
              "What to do",
              "Cosa fare",
              "Ask for the exact rule or document they are applying. If the answer stays vague, write a short factual email to URP or PEC attaching the refusal and your complete document packet.",
              "Chiedi la regola precisa o il documento mancante che stanno applicando. Se la risposta resta vaga, scrivi una email breve e fattuale a URP o PEC allegando rifiuto e pacchetto documenti completo.",
            ),
            sectionText(
              "office_phrase",
              "What to say",
              "Cosa dire",
              "Italian: \"Per favore, mi puo indicare per iscritto il motivo del rifiuto e il documento preciso che manca?\" English: Please tell me in writing why the request was refused and exactly which document is missing.",
              "Italiano: \"Per favore, mi puo indicare per iscritto il motivo del rifiuto e il documento preciso che manca?\" Inglese: Please tell me in writing why the request was refused and exactly which document is missing.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - administrative counters",
              "ASL Citta di Torino - sportelli pratiche amministrative",
              "https://www.aslcittaditorino.it/sportelli-per-pratiche-amministrative/",
              "ASL Citta di Torino",
              "Torino",
              "First escalation point",
            ),
            link(
              "ASL Citta di Torino - healthcare forms",
              "ASL Citta di Torino - modulistica assistenza sanitaria",
              "https://www.aslcittaditorino.it/assistenza-sanitaria-modulistica/",
              "ASL Citta di Torino",
              "Torino",
              "Forms and document references used by counters",
            ),
          ],
          contacts: [commonContacts.urp, commonContacts.pec],
          hasPremiumContent: true,
          premiumTeaserEn:
            "Premium can turn your refusal into a clean Torino-ready document packet, plus an Italian escalation email or PEC draft.",
          premiumTeaserIt:
            "Premium puo trasformare il rifiuto in un pacchetto documenti chiaro, con bozza email o PEC di escalation in italiano.",
        }),
      ],
    }),
    subcategory({
      id: "student_insurance",
      sortOrder: 70,
      titleEn: "I am a student or foreign citizen",
      titleIt: "Sono studente o cittadino straniero",
      descriptionEn:
        "Voluntary SSN for students, foreign-student choices, and when private insurance is only temporary.",
      descriptionIt:
        "SSN volontario per studenti, scelte per studenti stranieri e quando l'assicurazione privata e solo temporanea.",
      procedures: [
        procedure({
          id: "voluntary_ssn_registration_student",
          subcategoryId: "student_insurance",
          sortOrder: 10,
          titleEn: "Voluntary SSN registration for students",
          titleIt: "Iscrizione volontaria al SSN per studenti",
          shortEn:
            "Use this if you are a student in Torino and the correct route is voluntary SSN instead of mandatory registration.",
          shortIt:
            "Usa questa guida se sei studente a Torino e il percorso corretto e il SSN volontario invece dell'iscrizione obbligatoria.",
          sections: [
            sectionText(
              "when",
              "Use this when",
              "Usa questo percorso quando",
              "You are studying in Torino, you are not covered by another mandatory SSN route, and your permit or university situation allows the voluntary registration path.",
              "Stai studiando a Torino, non sei coperto da un altro percorso SSN obbligatorio e il tuo permesso o la tua situazione universitaria consentono l'iscrizione volontaria.",
            ),
            sectionChecklist(
              "documents",
              "Bring these documents",
              "Porta questi documenti",
              [
                "Passport and codice fiscale.",
                "Permesso di soggiorno or application/renewal receipt.",
                "University enrollment document.",
                "Payment proof if the office tells you the voluntary contribution is required for your case.",
                "Address or domicile document in Torino.",
              ],
              [
                "Passaporto e codice fiscale.",
                "Permesso di soggiorno o ricevuta di domanda/rinnovo.",
                "Documento di iscrizione universitaria.",
                "Prova del pagamento se l'ufficio ti conferma che nel tuo caso il contributo volontario e dovuto.",
                "Documento di indirizzo o domicilio a Torino.",
              ],
            ),
            sectionText(
              "warning",
              "Important warning",
              "Avviso importante",
              "Do not pay before checking whether another route fits better. Some students discover too late that work, family, or another status already gave mandatory SSN access.",
              "Non pagare prima di avere verificato se esiste un percorso migliore. Alcuni studenti scoprono tardi che lavoro, famiglia o altro status davano gia accesso obbligatorio al SSN.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - voluntary SSN registration",
              "ASL Citta di Torino - iscrizione volontaria al SSN",
              "https://www.aslcittaditorino.it/cittadini-che-richiedono-liscrizione-volontaria-al-servizio-sanitario-nazionale/",
              "ASL Citta di Torino",
              "Torino",
              "Local voluntary SSN instructions",
            ),
            link(
              "ASL Citta di Torino - healthcare forms",
              "ASL Citta di Torino - modulistica assistenza sanitaria",
              "https://www.aslcittaditorino.it/assistenza-sanitaria-modulistica/",
              "ASL Citta di Torino",
              "Torino",
              "Forms used for voluntary registration",
            ),
            link(
              "EDISU Piemonte - health assistance information",
              "EDISU Piemonte - informazioni assistenza sanitaria",
              "https://edisu.piemonte.it/altri-servizi/informazioni-assistenza-sanitaria",
              "EDISU Piemonte",
              "Piemonte",
              "Student-facing health guidance",
            ),
          ],
          contacts: [commonContacts.adminCounters],
          relatedProcedures: [
            related(
              "Insurance Finder",
              "Insurance Finder",
              "insurance_finder",
              "insurance_finder_tool",
            ),
          ],
        }),
        procedure({
          id: "foreign_students_health_options",
          subcategoryId: "student_insurance",
          sortOrder: 20,
          titleEn: "Foreign students, non-EU residents, and temporary private insurance options",
          titleIt: "Studenti stranieri, residenti extra-UE e opzioni di assicurazione privata temporanea",
          shortEn:
            "Use this if you are comparing student insurance, voluntary SSN, or temporary coverage while waiting for your full health position.",
          shortIt:
            "Usa questa guida se stai confrontando assicurazione studenti, SSN volontario o copertura temporanea mentre aspetti la tua posizione sanitaria completa.",
          sections: [
            sectionChecklist(
              "compare",
              "Compare these routes",
              "Confronta questi percorsi",
              [
                "Mandatory SSN if your legal status already gives it.",
                "Voluntary SSN if your student route allows it and you want public coverage.",
                "Private insurance only if your university, Questura, or administrative purpose accepts it for your case.",
              ],
              [
                "SSN obbligatorio se il tuo status lo prevede gia.",
                "SSN volontario se il tuo percorso studente lo consente e vuoi copertura pubblica.",
                "Assicurazione privata solo se universita, Questura o finalita amministrativa la accettano davvero per il tuo caso.",
              ],
            ),
            sectionText(
              "warning",
              "Important warning",
              "Avviso importante",
              "Private insurance is not automatically equivalent to SSN. It can be a temporary or limited solution and may not satisfy every healthcare or immigration need.",
              "L'assicurazione privata non e automaticamente equivalente al SSN. Puo essere una soluzione temporanea o limitata e potrebbe non soddisfare ogni esigenza sanitaria o di immigrazione.",
            ),
          ],
          officialLinks: [
            link(
              "Regione Piemonte - healthcare for foreigners",
              "Regione Piemonte - assistenza sanitaria agli stranieri",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/assistenza-sanitaria-agli-stranieri",
              "Regione Piemonte",
              "Piemonte",
              "Legal baseline for foreign-health access",
            ),
            link(
              "Politecnico di Torino - health insurance for international students",
              "Politecnico di Torino - assicurazione sanitaria per studenti internazionali",
              "https://www.polito.it/en/education/international-students/practical-information/health-insurance",
              "Politecnico di Torino",
              "Torino",
              "Student-facing explanation of SSN and private coverage",
            ),
          ],
          relatedProcedures: [
            related(
              "Insurance Finder live comparison",
              "Confronto live Insurance Finder",
              "insurance_finder",
              "insurance_finder_tool",
            ),
          ],
        }),
      ],
    }),
    subcategory({
      id: "insurance_finder",
      sortOrder: 80,
      titleEn: "Insurance Finder",
      titleIt: "Insurance Finder",
      descriptionEn:
        "Compare when private insurance makes sense, when SSN is better, and run the live premium-only comparison if available.",
      descriptionIt:
        "Confronta quando l'assicurazione privata ha senso, quando il SSN e meglio, e usa il confronto live premium se disponibile.",
      hasPremiumContent: true,
      procedures: [
        procedure({
          id: "ssn_vs_private_insurance",
          subcategoryId: "insurance_finder",
          sortOrder: 10,
          titleEn: "SSN versus private insurance: use the right route",
          titleIt: "SSN o assicurazione privata: scegli il percorso giusto",
          shortEn:
            "Use this to understand whether SSN, voluntary SSN, student insurance, travel insurance, or a fuller private policy fits your real problem.",
          shortIt:
            "Usa questa guida per capire se nel tuo caso servono SSN, SSN volontario, assicurazione studenti, travel insurance o una polizza privata piu completa.",
          sections: [
            sectionChecklist(
              "compare",
              "Quick comparison",
              "Confronto rapido",
              [
                "Voluntary SSN: best when you want public coverage and your status allows it.",
                "Student private insurance: useful only if your school or permit path accepts it and you understand the exclusions.",
                "Travel medical insurance: often too weak for ordinary life in Torino.",
                "Full private health insurance: broader care, but still not automatically equal to SSN for every administrative purpose.",
                "Family or employer-based SSN: usually stronger than buying private coverage just because you are in a hurry.",
              ],
              [
                "SSN volontario: migliore quando vuoi copertura pubblica e il tuo status lo consente.",
                "Assicurazione privata studenti: utile solo se scuola o permesso la accettano davvero e se capisci bene le esclusioni.",
                "Travel medical insurance: spesso troppo debole per la vita ordinaria a Torino.",
                "Assicurazione privata completa: copertura piu ampia, ma non equivale automaticamente al SSN per ogni esigenza amministrativa.",
                "SSN tramite famiglia o lavoro: di solito e piu forte che comprare assicurazione privata solo per fretta.",
              ],
            ),
            sectionChecklist(
              "check_before_buying",
              "Check this before you buy",
              "Controlla questo prima di comprare",
              [
                "Whether the policy is accepted for your university, Questura, employer, or permit case.",
                "Whether GP-like care, specialist visits, medicines, and hospitalization are really included.",
                "Territorial validity in Italy and claim procedure.",
                "Waiting periods, exclusions, deductible, and annual ceiling.",
              ],
              [
                "Se la polizza e accettata per universita, Questura, datore o pratica di permesso.",
                "Se sono davvero inclusi medico, visite specialistiche, farmaci e ricovero.",
                "Validita territoriale in Italia e procedura di rimborso.",
                "Carenze, esclusioni, franchigia e massimale annuo.",
              ],
            ),
            sectionText(
              "warning",
              "Important warning",
              "Avviso importante",
              "Price alone is not enough. Emergency-only policies can be useless for ordinary care in Torino, and a cheap policy can fail exactly when you need administrative acceptance.",
              "Il prezzo da solo non basta. Le polizze solo emergenza possono essere inutili per la vita ordinaria a Torino, e una polizza economica puo fallire proprio quando ti serve l'accettazione amministrativa.",
            ),
          ],
          officialLinks: [
            link(
              "ASL Citta di Torino - voluntary SSN registration",
              "ASL Citta di Torino - iscrizione volontaria al SSN",
              "https://www.aslcittaditorino.it/cittadini-che-richiedono-liscrizione-volontaria-al-servizio-sanitario-nazionale/",
              "ASL Citta di Torino",
              "Torino",
              "Public alternative to private insurance",
            ),
            link(
              "Politecnico di Torino - health insurance for international students",
              "Politecnico di Torino - assicurazione sanitaria per studenti internazionali",
              "https://www.polito.it/en/education/international-students/practical-information/health-insurance",
              "Politecnico di Torino",
              "Torino",
              "Student-facing comparison baseline",
            ),
            link(
              "EDISU Piemonte - health assistance information",
              "EDISU Piemonte - informazioni assistenza sanitaria",
              "https://edisu.piemonte.it/altri-servizi/informazioni-assistenza-sanitaria",
              "EDISU Piemonte",
              "Piemonte",
              "Public student guidance on SSN and insurance",
            ),
          ],
          relatedProcedures: [
            related(
              "Run the Insurance Finder comparison",
              "Apri il confronto Insurance Finder",
              "insurance_finder",
              "insurance_finder_tool",
            ),
            related(
              "Voluntary SSN for students",
              "SSN volontario per studenti",
              "student_insurance",
              "voluntary_ssn_registration_student",
            ),
          ],
        }),
        procedure({
          id: "insurance_finder_tool",
          subcategoryId: "insurance_finder",
          sortOrder: 20,
          titleEn: "Insurance Finder live comparison",
          titleIt: "Confronto live Insurance Finder",
          shortEn:
            "Answer a few questions to check whether private insurance makes sense and, if live search is enabled, compare the top verified offers.",
          shortIt:
            "Rispondi a poche domande per capire se l'assicurazione privata ha senso e, se la ricerca live e attiva, confronta le migliori offerte verificate.",
          sections: [
            sectionText(
              "how_it_works",
              "How it works",
              "Come funziona",
              "The questionnaire helps you compare private insurance with SSN logic for Torino. Static guidance is always available. Live top-5 comparison stays premium and only appears when a verified provider source is configured server-side.",
              "Il questionario ti aiuta a confrontare assicurazione privata e logica SSN per Torino. La guida statica e sempre disponibile. Il confronto live top-5 resta premium e appare solo quando sul server esiste una fonte verificata.",
            ),
            sectionText(
              "safety",
              "Safety rule",
              "Regola di sicurezza",
              "No live result should be trusted without checking the policy wording and the provider page on the same day. If live search is unavailable, the app must show a safe unavailable state instead of invented offers.",
              "Nessun risultato live va accettato senza controllare il testo di polizza e la pagina del provider nello stesso giorno. Se la ricerca live non e disponibile, l'app deve mostrare uno stato sicuro di indisponibilita invece di offerte inventate.",
            ),
            sectionText(
              "premium_help",
              "Premium help",
              "Aiuto premium",
              "Premium unlocks the live comparison when a verified source exists, plus a tailored reading of what coverage looks unsafe for your Torino case.",
              "Premium sblocca il confronto live quando esiste una fonte verificata, piu una lettura mirata di cio che sembra rischioso per il tuo caso a Torino.",
              { isPremiumOnly: true },
            ),
          ],
          officialLinks: [
            link(
              "Politecnico di Torino - health insurance for international students",
              "Politecnico di Torino - assicurazione sanitaria per studenti internazionali",
              "https://www.polito.it/en/education/international-students/practical-information/health-insurance",
              "Politecnico di Torino",
              "Torino",
              "Student admin-acceptance baseline",
            ),
            link(
              "Regione Piemonte - healthcare for foreigners",
              "Regione Piemonte - assistenza sanitaria agli stranieri",
              "https://www.regione.piemonte.it/web/temi/sanita/accesso-ai-servizi-sanitari/assistenza-sanitaria-agli-stranieri",
              "Regione Piemonte",
              "Piemonte",
              "Legal baseline before buying private coverage",
            ),
          ],
          hasPremiumContent: true,
          premiumTeaserEn:
            "See the top verified insurance matches for your Torino situation when live sources are enabled.",
          premiumTeaserIt:
            "Vedi le migliori assicurazioni verificate per il tuo caso a Torino quando le fonti live sono abilitate.",
          relatedProcedures: [
            related(
              "Private insurance versus SSN",
              "Assicurazione privata o SSN",
              "insurance_finder",
              "ssn_vs_private_insurance",
            ),
            related(
              "Register with SSN in Torino",
              "Iscriverti al SSN a Torino",
              "ssn_asl_access",
              "register_with_ssn",
            ),
          ],
        }),
      ],
    }),
  ],
};

for (const catalogPath of catalogPaths) {
  const raw = fs.readFileSync(catalogPath, "utf8");
  const catalog = JSON.parse(raw);
  const categories = Array.isArray(catalog.categories) ? catalog.categories : [];
  const index = categories.findIndex((category) => category.id === "health_asl");
  if (index === -1) {
    throw new Error(`Missing health_asl category in ${catalogPath}`);
  }
  categories[index] = healthCategory;
  catalog.categories = categories;
  fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2) + "\n");
  console.log(`Updated ${catalogPath}`);
}
