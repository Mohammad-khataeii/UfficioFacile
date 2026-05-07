import 'package:flutter/material.dart';

class AdminCategoryEditorScreen extends StatelessWidget {
  const AdminCategoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Category editing is managed through CMS records. Import bundled content first, then edit records from Supabase-backed forms in the next iteration of this panel.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
