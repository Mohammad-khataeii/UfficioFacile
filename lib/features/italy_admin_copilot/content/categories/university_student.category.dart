import '../../data/university_student_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final universityStudentCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: UniversityStudentGuidanceDefinitions.category,
  sortOrder: 8,
  localizedTitle: localeMapFromPrimary(
    'University / Student',
    it: 'Università / Studente',
    fr: 'Université / Étudiant',
    es: 'Universidad / Estudiante',
    fa: 'دانشگاه / دانشجو',
    ar: 'الجامعة / الطالب',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Do you need help with enrollment, scholarships, student documents, residence permits, or university offices?',
    it: 'Hai bisogno di aiuto con iscrizione, borse di studio, documenti da studente, permesso di soggiorno o uffici universitari?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Start here for university paperwork, student offices, scholarships, tuition-related steps, and study admin in Italy.',
    it: 'Parti da qui per pratiche universitarie, uffici studenti, borse di studio, passaggi legati alle tasse e amministrazione dello studio in Italia.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'school',
  color: '#DC2626',
  tags: const ['university', 'student', 'scholarship', 'edisu', 'tuition'],
  searchableKeywords: const ['student', 'university', 'scholarship', 'edisu'],
  isProcedurePremium: (slug) =>
      slug.contains('scholarship') ||
      slug.contains('loan') ||
      slug.contains('benefit') ||
      slug.contains('insurance') ||
      slug.contains('tuition'),
  procedureMonetizationType: (slug) =>
      slug.contains('scholarship') ||
          slug.contains('loan') ||
          slug.contains('benefit') ||
          slug.contains('insurance') ||
          slug.contains('tuition')
      ? 'premium_money_value'
      : 'free',
);
