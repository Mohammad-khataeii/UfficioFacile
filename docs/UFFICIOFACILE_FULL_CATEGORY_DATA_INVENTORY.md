# UfficioFacile Full Category Data Inventory

## 1. Executive Summary

- total number of categories found: 9
- total number of subcategories found: 36
- total number of procedures found: 36
- total number of providers found: 26
- total number of official links found: 9
- total number of official contacts found: 2
- total number of verified items: 51
- total number of needsReview items: 92
- total number of unverified items: 2
- biggest missing data areas: exact ASL contacts, provider complaint/disdetta forms, Comune appointment/office finders, university office links, official PEC/email/address/phone coverage.

## 2. Category Map

- Canone RAI
  - category ID/name: canoneRai / Canone RAI
  - subcategories: No-TV declaration, Over-75 exemption, Refund / wrong charge
  - procedure IDs: CANONE_RAI_NO_TV_DECLARATION_CHECKLIST, CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST, CANONE_RAI_REFUND_OR_WRONG_CHARGE
  - current maturity score: Generic
  - notes: Official forms and deadline-specific submission data remain incomplete.
- General
  - category ID/name: general / General
  - subcategories: Rejected request, Refund / complaint, Appointment, Generic formal
  - procedure IDs: REJECTED_REQUEST_REPLY, REFUND_OR_COMPLAINT_REQUEST, APPOINTMENT_REQUEST, GENERIC_FORMAL_REQUEST
  - current maturity score: Generic
  - notes: Operational contact and form details are still generic in several flows.
- Health
  - category ID/name: health / Health
  - subcategories: Change doctor, Health card, Rejected ASL request, ASL appointment
  - procedure IDs: CHANGE_DOCTOR, TESSERA_SANITARIA_RENEWAL, ASL_REJECTED_REQUEST_REPLY, ASL_APPOINTMENT_REQUEST
  - current maturity score: Missing real data
  - notes: Exact ASL email/PEC/office finder coverage is still sparse.
- Housing
  - category ID/name: housing / Housing
  - subcategories: Contract change, Maintenance & contract, Deposit return, Contract termination
  - procedure IDs: RENTAL_CONTRACT_CHANGE, LANDLORD_MAINTENANCE_OR_CONTRACT, DEPOSIT_RETURN_REQUEST, RENT_CONTRACT_TERMINATION_NOTICE
  - current maturity score: Generic
  - notes: No exact landlord/agency PEC, address, or raccomandata targets are stored.
- Public office
  - category ID/name: publicOffice / Public office
  - subcategories: Residence, Certificate request
  - procedure IDs: COMUNE_RESIDENCE_REQUEST, ANAGRAFE_CERTIFICATE_REQUEST
  - current maturity score: Missing real data
  - notes: Comune appointment links, PEC, and office-finder coverage are incomplete.
- Telecom
  - category ID/name: telecom / Telecom
  - subcategories: Cancellation, Wrong bill, Service issue, Modem dispute
  - procedure IDs: INTERNET_PHONE_CANCELLATION, TELECOM_WRONG_BILL_COMPLAINT, SERVICE_NOT_WORKING_COMPLAINT, MODEM_RETURN_OR_CHARGE_DISPUTE
  - current maturity score: Missing real data
  - notes: Provider cancellation and complaint contacts remain mostly unverified placeholders.
- University
  - category ID/name: university / University
  - subcategories: University office, Permesso support
  - procedure IDs: UNIVERSITY_OFFICE_REQUEST, PERMESSO_DOCUMENT_CHECKLIST
  - current maturity score: Generic
  - notes: University-specific office links and helpdesk contacts are largely absent.
- Utilities
  - category ID/name: utilities / Utilities
  - subcategories: Bill understanding, Offer comparison, Provider switching, Voltura, Subentro, Disdetta, High bill complaint, Reading correction, Payment plan, Wrong charge refund, Contract change complaint
  - procedure IDs: ENERGY_BILL_ANALYZER_CHECKLIST, ENERGY_SUPPLIER_COMPARISON, ELECTRICITY_GAS_SWITCH_REQUEST, VOLTURA_REQUEST, SUBENTRO_REQUEST, UTILITY_CANCELLATION_DISDETTA, HIGH_BILL_COMPLAINT, METER_READING_CORRECTION, PAYMENT_PLAN_REQUEST, WRONG_CHARGE_REFUND_REQUEST, UNILATERAL_CONTRACT_CHANGE_COMPLAINT
  - current maturity score: Missing real data
  - notes: Provider-specific forms, PEC, and complaint channels are mostly missing.
- Work
  - category ID/name: work / Work
  - subcategories: NASpI, Patronato appointment
  - procedure IDs: NASPI_PREPARATION, PATRONATO_APPOINTMENT_REQUEST
  - current maturity score: Generic
  - notes: INPS/Patronato office-level contacts and forms are limited.

## 3. Full Procedure Inventory

### Procedure: CHANGE_DOCTOR

Basic:
- Title: Change Doctor / Medico di Base Request
- Category: Health
- Subcategory: Change doctor
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: medico, ASL, tessera sanitaria, health
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Health and ASL support workflow.
- Long description: Change Doctor / Medico di Base Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| addressOrDomicile | Address | text | true |  |  |  |
| aslOrOfficeName | ASL or office | text | true |  |  |  |
| requestedDoctor | Requested doctor | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| cannotGoInPerson | Cannot go in person | boolean | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Documento d’identità | Required | Documento d’identità | suggested attachment |
| Codice fiscale / tessera sanitaria | Required | Codice fiscale / tessera sanitaria | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.
- Responsible authority: ASL / regional health authority
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Regional health service portal","description":"Some regions allow online requests or appointment handling through regional portals.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"ASL / district office in person","description":"If you prefer to go in person, check the official ASL or district office for your address.","address":null,"officeFinderLink":"","documentsToBring":["ID","Codice fiscale","Tessera sanitaria if available","Previous receipt or protocol if available"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"CHANGE_DOCTOR_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CHANGE_DOCTOR_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CHANGE_DOCTOR_req_Health card if available","name":"Health card if available","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Health card if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"CHANGE_DOCTOR_rec_Previous correspondence","name":"Previous correspondence","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous correspondence"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CHANGE_DOCTOR_rec_Protocol or rejection notice if relevant","name":"Protocol or rejection notice if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Protocol or rejection notice if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"CHANGE_DOCTOR_cond_Work/study documents if the office requested them","name":"Work/study documents if the office requested them","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Work/study documents if the office requested them"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer after several working days, use the follow-up message and include any protocol or previous request reference.
- Rejection guidance: If the office rejects the request for missing documents, open the rejected request reply flow and attach the missing items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: If your city or region has a dedicated health portal, use that official portal or office-finder first.
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: Piemonte, Lombardia, Lazio
- City-specific guidance found: 
- Region-specific guidance found: Piemonte, Lombardia, Lazio

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Change doctor official ASL contact Change Doctor / Medico di Base Request | Change doctor PEC ASL official site | Change doctor region portal official

### Procedure: TESSERA_SANITARIA_RENEWAL

Basic:
- Title: Tessera Sanitaria Renewal / Health Card Problem
- Category: Health
- Subcategory: Health card
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: medico, ASL, tessera sanitaria, health
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Health and ASL support workflow.
- Long description: Tessera Sanitaria Renewal / Health Card Problem helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the exact ASL office or portal for your residence. | Verify the contact or office finder on the official regional/ASL site. | Keep any protocol or previous request receipt.
- User-facing guidance currently shown: This request is usually handled by your local ASL or the regional health authority. The correct email, PEC, portal, or desk depends on your region and city.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| cardExpiryDate | Card expiry date | date | true |  |  |  |
| cityOrAsl | City or ASL | text | true |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| canGoInPerson | Can go in person | boolean | true |  |  |  |
| urgencyReason | Urgency reason | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Documento d’identità | Required | Documento d’identità | suggested attachment |
| Tessera sanitaria | Recommended | Tessera sanitaria | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: This request is usually handled by your local ASL or the regional health authority. The correct email, PEC, portal, or desk depends on your region and city.
- Responsible authority: ASL / regional health authority
- Submission channels: online-portal, in-person, normal-email, pec
- Online options: [{"title":"Regional health portal","description":"This request may be available through regional health portals such as Salute Piemonte, Fascicolo Sanitario, or ASL online services depending on region.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"ASL / district office in person","description":"If you prefer to go in person, check the official ASL or district office for your address.","address":null,"officeFinderLink":"","documentsToBring":["ID","Codice fiscale","Tessera sanitaria if available","Previous receipt or protocol if available"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"TESSERA_SANITARIA_RENEWAL_req_ID or passport","name":"ID or passport","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID or passport"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"TESSERA_SANITARIA_RENEWAL_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"TESSERA_SANITARIA_RENEWAL_req_Tessera sanitaria if available","name":"Tessera sanitaria if available","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Tessera sanitaria if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"TESSERA_SANITARIA_RENEWAL_rec_Any previous ASL receipt","name":"Any previous ASL receipt","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Any previous ASL receipt"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"TESSERA_SANITARIA_RENEWAL_rec_Residence or domicile details","name":"Residence or domicile details","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Residence or domicile details"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"TESSERA_SANITARIA_RENEWAL_cond_Permesso or stay documentation if requested locally","name":"Permesso or stay documentation if requested locally","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Permesso or stay documentation if requested locally"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the exact ASL office or portal for your residence. | Verify the contact or office finder on the official regional/ASL site. | Keep any protocol or previous request receipt.
- Follow-up guidance: If there is no answer after several working days, use the follow-up message and include any protocol or previous request reference.
- Rejection guidance: If the office rejects the request for missing documents, open the rejected request reply flow and attach the missing items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: If your city or region has a dedicated health portal, use that official portal or office-finder first.
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Salute Piemonte | https://www.salutepiemonte.it/ | https://www.salutepiemonte.it/ | verified | 2026-05-06T00:00:00.000 | {} |
| Salute Piemonte - Fascicolo Sanitario Elettronico FAQ | https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico | https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico | verified | 2026-05-06T00:00:00.000 | {} |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Local ASL contact finder | officeFinder | Verify the correct ASL office through your region or city health portal. |  |  | needsReview |  |  |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: Piemonte, Lombardia, Lazio
- City-specific guidance found: 
- Region-specific guidance found: Piemonte, Lombardia, Lazio

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: 
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: 
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- Medium

Research notes:
- Exact things a researcher should search for: Health card official ASL contact Tessera Sanitaria Renewal / Health Card Problem | Health card PEC ASL official site | Health card region portal official

### Procedure: ASL_REJECTED_REQUEST_REPLY

Basic:
- Title: ASL Rejected Request Reply
- Category: Health
- Subcategory: Rejected ASL request
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: medico, ASL, tessera sanitaria, health
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Health and ASL support workflow.
- Long description: ASL Rejected Request Reply helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| officeName | Office name | text | true |  |  |  |
| originalRequestTopic | Original request topic | text | true |  |  |  |
| originalRequestDate | Original request date | date | true |  |  |  |
| rejectionDate | Rejection date | date | true |  |  |  |
| rejectionReason | Rejection reason | textarea | true |  |  |  |
| missingDocumentNowAttached | Missing document now attached | textarea | false |  |  |  |
| desiredOutcome | Desired outcome | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Notice or rejection letter | Required | Notice or rejection letter | suggested attachment |
| Supporting document | Required | Supporting document | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.
- Responsible authority: ASL / regional health authority
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Regional health service portal","description":"Some regions allow online requests or appointment handling through regional portals.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"ASL / district office in person","description":"If you prefer to go in person, check the official ASL or district office for your address.","address":null,"officeFinderLink":"","documentsToBring":["ID","Codice fiscale","Tessera sanitaria if available","Previous receipt or protocol if available"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"ASL_REJECTED_REQUEST_REPLY_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_REJECTED_REQUEST_REPLY_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_REJECTED_REQUEST_REPLY_req_Health card if available","name":"Health card if available","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Health card if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ASL_REJECTED_REQUEST_REPLY_rec_Previous correspondence","name":"Previous correspondence","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous correspondence"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_REJECTED_REQUEST_REPLY_rec_Protocol or rejection notice if relevant","name":"Protocol or rejection notice if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Protocol or rejection notice if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ASL_REJECTED_REQUEST_REPLY_cond_Work/study documents if the office requested them","name":"Work/study documents if the office requested them","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Work/study documents if the office requested them"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer after several working days, use the follow-up message and include any protocol or previous request reference.
- Rejection guidance: If the office rejects the request for missing documents, open the rejected request reply flow and attach the missing items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: If your city or region has a dedicated health portal, use that official portal or office-finder first.
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Rejected ASL request official ASL contact ASL Rejected Request Reply | Rejected ASL request PEC ASL official site | Rejected ASL request region portal official

### Procedure: ASL_APPOINTMENT_REQUEST

Basic:
- Title: ASL Appointment Request
- Category: Health
- Subcategory: ASL appointment
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: medico, ASL, tessera sanitaria, health
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Health and ASL support workflow.
- Long description: ASL Appointment Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| recipient | Recipient | text | true |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| preferredDatesOrTimes | Preferred dates or times | textarea | false |  |  |  |
| urgency | Urgency | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: This is usually handled by the ASL, distretto sanitario, or regional health service for your area.
- Responsible authority: ASL / regional health authority
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Regional health service portal","description":"Some regions allow online requests or appointment handling through regional portals.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"ASL / district office in person","description":"If you prefer to go in person, check the official ASL or district office for your address.","address":null,"officeFinderLink":"","documentsToBring":["ID","Codice fiscale","Tessera sanitaria if available","Previous receipt or protocol if available"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"ASL_APPOINTMENT_REQUEST_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_APPOINTMENT_REQUEST_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_APPOINTMENT_REQUEST_req_Health card if available","name":"Health card if available","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Health card if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ASL_APPOINTMENT_REQUEST_rec_Previous correspondence","name":"Previous correspondence","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous correspondence"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ASL_APPOINTMENT_REQUEST_rec_Protocol or rejection notice if relevant","name":"Protocol or rejection notice if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Protocol or rejection notice if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ASL_APPOINTMENT_REQUEST_cond_Work/study documents if the office requested them","name":"Work/study documents if the office requested them","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Work/study documents if the office requested them"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer after several working days, use the follow-up message and include any protocol or previous request reference.
- Rejection guidance: If the office rejects the request for missing documents, open the rejected request reply flow and attach the missing items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: If your city or region has a dedicated health portal, use that official portal or office-finder first.
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: Piemonte
- City-specific guidance found: 
- Region-specific guidance found: Piemonte

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: ASL appointment official ASL contact ASL Appointment Request | ASL appointment PEC ASL official site | ASL appointment region portal official

### Procedure: RENTAL_CONTRACT_CHANGE

Basic:
- Title: Rental Contract Add Tenant / Subentro / Cessione / Integrazione
- Category: Housing
- Subcategory: Contract change
- Difficulty: High
- Estimated time: 9 minutes
- Free/Pro: Free
- Tags: affitto, landlord, subentro, deposit, housing
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Housing and rent administration workflow.
- Long description: Rental Contract Add Tenant / Subentro / Cessione / Integrazione helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| tenantName | Tenant name | text | true |  |  |  |
| landlordOrAgencyName | Landlord or agency | text | true |  |  |  |
| propertyAddress | Property address | text | true |  |  |  |
| requestType | Request type | text | true |  |  |  |
| effectiveDate | Effective date | date | true |  |  |  |
| allPartiesAgree | All parties agree | boolean | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Lease copy | Required | Lease copy | suggested attachment |
| ID documents | Required | ID documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.
- Responsible authority: Landlord / agency / Agenzia Entrate
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Agenzia Entrate information pages","description":"Check official registration guidance if the contract change requires fiscal/registration follow-up.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Meeting with landlord or agency","description":"For contract updates, handover, or deposit issues, an in-person meeting may be useful after formal written notice.","address":null,"officeFinderLink":null,"documentsToBring":["Rental contract","ID","Previous emails/messages","Photos or proof if the issue is about damage or maintenance"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"RENTAL_CONTRACT_CHANGE_req_Rental contract","name":"Rental contract","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Rental contract"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"RENTAL_CONTRACT_CHANGE_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"RENTAL_CONTRACT_CHANGE_rec_Previous communications","name":"Previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"RENTAL_CONTRACT_CHANGE_rec_Proof of payment or deposit where relevant","name":"Proof of payment or deposit where relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Proof of payment or deposit where relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"RENTAL_CONTRACT_CHANGE_cond_Photos, invoices, witness note, or handover evidence depending on the issue","name":"Photos, invoices, witness note, or handover evidence depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Photos, invoices, witness note, or handover evidence depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If no answer arrives, send a polite follow-up and keep proof of sending.
- Rejection guidance: If the landlord or agency refuses, keep all written proof and prepare a stronger follow-up or complaint pack.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: If an agency manages the property, verify whether communications should go first to the agency instead of the owner.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Contract change raccomandata A/R Italy official guidance | Contract change Agenzia Entrate contract official | Contract change landlord PEC contract notice Italy

### Procedure: LANDLORD_MAINTENANCE_OR_CONTRACT

Basic:
- Title: Landlord Maintenance / Contract Problem Letter
- Category: Housing
- Subcategory: Maintenance & contract
- Difficulty: High
- Estimated time: 9 minutes
- Free/Pro: Free
- Tags: affitto, landlord, subentro, deposit, housing
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Housing and rent administration workflow.
- Long description: Landlord Maintenance / Contract Problem Letter helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Describe the issue clearly and truthfully. | Do not make legal claims you cannot support. | Keep photos, messages, and contract proof together. | For urgent safety issues, consider competent authority or professional support.
- User-facing guidance currently shown: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| tenantName | Tenant name | text | true |  |  |  |
| landlordOrAgencyName | Landlord or agency | text | true |  |  |  |
| propertyAddress | Property address | text | true |  |  |  |
| issueType | Issue type | text | true |  |  |  |
| description | Description | textarea | true |  |  |  |
| dateDiscovered | Date discovered | date | true |  |  |  |
| desiredAction | Desired action | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Photos or evidence | Required | Photos or evidence | suggested attachment |
| Lease copy | Recommended | Lease copy | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.
- Responsible authority: Landlord / agency / Agenzia Entrate
- Submission channels: whatsapp, normal-email, pec, raccomandata-ar, in-person
- Online options: [{"title":"Agenzia Entrate information pages","description":"Check official registration guidance if the contract change requires fiscal/registration follow-up.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Meeting with landlord or agency","description":"For contract updates, handover, or deposit issues, an in-person meeting may be useful after formal written notice.","address":null,"officeFinderLink":null,"documentsToBring":["Rental contract","ID","Previous emails/messages","Photos or proof if the issue is about damage or maintenance"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"LANDLORD_MAINTENANCE_OR_CONTRACT_req_Rental contract","name":"Rental contract","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Rental contract"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"LANDLORD_MAINTENANCE_OR_CONTRACT_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"LANDLORD_MAINTENANCE_OR_CONTRACT_rec_Previous communications","name":"Previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"LANDLORD_MAINTENANCE_OR_CONTRACT_rec_Proof of payment or deposit where relevant","name":"Proof of payment or deposit where relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Proof of payment or deposit where relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"LANDLORD_MAINTENANCE_OR_CONTRACT_cond_Photos, invoices, witness note, or handover evidence depending on the issue","name":"Photos, invoices, witness note, or handover evidence depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Photos, invoices, witness note, or handover evidence depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Describe the issue clearly and truthfully. | Do not make legal claims you cannot support. | Keep photos, messages, and contract proof together. | For urgent safety issues, consider competent authority or professional support.
- Follow-up guidance: If no answer arrives, send a polite follow-up and keep proof of sending.
- Rejection guidance: If the landlord or agency refuses, keep all written proof and prepare a stronger follow-up or complaint pack.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: If an agency manages the property, verify whether communications should go first to the agency instead of the owner.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Agenzia Entrate | https://www.agenziaentrate.gov.it/portale/ | https://www.agenziaentrate.gov.it/portale/ | verified | 2026-05-06T00:00:00.000 | {} |
| Poste Italiane - Posta Raccomandata | https://www.poste.it/posta-raccomandata | https://www.poste.it/posta-raccomandata | verified | 2026-05-06T00:00:00.000 | {} |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |
| Rental and contract obligations | civilCodeReference |  | needsReview | {"en":"Useful for maintenance, deposit return, and formal notice wording.","it":"Utile per manutenzione, restituzione deposito e formulazione di solleciti formali."} | {"en":"This is practical guidance only and not legal advice.","it":"Questa è solo guida pratica e non consulenza legale.","es":"Esta es solo una guía práctica y no asesoramiento legal.","fa":"این فقط راهنمای عملی است و مشاوره حقوقی نیست.","ar":"هذه إرشادات عملية فقط وليست استشارة قانونية."} |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: 
- Missing legal/authority reference: 
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- Medium

Research notes:
- Exact things a researcher should search for: Maintenance & contract raccomandata A/R Italy official guidance | Maintenance & contract Agenzia Entrate contract official | Maintenance & contract landlord PEC contract notice Italy

### Procedure: DEPOSIT_RETURN_REQUEST

Basic:
- Title: Deposit Return Request
- Category: Housing
- Subcategory: Deposit return
- Difficulty: High
- Estimated time: 9 minutes
- Free/Pro: Free
- Tags: affitto, landlord, subentro, deposit, housing
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Housing and rent administration workflow.
- Long description: Deposit Return Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| tenantName | Tenant name | text | true |  |  |  |
| landlordOrAgencyName | Landlord or agency | text | true |  |  |  |
| propertyAddress | Property address | text | true |  |  |  |
| issueType | Issue type | text | true |  |  |  |
| description | Description | textarea | true |  |  |  |
| dateDiscovered | Date discovered | date | true |  |  |  |
| desiredAction | Desired action | textarea | true |  |  |  |
| depositAmount | Deposit amount | number | false |  |  |  |
| moveOutDate | Move-out date | date | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Lease copy | Required | Lease copy | suggested attachment |
| Move-out proof | Recommended | Move-out proof | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.
- Responsible authority: Landlord / agency / Agenzia Entrate
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Agenzia Entrate information pages","description":"Check official registration guidance if the contract change requires fiscal/registration follow-up.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Meeting with landlord or agency","description":"For contract updates, handover, or deposit issues, an in-person meeting may be useful after formal written notice.","address":null,"officeFinderLink":null,"documentsToBring":["Rental contract","ID","Previous emails/messages","Photos or proof if the issue is about damage or maintenance"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"DEPOSIT_RETURN_REQUEST_req_Rental contract","name":"Rental contract","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Rental contract"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"DEPOSIT_RETURN_REQUEST_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"DEPOSIT_RETURN_REQUEST_rec_Previous communications","name":"Previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"DEPOSIT_RETURN_REQUEST_rec_Proof of payment or deposit where relevant","name":"Proof of payment or deposit where relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Proof of payment or deposit where relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"DEPOSIT_RETURN_REQUEST_cond_Photos, invoices, witness note, or handover evidence depending on the issue","name":"Photos, invoices, witness note, or handover evidence depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Photos, invoices, witness note, or handover evidence depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If no answer arrives, send a polite follow-up and keep proof of sending.
- Rejection guidance: If the landlord or agency refuses, keep all written proof and prepare a stronger follow-up or complaint pack.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: If an agency manages the property, verify whether communications should go first to the agency instead of the owner.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Deposit return raccomandata A/R Italy official guidance | Deposit return Agenzia Entrate contract official | Deposit return landlord PEC contract notice Italy

### Procedure: RENT_CONTRACT_TERMINATION_NOTICE

Basic:
- Title: Rent Contract Termination Notice
- Category: Housing
- Subcategory: Contract termination
- Difficulty: High
- Estimated time: 9 minutes
- Free/Pro: Free
- Tags: affitto, landlord, subentro, deposit, housing
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Housing and rent administration workflow.
- Long description: Rent Contract Termination Notice helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| tenantName | Tenant name | text | true |  |  |  |
| landlordOrAgencyName | Landlord or agency | text | true |  |  |  |
| propertyAddress | Property address | text | true |  |  |  |
| terminationDate | Termination date | date | true |  |  |  |
| noticeReason | Notice reason | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Lease copy | Required | Lease copy | suggested attachment |
| ID documents | Required | ID documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.
- Responsible authority: Landlord / agency / Agenzia Entrate
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Agenzia Entrate information pages","description":"Check official registration guidance if the contract change requires fiscal/registration follow-up.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Meeting with landlord or agency","description":"For contract updates, handover, or deposit issues, an in-person meeting may be useful after formal written notice.","address":null,"officeFinderLink":null,"documentsToBring":["Rental contract","ID","Previous emails/messages","Photos or proof if the issue is about damage or maintenance"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"RENT_CONTRACT_TERMINATION_NOTICE_req_Rental contract","name":"Rental contract","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Rental contract"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"RENT_CONTRACT_TERMINATION_NOTICE_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"RENT_CONTRACT_TERMINATION_NOTICE_rec_Previous communications","name":"Previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"RENT_CONTRACT_TERMINATION_NOTICE_rec_Proof of payment or deposit where relevant","name":"Proof of payment or deposit where relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Proof of payment or deposit where relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"RENT_CONTRACT_TERMINATION_NOTICE_cond_Photos, invoices, witness note, or handover evidence depending on the issue","name":"Photos, invoices, witness note, or handover evidence depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Photos, invoices, witness note, or handover evidence depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If no answer arrives, send a polite follow-up and keep proof of sending.
- Rejection guidance: If the landlord or agency refuses, keep all written proof and prepare a stronger follow-up or complaint pack.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: If an agency manages the property, verify whether communications should go first to the agency instead of the owner.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Contract termination raccomandata A/R Italy official guidance | Contract termination Agenzia Entrate contract official | Contract termination landlord PEC contract notice Italy

### Procedure: ENERGY_BILL_ANALYZER_CHECKLIST

Basic:
- Title: Energy Bill Analyzer Checklist
- Category: Utilities
- Subcategory: Bill understanding
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Energy Bill Analyzer Checklist helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| providerName | Provider name | text | true |  |  |  |
| billPeriod | Bill period | text | true |  |  |  |
| amount | Amount | number | true |  |  |  |
| billType | Bill type | select | true | Electricity, Gas, Water, Internet |  |  |
| readingType | Reading type | text | false |  |  |  |
| consumption | Consumption | number | false |  |  |  |
| hasConguaglio | Conguaglio present | boolean | false |  |  |  |
| hasCanoneRai | Canone RAI present | boolean | false |  |  |  |
| amountSeemsAbnormal | Amount seems abnormal | boolean | false |  |  |  |
| previousBillAmount | Previous bill amount | number | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"ENERGY_BILL_ANALYZER_CHECKLIST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ENERGY_BILL_ANALYZER_CHECKLIST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ENERGY_BILL_ANALYZER_CHECKLIST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ENERGY_BILL_ANALYZER_CHECKLIST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ENERGY_BILL_ANALYZER_CHECKLIST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Bill understanding provider official complaint form Italy | Bill understanding ARERA Portale Offerte official | Bill understanding provider PEC reclami official

### Procedure: ENERGY_SUPPLIER_COMPARISON

Basic:
- Title: Energy Supplier Comparison
- Category: Utilities
- Subcategory: Offer comparison
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Pro
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Energy Supplier Comparison helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| currentProvider | Current provider | text | true |  |  |  |
| currentAnnualCost | Current annual cost | number | false |  |  |  |
| currentMonthlyCost | Current monthly cost | number | false |  |  |  |
| currentConsumptionKwh | Current kWh consumption | number | false |  |  |  |
| currentGasSmc | Current gas Smc | number | false |  |  |  |
| residentDomestic | Resident domestic | boolean | false |  |  |  |
| hasCanoneRaiCharge | Canone RAI charge | boolean | false |  |  |  |
| offerAProvider | Offer A provider | text | true |  |  |  |
| offerAName | Offer A name | text | true |  |  |  |
| offerAEstimatedAnnualCost | Offer A estimated annual cost | number | false |  |  |  |
| offerBProvider | Offer B provider | text | true |  |  |  |
| offerBName | Offer B name | text | true |  |  |  |
| offerBEstimatedAnnualCost | Offer B estimated annual cost | number | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"ENERGY_SUPPLIER_COMPARISON_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ENERGY_SUPPLIER_COMPARISON_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ENERGY_SUPPLIER_COMPARISON_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ENERGY_SUPPLIER_COMPARISON_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ENERGY_SUPPLIER_COMPARISON_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Offer comparison provider official complaint form Italy | Offer comparison ARERA Portale Offerte official | Offer comparison provider PEC reclami official

### Procedure: ELECTRICITY_GAS_SWITCH_REQUEST

Basic:
- Title: Electricity / Gas Switch Request
- Category: Utilities
- Subcategory: Provider switching
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Electricity / Gas Switch Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Contract holder | text | true |  |  |  |
| provider | Provider | text | true |  |  |  |
| supplyAddress | Supply address | text | true |  |  |  |
| podOrPdr | POD / PDR | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Contract or bill copy | Required | Contract or bill copy | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"ELECTRICITY_GAS_SWITCH_REQUEST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ELECTRICITY_GAS_SWITCH_REQUEST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ELECTRICITY_GAS_SWITCH_REQUEST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"ELECTRICITY_GAS_SWITCH_REQUEST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ELECTRICITY_GAS_SWITCH_REQUEST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Provider switching provider official complaint form Italy | Provider switching ARERA Portale Offerte official | Provider switching provider PEC reclami official

### Procedure: VOLTURA_REQUEST

Basic:
- Title: Voltura Request
- Category: Utilities
- Subcategory: Voltura
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Voltura Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Contract holder | text | true |  |  |  |
| provider | Provider | text | true |  |  |  |
| supplyAddress | Supply address | text | true |  |  |  |
| podOrPdr | POD / PDR | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Contract or bill copy | Required | Contract or bill copy | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"VOLTURA_REQUEST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"VOLTURA_REQUEST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"VOLTURA_REQUEST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"VOLTURA_REQUEST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"VOLTURA_REQUEST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Voltura provider official complaint form Italy | Voltura ARERA Portale Offerte official | Voltura provider PEC reclami official

### Procedure: SUBENTRO_REQUEST

Basic:
- Title: Subentro Request
- Category: Utilities
- Subcategory: Subentro
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Subentro Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Contract holder | text | true |  |  |  |
| provider | Provider | text | true |  |  |  |
| supplyAddress | Supply address | text | true |  |  |  |
| podOrPdr | POD / PDR | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Contract or bill copy | Required | Contract or bill copy | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"SUBENTRO_REQUEST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"SUBENTRO_REQUEST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"SUBENTRO_REQUEST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"SUBENTRO_REQUEST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"SUBENTRO_REQUEST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Subentro provider official complaint form Italy | Subentro ARERA Portale Offerte official | Subentro provider PEC reclami official

### Procedure: UTILITY_CANCELLATION_DISDETTA

Basic:
- Title: Utility Cancellation / Disdetta
- Category: Utilities
- Subcategory: Disdetta
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Utility Cancellation / Disdetta helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Contract holder | text | true |  |  |  |
| provider | Provider | text | true |  |  |  |
| supplyAddress | Supply address | text | true |  |  |  |
| podOrPdr | POD / PDR | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| contractNumber | Contract number | text | false |  |  |  |
| cancellationDate | Cancellation date | date | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Contract or bill copy | Required | Contract or bill copy | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"UTILITY_CANCELLATION_DISDETTA_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"UTILITY_CANCELLATION_DISDETTA_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"UTILITY_CANCELLATION_DISDETTA_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"UTILITY_CANCELLATION_DISDETTA_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"UTILITY_CANCELLATION_DISDETTA_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Disdetta provider official complaint form Italy | Disdetta ARERA Portale Offerte official | Disdetta provider PEC reclami official

### Procedure: HIGH_BILL_COMPLAINT

Basic:
- Title: High Bill Complaint
- Category: Utilities
- Subcategory: High bill complaint
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Pro
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: High Bill Complaint helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: yes, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Check whether the bill uses estimated or actual readings. | Check whether the amount includes conguaglio. | Keep photos of the meter and the bill pages you contest.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| providerName | Provider name | text | true |  |  |  |
| billPeriod | Bill period | text | true |  |  |  |
| amount | Amount | number | true |  |  |  |
| billType | Bill type | select | true | Electricity, Gas, Water, Internet |  |  |
| readingType | Reading type | text | false |  |  |  |
| consumption | Consumption | number | false |  |  |  |
| hasConguaglio | Conguaglio present | boolean | false |  |  |  |
| hasCanoneRai | Canone RAI present | boolean | false |  |  |  |
| amountSeemsAbnormal | Amount seems abnormal | boolean | false |  |  |  |
| previousBillAmount | Previous bill amount | number | false |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: yes
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: online-portal, normal-email, pec, raccomandata-ar
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"HIGH_BILL_COMPLAINT_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"HIGH_BILL_COMPLAINT_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"HIGH_BILL_COMPLAINT_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"HIGH_BILL_COMPLAINT_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"HIGH_BILL_COMPLAINT_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Check whether the bill uses estimated or actual readings. | Check whether the amount includes conguaglio. | Keep photos of the meter and the bill pages you contest.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Portale Offerte luce e gas | https://www.ilportaleofferte.it/ | https://www.ilportaleofferte.it/ | verified | 2026-05-06T00:00:00.000 | {} |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Provider official customer area or complaints channel | customerArea | Check the official provider website, contract, or customer area for the correct cancellation or complaint channel. |  |  | needsReview |  |  |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |
| ARERA / Portale Offerte | energyAuthorityGuidance | https://www.ilportaleofferte.it/ | verified | {"en":"Relevant for high bill checks, offer comparison, and consumer orientation.","it":"Rilevante per controlli su bollette alte, confronto offerte e orientamento consumatori."} | {"en":"This is practical guidance only and not legal advice.","it":"Questa è solo guida pratica e non consulenza legale.","es":"Esta es solo una guía práctica y no asesoramiento legal.","fa":"این فقط راهنمای عملی است و مشاوره حقوقی نیست.","ar":"هذه إرشادات عملية فقط وليست استشارة قانونية."} |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: Enel Energia, Servizio Elettrico Nazionale, Plenitude / Eni, Edison, A2A Energia, Hera Comm, Iren, Sorgenia, NeN, Octopus Energy, Engie, Wekiwi, Acea Energia, Dolomiti Energia, Other provider
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: 
- Missing legal/authority reference: 
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- Medium

Research notes:
- Exact things a researcher should search for: High bill complaint provider official complaint form Italy | High bill complaint ARERA Portale Offerte official | High bill complaint provider PEC reclami official

### Procedure: METER_READING_CORRECTION

Basic:
- Title: Meter Reading Correction
- Category: Utilities
- Subcategory: Reading correction
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Meter Reading Correction helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Contract holder | text | true |  |  |  |
| provider | Provider | text | true |  |  |  |
| supplyAddress | Supply address | text | true |  |  |  |
| podOrPdr | POD / PDR | text | false |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| meterReadingValue | Correct meter reading | number | false |  |  |  |
| invoiceNumber | Invoice number | text | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"METER_READING_CORRECTION_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"METER_READING_CORRECTION_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"METER_READING_CORRECTION_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"METER_READING_CORRECTION_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"METER_READING_CORRECTION_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Reading correction provider official complaint form Italy | Reading correction ARERA Portale Offerte official | Reading correction provider PEC reclami official

### Procedure: PAYMENT_PLAN_REQUEST

Basic:
- Title: Payment Plan Request
- Category: Utilities
- Subcategory: Payment plan
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Payment Plan Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| providerName | Provider name | text | true |  |  |  |
| billPeriod | Bill period | text | true |  |  |  |
| amount | Amount | number | true |  |  |  |
| billType | Bill type | select | true | Electricity, Gas, Water, Internet |  |  |
| readingType | Reading type | text | false |  |  |  |
| consumption | Consumption | number | false |  |  |  |
| hasConguaglio | Conguaglio present | boolean | false |  |  |  |
| hasCanoneRai | Canone RAI present | boolean | false |  |  |  |
| amountSeemsAbnormal | Amount seems abnormal | boolean | false |  |  |  |
| previousBillAmount | Previous bill amount | number | false |  |  |  |
| urgencyReason | Reason for payment plan | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"PAYMENT_PLAN_REQUEST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"PAYMENT_PLAN_REQUEST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"PAYMENT_PLAN_REQUEST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"PAYMENT_PLAN_REQUEST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"PAYMENT_PLAN_REQUEST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Payment plan provider official complaint form Italy | Payment plan ARERA Portale Offerte official | Payment plan provider PEC reclami official

### Procedure: WRONG_CHARGE_REFUND_REQUEST

Basic:
- Title: Wrong Charge Refund Request
- Category: Utilities
- Subcategory: Wrong charge refund
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Wrong Charge Refund Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| providerName | Provider name | text | true |  |  |  |
| billPeriod | Bill period | text | true |  |  |  |
| amount | Amount | number | true |  |  |  |
| billType | Bill type | select | true | Electricity, Gas, Water, Internet |  |  |
| readingType | Reading type | text | false |  |  |  |
| consumption | Consumption | number | false |  |  |  |
| hasConguaglio | Conguaglio present | boolean | false |  |  |  |
| hasCanoneRai | Canone RAI present | boolean | false |  |  |  |
| amountSeemsAbnormal | Amount seems abnormal | boolean | false |  |  |  |
| previousBillAmount | Previous bill amount | number | false |  |  |  |
| wrongChargeDescription | Wrong charge description | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"WRONG_CHARGE_REFUND_REQUEST_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"WRONG_CHARGE_REFUND_REQUEST_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"WRONG_CHARGE_REFUND_REQUEST_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"WRONG_CHARGE_REFUND_REQUEST_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"WRONG_CHARGE_REFUND_REQUEST_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Wrong charge refund provider official complaint form Italy | Wrong charge refund ARERA Portale Offerte official | Wrong charge refund provider PEC reclami official

### Procedure: UNILATERAL_CONTRACT_CHANGE_COMPLAINT

Basic:
- Title: Unilateral Contract Change Complaint
- Category: Utilities
- Subcategory: Contract change complaint
- Difficulty: High
- Estimated time: 10 minutes
- Free/Pro: Free
- Tags: bolletta, luce, gas, fornitore, voltura, disdetta
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Electricity and gas workflow or checklist.
- Long description: Unilateral Contract Change Complaint helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| providerName | Provider name | text | true |  |  |  |
| billPeriod | Bill period | text | true |  |  |  |
| amount | Amount | number | true |  |  |  |
| billType | Bill type | select | true | Electricity, Gas, Water, Internet |  |  |
| readingType | Reading type | text | false |  |  |  |
| consumption | Consumption | number | false |  |  |  |
| hasConguaglio | Conguaglio present | boolean | false |  |  |  |
| hasCanoneRai | Canone RAI present | boolean | false |  |  |  |
| amountSeemsAbnormal | Amount seems abnormal | boolean | false |  |  |  |
| previousBillAmount | Previous bill amount | number | false |  |  |  |
| changeNoticeDate | Change notice date | date | false |  |  |  |
| issueDescription | Issue description | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Bill copy | Required | Bill copy | suggested attachment |
| Screenshots or prior communication | Recommended | Screenshots or prior communication | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official customer service, complaint, switch, or contract channel shown in your bill, contract, or provider customer area.
- Responsible authority: Utility provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider customer area or official website","description":"Utility requests often depend on the provider customer area, contract section, or complaint form.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Provider desk or authorized point","description":"Some providers or authorized desks may accept in-person support for contract changes or documentation review.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Recent bill","Meter information or reading if relevant"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"UNILATERAL_CONTRACT_CHANGE_COMPLAINT_req_Recent bill or contract reference","name":"Recent bill or contract reference","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Recent bill or contract reference"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"UNILATERAL_CONTRACT_CHANGE_COMPLAINT_rec_Previous bill","name":"Previous bill","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous bill"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"UNILATERAL_CONTRACT_CHANGE_COMPLAINT_rec_Screenshots of customer area or messages","name":"Screenshots of customer area or messages","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Screenshots of customer area or messages"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"UNILATERAL_CONTRACT_CHANGE_COMPLAINT_rec_Payment proof if relevant","name":"Payment proof if relevant","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Payment proof if relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"UNILATERAL_CONTRACT_CHANGE_COMPLAINT_cond_Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","name":"Meter photo, activation data, switch terms, or payment-plan evidence depending on the case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Meter photo, activation data, switch terms, or payment-plan evidence depending on the case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Contract change complaint provider official complaint form Italy | Contract change complaint ARERA Portale Offerte official | Contract change complaint provider PEC reclami official

### Procedure: CANONE_RAI_NO_TV_DECLARATION_CHECKLIST

Basic:
- Title: Canone RAI No-TV Declaration Checklist
- Category: Canone RAI
- Subcategory: No-TV declaration
- Difficulty: High
- Estimated time: 8 minutes
- Free/Pro: Pro
- Tags: canone rai, tv, refund, exemption
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Canone RAI checklist and support workflow.
- Long description: Canone RAI No-TV Declaration Checklist helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Read the official instructions carefully. | Submit only truthful declarations. | Keep the submission receipt.
- User-facing guidance currently shown: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| billHolderName | Bill holder name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | true |  |  |  |
| hasTV | Has TV | boolean | false |  |  |  |
| householdMemberAlreadyPaying | Another household member already paying | boolean | false |  |  |  |
| yearOfExemption | Year or period | text | false |  |  |  |
| billProvider | Bill provider | text | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Electricity bill copy | Required | Electricity bill copy | suggested attachment |
| Any supporting declaration or prior payment proof | Recommended | Any supporting declaration or prior payment proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.
- Responsible authority: Agenzia Entrate / electricity provider context
- Submission channels: online-portal, officialForm, raccomandata-ar
- Online options: [{"title":"Agenzia Entrate official instructions","description":"Check official instructions, declaration channels, and truthful filing requirements before submitting.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST_req_Bill holder data","name":"Bill holder data","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Bill holder data"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST_rec_Electricity bill showing the charge","name":"Electricity bill showing the charge","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Electricity bill showing the charge"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST_rec_Previous declaration/refund proof if available","name":"Previous declaration/refund proof if available","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous declaration/refund proof if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST_cond_Eligibility evidence depends on the official case and year involved","name":"Eligibility evidence depends on the official case and year involved","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Eligibility evidence depends on the official case and year involved"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Read the official instructions carefully. | Submit only truthful declarations. | Keep the submission receipt.
- Follow-up guidance: If there is no answer, use a follow-up referencing the year, bill period, and any previous submission details.
- Rejection guidance: If rejected, review the official reason and prepare a correction or clarification request instead of repeating an unsupported declaration.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| Agenzia Entrate | https://www.agenziaentrate.gov.it/portale/ | https://www.agenziaentrate.gov.it/portale/ | verified | 2026-05-06T00:00:00.000 | {} |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |
| Agenzia Entrate - Canone RAI guidance | taxAuthorityGuidance | https://www.agenziaentrate.gov.it/portale/ | verified | {"en":"Relevant for official submission paths and truthful declaration warnings.","it":"Rilevante per percorsi di invio ufficiali e avvisi sulla dichiarazione veritiera."} | {"en":"This is practical guidance only and not legal advice.","it":"Questa è solo guida pratica e non consulenza legale.","es":"Esta es solo una guía práctica y no asesoramiento legal.","fa":"این فقط راهنمای عملی است و مشاوره حقوقی نیست.","ar":"هذه إرشادات عملية فقط وليست استشارة قانونية."} |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: 
- Missing legal/authority reference: 
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- Medium

Research notes:
- Exact things a researcher should search for: No-TV declaration Agenzia Entrate official form | No-TV declaration Canone RAI official declaration official

### Procedure: CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST

Basic:
- Title: Canone RAI Over-75 Exemption Checklist
- Category: Canone RAI
- Subcategory: Over-75 exemption
- Difficulty: High
- Estimated time: 8 minutes
- Free/Pro: Pro
- Tags: canone rai, tv, refund, exemption
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Canone RAI checklist and support workflow.
- Long description: Canone RAI Over-75 Exemption Checklist helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| billHolderName | Bill holder name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | true |  |  |  |
| hasTV | Has TV | boolean | false |  |  |  |
| householdMemberAlreadyPaying | Another household member already paying | boolean | false |  |  |  |
| yearOfExemption | Year or period | text | false |  |  |  |
| billProvider | Bill provider | text | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Electricity bill copy | Required | Electricity bill copy | suggested attachment |
| Any supporting declaration or prior payment proof | Recommended | Any supporting declaration or prior payment proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.
- Responsible authority: Agenzia Entrate / electricity provider context
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Agenzia Entrate official instructions","description":"Check official instructions, declaration channels, and truthful filing requirements before submitting.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST_req_Bill holder data","name":"Bill holder data","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Bill holder data"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST_rec_Electricity bill showing the charge","name":"Electricity bill showing the charge","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Electricity bill showing the charge"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST_rec_Previous declaration/refund proof if available","name":"Previous declaration/refund proof if available","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous declaration/refund proof if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST_cond_Eligibility evidence depends on the official case and year involved","name":"Eligibility evidence depends on the official case and year involved","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Eligibility evidence depends on the official case and year involved"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a follow-up referencing the year, bill period, and any previous submission details.
- Rejection guidance: If rejected, review the official reason and prepare a correction or clarification request instead of repeating an unsupported declaration.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Over-75 exemption Agenzia Entrate official form | Over-75 exemption Canone RAI official declaration official

### Procedure: CANONE_RAI_REFUND_OR_WRONG_CHARGE

Basic:
- Title: Canone RAI Refund or Wrong Charge
- Category: Canone RAI
- Subcategory: Refund / wrong charge
- Difficulty: High
- Estimated time: 8 minutes
- Free/Pro: Pro
- Tags: canone rai, tv, refund, exemption
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Canone RAI checklist and support workflow.
- Long description: Canone RAI Refund or Wrong Charge helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| billHolderName | Bill holder name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | true |  |  |  |
| hasTV | Has TV | boolean | false |  |  |  |
| householdMemberAlreadyPaying | Another household member already paying | boolean | false |  |  |  |
| yearOfExemption | Year or period | text | false |  |  |  |
| billProvider | Bill provider | text | false |  |  |  |
| chargeAlreadyPaid | Charge already paid | boolean | false |  |  |  |
| wantsRefund | Wants refund | boolean | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Electricity bill copy | Required | Electricity bill copy | suggested attachment |
| Any supporting declaration or prior payment proof | Recommended | Any supporting declaration or prior payment proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Canone RAI declarations, exemptions, and refund-related guidance must be verified through Agenzia Entrate official instructions. If the issue appears in the electricity bill, you may also need to identify the bill provider context.
- Responsible authority: Agenzia Entrate / electricity provider context
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Agenzia Entrate official instructions","description":"Check official instructions, declaration channels, and truthful filing requirements before submitting.","url":"https://www.agenziaentrate.gov.it/","requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"CANONE_RAI_REFUND_OR_WRONG_CHARGE_req_Bill holder data","name":"Bill holder data","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Bill holder data"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_REFUND_OR_WRONG_CHARGE_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"CANONE_RAI_REFUND_OR_WRONG_CHARGE_rec_Electricity bill showing the charge","name":"Electricity bill showing the charge","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Electricity bill showing the charge"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"CANONE_RAI_REFUND_OR_WRONG_CHARGE_rec_Previous declaration/refund proof if available","name":"Previous declaration/refund proof if available","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Previous declaration/refund proof if available"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"CANONE_RAI_REFUND_OR_WRONG_CHARGE_cond_Eligibility evidence depends on the official case and year involved","name":"Eligibility evidence depends on the official case and year involved","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Eligibility evidence depends on the official case and year involved"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a follow-up referencing the year, bill period, and any previous submission details.
- Rejection guidance: If rejected, review the official reason and prepare a correction or clarification request instead of repeating an unsupported declaration.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Refund / wrong charge Agenzia Entrate official form | Refund / wrong charge Canone RAI official declaration official

### Procedure: INTERNET_PHONE_CANCELLATION

Basic:
- Title: Internet / Phone Cancellation
- Category: Telecom
- Subcategory: Cancellation
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Pro
- Tags: internet, telefono, modem, disdetta, telecom
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Internet and phone complaint workflow.
- Long description: Internet / Phone Cancellation helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: yes, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Check contract conditions and notice period. | Verify modem or router return rules. | If portability matters, avoid sending a cancellation that conflicts with your transfer process.
- User-facing guidance currently shown: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| provider | Provider | text | true |  |  |  |
| contractHolder | Contract holder | text | true |  |  |  |
| customerCode | Customer code | text | false |  |  |  |
| contractNumber | Contract number | text | false |  |  |  |
| serviceAddress | Service address | text | true |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Invoice or bill copy | Required | Invoice or bill copy | suggested attachment |
| Previous contact proof | Recommended | Previous contact proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: yes
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.
- Responsible authority: Telecom provider
- Submission channels: online-portal, pec, raccomandata-ar, in-person
- Online options: [{"title":"Provider support / customer area","description":"Telecom complaints and cancellations are usually handled through official support channels and contract-specific forms.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"INTERNET_PHONE_CANCELLATION_req_Contract number or customer code","name":"Contract number or customer code","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Contract number or customer code"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"INTERNET_PHONE_CANCELLATION_rec_Invoice disputed","name":"Invoice disputed","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Invoice disputed"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"INTERNET_PHONE_CANCELLATION_rec_Cancellation proof","name":"Cancellation proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Cancellation proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"INTERNET_PHONE_CANCELLATION_rec_Provider replies or screenshots","name":"Provider replies or screenshots","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Provider replies or screenshots"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"INTERNET_PHONE_CANCELLATION_cond_Modem return receipt, portability reference, or payment proof when relevant","name":"Modem return receipt, portability reference, or payment proof when relevant","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Modem return receipt, portability reference, or payment proof when relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Check contract conditions and notice period. | Verify modem or router return rules. | If portability matters, avoid sending a cancellation that conflicts with your transfer process.
- Follow-up guidance: If there is no answer, send a follow-up and keep contract, invoice, cancellation, and modem return proof together.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint pack with all proof items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Customer support, complaints, and cancellation channels may differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| AGCOM - Servizi per il cittadino | https://www.agcom.it/servizi/cittadino | https://www.agcom.it/servizi/cittadino | verified | 2026-05-06T00:00:00.000 | {} |
| ConciliaWeb | https://conciliaweb.agcom.it/conciliaweb/login.htm?lang=en | https://conciliaweb.agcom.it/conciliaweb/login.htm?lang=en | verified | 2026-05-06T00:00:00.000 | {} |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Provider official customer area or complaints channel | customerArea | Check the official provider website, contract, or customer area for the correct cancellation or complaint channel. |  |  | needsReview |  |  |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |
| AGCOM / ConciliaWeb | telecomAuthorityGuidance | https://www.agcom.it/servizi/cittadino | verified | {"en":"Useful for internet cancellation disputes, wrong bills, and service problems.","it":"Utile per controversie su disdetta internet, bollette errate e problemi di servizio."} | {"en":"This is practical guidance only and not legal advice.","it":"Questa è solo guida pratica e non consulenza legale.","es":"Esta es solo una guía práctica y no asesoramiento legal.","fa":"این فقط راهنمای عملی است و مشاوره حقوقی نیست.","ar":"هذه إرشادات عملية فقط وليست استشارة قانونية."} |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: TIM, Vodafone, WINDTRE, Fastweb, Iliad, Sky Wifi, PosteMobile / PosteCasa, Tiscali, Aruba, Linkem / OpNet, Other provider
- Provider-specific forms currently stored: TIM cancellation information, Vodafone cancellation information
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: 
- Missing legal/authority reference: 
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- Medium

Research notes:
- Exact things a researcher should search for: Cancellation provider disdetta official site | Cancellation AGCOM ConciliaWeb official | Cancellation modem return official provider

### Procedure: TELECOM_WRONG_BILL_COMPLAINT

Basic:
- Title: Telecom Wrong Bill Complaint
- Category: Telecom
- Subcategory: Wrong bill
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Pro
- Tags: internet, telefono, modem, disdetta, telecom
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Internet and phone complaint workflow.
- Long description: Telecom Wrong Bill Complaint helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| provider | Provider | text | true |  |  |  |
| contractHolder | Contract holder | text | true |  |  |  |
| customerCode | Customer code | text | false |  |  |  |
| contractNumber | Contract number | text | false |  |  |  |
| serviceAddress | Service address | text | true |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |
| issueType | Issue type | text | true |  |  |  |
| invoiceNumber | Invoice number | text | false |  |  |  |
| amountDisputed | Amount disputed | number | false |  |  |  |
| previousContacts | Previous contacts | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Invoice or bill copy | Required | Invoice or bill copy | suggested attachment |
| Previous contact proof | Recommended | Previous contact proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.
- Responsible authority: Telecom provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider support / customer area","description":"Telecom complaints and cancellations are usually handled through official support channels and contract-specific forms.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"TELECOM_WRONG_BILL_COMPLAINT_req_Contract number or customer code","name":"Contract number or customer code","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Contract number or customer code"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"TELECOM_WRONG_BILL_COMPLAINT_rec_Invoice disputed","name":"Invoice disputed","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Invoice disputed"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"TELECOM_WRONG_BILL_COMPLAINT_rec_Cancellation proof","name":"Cancellation proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Cancellation proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"TELECOM_WRONG_BILL_COMPLAINT_rec_Provider replies or screenshots","name":"Provider replies or screenshots","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Provider replies or screenshots"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"TELECOM_WRONG_BILL_COMPLAINT_cond_Modem return receipt, portability reference, or payment proof when relevant","name":"Modem return receipt, portability reference, or payment proof when relevant","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Modem return receipt, portability reference, or payment proof when relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, send a follow-up and keep contract, invoice, cancellation, and modem return proof together.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint pack with all proof items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Customer support, complaints, and cancellation channels may differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Wrong bill provider disdetta official site | Wrong bill AGCOM ConciliaWeb official | Wrong bill modem return official provider

### Procedure: SERVICE_NOT_WORKING_COMPLAINT

Basic:
- Title: Service Not Working Complaint
- Category: Telecom
- Subcategory: Service issue
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Pro
- Tags: internet, telefono, modem, disdetta, telecom
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Internet and phone complaint workflow.
- Long description: Service Not Working Complaint helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| provider | Provider | text | true |  |  |  |
| contractHolder | Contract holder | text | true |  |  |  |
| customerCode | Customer code | text | false |  |  |  |
| contractNumber | Contract number | text | false |  |  |  |
| serviceAddress | Service address | text | true |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |
| issueType | Issue type | text | true |  |  |  |
| invoiceNumber | Invoice number | text | false |  |  |  |
| amountDisputed | Amount disputed | number | false |  |  |  |
| previousContacts | Previous contacts | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Invoice or bill copy | Required | Invoice or bill copy | suggested attachment |
| Previous contact proof | Recommended | Previous contact proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.
- Responsible authority: Telecom provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider support / customer area","description":"Telecom complaints and cancellations are usually handled through official support channels and contract-specific forms.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"SERVICE_NOT_WORKING_COMPLAINT_req_Contract number or customer code","name":"Contract number or customer code","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Contract number or customer code"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"SERVICE_NOT_WORKING_COMPLAINT_rec_Invoice disputed","name":"Invoice disputed","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Invoice disputed"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"SERVICE_NOT_WORKING_COMPLAINT_rec_Cancellation proof","name":"Cancellation proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Cancellation proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"SERVICE_NOT_WORKING_COMPLAINT_rec_Provider replies or screenshots","name":"Provider replies or screenshots","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Provider replies or screenshots"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"SERVICE_NOT_WORKING_COMPLAINT_cond_Modem return receipt, portability reference, or payment proof when relevant","name":"Modem return receipt, portability reference, or payment proof when relevant","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Modem return receipt, portability reference, or payment proof when relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, send a follow-up and keep contract, invoice, cancellation, and modem return proof together.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint pack with all proof items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Customer support, complaints, and cancellation channels may differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Service issue provider disdetta official site | Service issue AGCOM ConciliaWeb official | Service issue modem return official provider

### Procedure: MODEM_RETURN_OR_CHARGE_DISPUTE

Basic:
- Title: Modem Return or Charge Dispute
- Category: Telecom
- Subcategory: Modem dispute
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Pro
- Tags: internet, telefono, modem, disdetta, telecom
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Internet and phone complaint workflow.
- Long description: Modem Return or Charge Dispute helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: generic, pecVersion: generic, whatsAppMessage: generic, raccomandataVersion: no, followUp: generic, strongFollowUp: generic, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| provider | Provider | text | true |  |  |  |
| contractHolder | Contract holder | text | true |  |  |  |
| customerCode | Customer code | text | false |  |  |  |
| contractNumber | Contract number | text | false |  |  |  |
| serviceAddress | Service address | text | true |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |
| issueType | Issue type | text | true |  |  |  |
| invoiceNumber | Invoice number | text | false |  |  |  |
| amountDisputed | Amount disputed | number | false |  |  |  |
| previousContacts | Previous contacts | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Invoice or bill copy | Required | Invoice or bill copy | suggested attachment |
| Previous contact proof | Recommended | Previous contact proof | suggested attachment |

Generated outputs:
- Normal email: generic
- PEC version: generic
- WhatsApp message: generic
- Raccomandata version: no
- Follow-up: generic
- Strong follow-up: generic
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official provider cancellation, complaint, or assistance channel shown in your contract, invoice, or official customer area.
- Responsible authority: Telecom provider
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Provider support / customer area","description":"Telecom complaints and cancellations are usually handled through official support channels and contract-specific forms.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: []
- Documents detailed: {"required":[{"id":"MODEM_RETURN_OR_CHARGE_DISPUTE_req_Contract number or customer code","name":"Contract number or customer code","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Contract number or customer code"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"MODEM_RETURN_OR_CHARGE_DISPUTE_rec_Invoice disputed","name":"Invoice disputed","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Invoice disputed"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"MODEM_RETURN_OR_CHARGE_DISPUTE_rec_Cancellation proof","name":"Cancellation proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Cancellation proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"MODEM_RETURN_OR_CHARGE_DISPUTE_rec_Provider replies or screenshots","name":"Provider replies or screenshots","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Provider replies or screenshots"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"MODEM_RETURN_OR_CHARGE_DISPUTE_cond_Modem return receipt, portability reference, or payment proof when relevant","name":"Modem return receipt, portability reference, or payment proof when relevant","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Modem return receipt, portability reference, or payment proof when relevant"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, send a follow-up and keep contract, invoice, cancellation, and modem return proof together.
- Rejection guidance: If the provider rejects the request, prepare a stronger complaint pack with all proof items.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: Customer support, complaints, and cancellation channels may differ.
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? yes
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: Provider-specific channel, form, and contact data are missing.
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Modem dispute provider disdetta official site | Modem dispute AGCOM ConciliaWeb official | Modem dispute modem return official provider

### Procedure: COMUNE_RESIDENCE_REQUEST

Basic:
- Title: Comune / Residenza / Anagrafe Request
- Category: Public office
- Subcategory: Residence
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: residenza, comune, anagrafe, documents
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Comune and document support workflow.
- Long description: Comune / Residenza / Anagrafe Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: The correct office depends on your Comune and sometimes on the district or service desk. Use the official Comune site or office-finder to verify the right contact.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| cityOrComune | City or Comune | text | true |  |  |  |
| address | Address | text | true |  |  |  |
| requestType | Request type | text | true |  |  |  |
| issueDescription | Issue description | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Identity document | Required | Identity document | suggested attachment |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: The correct office depends on your Comune and sometimes on the district or service desk. Use the official Comune site or office-finder to verify the right contact.
- Responsible authority: Comune / Anagrafe
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Comune portal or appointment page","description":"Some Comuni allow appointments, certificate requests, or status checks online.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Comune / Anagrafe desk in person","description":"For many residence and certificate issues, in-person support may be available depending on the Comune.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Residence proof if relevant"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"COMUNE_RESIDENCE_REQUEST_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"COMUNE_RESIDENCE_REQUEST_rec_Protocol number or previous receipt if any","name":"Protocol number or previous receipt if any","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Protocol number or previous receipt if any"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"COMUNE_RESIDENCE_REQUEST_cond_Residence or family documentation depending on the certificate or request","name":"Residence or family documentation depending on the certificate or request","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Residence or family documentation depending on the certificate or request"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the office does not answer, reference your protocol number or appointment request in the follow-up.
- Rejection guidance: If rejected, verify which document was missing and reply with the correction or additional attachment.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: Torino, Milano, Roma, Bologna, Firenze, Napoli
- City-specific guidance found: Torino, Milano, Roma, Bologna, Firenze, Napoli
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Residence Comune official appointment | Residence anagrafe PEC official | Residence residenza office finder official

### Procedure: ANAGRAFE_CERTIFICATE_REQUEST

Basic:
- Title: Anagrafe Certificate Request
- Category: Public office
- Subcategory: Certificate request
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: residenza, comune, anagrafe, documents
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Comune and document support workflow.
- Long description: Anagrafe Certificate Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: yes}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: The correct office depends on your Comune and sometimes on the district or service desk. Use the official Comune site or office-finder to verify the right contact.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| cityOrComune | City or Comune | text | true |  |  |  |
| certificateType | Certificate type | text | true |  |  |  |
| useReason | Use reason | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Identity document | Required | Identity document | suggested attachment |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: yes

Service intelligence:
- Exists? yes
- Destination guidance: The correct office depends on your Comune and sometimes on the district or service desk. Use the official Comune site or office-finder to verify the right contact.
- Responsible authority: Comune / Anagrafe
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"Comune portal or appointment page","description":"Some Comuni allow appointments, certificate requests, or status checks online.","url":null,"requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Comune / Anagrafe desk in person","description":"For many residence and certificate issues, in-person support may be available depending on the Comune.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Residence proof if relevant"],"verificationStatus":"needsReview"}]
- Documents detailed: {"required":[{"id":"ANAGRAFE_CERTIFICATE_REQUEST_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"ANAGRAFE_CERTIFICATE_REQUEST_rec_Protocol number or previous receipt if any","name":"Protocol number or previous receipt if any","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Protocol number or previous receipt if any"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"ANAGRAFE_CERTIFICATE_REQUEST_cond_Residence or family documentation depending on the certificate or request","name":"Residence or family documentation depending on the certificate or request","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Residence or family documentation depending on the certificate or request"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If the office does not answer, reference your protocol number or appointment request in the follow-up.
- Rejection guidance: If rejected, verify which document was missing and reply with the correction or additional attachment.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? true
- Current cities/regions covered: Torino, Milano, Roma, Bologna, Firenze, Napoli
- City-specific guidance found: Torino, Milano, Roma, Bologna, Firenze, Napoli
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Certificate request Comune official appointment | Certificate request anagrafe PEC official | Certificate request residenza office finder official

### Procedure: NASPI_PREPARATION

Basic:
- Title: NASpI Preparation
- Category: Work
- Subcategory: NASpI
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: NASpI, patronato, INPS, lavoro
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Work and patronato support workflow.
- Long description: NASpI Preparation helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use official INPS guidance or a trusted patronato/CAF after verifying the correct appointment or online path.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| contractType | Contract type | text | true |  |  |  |
| employer | Employer | text | true |  |  |  |
| contractEndDate | Contract end date | date | true |  |  |  |
| terminationReason | Termination reason | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Termination documents | Required | Termination documents | suggested attachment |
| Recent payslips | Recommended | Recent payslips | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use official INPS guidance or a trusted patronato/CAF after verifying the correct appointment or online path.
- Responsible authority: Patronato / INPS / employer support context
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"INPS portal","description":"Some employment or benefit steps may require official portal access depending on the case.","url":"https://www.inps.it/","requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Patronato / CAF appointment","description":"A patronato or similar office can help review your paperwork in person.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Employment documents relevant to the case"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"NASPI_PREPARATION_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"NASPI_PREPARATION_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"NASPI_PREPARATION_rec_Employer documents or previous communications","name":"Employer documents or previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Employer documents or previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"NASPI_PREPARATION_cond_Termination, payslip, or benefit documents depending on the issue","name":"Termination, payslip, or benefit documents depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Termination, payslip, or benefit documents depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If you are waiting for a reply or appointment, follow up with the office and keep the request date and reference.
- Rejection guidance: If rejected, check whether the issue is document-related or eligibility-related before replying.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: NASpI INPS NASpI official | NASpI patronato appointment official

### Procedure: PATRONATO_APPOINTMENT_REQUEST

Basic:
- Title: Patronato Appointment Request
- Category: Work
- Subcategory: Patronato appointment
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: NASpI, patronato, INPS, lavoro
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: Work and patronato support workflow.
- Long description: Patronato Appointment Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use official INPS guidance or a trusted patronato/CAF after verifying the correct appointment or online path.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| recipient | Recipient | text | true |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| preferredDatesOrTimes | Preferred dates or times | textarea | false |  |  |  |
| urgency | Urgency | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use official INPS guidance or a trusted patronato/CAF after verifying the correct appointment or online path.
- Responsible authority: Patronato / INPS / employer support context
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"INPS portal","description":"Some employment or benefit steps may require official portal access depending on the case.","url":"https://www.inps.it/","requiresSpid":true,"requiresCie":true,"requiresPec":false,"verificationStatus":"verified"}]
- In-person options: [{"title":"Patronato / CAF appointment","description":"A patronato or similar office can help review your paperwork in person.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Codice fiscale","Employment documents relevant to the case"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"PATRONATO_APPOINTMENT_REQUEST_req_ID","name":"ID","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID"],"relatedDocumentType":null,"canUseCopy":true,"warning":null},{"id":"PATRONATO_APPOINTMENT_REQUEST_req_Codice fiscale","name":"Codice fiscale","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Codice fiscale"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"PATRONATO_APPOINTMENT_REQUEST_rec_Employer documents or previous communications","name":"Employer documents or previous communications","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Employer documents or previous communications"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"PATRONATO_APPOINTMENT_REQUEST_cond_Termination, payslip, or benefit documents depending on the issue","name":"Termination, payslip, or benefit documents depending on the issue","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Termination, payslip, or benefit documents depending on the issue"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If you are waiting for a reply or appointment, follow up with the office and keep the request date and reference.
- Rejection guidance: If rejected, check whether the issue is document-related or eligibility-related before replying.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Patronato appointment INPS NASpI official | Patronato appointment patronato appointment official

### Procedure: UNIVERSITY_OFFICE_REQUEST

Basic:
- Title: University Office Request
- Category: University
- Subcategory: University office
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: università, ISEE, borsa, tuition
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: University administration support workflow.
- Long description: University Office Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: The correct office depends on the university and the issue: student office, international office, fees office, scholarship office, or department administration.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| universityName | University name | text | true |  |  |  |
| officeName | Office name | text | true |  |  |  |
| studentName | Student name | text | true |  |  |  |
| studentId | Student ID | text | true |  |  |  |
| topic | Topic | text | true |  |  |  |
| situation | Situation | textarea | true |  |  |  |
| request | Request | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Student ID or card | Required | Student ID or card | suggested attachment |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: The correct office depends on the university and the issue: student office, international office, fees office, scholarship office, or department administration.
- Responsible authority: University office
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"University portal or student area","description":"Some student requests are handled through the official portal or ticketing system.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Student office in person","description":"Some universities handle corrections, document checks, or international support in person.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Student number if available","Relevant supporting documents"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"UNIVERSITY_OFFICE_REQUEST_req_ID or student identification details","name":"ID or student identification details","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID or student identification details"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"UNIVERSITY_OFFICE_REQUEST_rec_Enrollment, fee, or scholarship evidence depending on the request","name":"Enrollment, fee, or scholarship evidence depending on the request","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Enrollment, fee, or scholarship evidence depending on the request"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"UNIVERSITY_OFFICE_REQUEST_cond_Permesso or residence documents if relevant to the student case","name":"Permesso or residence documents if relevant to the student case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Permesso or residence documents if relevant to the student case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no reply, follow up with the office name, student number, and original message date.
- Rejection guidance: If rejected, clarify what document or office path was missing before sending a second request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: University office university student office official | University office international office official

### Procedure: PERMESSO_DOCUMENT_CHECKLIST

Basic:
- Title: Permesso Document Checklist
- Category: University
- Subcategory: Permesso support
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: università, ISEE, borsa, tuition
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: University administration support workflow.
- Long description: Permesso Document Checklist helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: yes, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: The correct office depends on the university and the issue: student office, international office, fees office, scholarship office, or department administration.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| permessoType | Permesso type | text | true |  |  |  |
| expiryDate | Expiry date | date | true |  |  |  |
| officeOrRecipient | Office or recipient | text | true |  |  |  |
| missingDocument | Missing document | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Passport copy | Required | Passport copy | suggested attachment |
| Current permit copy | Required | Current permit copy | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: yes
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: The correct office depends on the university and the issue: student office, international office, fees office, scholarship office, or department administration.
- Responsible authority: University office
- Submission channels: normal-email, online-portal, in-person
- Online options: [{"title":"University portal or student area","description":"Some student requests are handled through the official portal or ticketing system.","url":null,"requiresSpid":false,"requiresCie":false,"requiresPec":false,"verificationStatus":"needsReview"}]
- In-person options: [{"title":"Student office in person","description":"Some universities handle corrections, document checks, or international support in person.","address":null,"officeFinderLink":null,"documentsToBring":["ID","Student number if available","Relevant supporting documents"],"verificationStatus":"unverified"}]
- Documents detailed: {"required":[{"id":"PERMESSO_DOCUMENT_CHECKLIST_req_ID or student identification details","name":"ID or student identification details","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["ID or student identification details"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"PERMESSO_DOCUMENT_CHECKLIST_rec_Enrollment, fee, or scholarship evidence depending on the request","name":"Enrollment, fee, or scholarship evidence depending on the request","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Enrollment, fee, or scholarship evidence depending on the request"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"PERMESSO_DOCUMENT_CHECKLIST_cond_Permesso or residence documents if relevant to the student case","name":"Permesso or residence documents if relevant to the student case","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Permesso or residence documents if relevant to the student case"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no reply, follow up with the office name, student number, and original message date.
- Rejection guidance: If rejected, clarify what document or office path was missing before sending a second request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Permesso support university student office official | Permesso support international office official

### Procedure: REJECTED_REQUEST_REPLY

Basic:
- Title: Reply to Rejected Public Office Request
- Category: General
- Subcategory: Rejected request
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: generic, formal, appointment, refund, complaint
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: General formal support workflow.
- Long description: Reply to Rejected Public Office Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: no, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| officeName | Office name | text | true |  |  |  |
| originalRequestTopic | Original request topic | text | true |  |  |  |
| originalRequestDate | Original request date | date | true |  |  |  |
| rejectionDate | Rejection date | date | true |  |  |  |
| rejectionReason | Rejection reason | textarea | true |  |  |  |
| missingDocumentNowAttached | Missing document now attached | textarea | false |  |  |  |
| desiredOutcome | Desired outcome | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Notice or rejection letter | Required | Notice or rejection letter | suggested attachment |
| Supporting document | Required | Supporting document | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: no
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.
- Responsible authority: General
- Submission channels: normal-email, online-portal, in-person
- Online options: []
- In-person options: []
- Documents detailed: {"required":[{"id":"REJECTED_REQUEST_REPLY_req_Basic case details and sender information","name":"Basic case details and sender information","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Basic case details and sender information"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"REJECTED_REQUEST_REPLY_rec_Any previous communication or supporting proof","name":"Any previous communication or supporting proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Any previous communication or supporting proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"REJECTED_REQUEST_REPLY_cond_Situation-specific attachments depending on the office or provider","name":"Situation-specific attachments depending on the office or provider","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Situation-specific attachments depending on the office or provider"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a short follow-up and restate the original request reference.
- Rejection guidance: If rejected, ask which information or document is missing and reply with a corrected request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Rejected request official form Italy | Rejected request PEC official guidance Italy

### Procedure: REFUND_OR_COMPLAINT_REQUEST

Basic:
- Title: Refund or Complaint Request
- Category: General
- Subcategory: Refund / complaint
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: generic, formal, appointment, refund, complaint
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: General formal support workflow.
- Long description: Refund or Complaint Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: no, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| companyOrOffice | Company or office | text | true |  |  |  |
| serviceOrProduct | Service or product | text | true |  |  |  |
| problemDescription | Problem description | textarea | true |  |  |  |
| desiredSolution | Desired solution | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Receipt or invoice | Required | Receipt or invoice | suggested attachment |
| Supporting evidence | Recommended | Supporting evidence | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: no
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.
- Responsible authority: General
- Submission channels: normal-email, online-portal, in-person
- Online options: []
- In-person options: []
- Documents detailed: {"required":[{"id":"REFUND_OR_COMPLAINT_REQUEST_req_Basic case details and sender information","name":"Basic case details and sender information","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Basic case details and sender information"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"REFUND_OR_COMPLAINT_REQUEST_rec_Any previous communication or supporting proof","name":"Any previous communication or supporting proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Any previous communication or supporting proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"REFUND_OR_COMPLAINT_REQUEST_cond_Situation-specific attachments depending on the office or provider","name":"Situation-specific attachments depending on the office or provider","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Situation-specific attachments depending on the office or provider"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a short follow-up and restate the original request reference.
- Rejection guidance: If rejected, ask which information or document is missing and reply with a corrected request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Refund / complaint official form Italy | Refund / complaint PEC official guidance Italy

### Procedure: APPOINTMENT_REQUEST

Basic:
- Title: Formal Appointment Request
- Category: General
- Subcategory: Appointment
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: generic, formal, appointment, refund, complaint
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: General formal support workflow.
- Long description: Formal Appointment Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: no, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| fullName | Full name | text | true |  |  |  |
| codiceFiscale | Codice fiscale | text | false |  |  |  |
| phone | Phone | phone | false |  |  |  |
| email | Email | email | false |  |  |  |
| city | City | text | false |  |  |  |
| recipient | Recipient | text | true |  |  |  |
| reason | Reason | textarea | true |  |  |  |
| preferredDatesOrTimes | Preferred dates or times | textarea | false |  |  |  |
| urgency | Urgency | textarea | false |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: no
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.
- Responsible authority: General
- Submission channels: normal-email, online-portal, in-person
- Online options: []
- In-person options: []
- Documents detailed: {"required":[{"id":"APPOINTMENT_REQUEST_req_Basic case details and sender information","name":"Basic case details and sender information","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Basic case details and sender information"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"APPOINTMENT_REQUEST_rec_Any previous communication or supporting proof","name":"Any previous communication or supporting proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Any previous communication or supporting proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"APPOINTMENT_REQUEST_cond_Situation-specific attachments depending on the office or provider","name":"Situation-specific attachments depending on the office or provider","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Situation-specific attachments depending on the office or provider"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a short follow-up and restate the original request reference.
- Rejection guidance: If rejected, ask which information or document is missing and reply with a corrected request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Appointment official form Italy | Appointment PEC official guidance Italy

### Procedure: GENERIC_FORMAL_REQUEST

Basic:
- Title: Generic Formal Request
- Category: General
- Subcategory: Generic formal
- Difficulty: Medium
- Estimated time: 7 minutes
- Free/Pro: Free
- Tags: generic, formal, appointment, refund, complaint
- Source file: lib/features/italy_admin_copilot/data/procedure_definitions.dart

Current UI/help:
- Short description: General formal support workflow.
- Long description: Generic Formal Request helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.
- What this generates: {normalEmail: specific, pecVersion: specific, whatsAppMessage: specific, raccomandataVersion: no, followUp: specific, strongFollowUp: specific, inPersonChecklist: yes, onlinePortalChecklist: no, proofChecklist: yes, providerSpecificInstructions: no, cityRegionSpecificInstructions: no}
- Warnings: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- User-facing guidance currently shown: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.

Form fields:
| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |
| --- | --- | --- | --- | --- | --- | --- |
| senderName | Sender name | text | true |  |  |  |
| recipientNameOrOffice | Recipient | text | true |  |  |  |
| topic | Topic | text | true |  |  |  |
| situation | Situation | textarea | true |  |  |  |
| request | Request | textarea | true |  |  |  |

Attachments:
| Name | Required/Recommended/Optional | Description | Current status |
| --- | --- | --- | --- |
| Supporting documents | Recommended | Supporting documents | suggested attachment |

Generated outputs:
- Normal email: specific
- PEC version: specific
- WhatsApp message: specific
- Raccomandata version: no
- Follow-up: specific
- Strong follow-up: specific
- In-person checklist: yes
- Online portal checklist: no
- Proof checklist: yes
- Provider-specific instructions: no
- City/region-specific instructions: no

Service intelligence:
- Exists? yes
- Destination guidance: Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.
- Responsible authority: General
- Submission channels: normal-email, online-portal, in-person
- Online options: []
- In-person options: []
- Documents detailed: {"required":[{"id":"GENERIC_FORMAL_REQUEST_req_Basic case details and sender information","name":"Basic case details and sender information","requiredLevel":"required","description":"Usually required to identify the sender or support the request.","whenNeeded":"Before sending or at the office if requested.","examples":["Basic case details and sender information"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"recommended":[{"id":"GENERIC_FORMAL_REQUEST_rec_Any previous communication or supporting proof","name":"Any previous communication or supporting proof","requiredLevel":"recommended","description":"Useful for context and proof.","whenNeeded":"Recommended when available.","examples":["Any previous communication or supporting proof"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}],"conditional":[{"id":"GENERIC_FORMAL_REQUEST_cond_Situation-specific attachments depending on the office or provider","name":"Situation-specific attachments depending on the office or provider","requiredLevel":"conditional","description":"Needed only for some situations.","whenNeeded":"Only if the office/provider asks for it or the case requires it.","examples":["Situation-specific attachments depending on the office or provider"],"relatedDocumentType":null,"canUseCopy":true,"warning":null}]}
- Before-sending checklist: Verify the recipient email, PEC, portal, or office on an official source. | Check personal data, protocol numbers, and references. | Attach the relevant documents. | Remove placeholders and review the final text. | Submit only truthful statements. | Save proof of sending. | Verify the destination on an official source. | Remove placeholders from the generated text. | Keep proof of sending.
- Follow-up guidance: If there is no answer, use a short follow-up and restate the original request reference.
- Rejection guidance: If rejected, ask which information or document is missing and reply with a corrected request.
- Escalation guidance: If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.
- City/region notes: 
- Provider notes: 
- Verification status: needsReview
- Source file: lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart

Official links currently stored:
| Title | URL | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |

Official contacts currently stored:
| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |

Source/legal/authority references:
| Title | Type | URL | Verification Status | Relevance | Notes |
| --- | --- | --- | --- | --- | --- |

Provider dependencies:
- Requires provider selection? no
- Providers currently listed: 
- Provider-specific forms currently stored: 
- Provider-specific contacts currently stored: 0

City/region dependencies:
- Requires city/region? false
- Current cities/regions covered: 
- City-specific guidance found: 
- Region-specific guidance found: 

Missing real-world data:
- Missing exact email: Exact official email not currently stored.
- Missing exact PEC: Exact official PEC not currently stored.
- Missing exact address: Exact physical office or postal address not currently stored.
- Missing phone: Official phone number not currently stored.
- Missing office finder: Office finder or local desk selector missing.
- Missing official form: Official form link not currently stored or not mapped to this procedure.
- Missing portal link: No concrete official link is currently attached to this procedure.
- Missing legal/authority reference: No concrete source/legal reference is currently attached.
- Missing provider-specific instructions: 
- Missing in-person guidance: No
- Missing raccomandata guidance: Yes
- Missing translation/localization: Localized guidance coverage is incomplete in several production screens.

Research priority:
- High

Research notes:
- Exact things a researcher should search for: Generic formal official form Italy | Generic formal PEC official guidance Italy

## Provider Inventory

### Provider: TIM

Basic:
- Category: telecom
- Normalized name: tim
- Website: https://www.tim.it/
- Customer area: https://www.tim.it/mytim
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |
| cancellation | TIM cancellation information |  | online-portal, pec, raccomandata-ar | needsReview | current bundled provider form shell |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: no
- Missing forms: partial
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "TIM disdetta official site"
- "TIM reclami official site"
- "TIM PEC reclami"
- "TIM customer area official"

### Provider: Vodafone

Basic:
- Category: telecom
- Normalized name: vodafone
- Website: https://www.vodafone.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |
| cancellation | Vodafone cancellation information |  | online-portal, pec, raccomandata-ar | needsReview | current bundled provider form shell |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: partial
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Vodafone disdetta official site"
- "Vodafone reclami official site"
- "Vodafone PEC reclami"
- "Vodafone customer area official"

### Provider: WINDTRE

Basic:
- Category: telecom
- Normalized name: windtre
- Website: https://www.windtre.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "WINDTRE disdetta official site"
- "WINDTRE reclami official site"
- "WINDTRE PEC reclami"
- "WINDTRE customer area official"

### Provider: Fastweb

Basic:
- Category: telecom
- Normalized name: fastweb
- Website: https://www.fastweb.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Fastweb disdetta official site"
- "Fastweb reclami official site"
- "Fastweb PEC reclami"
- "Fastweb customer area official"

### Provider: Iliad

Basic:
- Category: telecom
- Normalized name: iliad
- Website: https://www.iliad.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Iliad disdetta official site"
- "Iliad reclami official site"
- "Iliad PEC reclami"
- "Iliad customer area official"

### Provider: Sky Wifi

Basic:
- Category: telecom
- Normalized name: sky-wifi
- Website: https://www.sky.it/sky-wifi
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Sky Wifi disdetta official site"
- "Sky Wifi reclami official site"
- "Sky Wifi PEC reclami"
- "Sky Wifi customer area official"

### Provider: PosteMobile / PosteCasa

Basic:
- Category: telecom
- Normalized name: postemobile-postecasa
- Website: https://www.postemobile.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "PosteMobile / PosteCasa disdetta official site"
- "PosteMobile / PosteCasa reclami official site"
- "PosteMobile / PosteCasa PEC reclami"
- "PosteMobile / PosteCasa customer area official"

### Provider: Tiscali

Basic:
- Category: telecom
- Normalized name: tiscali
- Website: https://www.tiscali.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Tiscali disdetta official site"
- "Tiscali reclami official site"
- "Tiscali PEC reclami"
- "Tiscali customer area official"

### Provider: Aruba

Basic:
- Category: telecom
- Normalized name: aruba
- Website: https://www.aruba.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Aruba disdetta official site"
- "Aruba reclami official site"
- "Aruba PEC reclami"
- "Aruba customer area official"

### Provider: Linkem / OpNet

Basic:
- Category: telecom
- Normalized name: opnet
- Website: https://www.opnet.it/
- Customer area: 
- Verification status: needsReview
- Last verified: 
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Linkem / OpNet disdetta official site"
- "Linkem / OpNet reclami official site"
- "Linkem / OpNet PEC reclami"
- "Linkem / OpNet customer area official"

### Provider: Other provider

Basic:
- Category: telecom
- Normalized name: other-telecom
- Website: 
- Customer area: 
- Verification status: unverified
- Last verified: 
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Other provider disdetta official site"
- "Other provider reclami official site"
- "Other provider PEC reclami"
- "Other provider customer area official"

### Provider: Enel Energia

Basic:
- Category: electricity
- Normalized name: enel-energia
- Website: https://www.enelenergia.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Enel Energia disdetta official site"
- "Enel Energia reclami official site"
- "Enel Energia PEC reclami"
- "Enel Energia customer area official"

### Provider: Servizio Elettrico Nazionale

Basic:
- Category: electricity
- Normalized name: servizio-elettrico-nazionale
- Website: https://www.servizioelettriconazionale.it/
- Customer area: 
- Verification status: needsReview
- Last verified: 
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Servizio Elettrico Nazionale disdetta official site"
- "Servizio Elettrico Nazionale reclami official site"
- "Servizio Elettrico Nazionale PEC reclami"
- "Servizio Elettrico Nazionale customer area official"

### Provider: Plenitude / Eni

Basic:
- Category: dualEnergy
- Normalized name: plenitude
- Website: https://eniplenitude.com/
- Customer area: 
- Verification status: needsReview
- Last verified: 
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Plenitude / Eni disdetta official site"
- "Plenitude / Eni reclami official site"
- "Plenitude / Eni PEC reclami"
- "Plenitude / Eni customer area official"

### Provider: Edison

Basic:
- Category: dualEnergy
- Normalized name: edison-energia
- Website: https://www.edisonenergia.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Edison disdetta official site"
- "Edison reclami official site"
- "Edison PEC reclami"
- "Edison customer area official"

### Provider: A2A Energia

Basic:
- Category: dualEnergy
- Normalized name: a2a-energia
- Website: https://www.a2aenergia.eu/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "A2A Energia disdetta official site"
- "A2A Energia reclami official site"
- "A2A Energia PEC reclami"
- "A2A Energia customer area official"

### Provider: Hera Comm

Basic:
- Category: dualEnergy
- Normalized name: hera-comm
- Website: https://heracomm.gruppohera.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Hera Comm disdetta official site"
- "Hera Comm reclami official site"
- "Hera Comm PEC reclami"
- "Hera Comm customer area official"

### Provider: Iren

Basic:
- Category: dualEnergy
- Normalized name: iren
- Website: https://www.irenlucegas.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Iren disdetta official site"
- "Iren reclami official site"
- "Iren PEC reclami"
- "Iren customer area official"

### Provider: Sorgenia

Basic:
- Category: dualEnergy
- Normalized name: sorgenia
- Website: https://www.sorgenia.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Sorgenia disdetta official site"
- "Sorgenia reclami official site"
- "Sorgenia PEC reclami"
- "Sorgenia customer area official"

### Provider: NeN

Basic:
- Category: dualEnergy
- Normalized name: nen
- Website: https://nen.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "NeN disdetta official site"
- "NeN reclami official site"
- "NeN PEC reclami"
- "NeN customer area official"

### Provider: Octopus Energy

Basic:
- Category: dualEnergy
- Normalized name: octopus-energy
- Website: https://octopusenergy.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Octopus Energy disdetta official site"
- "Octopus Energy reclami official site"
- "Octopus Energy PEC reclami"
- "Octopus Energy customer area official"

### Provider: Engie

Basic:
- Category: dualEnergy
- Normalized name: engie
- Website: https://www.engie.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Engie disdetta official site"
- "Engie reclami official site"
- "Engie PEC reclami"
- "Engie customer area official"

### Provider: Wekiwi

Basic:
- Category: dualEnergy
- Normalized name: wekiwi
- Website: https://www.wekiwi.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Wekiwi disdetta official site"
- "Wekiwi reclami official site"
- "Wekiwi PEC reclami"
- "Wekiwi customer area official"

### Provider: Acea Energia

Basic:
- Category: dualEnergy
- Normalized name: acea-energia
- Website: https://www.acea.it/acea-energia
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Acea Energia disdetta official site"
- "Acea Energia reclami official site"
- "Acea Energia PEC reclami"
- "Acea Energia customer area official"

### Provider: Dolomiti Energia

Basic:
- Category: dualEnergy
- Normalized name: dolomiti-energia
- Website: https://www.dolomitienergia.it/
- Customer area: 
- Verification status: verified
- Last verified: 2026-05-06T00:00:00.000
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Dolomiti Energia disdetta official site"
- "Dolomiti Energia reclami official site"
- "Dolomiti Energia PEC reclami"
- "Dolomiti Energia customer area official"

### Provider: Other provider

Basic:
- Category: dualEnergy
- Normalized name: other-energy
- Website: 
- Customer area: 
- Verification status: unverified
- Last verified: 
- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart

Contacts:
| Type | Value/URL | Source URL | Verification | Notes |
| --- | --- | --- | --- | --- |

Forms:
| Form Type | Title | URL | Submission Channels | Verification | Notes |
| --- | --- | --- | --- | --- | --- |

Guidance:
- Cancellation: {"en":"Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.","it":"Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione."}
- Complaint: {"en":"Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.","it":"Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo."}
- Modem return: {"en":"If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.","it":"Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione."}
- Refund: no dedicated refund guidance object
- Payment plan: {"en":"Check whether the provider offers an official instalment or payment-plan route in the customer area.","it":"Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti."}
- Voltura/Subentro: no provider-specific voltura/subentro object
- Disdetta: see cancellation guidance
- In-person: no dedicated in-person provider store guidance
- Raccomandata: no provider-specific postal target stored

Missing:
- Missing PEC: yes
- Missing email: yes
- Missing postal address: yes
- Missing customer area: yes
- Missing forms: yes
- Missing modem return: partial
- Missing complaint escalation: yes

Research queries:
- "Other provider disdetta official site"
- "Other provider reclami official site"
- "Other provider PEC reclami"
- "Other provider customer area official"

## City and Region Guidance Inventory

### Region: Piemonte
- Current links: Salute Piemonte, Salute Piemonte - Fascicolo Sanitario Elettronico FAQ
- Current contacts: no exact region-level contact rows stored
- Health/ASL guidance: Piemonte health services
- Comune guidance: none stored at region level
- Portal links: https://www.salutepiemonte.it/, https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico
- Missing data: exact ASL emails, PECs, local desk finder pages, and phone numbers remain incomplete
- Research queries: "Piemonte ASL contatti ufficiali", "Piemonte scelta medico portale ufficiale"

### Region: Lombardia
- Current links: 
- Current contacts: no exact region-level contact rows stored
- Health/ASL guidance: Lombardia health services
- Comune guidance: none stored at region level
- Portal links: 
- Missing data: exact ASL emails, PECs, local desk finder pages, and phone numbers remain incomplete
- Research queries: "Lombardia ASL contatti ufficiali", "Lombardia scelta medico portale ufficiale"

### Region: Lazio
- Current links: 
- Current contacts: no exact region-level contact rows stored
- Health/ASL guidance: Lazio health services
- Comune guidance: none stored at region level
- Portal links: 
- Missing data: exact ASL emails, PECs, local desk finder pages, and phone numbers remain incomplete
- Research queries: "Lazio ASL contatti ufficiali", "Lazio scelta medico portale ufficiale"

### City: Torino
- Comune official link: https://www.comune.torino.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Torino comune anagrafe residenza appuntamento", "Torino PEC anagrafe ufficiale"

### City: Milano
- Comune official link: https://www.comune.milano.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Milano comune anagrafe residenza appuntamento", "Milano PEC anagrafe ufficiale"

### City: Roma
- Comune official link: https://www.comune.roma.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Roma comune anagrafe residenza appuntamento", "Roma PEC anagrafe ufficiale"

### City: Bologna
- Comune official link: https://www.comune.bologna.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Bologna comune anagrafe residenza appuntamento", "Bologna PEC anagrafe ufficiale"

### City: Firenze
- Comune official link: https://www.comune.fi.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Firenze comune anagrafe residenza appuntamento", "Firenze PEC anagrafe ufficiale"

### City: Napoli
- Comune official link: https://www.comune.napoli.it/
- Anagrafe/residenza link: no exact deep link stored
- Office address/finder: not stored
- PEC/email: not stored
- Appointment system: not stored
- University links: not stored in city guidance
- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza
- Research queries: "Napoli comune anagrafe residenza appuntamento", "Napoli PEC anagrafe ufficiale"

## Terms / Guides Inventory

### Term: PEC
- current explanation: PEC stands for Posta Elettronica Certificata. It is different from normal email because it provides delivery and acceptance receipts that are commonly used for formal communications with offices, providers, and professionals in Italy. Many offices accept normal email for first contact, but some official workflows may specifically ask for PEC.
- official source link if present: https://www.agid.gov.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: SPID
- current explanation: SPID is a digital identity system used to access many Italian public administration services. Some regional health, INPS, Comune, and Agenzia Entrate portals may require it for online access.
- official source link if present: https://www.agid.gov.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: CIE
- current explanation: CIE is the electronic identity card. Some online public services accept CIE login as an alternative to SPID.
- official source link if present: https://www.cartaidentita.interno.gov.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: Codice fiscale
- current explanation: The codice fiscale is commonly used by public offices, health services, landlords, universities, and providers to identify the person involved in the request.
- official source link if present: https://www.agenziaentrate.gov.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Tessera sanitaria
- current explanation: The tessera sanitaria is the health card used in Italy for many healthcare and identification contexts. Handling rules may vary by region and health authority.
- official source link if present: https://www.salute.gov.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Canone RAI
- current explanation: Canone RAI is the public television fee. Declarations, exemptions, and refunds must be checked carefully on official instructions before submitting anything.
- official source link if present: https://www.agenziaentrate.gov.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Voltura
- current explanation: Voltura is usually used when a utility supply stays active but the contract holder changes.
- official source link if present: https://www.arera.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Subentro
- current explanation: Subentro is commonly used when the line is inactive and a new holder needs reactivation.
- official source link if present: https://www.arera.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Disdetta
- current explanation: Disdetta is a formal cancellation notice often used for utilities, telecom, subscriptions, or some contracts.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Conguaglio
- current explanation: A conguaglio is a bill adjustment that can happen when previous estimates are corrected or other recalculations are applied.
- official source link if present: https://www.arera.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: Lettura stimata
- current explanation: A lettura stimata means the bill used an estimated reading instead of an actual measured value.
- official source link if present: https://www.arera.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: Lettura effettiva
- current explanation: A lettura effettiva means the bill was based on an actual meter reading.
- official source link if present: https://www.arera.it/
- missing official source: partial
- missing provider/source references: partial
- localization status: Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.

### Term: Residenza
- current explanation: Residenza refers to official residence registration with the Comune and can affect access to services and local procedures.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Anagrafe
- current explanation: Anagrafe is the municipal registry office that handles residence and certificate-related services.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: NASpI
- current explanation: NASpI is an unemployment support measure managed through official channels such as INPS and support offices where relevant.
- official source link if present: https://www.inps.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Patronato
- current explanation: A patronato can help review documents and explain official procedures, especially for work, benefits, and some residence-related paperwork.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: CAF
- current explanation: CAF offices often help with tax or document-related administrative tasks.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: ISEE
- current explanation: ISEE is used in many contexts involving benefits, fees, and eligibility assessments.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Permesso di soggiorno
- current explanation: Residence permit requirements depend on the legal and administrative context involved. The app only helps organize requests and checklists.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Marca da bollo
- current explanation: Some procedures or forms may require a marca da bollo depending on the authority and purpose.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Modello RLI
- current explanation: Modello RLI is commonly associated with rental registration and related steps handled through official fiscal channels.
- official source link if present: https://www.agenziaentrate.gov.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Modello 69
- current explanation: References to Modello 69 can still appear in explanations or older workflows. Always verify the current official form and process.
- official source link if present: https://www.agenziaentrate.gov.it/
- missing official source: partial
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

### Term: Protocollo
- current explanation: A protocollo is often the official reference or registration number that helps identify a request, filing, or office communication.
- official source link if present: 
- missing official source: yes
- missing provider/source references: yes
- localization status: Dictionary only, mostly English strings.

