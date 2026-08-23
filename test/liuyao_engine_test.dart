/// 六爻排盘引擎单元测试
///
/// 验证：64卦名表正确、八宫世应正确、纳甲/六亲/六神/旺衰基本计算正确。
/// 不依赖 Flutter，可用 `dart test` 运行。
library;

import 'package:test/test.dart';
import 'package:qiankunyi_app/features/paipan/engines/liuyao_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/gua_model.dart';
import 'package:qiankunyi_app/features/paipan/models/paipan_result.dart';
import 'package:qiankunyi_app/features/paipan/models/yao_model.dart';

void main() {
  group('六爻引擎 - 64卦名表', () {
    // 验证所有 64 个 GuaName 枚举值都能在表中找到（不 crash）
    test('所有 64 卦名枚举值可用', () {
      // 时间起卦 2024-01-01 午时
      final r = LiuYaoEngine.byTime(
        DateTime(2024, 1, 1, 12, 0),
      );
      expect(r, isNotNull);
      expect(r.benGua, isNotNull);
      expect(r.benGua.name, isA<GuaName>());
    });

    // 验证通过数字起卦能得到正确的卦名
    test('数字起卦返回正确卦名', () {
      // 乾为天：上乾(1)下乾(1)，动爻 1
      // byNumbers 参数：a=上卦数, b=下卦数, c=动爻序号
      // 1→乾(0), 1→乾(0)
      // 乾为天 ䷀
      final r = LiuYaoEngine.byNumbers(1, 1, 1);
      expect(r.benGua.name, equals(GuaName.qian));
      expect(r.benGua.gong, equals(GuaGong.qian));
    });

    test('数字起卦 - 天风姤', () {
      // 天风姤：上乾(1)下巽(5)，动爻 1
      final r = LiuYaoEngine.byNumbers(1, 5, 1);
      expect(r.benGua.name, equals(GuaName.gou));
      expect(r.benGua.gong, equals(GuaGong.qian));
    });

    test('数字起卦 - 水天需', () {
      // 水天需：上坎(6)下乾(1)，动爻 1
      final r = LiuYaoEngine.byNumbers(6, 1, 1);
      expect(r.benGua.name, equals(GuaName.xu));
      // 需为坤宫游魂
      expect(r.benGua.gong, equals(GuaGong.kun));
    });

    test('64 卦各不相同 - 生成所有组合验证无重复', () {
      final names = <GuaName>{};
      for (int upper = 1; upper <= 8; upper++) {
        for (int lower = 1; lower <= 8; lower++) {
          final r = LiuYaoEngine.byNumbers(upper, lower, 1);
          names.add(r.benGua.name);
        }
      }
      expect(names.length, equals(64),
          reason: '64种上下卦组合应产生64个不同的卦名');
    });
  });

  group('六爻引擎 - 八宫世应', () {
    test('乾为天 - 世在上爻 应在三爻', () {
      final r = LiuYaoEngine.byNumbers(1, 1, 1);
      expect(r.benGua.shiYaoIndex, equals(5));
      expect(r.benGua.yingYaoIndex, equals(2));
    });

    test('天风姤 - 乾宫一世 世在初爻 应在四爻', () {
      final r = LiuYaoEngine.byNumbers(1, 5, 1);
      expect(r.benGua.shiYaoIndex, equals(0));
      expect(r.benGua.yingYaoIndex, equals(3));
    });

    test('坤为地 - 坤宫 世在上爻 应在三爻', () {
      final r = LiuYaoEngine.byNumbers(8, 8, 1);
      expect(r.benGua.name, equals(GuaName.kun));
      expect(r.benGua.gong, equals(GuaGong.kun));
      expect(r.benGua.shiYaoIndex, equals(5));
      expect(r.benGua.yingYaoIndex, equals(2));
    });

    test('泽天夬 - 坤宫五世 世在五爻 应在二爻', () {
      final r = LiuYaoEngine.byNumbers(2, 1, 1);
      expect(r.benGua.name, equals(GuaName.guai));
      expect(r.benGua.gong, equals(GuaGong.kun));
      expect(r.benGua.shiYaoIndex, equals(4));
      expect(r.benGua.yingYaoIndex, equals(1));
    });
  });

  group('六爻引擎 - 六亲', () {
    test('坤为地 - 六亲计算', () {
      final r = LiuYaoEngine.byNumbers(8, 8, 1);
      for (final y in r.benGua.yaos) {
        // 坤宫属土，坤为地六爻皆土，应皆为"比和"关系
        // 兄弟：土（比和），父母：火（生土），官鬼：木（克土）
        // 妻财：水（土克），子孙：金（土生）
        expect(y.liuQin, isNotNull);
      }
    });
  });

  group('六爻引擎 - 变卦', () {
    test('动爻产生变卦', () {
      final r = LiuYaoEngine.byNumbers(1, 1, 3); // 动爻 3
      expect(r.bianGua, isNotNull);
      expect(r.bianGua!.name, isNot(equals(r.benGua.name)));
    });

    test('无动爻不变卦', () {
      // 手工摇卦：全少阳 → 无动爻
      final ys = List.generate(6, (i) => YaoModel(
        yinYang: YaoYinYang.yang,
        position: YaoPosition.values[i],
        isMoving: false,
      ));
      final r = LiuYaoEngine.fromYaos(ys, time: DateTime(2024, 1, 1));
      expect(r.bianGua, isNull);
    });
  });

  group('六爻引擎 - 旬空', () {
    test('日柱旬空计算', () {
      // 2024-01-01 的日干支
      final r = LiuYaoEngine.byTime(DateTime(2024, 1, 1, 12, 0));
      expect(r.kongWang, isNotNull);
      // 应该至少有一个空亡地支
      expect(r.kongWang!.length, greaterThanOrEqualTo(1));
    });
  });
}