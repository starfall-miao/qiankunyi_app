import 'package:flutter_test/flutter_test.dart';
import 'package:qiankunyi_app/features/paipan/engines/xiaoliuren_engine.dart';

void main() {
  group('小六壬引擎', () {
    test('正月子时起课：大安起，正月=大安(0)，日子时=0 → 大安', () {
      final r = XiaoLiuRenEngine.byMonthDayHour(1, 1, 0);
      expect(r.monthPos, 0);
      expect(r.dayPos, 0);
      expect(r.resultPos, 0);
      expect(r.resultPalm.name, '大安');
    });

    test('二月午时：月=留连(1)，日=午=留连顺1=速喜(2)，时午=速喜顺6=速喜(2)', () {
      final r = XiaoLiuRenEngine.byMonthDayHour(2, 1, 6);
      expect(r.monthPos, 1);
      expect(r.dayPos, 2);
      expect(r.resultPos, 2);
      expect(r.resultPalm.name, '速喜');
    });

    test('六掌诀齐全且吉凶标记正确', () {
      expect(xiaoliurenPalms.length, 6);
      expect(xiaoliurenPalms[0].name, '大安');
      expect(xiaoliurenPalms[5].name, '空亡');
      // 吉凶分布：3吉3凶
      final good = xiaoliurenPalms.where((p) => p.goodBad == '吉').length;
      expect(good, 3);
    });

    test('数字起课：1,1,1 → 大安', () {
      final r = XiaoLiuRenEngine.byNumbers(1, 1, 1);
      expect(r.resultPos, 0);
      expect(r.resultPalm.name, '大安');
    });
  });
}
