/// 梅花易数排盘引擎单元测试
library;

import 'package:test/test.dart';
import 'package:qiankunyi_app/features/paipan/engines/meihua_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/gua_model.dart';

void main() {
  group('梅花引擎 - 数字起卦', () {
    test('乾为天：1,1,1', () {
      final r = MeihuaEngine.fromNumbers(1, 1, 1);
      expect(r.benGua.name, equals(GuaName.qian));
    });

    test('坤为地：8,8,1', () {
      final r = MeihuaEngine.fromNumbers(8, 8, 1);
      expect(r.benGua.name, equals(GuaName.kun));
    });

    test('地天泰：8,1,1（上坤下乾）', () {
      final r = MeihuaEngine.fromNumbers(8, 1, 1);
      expect(r.benGua.name, equals(GuaName.tai));
    });

    test('天地否：1,8,1（上乾下坤）', () {
      final r = MeihuaEngine.fromNumbers(1, 8, 1);
      expect(r.benGua.name, equals(GuaName.pi));
    });

    test('64 卦各不相同', () {
      final names = <GuaName>{};
      for (int a = 1; a <= 8; a++) {
        for (int b = 1; b <= 8; b++) {
          final r = MeihuaEngine.fromNumbers(a, b, 1);
          names.add(r.benGua.name);
        }
      }
      expect(names.length, equals(64));
    });
  });

  group('梅花引擎 - 体用生克', () {
    test('体用生克不为空', () {
      final r = MeihuaEngine.fromNumbers(1, 8, 3);
      final tiYong = MeihuaEngine.getTiYong(r);
      expect(tiYong, isNotEmpty);
      expect(tiYong, contains('体卦'));
      expect(tiYong, contains('用卦'));
    });
  });

  group('梅花引擎 - 物象起卦', () {
    test('fromTrigrams 乾为天', () {
      final r = MeihuaEngine.fromTrigrams(0, 0, 0);
      expect(r.benGua.name, equals(GuaName.qian));
    });

    test('fromTrigrams 天火同人', () {
      final r = MeihuaEngine.fromTrigrams(0, 2, 1);
      expect(r.benGua.name, equals(GuaName.tongRen));
    });
  });

  group('梅花引擎 - 时间起卦', () {
    test('时间起卦返回结果', () {
      final r = MeihuaEngine.fromDateTime(DateTime(2024, 1, 1, 12, 0));
      expect(r.benGua, isNotNull);
      expect(r.method, equals('时间起卦'));
    });
  });
}