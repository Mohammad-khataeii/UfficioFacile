import '../domain/generated_pack.dart';
import '../domain/generated_pack_quality.dart';
import 'generators/shared_generator_helpers.dart';

class GeneratedPackQualityService {
  GeneratedPackQualityResult check(GeneratedPack pack) {
    final warnings = <String>[];
    if (pack.subject.trim().isEmpty) warnings.add('Subject is empty.');
    if (pack.bodyItalian.trim().isEmpty) warnings.add('Email body is empty.');
    if (pack.bodyPecItalian.trim().isEmpty) warnings.add('PEC body is empty.');
    if (pack.shortMessageItalian.trim().isEmpty) {
      warnings.add('Short message is empty.');
    }
    if (!pack.fullText.contains(kItalianDisclaimer)) {
      warnings.add('Mandatory disclaimer is missing.');
    }
    const forbiddenSnippets = ['null', 'undefined', '[]'];
    for (final snippet in forbiddenSnippets) {
      if (pack.fullText.contains(snippet)) {
        warnings.add('Pack contains suspicious placeholder text: $snippet');
      }
    }
    if (pack.attachmentChecklist.isEmpty) {
      warnings.add('Attachment checklist is missing.');
    }
    return GeneratedPackQualityResult(ok: warnings.isEmpty, warnings: warnings);
  }
}
