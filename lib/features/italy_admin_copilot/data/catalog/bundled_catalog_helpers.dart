import '../../domain/catalog_models.dart';

const kCatalogWarning = <String, String>{
  'en':
      'Contacts and links may change. Verify on the official website before sending.',
  'it':
      'Contatti e link possono cambiare. Verifica sul sito ufficiale prima dell’invio.',
  'es':
      'Los contactos y enlaces pueden cambiar. Verifícalos en el sitio oficial antes de enviar.',
  'fa':
      'لینک‌ها و اطلاعات تماس ممکن است تغییر کنند. قبل از ارسال در وب‌سایت رسمی بررسی کنید.',
  'ar': 'قد تتغير الروابط وجهات الاتصال. تحقق من الموقع الرسمي قبل الإرسال.',
};

const kNeedsReviewWarning = <String, String>{
  'en': 'This information still needs review before use.',
  'it': 'Questa informazione richiede ancora verifica prima dell’uso.',
  'es': 'Esta información todavía necesita revisión antes de usarse.',
  'fa': 'این اطلاعات هنوز قبل از استفاده نیاز به بررسی دارد.',
  'ar': 'هذه المعلومات ما زالت تحتاج إلى مراجعة قبل الاستخدام.',
};

const kNoLegalAdviceWarning = <String, String>{
  'en': 'This is practical guidance only and not legal advice.',
  'it': 'Questa è solo guida pratica e non consulenza legale.',
  'es': 'Esta es solo una guía práctica y no asesoramiento legal.',
  'fa': 'این فقط راهنمای عملی است و مشاوره حقوقی نیست.',
  'ar': 'هذه إرشادات عملية فقط وليست استشارة قانونية.',
};

DateTime verifiedOn(int year, int month, int day) => DateTime(year, month, day);

String localized(
  LocalizedText values,
  String languageCode, {
  String fallback = '',
}) => localizedValue(values, languageCode, fallback: fallback);
