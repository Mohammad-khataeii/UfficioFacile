import '../../italy_admin_copilot/data/canone_rai_guidance_definitions.dart';
import '../../italy_admin_copilot/data/general_guidance_definitions.dart';
import '../../italy_admin_copilot/data/public_office_comune_guidance_definitions.dart';
import '../../italy_admin_copilot/data/university_student_guidance_definitions.dart';
import '../../italy_admin_copilot/data/utilities_electricity_gas_guidance_definitions.dart';
import '../../italy_admin_copilot/data/work_inps_patronato_guidance_definitions.dart';
import '../../italy_admin_copilot/domain/rich_category_models.dart';

class BundledToCmsMapper {
  const BundledToCmsMapper();

  List<RichCategoryGuidance> allGuidance() => [
    utilitiesElectricityGasTorino,
    canoneRaiTorino,
    PublicOfficeComuneGuidanceDefinitions.category,
    WorkInpsPatronatoGuidanceDefinitions.category,
    UniversityStudentGuidanceDefinitions.category,
    GeneralGuidanceDefinitions.category,
  ];

  List<Map<String, dynamic>> exportCategories() {
    return allGuidance()
        .map(
          (item) => {
            'slug': item.id,
            'title': {'en': item.title, 'it': item.titleIt},
            'short_description': {'en': item.shortDescription},
            'long_description': {'en': item.mainUserQuestion},
            'sort_order': 0,
            'is_active': true,
            'visibility': 'public',
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> exportProcedures() {
    final items = <Map<String, dynamic>>[];
    for (final guidance in allGuidance()) {
      for (final subcategory in guidance.subcategories) {
        items.add({
          'slug': subcategory.id,
          'category_slug': guidance.id,
          'subcategory_slug': subcategory.id,
          'title': {'en': subcategory.title, 'it': subcategory.titleIt},
          'summary': {'en': subcategory.whatIsIt},
          'what_is_it': {'en': subcategory.whatIsIt},
          'why_you_need_it': {'en': subcategory.whyDoYouNeedIt.join('\n')},
          'how_to_do_it': {'en': subcategory.recommendedChannels.join('\n')},
          'documents_needed': {'en': subcategory.documents.join('\n')},
          'costs_and_timing': const {'en': ''},
          'common_mistakes': {'en': subcategory.warnings.join('\n')},
          'warnings': {'en': subcategory.warnings.join('\n')},
          'official_links': const [],
          'official_contacts': subcategory.recommendedContacts,
          'checklist': subcategory.documents,
          'faqs': const [],
          'premium_notes': const {'en': ''},
          'cta_config': const {},
          'verification_status': 'needsReview',
          'sort_order': 0,
          'is_active': true,
          'visibility': 'public',
        });
      }
    }
    return items;
  }
}
