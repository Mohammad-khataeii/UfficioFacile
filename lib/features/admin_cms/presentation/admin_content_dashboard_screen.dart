import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import 'admin_category_editor_screen.dart';
import 'admin_category_list_screen.dart';
import 'admin_content_import_export_screen.dart';
import 'admin_content_preview_screen.dart';
import 'admin_procedure_editor_screen.dart';
import 'admin_procedure_list_screen.dart';
import 'admin_translation_editor_screen.dart';

class AdminContentDashboardScreen extends StatefulWidget {
  const AdminContentDashboardScreen({super.key});

  @override
  State<AdminContentDashboardScreen> createState() =>
      _AdminContentDashboardScreenState();
}

class _AdminContentDashboardScreenState
    extends State<AdminContentDashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppScope.of(context).cmsContentController.load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: const [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Categories'),
              Tab(text: 'Category editor'),
              Tab(text: 'Procedures'),
              Tab(text: 'Procedure editor'),
              Tab(text: 'Translations'),
              Tab(text: 'Preview'),
              Tab(text: 'Import / revisions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AdminCategoryListScreen(),
                AdminCategoryEditorScreen(),
                AdminProcedureListScreen(),
                AdminProcedureEditorScreen(),
                AdminTranslationEditorScreen(),
                AdminContentPreviewScreen(),
                AdminContentImportExportScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
