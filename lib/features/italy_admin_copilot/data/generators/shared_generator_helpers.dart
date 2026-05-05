import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/admin_procedure.dart';
import '../../domain/attachment_item.dart';
import '../../domain/generated_pack.dart';
import '../../domain/request_status.dart';

const kItalianDisclaimer =
    'Questo strumento fornisce supporto amministrativo e organizzativo. Non '
    'sostituisce consulenza legale, fiscale, medica, finanziaria, energetica '
    'o professionale. Prima dell’invio o della scelta di un’offerta, verifica '
    'sempre dati, condizioni contrattuali, ufficio competente, indirizzi '
    'ufficiali, scadenze e normativa aggiornata.';

const kEnglishDisclaimer =
    'This tool provides administrative and organizational assistance only. It '
    'does not replace legal, tax, medical, financial, energy-market, or '
    'professional advice. Always verify personal data, contract terms, '
    'competent offices, official addresses, deadlines, and updated rules '
    'before sending or switching provider.';

String valueOrPlaceholder(
  Map<String, dynamic> input,
  String key,
  String placeholder,
) {
  final value = input[key];
  if (value == null) {
    return placeholder;
  }
  if (value is String && value.trim().isEmpty) {
    return placeholder;
  }
  if (value is DateTime) {
    return formatDate(value);
  }
  return '$value';
}

String formatDate(dynamic value) {
  final date = value is DateTime ? value : DateTime.tryParse('$value');
  if (date == null) {
    return 'data da verificare';
  }
  return DateFormat('dd/MM/yyyy').format(date);
}

String buildGreeting(String? recipient) {
  return recipient == null || recipient.trim().isEmpty
      ? 'Buongiorno,'
      : 'Buongiorno $recipient,';
}

String buildIdentityLine(Map<String, dynamic> input) {
  final name = valueOrPlaceholder(
    input,
    'fullName',
    valueOrPlaceholder(input, 'senderName', 'Nome e Cognome'),
  );
  final codiceFiscale = input['codiceFiscale'] == null
      ? ''
      : ', codice fiscale ${input['codiceFiscale']}';
  final address =
      input['addressOrDomicile'] ??
      input['address'] ??
      input['propertyAddress'] ??
      '';
  final city = input['city'] ?? input['cityOrComune'] ?? '';
  final location = '$address ${city.toString()}'.trim();
  if (location.isEmpty) {
    return 'mi chiamo $name$codiceFiscale.';
  }
  return 'mi chiamo $name$codiceFiscale, residente/domiciliato/a in $location.';
}

List<AttachmentItem> createAttachmentChecklist(AdminProcedure procedure) {
  return procedure.attachmentSuggestions
      .map(
        (item) => AttachmentItem(
          id: item.id,
          name: item.name,
          description: item.description,
          required: item.required,
          userHasIt: false,
        ),
      )
      .toList();
}

List<String> buildAttachmentList(List<AttachmentItem> items) {
  if (items.isEmpty) {
    return const ['Documentazione da verificare in base al caso concreto'];
  }
  return items.map((item) => item.name).toList();
}

String buildClosing(Map<String, dynamic> input) {
  final name = valueOrPlaceholder(
    input,
    'fullName',
    valueOrPlaceholder(input, 'senderName', 'Nome e Cognome'),
  );
  final phone = input['phone'];
  final email = input['email'];
  final contacts = [
    if (phone != null && '$phone'.trim().isNotEmpty) 'Tel. $phone',
    if (email != null && '$email'.trim().isNotEmpty) 'Email $email',
  ].join(' - ');
  return [
    'Resto a disposizione per eventuali chiarimenti e chiedo gentilmente un riscontro sulla presa in carico della richiesta.',
    '',
    'Cordiali saluti,',
    name,
    if (contacts.isNotEmpty) contacts,
  ].join('\n');
}

String buildDisclaimer() => '$kItalianDisclaimer\n\n$kEnglishDisclaimer';

RequestPriority inferPriority(Map<String, dynamic> input) {
  final urgency =
      '${input['urgency'] ?? input['urgencyLevel'] ?? input['urgencyReason'] ?? ''}'
          .toLowerCase();
  if (urgency.contains('urgent') ||
      urgency.contains('urgente') ||
      urgency.contains('health') ||
      urgency.contains('salute')) {
    return RequestPriority.urgent;
  }
  if (input['cannotGoInPerson'] == true || input['canGoInPerson'] == false) {
    return RequestPriority.high;
  }
  return RequestPriority.normal;
}

List<String> suggestDeadline(Map<String, dynamic> input) {
  final deadline = input['deadline'] ?? input['deadlineRequested'];
  if (deadline != null && '$deadline'.trim().isNotEmpty) {
    return [
      'Monitor the requested deadline around ${formatDate(deadline)}.',
      'If no response arrives, send a polite follow-up within 7 days after that date.',
    ];
  }
  return const [
    'Suggested follow-up: 7 days after sending.',
    'If still unanswered, send a firmer follow-up after 14 days.',
    'Escalate or seek professional help after 30 days if the matter is urgent.',
  ];
}

String buildFullText({
  required String subject,
  required String bodyItalian,
  required String bodyPecItalian,
  required String shortMessageItalian,
  required String whatsappMessageItalian,
  required String whatsappFollowUpItalian,
  required String whatsappStrongFollowUpItalian,
  required String ultraShortSummaryItalian,
  required String followUpItalian,
  required String strongFollowUpItalian,
  String? rejectedReplyItalian,
  required String userExplanationEnglish,
  required List<String> nextSteps,
  required List<String> warnings,
}) {
  return [
    'OGGETTO\n$subject',
    'EMAIL\n$bodyItalian',
    'PEC\n$bodyPecItalian',
    'SHORT MESSAGE\n$shortMessageItalian',
    'WHATSAPP\n$whatsappMessageItalian',
    'WHATSAPP FOLLOW-UP\n$whatsappFollowUpItalian',
    'WHATSAPP FORTE\n$whatsappStrongFollowUpItalian',
    'ULTRA SHORT\n$ultraShortSummaryItalian',
    'FOLLOW-UP\n$followUpItalian',
    'FOLLOW-UP FORTE\n$strongFollowUpItalian',
    if (rejectedReplyItalian != null)
      'RISPOSTA A RIGETTO\n$rejectedReplyItalian',
    'ENGLISH EXPLANATION\n$userExplanationEnglish',
    'NEXT STEPS\n${nextSteps.map((item) => '- $item').join('\n')}',
    'WARNINGS\n${warnings.map((item) => '- $item').join('\n')}',
    'DISCLAIMER\n${buildDisclaimer()}',
  ].join('\n\n');
}

GeneratedPack buildStandardPack({
  required AdminProcedure procedure,
  required Map<String, dynamic> inputData,
  required String subject,
  required String recipientLabel,
  required String requestSummary,
  required String englishExplanation,
  List<String> warnings = const [],
  List<String> nextSteps = const [],
  String? requestVerb,
  String? rejectedReplyItalian,
}) {
  final attachments = createAttachmentChecklist(procedure);
  final attachmentLines = buildAttachmentList(
    attachments,
  ).map((item) => '- $item').join('\n');
  final recipient = valueOrPlaceholder(
    inputData,
    recipientLabel,
    procedure.authorityType,
  );
  final formalVerb = requestVerb ?? 'chiedere cortesemente';
  final name = valueOrPlaceholder(
    inputData,
    'fullName',
    valueOrPlaceholder(inputData, 'senderName', 'il/la richiedente'),
  );
  final previousRequestDate = inputData['previousRequestDate'] == null
      ? null
      : formatDate(inputData['previousRequestDate']);

  final bodyItalian = [
    buildGreeting(recipient),
    '',
    buildIdentityLine(inputData),
    '',
    'Con la presente desidero $formalVerb $requestSummary.',
    '',
    'Se possibile, chiedo conferma che la documentazione allegata sia sufficiente oppure indicazioni sugli eventuali ulteriori documenti necessari.',
    '',
    'Allego alla presente:',
    attachmentLines,
    '',
    buildClosing(inputData),
  ].join('\n');

  final shortMessageItalian = [
    'Buongiorno,',
    'scrivo per $requestSummary.',
    if (inputData['urgencyReason'] != null)
      'Segnalo inoltre questa urgenza: ${inputData['urgencyReason']}.',
    'Resto disponibile per inviare documenti o chiarimenti se necessari.',
    'Grazie, $name.',
  ].join('\n');
  final whatsappMessageItalian = shortMessageItalian;
  final whatsappFollowUpItalian = [
    'Buongiorno,',
    'scrivo per un aggiornamento su $requestSummary.',
    'Potete indicarmi se servono altri documenti?',
    'Grazie, $name.',
  ].join('\n');
  final whatsappStrongFollowUpItalian = [
    'Buongiorno,',
    'sollecito gentilmente un riscontro su $requestSummary.',
    'Se possibile, chiedo conferma della presa in carico e dei prossimi passaggi.',
    'Grazie, $name.',
  ].join('\n');
  final ultraShortSummaryItalian = 'Richiesta: $subject';

  final bodyPecItalian = [
    'Spett.le $recipient,',
    '',
    'Il/La sottoscritto/a $name, ${buildIdentityLine(inputData).replaceFirst('mi chiamo ', '')}',
    '',
    'PREMESSO CHE',
    requestSummary[0].toUpperCase() + requestSummary.substring(1),
    '',
    'CHIEDE',
    'di voler cortesemente prendere in carico la presente istanza e di comunicare eventuali integrazioni documentali necessarie.',
    '',
    'Documenti allegati:',
    attachmentLines,
    '',
    'Si richiede cortese conferma di ricezione.',
    '',
    buildClosing(inputData),
  ].join('\n');

  final followUpItalian = [
    buildGreeting(recipient),
    '',
    if (previousRequestDate != null)
      'faccio seguito alla mia richiesta inviata in data $previousRequestDate relativa a $requestSummary.'
    else
      'faccio seguito alla mia precedente richiesta relativa a $requestSummary.',
    '',
    'Vorrei cortesemente sapere se la pratica è in lavorazione e se sono necessari ulteriori documenti o chiarimenti.',
    '',
    buildClosing(inputData),
  ].join('\n');

  final strongFollowUpItalian = [
    buildGreeting(recipient),
    '',
    'sollecito gentilmente un aggiornamento in merito alla richiesta relativa a $requestSummary.',
    '',
    'Considerata la necessità di definire la pratica in tempi utili, chiedo cortesemente conferma della presa in carico, eventuale numero di protocollo e indicazione degli ulteriori passaggi richiesti.',
    '',
    if (inputData['urgencyReason'] != null)
      'Segnalo inoltre la seguente urgenza: ${inputData['urgencyReason']}.',
    '',
    buildClosing(inputData),
  ].join('\n');

  final mergedWarnings = [
    'Verify the official office email or PEC address before sending.',
    'Do not rely on this draft as legal certainty; review dates, names, and attachments.',
    ...warnings,
  ];

  final mergedNextSteps = [
    'Review the draft and personalize any bracketed or placeholder details.',
    'Check the official website for the correct office, PEC/email address, and updated requirements.',
    'Send the message with the listed attachments and keep proof of submission.',
    ...nextSteps,
  ];

  final fullText = buildFullText(
    subject: subject,
    bodyItalian: bodyItalian,
    bodyPecItalian: bodyPecItalian,
    shortMessageItalian: shortMessageItalian,
    whatsappMessageItalian: whatsappMessageItalian,
    whatsappFollowUpItalian: whatsappFollowUpItalian,
    whatsappStrongFollowUpItalian: whatsappStrongFollowUpItalian,
    ultraShortSummaryItalian: ultraShortSummaryItalian,
    followUpItalian: followUpItalian,
    strongFollowUpItalian: strongFollowUpItalian,
    rejectedReplyItalian: rejectedReplyItalian,
    userExplanationEnglish: englishExplanation,
    nextSteps: mergedNextSteps,
    warnings: mergedWarnings,
  );

  final now = DateTime.now();
  return GeneratedPack(
    id: const Uuid().v4(),
    procedureId: procedure.id,
    procedureTitle: procedure.title,
    category: procedure.category.label,
    status: RequestStatus.generated,
    priority: inferPriority(inputData),
    inputData: inputData,
    subject: subject,
    bodyItalian: bodyItalian,
    bodyPecItalian: bodyPecItalian,
    shortMessageItalian: shortMessageItalian,
    whatsappMessageItalian: whatsappMessageItalian,
    whatsappFollowUpItalian: whatsappFollowUpItalian,
    whatsappStrongFollowUpItalian: whatsappStrongFollowUpItalian,
    ultraShortSummaryItalian: ultraShortSummaryItalian,
    followUpItalian: followUpItalian,
    strongFollowUpItalian: strongFollowUpItalian,
    rejectedReplyItalian: rejectedReplyItalian,
    userExplanationEnglish: '$englishExplanation\n\n$kEnglishDisclaimer',
    localizedExplanations: {
      'en': '$englishExplanation\n\n$kEnglishDisclaimer',
      'it':
          'Questo pack spiega la richiesta in modo operativo. Verifica sempre i dati ufficiali prima dell’invio.\n\n$kItalianDisclaimer',
      'es':
          'Este paquete explica la solicitud de forma práctica. Verifica siempre los datos oficiales antes del envío.\n\n$kEnglishDisclaimer',
      'fa':
          'این بسته درخواست را به صورت کاربردی توضیح می‌دهد. پیش از ارسال همیشه اطلاعات رسمی را بررسی کنید.\n\n$kEnglishDisclaimer',
      'ar':
          'تشرح هذه الحزمة الطلب بشكل عملي. تحقق دائمًا من المعلومات الرسمية قبل الإرسال.\n\n$kEnglishDisclaimer',
    },
    attachmentChecklist: attachments,
    nextSteps: mergedNextSteps,
    warnings: mergedWarnings,
    deadlineSuggestions: suggestDeadline(inputData),
    fullText: fullText,
    createdAt: now,
    updatedAt: now,
  );
}
