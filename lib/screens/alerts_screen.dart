import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final servants = provider.getFilteredServants();

    final alerted = <Map<String, dynamic>>[];
    for (var s in servants) {
      final abs = provider.calculateConsecutiveAbsences(s.id);
      if (abs >= 2) {
        alerted.add({'servant': s, 'absences': abs});
      }
    }

    alerted.sort((a, b) => (b['absences'] as int).compareTo(a['absences'] as int));

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'متابعة وافتقاد الخدام',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                SizedBox(height: 4),
                Text(
                  'قائمة بالخدام المتغيبين لأسبوعين أو أكثر للمتابعة والافتقاد الهاتفي.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (alerted.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: const Column(
              children: [
                Text('لا يوجد متغيبين', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.statusGreenText)),
                SizedBox(height: 4),
                Text('جميع الخدام مواظبون على الحضور بانتظام.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          )
        else
          ...alerted.map((item) {
            final s = item['servant'];
            final abs = item['absences'] as int;
            final isUrgent = abs >= 3;
            final branch = provider.branches.firstWhere((b) => b.id == s.branchId, orElse: () => Branch(id: '', name: '', adminName: ''));

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUrgent ? AppTheme.statusRedBg : AppTheme.statusAmberBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isUrgent ? AppTheme.statusRedBorder : AppTheme.statusAmberBorder),
                          ),
                          child: Text(
                            'غياب $abs أسابيع متتالية',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isUrgent ? AppTheme.statusRedText : AppTheme.statusAmberText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${branch.name} • ${s.phone}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textMain,
                              side: const BorderSide(color: AppTheme.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => launchUrl(Uri.parse('tel:${s.phone}')),
                            child: const Text('اتصال هاتفي', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.statusGreenText,
                              side: const BorderSide(color: AppTheme.statusGreenBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => launchUrl(Uri.parse('https://wa.me/2${s.phone}')),
                            child: const Text('واتساب', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
