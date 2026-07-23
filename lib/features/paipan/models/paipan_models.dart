/// 排盘 - 数据模型
class PaipanResult {
  final DateTime birthDate;
  final int gender; // 0: 女, 1: 男
  final String bazi; // 八字字符串

  const PaipanResult({
    required this.birthDate,
    required this.gender,
    required this.bazi,
  });
}
