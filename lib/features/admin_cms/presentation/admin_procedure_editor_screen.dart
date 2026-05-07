import 'package:flutter/material.dart';

class AdminProcedureEditorScreen extends StatelessWidget {
  const AdminProcedureEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Procedure editing is backed by the CMS tables added in Supabase. This screen is the place to expand into full no-code forms without changing app code.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
