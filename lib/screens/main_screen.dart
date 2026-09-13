import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';
import 'attendance_screen.dart';
import 'alerts_screen.dart';
import 'management_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AttendanceScreen(),
    AlertsScreen(),
    ManagementScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    final branchName = user.isSuperAdmin
        ? 'إشراف عام على كل الفروع'
        : provider.branches.firstWhere((b) => b.id == user.branchId, orElse: () => Branch(id: '', name: 'فرعك', adminName: '')).name;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.isSuperAdmin ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.isSuperAdmin ? 'أمين عام' : 'أمين فرع',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: user.isSuperAdmin ? AppTheme.primaryBlue : AppTheme.textMain,
                    ),
                  ),
                ),
              ],
            ),
            Text(branchName, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              provider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('الجمعة: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                    DropdownButton<String>(
                      value: provider.selectedFriday,
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      items: provider.fridays.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (val) {
                        if (val != null) provider.setSelectedFriday(val);
                      },
                    ),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.bgLight,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 14),
                  label: const Text('توليد جمع', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showGenerateFridaysDialog(context, provider),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'الرصد'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'الافتقاد'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'الخدام'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'التقارير'),
        ],
      ),
    );
  }

  void _showGenerateFridaysDialog(BuildContext context, AttendanceProvider provider) {
    int year = 2026;
    int month = 9; // September
    String scope = 'month';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('توليد تواريخ أيام الجمع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('السنة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<int>(
                value: year,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 2026, child: Text('2026')),
                  DropdownMenuItem(value: 2027, child: Text('2027')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => year = v);
                },
              ),
              const SizedBox(height: 8),
              const Text('نطاق التوليد:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: scope,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'month', child: Text('شهر محدد (شهر بشهر)')),
                  DropdownMenuItem(value: 'full_year', child: Text('توليد سنة كاملة')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => scope = v);
                },
              ),
              if (scope == 'month') ...[
                const SizedBox(height: 8),
                const Text('الشهر:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: month,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('يناير (1)')),
                    DropdownMenuItem(value: 2, child: Text('فبراير (2)')),
                    DropdownMenuItem(value: 3, child: Text('مارس (3)')),
                    DropdownMenuItem(value: 4, child: Text('أبريل (4)')),
                    DropdownMenuItem(value: 5, child: Text('مايو (5)')),
                    DropdownMenuItem(value: 6, child: Text('يونيو (6)')),
                    DropdownMenuItem(value: 7, child: Text('يوليو (7)')),
                    DropdownMenuItem(value: 8, child: Text('أغسطس (8)')),
                    DropdownMenuItem(value: 9, child: Text('سبتمبر (9)')),
                    DropdownMenuItem(value: 10, child: Text('أكتوبر (10)')),
                    DropdownMenuItem(value: 11, child: Text('نوفمبر (11)')),
                    DropdownMenuItem(value: 12, child: Text('ديسمبر (12)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => month = v);
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (scope == 'full_year') {
                  provider.generateFridaysForYear(year);
                } else {
                  provider.generateFridaysForMonth(year, month);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم توليد أيام الجمع بنجاح')),
                );
              },
              child: const Text('توليد الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
