import 'categories/bonuses_benefits.category.dart';
import 'categories/canone_rai.category.dart';
import 'categories/general.category.dart';
import 'categories/health_asl.category.dart';
import 'categories/housing_rent.category.dart';
import 'categories/loans_credit.category.dart';
import 'categories/public_office.category.dart';
import 'categories/telecom.category.dart';
import 'categories/university_student.category.dart';
import 'categories/utilities_bills.category.dart';
import 'categories/work_inps.category.dart';
import 'models/cms_seed_models.dart';

final List<CmsCategorySeed> cmsCategoryRegistry = [
  healthAslCategorySeed,
  housingRentCategorySeed,
  utilitiesBillsCategorySeed,
  canoneRaiCategorySeed,
  telecomCategorySeed,
  publicOfficeCategorySeed,
  workInpsCategorySeed,
  universityStudentCategorySeed,
  generalCategorySeed,
  bonusesBenefitsCategorySeed,
  loansCreditCategorySeed,
];
