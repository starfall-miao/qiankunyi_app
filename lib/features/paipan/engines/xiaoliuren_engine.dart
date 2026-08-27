// 小六壬排盘引擎
// 纯 Dart 实现，离线运行
//
// 小六壬：以月、日、时（或三个数字）起课，
// 在"大安→留连→速喜→赤口→小吉→空亡"六个掌诀中顺数定位，
// 以最终落位掌诀断吉凶。

/// 六掌诀定义
class XiaoLiuRenName {
  final int index;      // 0-5
  final String name;    // 名称
  final String element; // 五行
  final String goodBad; // 吉/凶/平
  final String meaning; // 象义
  const XiaoLiuRenName(
      this.index, this.name, this.element, this.goodBad, this.meaning);
}

/// 六个掌诀（从大安起顺数）
const xiaoliurenPalms = [
  XiaoLiuRenName(0, '大安', '木', '吉', '身不动时，属木青龙，谋事主一、五、七。有身安、平安之意。'),
  XiaoLiuRenName(1, '留连', '水', '凶', '卒未归时，属水玄武，谋事主二、八、十。有拖延、滞留之意。'),
  XiaoLiuRenName(2, '速喜', '火', '吉', '人便至时，属火朱雀，谋事主三、六、九。有迅速、喜事之意。'),
  XiaoLiuRenName(3, '赤口', '金', '凶', '官事凶时，属金白虎，谋事主四、七、十。有口舌、是非之意。'),
  XiaoLiuRenName(4, '小吉', '木', '吉', '人来喜时，属木六合，谋事主一、五、七。有和合、顺利之意。'),
  XiaoLiuRenName(5, '空亡', '土', '凶', '音信稀时，属土勾陈，谋事主三、六、九。有落空、无结果之意。'),
];

/// 小六壬排盘结果
class XiaoLiuRenResult {
  final int month;       // 起课月（1-12）
  final int day;         // 起课日（1-30）
  final int hour;        // 起课时辰（0-11，0=子时）
  final int monthPos;    // 月落位掌诀索引
  final int dayPos;      // 日落位掌诀索引
  final int resultPos;   // 最终落位掌诀索引
  final String method;   // 起课方式：月日时 / 随机 / 数字

  XiaoLiuRenResult({
    required this.month,
    required this.day,
    required this.hour,
    required this.monthPos,
    required this.dayPos,
    required this.resultPos,
    required this.method,
  });

  XiaoLiuRenName get resultPalm => xiaoliurenPalms[resultPos];
  XiaoLiuRenName get monthPalm => xiaoliurenPalms[monthPos];
  XiaoLiuRenName get dayPalm => xiaoliurenPalms[dayPos];

  Map<String, dynamic> toJson() => {
        'month': month,
        'day': day,
        'hour': hour,
        'monthPos': monthPos,
        'dayPos': dayPos,
        'resultPos': resultPos,
        'method': method,
      };

  factory XiaoLiuRenResult.fromJson(Map<String, dynamic> j) =>
      XiaoLiuRenResult(
        month: j['month'] as int,
        day: j['day'] as int,
        hour: j['hour'] as int,
        monthPos: j['monthPos'] as int,
        dayPos: j['dayPos'] as int,
        resultPos: j['resultPos'] as int,
        method: j['method'] as String? ?? '数字',
      );
}

/// 小六壬引擎
class XiaoLiuRenEngine {
  /// 从月日时起课（月1-12、日1-30、时辰0-11，0=子时）
  static XiaoLiuRenResult byMonthDayHour(
      int month, int day, int hour) {
    // 正月起大安(0)，顺数至月
    final monthPos = (month - 1) % 6;
    // 月上起日：从月落位开始，顺数 day-1 位
    final dayPos = (monthPos + (day - 1)) % 6;
    // 日上起时：从日落位开始，顺数 hour 位（子时=0）
    final resultPos = (dayPos + hour) % 6;
    return XiaoLiuRenResult(
      month: month,
      day: day,
      hour: hour,
      monthPos: monthPos,
      dayPos: dayPos,
      resultPos: resultPos,
      method: '月日时',
    );
  }

  /// 从三个数字起课（数字1起大安顺数）
  static XiaoLiuRenResult byNumbers(int n1, int n2, int n3) {
    final monthPos = (n1 - 1) % 6;
    final dayPos = (monthPos + (n2 - 1)) % 6;
    final resultPos = (dayPos + (n3 - 1)) % 6;
    return XiaoLiuRenResult(
      month: n1,
      day: n2,
      hour: n3 % 12,
      monthPos: monthPos,
      dayPos: dayPos,
      resultPos: resultPos,
      method: '数字',
    );
  }

  /// 随机起课
  static XiaoLiuRenResult random({int seed = 0}) {
    final rand = seed == 0
        ? DateTime.now().millisecondsSinceEpoch % 100000
        : seed;
    final n1 = (rand ~/ 7) % 12 + 1;
    final n2 = (rand ~/ 11) % 30 + 1;
    final n3 = (rand ~/ 13) % 6 + 1;
    return byNumbers(n1, n2, n3);
  }
}
