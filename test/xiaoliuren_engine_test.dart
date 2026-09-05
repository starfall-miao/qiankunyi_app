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

    test('二月一日午时：月留连(1)，日落位留连(1)，时午顺6回留连(1)', () {
      final r = XiaoLiuRenEngine.byMonthDayHour(2, 1, 6);
      expect(r.monthPos, 1);
      expect(r.dayPos, 1);
      expect(r.resultPos, 1);
      expect(r.resultPalm.name, '留连');
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

    test('三月十五辰时：月速喜(2)，日小吉(4)，时顺4回速喜(2)', () {
      final r = XiaoLiuRenEngine.byMonthDayHour(3, 15, 4);
      expect(r.monthPos, 2);   // 三月 → 速喜
      expect(r.dayPos, 4);     // (2+14)%6 → 小吉
      expect(r.resultPos, 2);  // (4+4)%6 → 速喜
      expect(r.resultPalm.name, '速喜');
    });

    test('随机起课结果在六掌诀范围内', () {
      final r = XiaoLiuRenEngine.random();
      expect(r.resultPos, inInclusiveRange(0, 5));
      expect(xiaoliurenPalms[r.resultPos].name, r.resultPalm.name);
    });

    test('吉凶标签为吉或凶', () {
      for (final p in xiaoliurenPalms) {
        expect(['吉', '凶'], contains(p.goodBad));
      }
    });
  });
}
