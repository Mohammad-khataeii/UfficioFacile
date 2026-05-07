import '../domain/service_intelligence.dart';

class ServiceTermsDictionary {
  static const Map<String, ServiceTermExplanation> _terms = {
    'pec': ServiceTermExplanation(
      id: 'pec',
      term: 'PEC',
      shortDefinition: 'Certified email used in Italy for formal delivery.',
      longExplanation:
          'PEC stands for Posta Elettronica Certificata. It is different from normal email because it provides delivery and acceptance receipts that are commonly used for formal communications with offices, providers, and professionals in Italy. Many offices accept normal email for first contact, but some official workflows may specifically ask for PEC.',
      relatedLinks: ['https://www.agid.gov.it/'],
      providers: [
        'Aruba PEC',
        'Poste Italiane / PosteCert',
        'Legalmail',
        'Register.it PEC',
        'Namirial',
        'InfoCert',
      ],
      warnings: [
        'Verify current prices, identity checks, and terms on the provider website.',
        'Do not send sensitive data to addresses you have not verified.',
        'A PEC-style message only has formal PEC value if it is sent from a PEC account when required.',
      ],
      relatedProcedures: [
        'TESSERA_SANITARIA_RENEWAL',
        'HIGH_BILL_COMPLAINT',
        'COMUNE_RESIDENCE_REQUEST',
      ],
    ),
    'spid': ServiceTermExplanation(
      id: 'spid',
      term: 'SPID',
      shortDefinition: 'Italian digital identity for many public portals.',
      longExplanation:
          'SPID is a digital identity system used to access many Italian public administration services. Some regional health, INPS, Comune, and Agenzia Entrate portals may require it for online access.',
      relatedLinks: ['https://www.agid.gov.it/'],
      providers: [],
      warnings: ['Use only official identity-provider and portal flows.'],
    ),
    'cie': ServiceTermExplanation(
      id: 'cie',
      term: 'CIE',
      shortDefinition:
          'Electronic Italian identity card used for online access.',
      longExplanation:
          'CIE is the electronic identity card. Some online public services accept CIE login as an alternative to SPID.',
      relatedLinks: ['https://www.cartaidentita.interno.gov.it/'],
      providers: [],
      warnings: [
        'Check official instructions for device and app requirements.',
      ],
    ),
    'codice-fiscale': ServiceTermExplanation(
      id: 'codice-fiscale',
      term: 'Codice fiscale',
      shortDefinition: 'Italian tax code used to identify a person.',
      longExplanation:
          'The codice fiscale is commonly used by public offices, health services, landlords, universities, and providers to identify the person involved in the request.',
      relatedLinks: ['https://www.agenziaentrate.gov.it/'],
      providers: [],
      warnings: ['Verify all personal data before sending.'],
    ),
    'tessera-sanitaria': ServiceTermExplanation(
      id: 'tessera-sanitaria',
      term: 'Tessera sanitaria',
      shortDefinition: 'Italian health card.',
      longExplanation:
          'The tessera sanitaria is the health card used in Italy for many healthcare and identification contexts. Handling rules may vary by region and health authority.',
      relatedLinks: ['https://www.salute.gov.it/'],
      providers: [],
      warnings: ['Regional handling and portals can differ.'],
    ),
    'canone-rai': ServiceTermExplanation(
      id: 'canone-rai',
      term: 'Canone RAI',
      shortDefinition:
          'Italian public TV fee often connected to electricity billing.',
      longExplanation:
          'Canone RAI is the public television fee. Declarations, exemptions, and refunds must be checked carefully on official instructions before submitting anything.',
      relatedLinks: ['https://www.agenziaentrate.gov.it/'],
      providers: [],
      warnings: ['False declarations can have serious consequences.'],
    ),
    'voltura': ServiceTermExplanation(
      id: 'voltura',
      term: 'Voltura',
      shortDefinition:
          'Change of utility account holder without new activation.',
      longExplanation:
          'Voltura is usually used when a utility supply stays active but the contract holder changes.',
      relatedLinks: ['https://www.arera.it/'],
      providers: [],
      warnings: ['Exact provider processes and documents can vary.'],
    ),
    'subentro': ServiceTermExplanation(
      id: 'subentro',
      term: 'Subentro',
      shortDefinition: 'New activation on an inactive utility line.',
      longExplanation:
          'Subentro is commonly used when the line is inactive and a new holder needs reactivation.',
      relatedLinks: ['https://www.arera.it/'],
      providers: [],
      warnings: [
        'Verify whether your case is subentro or voltura before proceeding.',
      ],
    ),
    'disdetta': ServiceTermExplanation(
      id: 'disdetta',
      term: 'Disdetta',
      shortDefinition: 'Formal cancellation or termination notice.',
      longExplanation:
          'Disdetta is a formal cancellation notice often used for utilities, telecom, subscriptions, or some contracts.',
      relatedLinks: [],
      providers: [],
      warnings: ['Notice periods and return obligations may apply.'],
    ),
    'conguaglio': ServiceTermExplanation(
      id: 'conguaglio',
      term: 'Conguaglio',
      shortDefinition:
          'Adjustment charge based on updated readings or recalculation.',
      longExplanation:
          'A conguaglio is a bill adjustment that can happen when previous estimates are corrected or other recalculations are applied.',
      relatedLinks: ['https://www.arera.it/'],
      providers: [],
      warnings: ['Review the bill period and reading type carefully.'],
    ),
    'lettura-stimata': ServiceTermExplanation(
      id: 'lettura-stimata',
      term: 'Lettura stimata',
      shortDefinition: 'Estimated meter reading.',
      longExplanation:
          'A lettura stimata means the bill used an estimated reading instead of an actual measured value.',
      relatedLinks: ['https://www.arera.it/'],
      providers: [],
      warnings: ['A meter photo can be useful if disputing the estimate.'],
    ),
    'lettura-effettiva': ServiceTermExplanation(
      id: 'lettura-effettiva',
      term: 'Lettura effettiva',
      shortDefinition: 'Actual meter reading.',
      longExplanation:
          'A lettura effettiva means the bill was based on an actual meter reading.',
      relatedLinks: ['https://www.arera.it/'],
      providers: [],
      warnings: [],
    ),
    'residenza': ServiceTermExplanation(
      id: 'residenza',
      term: 'Residenza',
      shortDefinition: 'Official registered residence.',
      longExplanation:
          'Residenza refers to official residence registration with the Comune and can affect access to services and local procedures.',
      relatedLinks: [],
      providers: [],
      warnings: ['Comune rules can be city-specific.'],
    ),
    'anagrafe': ServiceTermExplanation(
      id: 'anagrafe',
      term: 'Anagrafe',
      shortDefinition: 'Comune registry office.',
      longExplanation:
          'Anagrafe is the municipal registry office that handles residence and certificate-related services.',
      relatedLinks: [],
      providers: [],
      warnings: ['Check the official Comune website for the correct desk.'],
    ),
    'naspi': ServiceTermExplanation(
      id: 'naspi',
      term: 'NASpI',
      shortDefinition: 'Italian unemployment benefit.',
      longExplanation:
          'NASpI is an unemployment support measure managed through official channels such as INPS and support offices where relevant.',
      relatedLinks: ['https://www.inps.it/'],
      providers: [],
      warnings: ['Eligibility and deadlines must be verified officially.'],
    ),
    'patronato': ServiceTermExplanation(
      id: 'patronato',
      term: 'Patronato',
      shortDefinition:
          'Support office that helps with social-security and paperwork matters.',
      longExplanation:
          'A patronato can help review documents and explain official procedures, especially for work, benefits, and some residence-related paperwork.',
      relatedLinks: [],
      providers: [],
      warnings: [
        'Verify the office, services offered, and appointment process.',
      ],
    ),
    'caf': ServiceTermExplanation(
      id: 'caf',
      term: 'CAF',
      shortDefinition: 'Tax and administrative assistance center.',
      longExplanation:
          'CAF offices often help with tax or document-related administrative tasks.',
      relatedLinks: [],
      providers: [],
      warnings: ['Services offered vary by office.'],
    ),
    'isee': ServiceTermExplanation(
      id: 'isee',
      term: 'ISEE',
      shortDefinition:
          'Indicator used for some social and fee-related assessments.',
      longExplanation:
          'ISEE is used in many contexts involving benefits, fees, and eligibility assessments.',
      relatedLinks: [],
      providers: [],
      warnings: ['Official requirements depend on the institution or benefit.'],
    ),
    'permesso-di-soggiorno': ServiceTermExplanation(
      id: 'permesso-di-soggiorno',
      term: 'Permesso di soggiorno',
      shortDefinition: 'Residence permit documentation.',
      longExplanation:
          'Residence permit requirements depend on the legal and administrative context involved. The app only helps organize requests and checklists.',
      relatedLinks: [],
      providers: [],
      warnings: ['This app does not provide immigration legal advice.'],
    ),
    'marca-da-bollo': ServiceTermExplanation(
      id: 'marca-da-bollo',
      term: 'Marca da bollo',
      shortDefinition: 'Stamp duty item required in some official procedures.',
      longExplanation:
          'Some procedures or forms may require a marca da bollo depending on the authority and purpose.',
      relatedLinks: [],
      providers: [],
      warnings: [
        'Verify whether it is actually required for your specific case.',
      ],
    ),
    'modello-rli': ServiceTermExplanation(
      id: 'modello-rli',
      term: 'Modello RLI',
      shortDefinition: 'Model used in some rental registration workflows.',
      longExplanation:
          'Modello RLI is commonly associated with rental registration and related steps handled through official fiscal channels.',
      relatedLinks: ['https://www.agenziaentrate.gov.it/'],
      providers: [],
      warnings: ['Verify the exact official form and current instructions.'],
    ),
    'modello-69': ServiceTermExplanation(
      id: 'modello-69',
      term: 'Modello 69',
      shortDefinition:
          'A model historically used in some registration contexts.',
      longExplanation:
          'References to Modello 69 can still appear in explanations or older workflows. Always verify the current official form and process.',
      relatedLinks: ['https://www.agenziaentrate.gov.it/'],
      providers: [],
      warnings: [
        'Check the current official procedure before relying on old references.',
      ],
    ),
    'protocollo': ServiceTermExplanation(
      id: 'protocollo',
      term: 'Protocollo',
      shortDefinition: 'Official reference number or registration record.',
      longExplanation:
          'A protocollo is often the official reference or registration number that helps identify a request, filing, or office communication.',
      relatedLinks: [],
      providers: [],
      warnings: [
        'Keep protocol numbers and previous receipts together for follow-up.',
      ],
    ),
  };

  static ServiceTermExplanation? byId(String id) => _terms[id];

  static ServiceTermExplanation? matchTerm(String value) {
    final normalized = value.trim().toLowerCase();
    return _terms[normalized];
  }

  static Iterable<ServiceTermExplanation> all() => _terms.values;

  static List<DictionaryPattern> get patterns => const [
    DictionaryPattern('PEC', 'pec'),
    DictionaryPattern('SPID', 'spid'),
    DictionaryPattern('CIE', 'cie'),
    DictionaryPattern('Codice fiscale', 'codice-fiscale'),
    DictionaryPattern('Tessera sanitaria', 'tessera-sanitaria'),
    DictionaryPattern('Canone RAI', 'canone-rai'),
    DictionaryPattern('Voltura', 'voltura'),
    DictionaryPattern('Subentro', 'subentro'),
    DictionaryPattern('Disdetta', 'disdetta'),
    DictionaryPattern('Conguaglio', 'conguaglio'),
    DictionaryPattern('Lettura stimata', 'lettura-stimata'),
    DictionaryPattern('Lettura effettiva', 'lettura-effettiva'),
    DictionaryPattern('Residenza', 'residenza'),
    DictionaryPattern('Anagrafe', 'anagrafe'),
    DictionaryPattern('NASpI', 'naspi'),
    DictionaryPattern('Patronato', 'patronato'),
    DictionaryPattern('CAF', 'caf'),
    DictionaryPattern('ISEE', 'isee'),
    DictionaryPattern('Permesso di soggiorno', 'permesso-di-soggiorno'),
    DictionaryPattern('Marca da bollo', 'marca-da-bollo'),
    DictionaryPattern('Modello RLI', 'modello-rli'),
    DictionaryPattern('Modello 69', 'modello-69'),
    DictionaryPattern('Protocollo', 'protocollo'),
  ];
}

class DictionaryPattern {
  const DictionaryPattern(this.label, this.id);

  final String label;
  final String id;
}
