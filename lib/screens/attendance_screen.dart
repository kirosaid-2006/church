import '../models/attendance_record.dart';
import '../models/branch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../models/servant.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final servants = provider.getFilteredServants(query: _searchController.text);
    final isSuper = provider.currentUser?.isSuperAdmin ?? false;

    // Calculate top mini stats
    int q = 0, k = 0, e = 0;
    if (provider.selectedFriday != null) {
      for (var s in servants) {
        final rec = provider.getRecord(provider.selectedFriday!, s.id);
        if (rec.quddas == 1) q++;
        if (rec.khedma == 1) k++;
        if (rec.egtmaa == 1) e++;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        // Mini Stats
        Row(
          children: [
            _statBox('القداس', '$q/${servants.length}', AppTheme.statusGreenText),
            const SizedBox(width: 8),
            _statBox('الخدمة', '$k/${servants.length}', AppTheme.primaryBlue),
            const SizedBox(width: 8),
            _statBox('الاجتماع', '$e/${servants.length}', AppTheme.accentGold),
          ],
        ),
        const SizedBox(height: 12),

        // Search & Branch Filter
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'بحث بالاسم أو الهاتف...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
              ),
            ),
            if (isSuper) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: DropdownButton<String>(
                  value: provider.filterBranchId,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMain),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('كل الفروع')),
                    ...provider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setFilterBranchId(val);
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),

        // Quick bulk action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${servants.length} خادم مسجل', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            TextButton(
              onPressed: () => provider.bulkMarkAllPresent(),
              child: const Text('تحضير الكل للقداس', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Servants List
        if (servants.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Text('لا يوجد خدام مطابقين للبحث أو الفرع', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          )
        else
          ...servants.map((s) => _servantAttendanceCard(s, provider)),
      ],
    );
  }

  Widget _statBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _servantAttendanceCard(Servant s, AttendanceProvider provider) {
    final curFriday = provider.selectedFriday ?? '';
    final rec = provider.getRecord(curFriday, s.id);
    final abs = provider.calculateConsecutiveAbsences(s.id);
    final branch = provider.branches.firstWhere((b) => b.id == s.branchId, orElse: () => Branch(id: '', name: '', adminName: ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        if (abs >= 2) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: abs >= 3 ? AppTheme.statusRedBg : AppTheme.statusAmberBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: abs >= 3 ? AppTheme.statusRedBorder : AppTheme.statusAmberBorder),
                            ),
                            child: Text(
                              'غياب $abs أسابيع',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: abs >= 3 ? AppTheme.statusRedText : AppTheme.statusAmberText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${branch.name} • ${s.phone}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
                InkWell(
                  onTap: () => launchUrl(Uri.parse('tel:${s.phone}')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Text('اتصال', style: TextStyle(fontSize: 11, color: AppTheme.textMain)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _toggleButton('القداس', rec.quddas, () => provider.toggleAttendance(s.id, 'quddas')),
                const SizedBox(width: 8),
                _toggleButton('الخدمة', rec.khedma, () => provider.toggleAttendance(s.id, 'khedma')),
                const SizedBox(width: 8),
                _toggleButton('الاجتماع', rec.egtmaa, () => provider.toggleAttendance(s.id, 'egtmaa')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String label, int state, VoidCallback onTap) {
    Color bg = AppTheme.statusGrayBg;
    Color text = AppTheme.statusGrayText;
    Color border = AppTheme.statusGrayBorder;
    String prefix = 'غائب';

    if (state == 1) {
      bg = AppTheme.statusGreenBg;
      text = AppTheme.statusGreenText;
      border = AppTheme.statusGreenBorder;
      prefix = 'حاضر';
    } else if (state == 2) {
      bg = AppTheme.statusAmberBg;
      text = AppTheme.statusAmberText;
      border = AppTheme.statusAmberBorder;
      prefix = 'عذر';
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Text(
            state == 0 ? label : '$prefix $label',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text),
          ),
        ),
      ),
    );
  }
}


