import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../models/branch.dart';
import '../models/user.dart';

class ManagementScreen extends StatelessWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final isSuper = provider.currentUser?.isSuperAdmin ?? false;
    final servants = provider.getServantsForManagement();

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
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
                      const Text('إدارة فروع الخدمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('فرع جديد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _showNewBranchDialog(context, provider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (provider.branches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('لا توجد فروع مسجلة، اضغط على «فرع جديد» للبدء', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ),
                    )
                  else
                    ...provider.branches.map((b) {
                      final count = provider.servants.where((s) => s.branchId == b.id).length;
                      final branchUser = provider.users.firstWhere((u) => u.branchId == b.id, orElse: () => AppUser(username: '', password: '', name: '', role: '', branchId: ''));
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
                                Text(b.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                                const SizedBox(height: 2),
                                Text('الأمين: ${b.adminName} ${branchUser.username.isNotEmpty ? '• يوزر: ' + branchUser.username : ''} • $count خادم', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.statusRedText),
                              tooltip: 'حذف الفرع',
                              onPressed: () => _confirmDeleteBranch(context, provider, b),
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

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سجل الخدام المسجلين', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_alt, size: 16),
                      label: const Text('خادم جديد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showNewServantDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (isSuper && provider.branches.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('كل الفروع', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: provider.managementBranchId == 'ALL',
                          onSelected: (_) => provider.setManagementBranchId('ALL'),
                        ),
                        const SizedBox(width: 6),
                        ...provider.branches.map((b) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text(b.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                selected: provider.managementBranchId == b.id,
                                onSelected: (_) => provider.setManagementBranchId(b.id),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                if (servants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('لا يوجد خدام مسجلين في هذا الفرع', style: TextStyle(fontSize: 12, color: AppTheme.textMuted))),
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
                              Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                              const SizedBox(height: 2),
                              Text('${branch.name} • ${s.phone}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
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
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة فرع خدمة جديد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الفرع / الأسرة')),
            const SizedBox(height: 8),
            TextField(controller: adminCtrl, decoration: const InputDecoration(labelText: 'اسم أمين الفرع المسئول')),
            const SizedBox(height: 8),
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'اسم مستخدم الدخول للأمين')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'كلمة المرور للأمين')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                provider.addBranch(nameCtrl.text.trim(), adminCtrl.text.trim(), userCtrl.text.trim(), passCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إنشاء الفرع'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBranch(BuildContext context, AttendanceProvider provider, Branch branch) {
    final count = provider.servants.where((s) => s.branchId == branch.id).length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد حذف الفرع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف فرع (${branch.name})؟' + (count > 0 ? '\nتحذير: سيتم حذف جميع الخدام التابعين لهذا الفرع وعددهم ($count خادم).' : ''), style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRedText, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteBranch(branch.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف الفرع'),
          ),
        ],
      ),
    );
  }

  void _showNewServantDialog(BuildContext context, AttendanceProvider provider) {
    if (provider.branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إنشاء فرع أولاً لإضافة الخدام بداخله')));
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String branchId = provider.branches.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('إضافة خادم جديد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                items: provider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, style: const TextStyle(fontSize: 13)))).toList(),
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
        content: const Text('هل أنت متأكد من حذف هذا الخادم؟', style: TextStyle(fontSize: 13)),
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
