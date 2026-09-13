class AttendanceRecord {
  final String date; // YYYY-MM-DD
  final String servantId;
  int quddas; // 0 = absent, 1 = present, 2 = excuse
  int khedma;
  int egtmaa;

  AttendanceRecord({
    required this.date,
    required this.servantId,
    this.quddas = 0,
    this.khedma = 0,
    this.egtmaa = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'servantId': servantId,
      'quddas': quddas,
      'khedma': khedma,
      'egtmaa': egtmaa,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      date: map['date'] ?? '',
      servantId: map['servantId'] ?? '',
      quddas: map['quddas'] ?? 0,
      khedma: map['khedma'] ?? 0,
      egtmaa: map['egtmaa'] ?? 0,
    );
  }
}
