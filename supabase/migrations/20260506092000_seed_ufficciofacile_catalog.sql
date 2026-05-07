insert into public.ufficcio_admin_config (key, value)
values
  ('beta_mode_enabled', 'true'::jsonb),
  ('paywall_enabled', 'false'::jsonb),
  ('free_pack_limit', '5'::jsonb),
  ('enable_utilities', 'true'::jsonb),
  ('enable_canone_rai', 'true'::jsonb),
  ('enable_telecom', 'true'::jsonb),
  ('enable_consultant_mode', 'false'::jsonb),
  ('enable_sync', 'true'::jsonb),
  ('enable_document_upload', 'false'::jsonb),
  ('enable_analytics', 'true'::jsonb)
on conflict (key) do nothing;

insert into public.ufficcio_city_packs (
  id, city_name, region, description, recommended_procedure_ids, common_topics, warnings, is_active
)
values
  ('torino', 'Torino', 'Piemonte', '{"en":"Useful workflows for Turin.","it":"Workflow utili per Torino."}'::jsonb, '{"COMUNE_RESIDENCE_REQUEST","CHANGE_DOCTOR","UNIVERSITY_OFFICE_REQUEST"}', '["residence","health","student life"]'::jsonb, '{"en":"Verify official websites before sending.","it":"Verifica sempre i siti ufficiali prima dell''invio."}'::jsonb, true),
  ('milano', 'Milano', 'Lombardia', '{"en":"Useful workflows for Milan.","it":"Workflow utili per Milano."}'::jsonb, '{"COMUNE_RESIDENCE_REQUEST","RENTAL_CONTRACT_CHANGE"}', '["housing","utilities"]'::jsonb, '{"en":"Verify official websites before sending.","it":"Verifica sempre i siti ufficiali prima dell''invio."}'::jsonb, true),
  ('roma', 'Roma', 'Lazio', '{"en":"Useful workflows for Rome.","it":"Workflow utili per Roma."}'::jsonb, '{"COMUNE_RESIDENCE_REQUEST","TESSERA_SANITARIA_RENEWAL"}', '["residence","health"]'::jsonb, '{"en":"Verify official websites before sending.","it":"Verifica sempre i siti ufficiali prima dell''invio."}'::jsonb, true)
on conflict (id) do nothing;

insert into public.ufficcio_official_links (
  title, category, description, url, country, related_procedure_ids, verification_status, warning, is_active
)
values
  ('Agenzia Entrate', 'Taxes', '{"en":"Official tax and Canone RAI reference.","it":"Riferimento fiscale ufficiale e Canone RAI."}'::jsonb, 'https://www.agenziaentrate.gov.it/', 'IT', '{"CANONE_RAI_NO_TV_DECLARATION_CHECKLIST","CANONE_RAI_REFUND_OR_WRONG_CHARGE"}', 'verified', '{"en":"Verify the exact page before use.","it":"Verifica la pagina esatta prima dell''uso."}'::jsonb, true),
  ('ARERA / Portale Offerte', 'Utilities', '{"en":"Official energy offer comparison reference.","it":"Riferimento ufficiale per il confronto delle offerte energia."}'::jsonb, 'https://www.ilportaleofferte.it/', 'IT', '{"ENERGY_SUPPLIER_COMPARISON"}', 'verified', '{"en":"Verify official conditions directly on the portal.","it":"Verifica le condizioni ufficiali direttamente sul portale."}'::jsonb, true),
  ('Comune official search', 'Comune', '{"en":"Find the official website for your city.","it":"Trova il sito ufficiale del Comune della tua città."}'::jsonb, null, 'IT', '{"COMUNE_RESIDENCE_REQUEST"}', 'needs_review', '{"en":"URL not seeded. Verify manually.","it":"URL non precompilato. Verifica manualmente."}'::jsonb, true);

insert into public.ufficcio_checklist_items (
  id, category, title_key, description_key, mode, priority, related_procedure_ids, related_document_types, is_active
)
values
  ('cf', 'identity', 'checklist.codice_fiscale', 'checklist.codice_fiscale_desc', null, 'high', '{"CHANGE_DOCTOR"}', '{"codice_fiscale"}', true),
  ('spid', 'identity', 'checklist.spid', 'checklist.spid_desc', null, 'normal', '{"GENERIC_FORMAL_REQUEST"}', '{}', true),
  ('university_enrollment', 'student', 'checklist.university_enrollment', 'checklist.university_enrollment_desc', 'student', 'high', '{"UNIVERSITY_OFFICE_REQUEST"}', '{"university_enrollment"}', true),
  ('rental_contract', 'housing', 'checklist.rental_contract', 'checklist.rental_contract_desc', 'tenant', 'high', '{"RENTAL_CONTRACT_CHANGE"}', '{"rental_contract"}', true)
on conflict (id) do nothing;
