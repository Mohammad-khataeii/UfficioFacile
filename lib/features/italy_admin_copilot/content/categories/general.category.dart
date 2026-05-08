import '../../data/general_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final generalCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: GeneralGuidanceDefinitions.category,
  sortOrder: 9,
  localizedTitle: localeMapFromPrimary(
    'General admin help',
    it: 'Aiuto amministrativo generale',
    fr: 'Aide administrative générale',
    es: 'Ayuda administrativa general',
    fa: 'راهنمای اداری عمومی',
    ar: 'مساعدة إدارية عامة',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'What do you need help with?',
    it: 'In cosa ti serve aiuto?',
    fr: 'De quoi avez-vous besoin ?',
    es: '¿En qué necesitas ayuda?',
    fa: 'در چه کاری به کمک نیاز داری؟',
    ar: 'ما الذي تحتاج إلى مساعدة فيه؟',
  ),
  localizedDescription: localeMapFromPrimary(
    'Not sure where your problem belongs? Start here. We help you choose the right office, reply to a rejected request, send missing documents, ask for a refund, make a complaint, or turn messy notes into formal Italian.',
    it: 'Non sai in quale categoria rientra il tuo problema? Parti da qui. Ti aiutiamo a capire quale ufficio contattare, rispondere a una richiesta respinta, inviare documenti mancanti, chiedere un rimborso, fare un reclamo o trasformare appunti confusi in un italiano formale.',
    fr: 'Vous ne savez pas à quelle catégorie appartient votre problème ? Commencez ici. Nous vous aidons à choisir le bon bureau, répondre à un refus, envoyer des documents manquants, demander un remboursement, faire une réclamation ou transformer des notes confuses en italien formel.',
    es: '¿No sabes en qué categoría encaja tu problema? Empieza aquí. Te ayudamos a elegir la oficina correcta, responder a un rechazo, enviar documentos faltantes, pedir un reembolso, presentar una reclamación o convertir notas confusas en italiano formal.',
    fa: 'نمی‌دانی مشکلت به کدام بخش مربوط است؟ از اینجا شروع کن. به تو کمک می‌کنیم اداره درست را پیدا کنی، به رد شدن درخواست پاسخ بدهی، مدارک ناقص را بفرستی، درخواست بازپرداخت ثبت کنی، شکایت بنویسی یا یادداشت‌های به‌هم‌ریخته را به ایتالیایی رسمی تبدیل کنی.',
    ar: 'إذا لم تكن متأكداً من القسم المناسب لمشكلتك، ابدأ من هنا. نساعدك على اختيار الجهة الصحيحة، الرد على طلب مرفوض، إرسال المستندات الناقصة، طلب استرداد، تقديم شكوى، أو تحويل الملاحظات غير المرتبة إلى إيطالية رسمية.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'support_agent',
  color: '#334155',
  tags: const ['general', 'complaint', 'refund', 'documents', 'formal message'],
  searchableKeywords: const [
    'general help',
    'complaint',
    'refund',
    'documents',
  ],
  isProcedurePremium: (slug) =>
      slug.contains('tax') ||
      slug.contains('refund') ||
      slug.contains('reclamo') ||
      slug.contains('detrazione'),
  procedureMonetizationType: (slug) =>
      slug.contains('tax') ||
          slug.contains('refund') ||
          slug.contains('reclamo') ||
          slug.contains('detrazione')
      ? 'premium_money_value'
      : 'free',
);
