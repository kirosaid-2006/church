import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../models/branch.dart';
import '../models/user.dart';
import '../models/servant.dart';
import '../models/attendance_record.dart';

class AttendanceProvider with ChangeNotifier {
  static const String _prefsKey = 'church_clean_data_v2';
  static const String _sessionKey = 'church_clean_session_v2';

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  List<Servant> _servants = [];
  List<Servant> get servants => _servants;

  List<String> _fridays = [];
  List<String> get fridays => _fridays;

  String? _selectedFriday;
  String? get selectedFriday => _selectedFriday;

  String _filterBranchId = 'ALL';
  String get filterBranchId => _filterBranchId;

  String _managementBranchId = 'ALL';
  String get managementBranchId => _managementBranchId;

  String _reportsBranchId = 'ALL';
  String get reportsBranchId => _reportsBranchId;

  final Map<String, AttendanceRecord> _records = {};

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AttendanceProvider() {
    loadData();
  }

  void setFilterBranchId(String bId) {
    _filterBranchId = bId;
    notifyListeners();
  }

  void setManagementBranchId(String bId) {
    _managementBranchId = bId;
    notifyListeners();
  }

  void setReportsBranchId(String bId) {
    _reportsBranchId = bId;
    notifyListeners();
  }

  void setSelectedFriday(String date) {
    _selectedFriday = date;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        _branches = (data['branches'] as List).map((e) => Branch.fromMap(e)).toList();
        _users = (data['users'] as List).map((e) => AppUser.fromMap(e)).toList();
        _servants = (data['servants'] as List).map((e) => Servant.fromMap(e)).toList();
        _fridays = (data['fridays'] as List).map((e) => e.toString()).toList();

        final recs = data['records'] as Map<String, dynamic>?;
        if (recs != null) {
          recs.forEach((k, v) {
            _records[k] = AttendanceRecord.fromMap(v);
          });
        }
      } catch (e) {
        _initCleanSeed();
      }
    } else {
      _initCleanSeed();
    }

    final savedSession = prefs.getString(_sessionKey);
    if (savedSession != null) {
      try {
        _currentUser = AppUser.fromMap(jsonDecode(savedSession));
      } catch (_) {
        _currentUser = null;
      }
    }

    if (_fridays.isEmpty) {
      final now = DateTime.now();
      generateFridaysForMonth(now.year, now.month);
    } else {
      _selectedFriday ??= _fridays.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _initCleanSeed() {
    _branches = [];
    _servants = [];
    _users = [
      AppUser(
        username: 'مجدي',
        password: 'مجدي 1234',
        name: 'أ/ مجدي خليل نوح',
        role: 'super_admin',
        branchId: 'SUPER_ADMIN',
      ),
    ];

    final now = DateTime.now();
    generateFridaysForMonth(now.year, now.month);
    saveData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      'branches': _branches.map((b) => b.toMap()).toList(),
      'users': _users.map((u) => u.toMap()).toList(),
      'servants': _servants.map((s) => s.toMap()).toList(),
      'fridays': _fridays,
      'records': _records.map((k, v) => MapEntry(k, v.toMap())),
    };

    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  bool login(String username, String password, String branchId, bool rememberMe) {
    final cleanUser = username.trim().toLowerCase();
    final cleanPass = password.trim();

    final user = _users.firstWhere(
      (u) {
        final uMatch = u.username.toLowerCase() == cleanUser ||
            (u.username == 'مجدي' && (cleanUser == 'magdy' || cleanUser == 'magdi'));
        final pMatch = u.password == cleanPass ||
            (u.password == 'مجدي 1234' && (cleanPass == '1234' || cleanPass == 'magdy1234'));
        final bMatch = u.branchId == branchId || (u.isSuperAdmin && branchId == 'SUPER_ADMIN');
        return uMatch && pMatch && bMatch;
      },
      orElse: () => AppUser(username: '', password: '', name: '', role: '', branchId: ''),
    );

    if (user.username.isNotEmpty) {
      _currentUser = user;
      if (rememberMe) {
        SharedPreferences.getInstance().then((p) {
          p.setString(_sessionKey, jsonEncode(user.toMap()));
        });
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  void generateFridaysForMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday == DateTime.friday) {
        final iso = DateFormat('yyyy-MM-dd').format(date);
        if (!_fridays.contains(iso)) {
          _fridays.add(iso);
        }
      }
    }
    _fridays.sort();
    _selectedFriday ??= _fridays.isNotEmpty ? _fridays.first : null;
    saveData();
    notifyListeners();
  }

  void generateFridaysForYear(int year) {
    for (int m = 1; m <= 12; m++) {
      final daysInMonth = DateTime(year, m + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, m, day);
        if (date.weekday == DateTime.friday) {
          final iso = DateFormat('yyyy-MM-dd').format(date);
          if (!_fridays.contains(iso)) {
            _fridays.add(iso);
          }
        }
      }
    }
    _fridays.sort();
    saveData();
    notifyListeners();
  }

  AttendanceRecord getRecord(String date, String servantId) {
    final key = '${date}_$servantId';
    return _records[key] ?? AttendanceRecord(date: date, servantId: servantId);
  }

  void toggleAttendance(String servantId, String type) {
    if (_selectedFriday == null) return;
    final key = '${_selectedFriday}_$servantId';
    final rec = _records[key] ?? AttendanceRecord(date: _selectedFriday!, servantId: servantId);

    if (type == 'quddas') {
      rec.quddas = (rec.quddas == 0) ? 1 : (rec.quddas == 1 ? 2 : 0);
    } else if (type == 'khedma') {
      rec.khedma = (rec.khedma == 0) ? 1 : (rec.khedma == 1 ? 2 : 0);
    } else if (type == 'egtmaa') {
      rec.egtmaa = (rec.egtmaa == 0) ? 1 : (rec.egtmaa == 1 ? 2 : 0);
    }

    _records[key] = rec;
    saveData();
    notifyListeners();
  }

  void bulkMarkAllPresent() {
    if (_selectedFriday == null) return;
    final visible = getFilteredServants();
    for (var s in visible) {
      final key = '${_selectedFriday}_${s.id}';
      final rec = _records[key] ?? AttendanceRecord(date: _selectedFriday!, servantId: s.id);
      rec.quddas = 1;
      _records[key] = rec;
    }
    saveData();
    notifyListeners();
  }

  int calculateConsecutiveAbsences(String servantId) {
    if (_fridays.isEmpty || _selectedFriday == null) return 0;
    final curIndex = _fridays.indexOf(_selectedFriday!);
    if (curIndex == -1) return 0;

    int count = 0;
    for (int i = curIndex; i >= 0; i--) {
      final fDate = _fridays[i];
      final key = '${fDate}_$servantId';
      final rec = _records[key];
      if (rec != null) {
        final attended = rec.quddas == 1 || rec.khedma == 1 || rec.egtmaa == 1;
        final excuse = rec.quddas == 2 || rec.khedma == 2 || rec.egtmaa == 2;
        if (attended || excuse) {
          break;
        } else {
          count++;
        }
      } else {
        count++;
      }
    }
    return count;
  }

  List<Servant> getFilteredServants({String query = ''}) {
    var list = _servants.where((s) => s.active).toList();

    if (_currentUser != null && !_currentUser!.isSuperAdmin) {
      list = list.where((s) => s.branchId == _currentUser!.branchId).toList();
    } else if (_filterBranchId != 'ALL') {
      list = list.where((s) => s.branchId == _filterBranchId).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((s) => s.name.toLowerCase().contains(q) || s.phone.contains(q)).toList();
    }

    return list;
  }

  List<Servant> getServantsForManagement() {
    var list = _servants.where((s) => s.active).toList();
    if (_currentUser != null && !_currentUser!.isSuperAdmin) {
      list = list.where((s) => s.branchId == _currentUser!.branchId).toList();
    } else if (_managementBranchId != 'ALL') {
      list = list.where((s) => s.branchId == _managementBranchId).toList();
    }
    return list;
  }

  List<Servant> getServantsForReports() {
    var list = _servants.where((s) => s.active).toList();
    if (_currentUser != null && !_currentUser!.isSuperAdmin) {
      list = list.where((s) => s.branchId == _currentUser!.branchId).toList();
    } else if (_reportsBranchId != 'ALL') {
      list = list.where((s) => s.branchId == _reportsBranchId).toList();
    }
    return list;
  }

  void addServant(String name, String phone, String branchId) {
    final s = Servant(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      branchId: branchId,
    );
    _servants.add(s);
    saveData();
    notifyListeners();
  }

  void removeServant(String id) {
    _servants.removeWhere((s) => s.id == id);
    saveData();
    notifyListeners();
  }

  void addBranch(String name, String adminName, String? username, String? password) {
    final bId = 'b_${DateTime.now().millisecondsSinceEpoch}';
    _branches.add(Branch(id: bId, name: name, adminName: adminName));

    if (username != null && username.isNotEmpty) {
      _users.add(AppUser(
        username: username,
        password: (password != null && password.isNotEmpty) ? password : '1234',
        name: adminName,
        role: 'branch_admin',
        branchId: bId,
      ));
    }
    saveData();
    notifyListeners();
  }

  void deleteBranch(String branchId) {
    _branches.removeWhere((b) => b.id == branchId);
    _servants.removeWhere((s) => s.branchId == branchId);
    _users.removeWhere((u) => u.branchId == branchId);
    if (_filterBranchId == branchId) _filterBranchId = 'ALL';
    if (_managementBranchId == branchId) _managementBranchId = 'ALL';
    if (_reportsBranchId == branchId) _reportsBranchId = 'ALL';
    saveData();
    notifyListeners();
  }

  Future<void> exportAttendanceCsv() async {
    final servants = getServantsForReports();
    if (servants.isEmpty) return;

    final StringBuffer buffer = StringBuffer();
    buffer.write('\uFEFF');
    buffer.writeln('اسم الخادم,الفرع,رقم الهاتف,نسبة القداس,نسبة الخدمة,نسبة الاجتماع');

    final totalFridays = _fridays.isEmpty ? 1 : _fridays.length;

    for (var s in servants) {
      final branch = _branches.firstWhere((b) => b.id == s.branchId, orElse: () => Branch(id: '', name: '', adminName: ''));
      int q = 0, k = 0, e = 0;

      for (var f in _fridays) {
        final rec = _records['${f}_${s.id}'];
        if (rec != null) {
          if (rec.quddas == 1) q++;
          if (rec.khedma == 1) k++;
          if (rec.egtmaa == 1) e++;
        }
      }

      final qPct = '${((q / totalFridays) * 100).round()}%';
      final kPct = '${((k / totalFridays) * 100).round()}%';
      final ePct = '${((e / totalFridays) * 100).round()}%';

      buffer.writeln('"${s.name}","${branch.name}","${s.phone}","$qPct","$kPct","$ePct"');
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/تقرير_حضور_الخدام_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
      await file.writeAsString(buffer.toString(), encoding: utf8);
      await Share.shareXFiles([XFile(file.path)], text: 'تقرير حضور الخدام - كنيسة السيدة العذراء والشهيدة كاترين');
    } catch (_) {}
  }
}
