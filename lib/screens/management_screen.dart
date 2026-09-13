import '../models/branch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final isSuper = provider.currentUser?.isSuperAdmin ?? false;
    final servants = provider.getFilteredServants();

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        // Branches Section (Super Admin only)
        if (isSuper) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('فروع وأسر الخدمة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      TextButton(
                        onPressed: () => _showNewBranchDialog(context, provider),
                        child: const Text('+ فرع جديد', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.branches.map((b) {
                    final count = provider.servants.where((s) => s.branchId == b.id).length;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                              const SizedBox(height: 2),
                              Text('المسؤول: ${b.adminName} • $count خادم', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                            child: const Text('نشط', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Servants Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سجل الخدام المسجلين', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    TextButton(
                      onPressed: () => _showNewServantDialog(context, provider),
                      child: const Text('+ خادم جديد', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (servants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('لا يوجد خدام مسجلين', style: TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                  )
                else
                  ...servants.map((s) {
                    final branch = provider.branches.firstWhere((b) => b.id == s.branchId, orElse: () => Branch(id: '', name: '', adminName: ''));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                              const SizedBox(height: 2),
                              Text('${branch.name} • ${s.phone}', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.statusRedText),
                            onPressed: () => _confirmDeleteServant(context, provider, s.id),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNewBranchDialog(BuildContext context, AttendanceProvider provider) {
    final nameCtrl = TextEditingController();
    final adminCtrl = TextEditingController();
    final userCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة فرع خدمة جديد', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الفرع / الأسرة')),
            const SizedBox(height: 8),
            TextField(controller: adminCtrl, decoration: const InputDecoration(labelText: 'اسم أمين الفرع')),
            const SizedBox(height: 8),
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'اسم مستخدم الدخول للأمين')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                provider.addBranch(nameCtrl.text.trim(), adminCtrl.text.trim(), userCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showNewServantDialog(BuildContext context, AttendanceProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String branchId = provider.branches.isNotEmpty ? provider.branches.first.id : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة خادم جديد', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الخادم ثلاثي')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: branchId,
                decoration: const InputDecoration(labelText: 'الفرع التابع له'),
                items: provider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => branchId = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  provider.addServant(nameCtrl.text.trim(), phoneCtrl.text.trim(), branchId);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteServant(BuildContext context, AttendanceProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من حذف هذا الخادم؟', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRedText, foregroundColor: Colors.white),
            onPressed: () {
              provider.removeServant(id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

