import fs from "node:fs";

const catalogPaths = [
  "assets/catalog/ufficio_catalog.torino.v1.json",
  "assets/catalog/ufficio_catalog.v1.json",
];

const t = (en, it) => ({ en, it });

const premiumByCategory = {
  health_asl: {
    teaser: t(
      "Premium can review your health-office route, documents, and refusal strategy before you go.",
      "Premium puo rivedere percorso ASL, documenti e strategia in caso di rifiuto prima che tu vada allo sportello.",
    ),
    title: t("Premium review", "Revisione premium"),
    body: t(
      "Use Premium if the case is blocked, cross-border, document-heavy, or you want a cleaner office strategy.",
      "Usa Premium se il caso e bloccato, internazionale, ricco di documenti o vuoi una strategia piu chiara per lo sportello.",
    ),
    items: t(
      [
        "Document checklist review before the appointment.",
        "Office route check when several health channels overlap.",
        "Short escalation summary if the office already refused the request.",
      ],
      [
        "Revisione della checklist documenti prima dell'appuntamento.",
        "Verifica del canale corretto quando si sovrappongono piu percorsi sanitari.",
        "Breve schema escalation se l'ufficio ha gia rifiutato la richiesta.",
      ],
    ),
  },
  housing_rent: {
    teaser: t(
      "Premium can review contract risks, landlord messages, and the safest next move before you send anything.",
      "Premium puo rivedere rischi del contratto, messaggi del proprietario e mossa piu sicura prima che tu invii qualcosa.",
    ),
    title: t("Premium contract check", "Controllo premium del contratto"),
    body: t(
      "Useful when the wording is unclear, the landlord is pushing, or the housing problem could get expensive fast.",
      "Utile quando il testo e ambiguo, il proprietario spinge o il problema casa rischia di diventare costoso in fretta.",
    ),
    items: t(
      [
        "Risk check before signing or replying.",
        "What to keep as proof before escalation.",
        "Clear next-step summary for deposit, repairs, or rent disputes.",
      ],
      [
        "Controllo rischi prima di firmare o rispondere.",
        "Cosa conservare come prova prima dell'escalation.",
        "Schema chiaro dei prossimi passi per cauzione, riparazioni o dispute sull'affitto.",
      ],
    ),
  },
  utilities_electricity_gas: {
    teaser: t(
      "Premium can review your bill, complaint timeline, or switch choice before you commit.",
      "Premium puo rivedere bolletta, cronologia reclamo o scelta del cambio fornitore prima che tu confermi.",
    ),
    title: t("Premium utility review", "Revisione premium utenze"),
    body: t(
      "Useful when the bill is messy, the complaint is technical, or you want a safer comparison before switching.",
      "Utile quando la bolletta e confusa, il reclamo e tecnico o vuoi un confronto piu sicuro prima del cambio.",
    ),
    items: t(
      [
        "High-bill and reading review before complaint.",
        "Switch or activation checklist before sending data.",
        "Escalation summary for supplier, distributor, or SMAT disputes.",
      ],
      [
        "Revisione bolletta alta e letture prima del reclamo.",
        "Checklist cambio fornitore o attivazione prima di inviare dati.",
        "Schema escalation per dispute con fornitore, distributore o SMAT.",
      ],
    ),
  },
  canone_rai: {
    teaser: t(
      "Premium can help you choose the right form, check the household logic, and avoid a wrong filing.",
      "Premium puo aiutarti a scegliere il modulo giusto, controllare la logica del nucleo familiare ed evitare un invio sbagliato.",
    ),
    title: t("Premium filing check", "Controllo premium dell'invio"),
    body: t(
      "Useful when several TV-fee routes look similar and a wrong declaration could create later refund work.",
      "Utile quando piu percorsi Canone TV sembrano simili e una dichiarazione sbagliata potrebbe creare poi lavoro di rimborso.",
    ),
    items: t(
      [
        "Form or quadro review before filing.",
        "Household logic check for duplicate-charge cases.",
        "Refund preparation if the wrong charge already appeared.",
      ],
      [
        "Revisione di modulo o quadro prima dell'invio.",
        "Controllo logica del nucleo nei casi di doppio addebito.",
        "Preparazione del rimborso se l'addebito errato e gia comparso.",
      ],
    ),
  },
  telecom_internet_mobile: {
    teaser: t(
      "Premium can review contract traps, portability details, and complaint files before AGCOM escalation.",
      "Premium puo rivedere trappole contrattuali, dettagli di portabilita e fascicolo reclamo prima dell'escalation AGCOM.",
    ),
    title: t("Premium telecom review", "Revisione premium telecom"),
    body: t(
      "Useful when the operator answer is vague, the contract is confusing, or you are preparing a serious dispute.",
      "Utile quando la risposta dell'operatore e vaga, il contratto e confuso o stai preparando una controversia seria.",
    ),
    items: t(
      [
        "Portability or cancellation risk review.",
        "Complaint timeline cleanup before ConciliaWeb.",
        "Bill, modem, or activation dispute checklist.",
      ],
      [
        "Revisione rischi su portabilita o disdetta.",
        "Pulizia della cronologia reclamo prima di ConciliaWeb.",
        "Checklist per bolletta, modem o disputa di attivazione.",
      ],
    ),
  },
  public_office_comune: {
    teaser: t(
      "Premium can help you choose the right office, protocol path, and supporting documents before you queue or send PEC.",
      "Premium puo aiutarti a scegliere l'ufficio giusto, il canale di protocollo e i documenti di supporto prima della fila o della PEC.",
    ),
    title: t("Premium office routing", "Instradamento premium uffici"),
    body: t(
      "Useful when the case bounces between offices or the public request needs cleaner wording and proof.",
      "Utile quando il caso rimbalza tra uffici o la richiesta pubblica ha bisogno di testo e prove piu puliti.",
    ),
    items: t(
      [
        "Office and channel check before sending.",
        "Protocol and attachment sanity check.",
        "Reply draft if the office already asked for integration.",
      ],
      [
        "Verifica ufficio e canale prima dell'invio.",
        "Controllo protocollo e allegati.",
        "Bozza risposta se l'ufficio ha gia chiesto integrazione.",
      ],
    ),
  },
  work_inps_patronato: {
    teaser: t(
      "Premium can help organize the work or INPS file before you lose time between patronato, employer, and INPS.",
      "Premium puo aiutare a ordinare il fascicolo lavoro o INPS prima che tu perda tempo tra patronato, datore e INPS.",
    ),
    title: t("Premium INPS review", "Revisione premium INPS"),
    body: t(
      "Useful when the case is blocked, documents are missing, or the employer and INPS are pushing you in circles.",
      "Utile quando il caso e bloccato, mancano documenti o datore e INPS ti rimandano l'uno all'altro.",
    ),
    items: t(
      [
        "Document checklist before patronato or INPS contact.",
        "Timeline review for blocked or rejected requests.",
        "Priority next-step summary for work, NASpI, or employer issues.",
      ],
      [
        "Checklist documenti prima del patronato o del contatto INPS.",
        "Revisione cronologia per pratiche bloccate o respinte.",
        "Schema priorita dei prossimi passi per lavoro, NASpI o problemi col datore.",
      ],
    ),
  },
  university_student: {
    teaser: t(
      "Premium can review the student route when university, EDISU, immigration, housing, and health rules overlap.",
      "Premium puo rivedere il percorso studente quando si sovrappongono universita, EDISU, immigrazione, casa e salute.",
    ),
    title: t("Premium student route review", "Revisione premium percorso studente"),
    body: t(
      "Useful when you are unsure which office comes first or one wrong move could delay enrollment, scholarship, or permit steps.",
      "Utile quando non sai quale ufficio viene prima o una mossa sbagliata puo ritardare immatricolazione, borsa o permesso.",
    ),
    items: t(
      [
        "Office-order check before contacting university or EDISU.",
        "Document and deadline sanity check.",
        "Cross-topic route review for housing, health, and immigration overlaps.",
      ],
      [
        "Verifica ordine uffici prima di contattare universita o EDISU.",
        "Controllo documenti e scadenze.",
        "Revisione del percorso quando si sovrappongono casa, salute e immigrazione.",
      ],
    ),
  },
  general: {
    teaser: t(
      "Premium can help turn a confusing admin problem into a cleaner route, message, and document pack.",
      "Premium puo trasformare un problema amministrativo confuso in un percorso, un messaggio e un fascicolo piu chiari.",
    ),
    title: t("Premium admin cleanup", "Riordino premium della pratica"),
    body: t(
      "Useful when the problem touches several offices or you need stronger wording, proof, and follow-up structure.",
      "Utile quando il problema tocca piu uffici o ti servono testo, prove e follow-up piu forti.",
    ),
    items: t(
      [
        "Problem framing before writing to the office.",
        "Attachment and proof organization.",
        "Follow-up or escalation summary when the answer is unclear.",
      ],
      [
        "Inquadramento del problema prima di scrivere all'ufficio.",
        "Organizzazione di allegati e prove.",
        "Schema di follow-up o escalation quando la risposta non e chiara.",
      ],
    ),
  },
  "bonuses-benefits": {
    teaser: t(
      "Premium can help review eligibility, missing documents, and deadlines before you waste a bonus application.",
      "Premium puo aiutare a rivedere requisiti, documenti mancanti e scadenze prima di sprecare una domanda bonus.",
    ),
    title: t("Premium eligibility review", "Revisione premium requisiti"),
    body: t(
      "Useful when several benefits look similar or the real risk is applying to the wrong one with incomplete proof.",
      "Utile quando piu benefici sembrano simili o il rischio vero e fare la domanda sbagliata con prove incomplete.",
    ),
    items: t(
      [
        "Eligibility and document check before applying.",
        "Deadline and office route review.",
        "Blocked-application summary before asking for correction.",
      ],
      [
        "Verifica requisiti e documenti prima della domanda.",
        "Controllo scadenze e percorso ufficio.",
        "Schema della pratica bloccata prima di chiedere correzione.",
      ],
    ),
  },
  "loans-credit": {
    teaser: t(
      "Premium can review credit risks, missing comparisons, and weak points before you sign or escalate.",
      "Premium puo rivedere rischi del credito, confronti mancanti e punti deboli prima che tu firmi o faccia escalation.",
    ),
    title: t("Premium credit review", "Revisione premium del credito"),
    body: t(
      "Useful when the offer is hard to compare, the rejection is unclear, or the monthly burden may be riskier than it looks.",
      "Utile quando l'offerta e difficile da confrontare, il rifiuto e poco chiaro o il peso mensile e piu rischioso di quanto sembri.",
    ),
    items: t(
      [
        "Pre-signing risk check.",
        "Offer-comparison sanity check before choosing.",
        "Document and explanation review for rejections or relief requests.",
      ],
      [
        "Controllo rischi prima della firma.",
        "Verifica del confronto offerte prima della scelta.",
        "Revisione documenti e spiegazione per rifiuti o richieste di sollievo.",
      ],
    ),
  },
};

for (const catalogPath of catalogPaths) {
  const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));

  for (const category of catalog.categories) {
    const premium = premiumByCategory[category.id];
    if (!premium) continue;
    category.hasPremiumContent = true;
    for (const subcategory of category.subcategories ?? []) {
      const procedures = subcategory.procedures ?? [];
      const alreadyPremium = subcategory.isPremiumOnly === true ||
        subcategory.hasPremiumContent === true ||
        procedures.some(
          (procedure) =>
            procedure.isPremiumOnly === true ||
            procedure.hasPremiumContent === true ||
            (procedure.sections ?? []).some(
              (section) => section.isPremiumOnly === true,
            ),
        );

      if (alreadyPremium) {
        continue;
      }

      if (procedures.length === 0) continue;
      const procedure = procedures[0];
      subcategory.hasPremiumContent = true;
      procedure.hasPremiumContent = true;
      if (
        !procedure.premiumTeaser ||
        Object.values(procedure.premiumTeaser).every(
          (value) => !String(value ?? "").trim(),
        )
      ) {
        procedure.premiumTeaser = premium.teaser;
      }

      const key = `premium_${subcategory.id}`;
      const hasPremiumSection = (procedure.sections ?? []).some(
        (section) =>
          section.isPremiumOnly === true ||
          section.key === key ||
          String(section.key ?? "").startsWith("premium_"),
      );
      if (!hasPremiumSection) {
        procedure.sections = procedure.sections ?? [];
        procedure.sections.push({
          type: "checklist",
          key,
          title: premium.title,
          body: premium.body,
          items: premium.items,
          isPremiumOnly: true,
        });
      }
    }
  }

  fs.writeFileSync(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`);
  console.log(`Applied Torino premium pass in ${catalogPath}`);
}
