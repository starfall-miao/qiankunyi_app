/// 八字排盘引擎单元测试
library;

import 'package:test/test.dart';
import 'package:qiankunyi_app/features/paipan/engines/bazi_engine.dart';

void main() {
  group('八字引擎 - 四柱', () {
    test('2024-01-01 午时 男性', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6, // 午时
      );
      expect(r.yearZhu.ganZhi, isNotEmpty);
      expect(r.monthZhu.ganZhi, isNotEmpty);
      expect(r.dayZhu.ganZhi, isNotEmpty);
      expect(r.hourZhu.ganZhi, isNotEmpty);
      // 四柱格式：每个干支字符串长度为2
      expect(r.yearZhu.ganZhi.length, equals(2));
      expect(r.monthZhu.ganZhi.length, equals(2));
      expect(r.dayZhu.ganZhi.length, equals(2));
      expect(r.hourZhu.ganZhi.length, equals(2));
    });
  });

  group('八字引擎 - 十神', () {
    test('十神映射不为空', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.shiShenMap.isNotEmpty, isTrue);
      // 日主应出现在十神映射中
      expect(r.shiShenMap.containsKey('日主'), isTrue);
    });
  });

  group('八字引擎 - 大运', () {
    test('大运列表长度', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.daYun.length, equals(8));
    });

    test('大运起运年龄为正', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      for (final dy in r.daYun) {
        expect(dy.startAge, greaterThan(0));
        expect(dy.ganZhi.length, equals(2));
      }
    });
  });

  group('八字引擎 - 旺衰/五行统计', () {
    test('五行旺衰不为空', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.wuXingWangShuai.isNotEmpty, isTrue);
      expect(r.wuXingCounts.isNotEmpty, isTrue);
    });
  });

  group('八字引擎 - 空亡', () {
    test('空亡计算', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.kongWang.isNotEmpty, isTrue);
      // 空亡是两个地支
      expect(r.kongWang.length, equals(2));
    });
  });

  group('八字引擎 - 纳音', () {
    test('四柱纳音不为空', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.yearZhu.naYin, isNotNull);
      expect(r.monthZhu.naYin, isNotNull);
      expect(r.dayZhu.naYin, isNotNull);
      expect(r.hourZhu.naYin, isNotNull);
    });
  });

  group('八字引擎 - 性别差异', () {
    test('男女大运不同（阳年男顺排，女逆排）', () {
      final male = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      final female = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: false,
        hourIndex: 6,
      );
      // 大运可能不同（顺逆排差异）
      expect(male.daYun[0].ganZhi, isNot(equals(female.daYun[0].ganZhi)));
    });
  });
}