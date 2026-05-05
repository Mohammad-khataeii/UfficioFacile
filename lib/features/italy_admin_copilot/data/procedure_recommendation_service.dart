import '../domain/procedure_recommendation.dart';

class ProcedureRecommendationService {
  static const Map<String, List<String>> _keywords = {
    'ENERGY_SUPPLIER_COMPARISON': [
      'cheap electricity',
      'cheaper electricity',
      'low cost gas',
      'find gas provider',
      'change luce',
      'cambiare fornitore luce',
      'energia',
      'luce',
      'gas',
      'fornitore',
      'mercato libero',
      'bolletta luce',
      'bolletta gas',
      'luz',
      'factura de luz',
      'برق',
      'گاز',
      'قبض',
      'كهرباء',
      'غاز',
      'فاتورة',
    ],
    'HIGH_BILL_COMPLAINT': [
      'high gas bill',
      'high bill',
      'bolletta alta',
      'bolletta anomala',
      'gas bill',
      'factura alta',
      'قبض بالا',
      'فاتورة عالية',
    ],
    'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST': [
      'remove canone rai',
      'no tv',
      'canone rai bolletta',
      'esenzione canone',
      'rai exemption',
      'sin tv',
      'بدون تلویزیون',
      'بدون تلفزيون',
    ],
    'CANONE_RAI_REFUND_OR_WRONG_CHARGE': [
      'wrong canone rai',
      'rimborso canone rai',
      'rai refund',
    ],
    'CHANGE_DOCTOR': [
      'doctor',
      'medico',
      'medico di base',
      'family doctor',
      'change doctor',
      'médico',
      'پزشک',
      'طبيب',
    ],
    'TESSERA_SANITARIA_RENEWAL': [
      'health card',
      'tessera sanitaria',
      'expired health card',
      'tarjeta sanitaria',
      'کارت سلامت',
      'بطاقة صحية',
    ],
    'INTERNET_PHONE_CANCELLATION': [
      'cancel internet',
      'disdetta internet',
      'internet cancellation',
      'fibra',
      'cancelar internet',
      'کنسلی اینترنت',
      'إلغاء الإنترنت',
    ],
    'TELECOM_WRONG_BILL_COMPLAINT': [
      'wrong phone bill',
      'phone bill',
      'telefono',
      'factura teléfono',
      'قبض تلفن',
      'فاتورة الهاتف',
    ],
    'MODEM_RETURN_OR_CHARGE_DISPUTE': [
      'modem charge',
      'modem return',
      'cargo modem',
      'هزینه مودم',
      'رسوم المودم',
    ],
    'RENTAL_CONTRACT_CHANGE': [
      'rent contract',
      'add tenant',
      'subentro',
      'contrato alquiler',
      'اجاره',
      'إيجار',
    ],
    'DEPOSIT_RETURN_REQUEST': [
      'deposit',
      'cauzione',
      'depósito',
      'ودیعه',
      'تأمين',
    ],
    'LANDLORD_MAINTENANCE_OR_CONTRACT': [
      'landlord',
      'mold',
      'heating broken',
      'riscaldamento',
      'muffa',
      'propietario',
      'گرمایش',
      'تدفئة',
    ],
    'NASPI_PREPARATION': [
      'naspi',
      'lost job',
      'contract ended',
      'desempleo',
      'بیکاری',
      'بطالة',
    ],
    'PATRONATO_APPOINTMENT_REQUEST': ['patronato', 'inps', 'job support'],
    'COMUNE_RESIDENCE_REQUEST': [
      'residenza',
      'comune',
      'residencia',
      'ثبت آدرس',
      'إقامة',
    ],
    'ANAGRAFE_CERTIFICATE_REQUEST': [
      'anagrafe',
      'certificate request',
      'certificato',
      'certificado',
    ],
    'UNIVERSITY_OFFICE_REQUEST': [
      'university',
      'polito',
      'tuition',
      'scholarship',
      'isee',
      'universidad',
      'دانشگاه',
      'جامعة',
    ],
  };

  List<ProcedureRecommendation> recommend(String userProblem) {
    final normalized = userProblem.toLowerCase().trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final recommendations = <ProcedureRecommendation>[];
    _keywords.forEach((procedureId, words) {
      final matches = words.where((word) => normalized.contains(word)).toList();
      if (matches.isNotEmpty) {
        recommendations.add(
          ProcedureRecommendation(
            procedureId: procedureId,
            confidence: (matches.length / words.length).clamp(0.3, 0.95),
            reason: 'Matched keywords related to ${matches.first}.',
            matchedKeywords: matches,
            category: _categoryForProcedure(procedureId),
          ),
        );
      }
    });
    recommendations.sort((a, b) => b.confidence.compareTo(a.confidence));
    if (recommendations.isEmpty) {
      return const [
        ProcedureRecommendation(
          procedureId: 'GENERIC_FORMAL_REQUEST',
          confidence: 0.25,
          reason:
              'No strong keyword match found, so the generic formal request is a safe fallback.',
          matchedKeywords: [],
          category: 'General',
        ),
      ];
    }
    return recommendations.take(3).toList();
  }

  String _categoryForProcedure(String procedureId) {
    if (procedureId.contains('CANONE_RAI')) return 'Canone RAI';
    if (procedureId.contains('ENERGY') ||
        procedureId.contains('UTILITY') ||
        procedureId.contains('VOLTURA') ||
        procedureId.contains('SUBENTRO') ||
        procedureId.contains('METER')) {
      return 'Bills & utilities';
    }
    if (procedureId.contains('TELECOM') || procedureId.contains('MODEM')) {
      return 'Internet & phone';
    }
    if (procedureId.contains('NASPI') || procedureId.contains('PATRONATO')) {
      return 'Work / INPS';
    }
    if (procedureId.contains('UNIVERSITY')) return 'University';
    if (procedureId.contains('COMUNE') || procedureId.contains('ANAGRAFE')) {
      return 'Comune & documents';
    }
    if (procedureId.contains('LANDLORD') ||
        procedureId.contains('RENT') ||
        procedureId.contains('DEPOSIT')) {
      return 'Housing & rent';
    }
    return 'Health & ASL';
  }
}
