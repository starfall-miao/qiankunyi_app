/// 数据序列化回归测试
///
/// 覆盖历史缺陷（保存 → 重新打开后字段丢失，属静默数据丢失）：
/// 1. 八字 toJson 写 'shishenMap'（小写 s）而 fromJson 读 'shiShenMap'
///    → 十神整块丢失（详情页十神区消失、AI 上下文缺十神）
/// 2. 六爻 toJson 写 'hiddenFuShen' 而 fromJson 漏读
///    → 藏爻/伏神丢失（详情与截图模板不显示）
library;

import 'package:test/test.dart';

import 'package:qiankunyi_app/features/paipan/engines/bazi_engine.dart';
import 'package:qiankunyi_app/features/paipan/engines/liuyao_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/bazi_models.dart';
import 'package:qiankunyi_app/features/paipan/models/paipan_result.dart';

void main() {
  group('八字序列化往返', () {
    test('toJson → fromJson 保留十神映射', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 1, 1, 12, 0),
        isMale: true,
        hourIndex: 6,
      );
      expect(r.shiShenMap, isNotEmpty, reason: '引擎应产出十神映射');

      final back = BaziResult.fromJson(r.toJson());
      expect(back.shiShenMap, equals(r.shiShenMap),
          reason: '八字卦例保存后重载，十神不能丢失');
      expect(back.shiShenMap.containsKey('日主'), isTrue);
    });

    test('两种历史键名均可读取（shishenMap / shiShenMap）', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(1990, 5, 20, 8, 0),
        isMale: false,
        hourIndex: 4,
      );

      // 现有 toJson 写的是 'shishenMap'（小写 s）——必须能读回
      final lower = Map<String, dynamic>.of(r.toJson());
      expect(lower.containsKey('shishenMap'), isTrue);
      expect(BaziResult.fromJson(lower).shiShenMap, equals(r.shiShenMap));

      // 若数据使用驼峰键 'shiShenMap'，同样要能读回（双键兼容）
      final camel = Map<String, dynamic>.of(r.toJson());
      camel['shiShenMap'] = camel.remove('shishenMap');
      expect(BaziResult.fromJson(camel).shiShenMap, equals(r.shiShenMap));
    });
  });

  group('六爻序列化往返', () {
    test('toJson → fromJson 保留藏爻/伏神', () {
      final base = LiuYaoEngine.byNumbers(1, 1, 1);
      // 手工构造带藏爻的结果（乾为天六亲齐全，引擎结果可能为空，此处显式赋值）
      final withFuShen = PaipanResult(
        benGua: base.benGua,
        bianGua: base.bianGua,
        huGua: base.huGua,
        paipanTime: base.paipanTime,
        method: base.method,
        school: base.school,
        monthZhi: base.monthZhi,
        monthGanZhi: base.monthGanZhi,
        dayGanZhi: base.dayGanZhi,
        shenSha: base.shenSha,
        kongWang: base.kongWang,
        naYin: base.naYin,
        fuShen: const [
          FuShenInfo(
            liuQin: '官鬼',
            ganZhi: '壬申',
            yaoIndex: 4,
            feiShenLiuQin: '兄弟',
            feiShenGanZhi: '壬申',
          ),
          FuShenInfo(liuQin: '父母', ganZhi: '乙未', yaoIndex: 0),
        ],
      );

      final back = PaipanResult.fromJson(withFuShen.toJson());
      expect(back.fuShen.length, 2, reason: '伏神保存后重载不能丢失');
      expect(back.fuShen.first.liuQin, '官鬼');
      expect(back.fuShen.first.ganZhi, '壬申');
      expect(back.fuShen.first.yaoIndex, 4, reason: '所伏爻位应保留');
      expect(back.fuShen.first.feiShenLiuQin, '兄弟', reason: '飞神六亲应保留');
      // 兼容旧接口
      expect(back.hiddenFuShen, equals(['官鬼 壬申', '父母 乙未']));
    });

    test('旧格式（字符串列表）可兼容读取', () {
      final r = LiuYaoEngine.byNumbers(1, 5, 1); // 天风姤：缺妻财，有伏神
      final legacy = Map<String, dynamic>.of(r.toJson())
        ..remove('fuShen')
        ..['hiddenFuShen'] = ['妻财 甲寅'];
      final back = PaipanResult.fromJson(legacy);
      expect(back.fuShen.length, 1);
      expect(back.fuShen.first.liuQin, '妻财');
      expect(back.fuShen.first.yaoIndex, -1, reason: '旧数据无爻位信息');
    });

    test('引擎结果整体往返保持一致', () {
      final r = LiuYaoEngine.byNumbers(1, 5, 4); // 天风姤，动爻四
      final back = PaipanResult.fromJson(r.toJson());

      expect(back.benGua.name, equals(r.benGua.name));
      expect(back.benGua.shiYaoIndex, equals(r.benGua.shiYaoIndex));
      expect(back.hiddenFuShen, equals(r.hiddenFuShen));
      expect(back.dayGanZhi, equals(r.dayGanZhi));
      expect(back.kongWang, equals(r.kongWang));
      expect(back.bianGua?.name, equals(r.bianGua?.name));
    });

    test('缺 hiddenFuShen 字段的旧数据回退为空列表', () {
      final r = LiuYaoEngine.byNumbers(1, 1, 1);
      final legacy = Map<String, dynamic>.of(r.toJson())..remove('hiddenFuShen');
      final back = PaipanResult.fromJson(legacy);
      expect(back.hiddenFuShen, isEmpty);
    });
  });
}
