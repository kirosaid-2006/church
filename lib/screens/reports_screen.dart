import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../models/branch.dart';
import '../models/attendance_record.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final isSuper = provider.currentUser?.isSuperAdmin ?? false;
    final servants = provider.getServantsForReports();
    final totalFridays = provider.fridays.isEmpty ? 1 : provider.fridays.length;

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تقارير ونسب الحضور', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                const SizedBox(height: 4),
                const Text('نسب حضور مفصولة لكل فرع لتجنب أي تداخل في السجلات.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 14),

                if (isSuper && provider.branches.isNotEmpty) ...[
                  const Text('عرض تقرير الفرع:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: provider.reportsBranchId,
                    decoration: const InputDecoration(isDense: true),
                    items: [
                      const DropdownMenuItem(value: 'ALL', child: Text('كل الفروع مجمعة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                      ...provider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setReportsBranchId(val);
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('تصدير تقرير الحضور إلى Excel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () => provider.exportAttendanceCsv(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('جدول النسب المئوية:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                const SizedBox(height: 8),
                if (servants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('لا توجد بيانات مسجلة لهذا الفرع', style: TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      horizontalMargin: 8,
                      headingRowHeight: 38,
                      dataRowHeight: 46,
                      columns: const [
                        DataColumn(label: Text('الخادم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الفرع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('قداس', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('خدمة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('اجتماع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                      rows: servants.map((s) {
                        final branch = provider.branches.firstWhere((b) => b.id == s.branchId, orElse: () => Branch(id: '', name: '', adminName: ''));
                        int q = 0, k = 0, e = 0;

                        for (var f in provider.fridays) {
                          final rec = provider.getRecord(f, s.id);
                          if (rec.quddas == 1) q++;
                          if (rec.khedma == 1) k++;
                          if (rec.egtmaa == 1) e++;
                        }

                        final qPct = '${((q / totalFridays) * 100).round()}%';
                        final kPct = '${((k / totalFridays) * 100).round()}%';
                        final ePct = '${((e / totalFridays) * 100).round()}%';

                        return DataRow(cells: [
                          DataCell(Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DataCell(Text(branch.name, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))),
                          DataCell(Text(qPct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.statusGreenText))),
                          DataCell(Text(kPct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue))),
                          DataCell(Text(ePct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGold))),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
