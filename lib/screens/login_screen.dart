import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_provider.dart';
import '../theme/app_theme.dart';
import '../models/branch.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedBranchId = 'SUPER_ADMIN';
  bool _rememberMe = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: AppTheme.primaryBlue,
                          child: const Icon(Icons.church, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'كنيسة السيدة العذراء والشهيدة كاترين',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'نظام تسجيل ومتابعة حضور الخدام',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تسجيل دخول المسؤول',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'الفرع / الأمانة:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedBranchId,
                            isExpanded: true,
                            decoration: const InputDecoration(),
                            items: [
                              const DropdownMenuItem(
                                value: 'SUPER_ADMIN',
                                child: Text('الأمانة العامة (إشراف عام)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              ...provider.branches.map((b) => DropdownMenuItem(
                                    value: b.id,
                                    child: Text(b.name, style: const TextStyle(fontSize: 13)),
                                  )),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedBranchId = val);
                            },
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'اسم المستخدم:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _usernameController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              hintText: 'ادخل اسم المستخدم',
                              hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'كلمة المرور:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: AppTheme.primaryBlue,
                                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                              ),
                              const Text(
                                'حفظ تسجيل الدخول على هذا الهاتف',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMain),
                              ),
                            ],
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.statusRedBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.statusRedBorder),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppTheme.statusRedText, fontSize: 12),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                final success = provider.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                  _selectedBranchId,
                                  _rememberMe,
                                );
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainScreen()),
                                  );
                                } else {
                                  setState(() => _errorMessage = 'بيانات الدخول غير صحيحة');
                                }
                              },
                              child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('حسابات تجريبية سريعة:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _quickChip('أمين عام', 'admin', '123', 'SUPER_ADMIN', provider),
                              _quickChip('أمين ثانوي', 'thanawy', '123', 'b_thanawy', provider),
                              _quickChip('أمين إعدادي', 'edady', '123', 'b_edady', provider),
                              _quickChip('أمين ابتدائي', 'ebteday', '123', 'b_ebteday', provider),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String label, String user, String pass, String branchId, AttendanceProvider provider) {
    return InkWell(
      onTap: () {
        _usernameController.text = user;
        _passwordController.text = pass;
        setState(() => _selectedBranchId = branchId);
        provider.login(user, pass, branchId, _rememberMe);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
      ),
    );
  }
}
