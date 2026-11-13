/// 排盘引擎术数规则回归测试
///
/// 覆盖审计中发现的 5 个高危计算错误（修复后固化，防止回退）：
/// 1. 六爻六合表（子午误判合、真六合判不出）
/// 2. 时间起卦时辰数（23 点子时算成亥时、偶数小时偏一）
/// 3. 六爻旺衰表（火/金/水/土四个月令整体错乱）
/// 4. 大六壬壬日寄宫（壬寄亥，非子）
/// 5. 大六壬月将（按节气月/中气换将，非公历月）
library;

import 'package:test/test.dart';

import 'package:qiankunyi_app/features/paipan/engines/liuyao_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/paipan_result.dart';
import 'package:qiankunyi_app/features/paipan/models/yao_model.dart';
import 'package:qiankunyi_app/features/paipan/views/daliuren_page.dart';

void main() {
  group('六爻 - 六合关系', () {
    test('乾为天：子午为六冲，不得同时判为六合', () {
      // 乾为天纳甲地支：子、寅、辰、午、申、戌
      final r = LiuYaoEngine.byNumbers(1, 1, 1);
      final chu = r.benGua.yaos[0]; // 初爻 甲子
      expect(chu.diZhi, equals(DiZhi.zi));
      expect(chu.isChong, isTrue, reason: '子午六冲应成立');
      expect(chu.isHe, isFalse, reason: '子午绝不应判为六合（旧六合表错把午当子之合）');
    });

    test('天地否：巳申、午未为真六合', () {
      // 天地否（上乾下坤）纳甲地支：未、巳、卯、午、申、戌
      final r = LiuYaoEngine.byNumbers(1, 8, 1);
      final si = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.si);
      final shen = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.shen);
      final wu = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.wu);
      final wei = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.wei);
      expect(si.isHe, isTrue, reason: '巳申六合');
      expect(shen.isHe, isTrue, reason: '巳申六合');
      expect(wu.isHe, isTrue, reason: '午未六合');
      expect(wei.isHe, isTrue, reason: '午未六合');
    });
  });

  group('六爻 - 时间起卦时辰数', () {
    test('23 点与 0 点同属子时，起卦结果应一致', () {
      final at23 = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 23, 30));
      final at0 = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 0, 10));
      expect(at23.benGua.name, equals(at0.benGua.name),
          reason: '23:00-00:59 同属子时，下卦与动爻必须一致');
    });

    test('同一时辰内（1 点/2 点为丑时）起卦结果应一致', () {
      final at1 = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 1, 0));
      final at2 = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 2, 0));
      expect(at1.benGua.name, equals(at2.benGua.name));
    });

    test('辰时(7-9 点)与寅时(3-5 点)起卦结果不同（时辰确实参与运算）', () {
      final chen = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 8, 0));
      final yin = LiuYaoEngine.byTime(DateTime(2024, 5, 10, 4, 0));
      expect(chen.benGua.name, isNot(equals(yin.benGua.name)));
    });
  });

  group('六爻 - 旺衰（月令）', () {
    /// 以固定日期起"乾为天"（全阳爻），月令由 tyme 精确节气月决定
    PaipanResult qianAt(DateTime dt) => LiuYaoEngine.fromYaos(
          List.generate(
            6,
            (i) => YaoModel(
              yinYang: YaoYinYang.yang,
              position: YaoPosition.values[i],
            ),
          ),
          time: dt,
        );

    test('巳月（火月）申金死于月令', () {
      // 2024-05-10 已过立夏，属巳月（火月）：火克金 → 金死（旧表误作囚）
      final r = qianAt(DateTime(2024, 5, 10, 12));
      expect(r.monthZhi, equals('巳'));
      final shenYao = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.shen);
      expect(shenYao.wangShuai, equals(WangShuaiLevel.si));
    });

    test('寅月（木月）申金囚于月令', () {
      // 2024-02-20 立春后，属寅月（木月）：金克木 → 金囚
      final r = qianAt(DateTime(2024, 2, 20, 12));
      expect(r.monthZhi, equals('寅'));
      final shenYao = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.shen);
      expect(shenYao.wangShuai, equals(WangShuaiLevel.qiu));
    });

    test('子月（水月）午火死于月令', () {
      // 2023-12-20 大雪后，属子月（水月）：水克火 → 火死
      final r = qianAt(DateTime(2023, 12, 20, 12));
      expect(r.monthZhi, equals('子'));
      final wuYao = r.benGua.yaos.firstWhere((y) => y.diZhi == DiZhi.wu);
      expect(wuYao.wangShuai, equals(WangShuaiLevel.si));
    });

    test('月建与月柱一致（不再用公历月近似）', () {
      // 公历 2 月 10 日仍属丑月（立春前），月建必须与月柱地支一致
      final r = qianAt(DateTime(2024, 2, 10, 12));
      expect(r.monthZhi, equals((r.monthGanZhi ?? '').substring(1)),
          reason: '月建应取自 tyme 精确节气月');
    });
  });

  group('大六壬 - 日干寄宫', () {
    test('壬日寄亥宫（非子宫）', () {
      final r = DaLiuRenEngine.byHour(0, 1, dayGan: '壬', dayZhi: '子');
      expect(r.siKeXia[0], equals('亥'), reason: '十干寄宫（一课下神）：壬亥');
    });

    test('甲日寄寅、癸日寄丑', () {
      expect(DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子').siKeXia[0], '寅');
      expect(DaLiuRenEngine.byHour(0, 1, dayGan: '癸', dayZhi: '子').siKeXia[0], '丑');
    });
  });

  group('大六壬 - 月将（中气换将）', () {
    test('按最近已过中气定月将', () {
      // 2024 年各中气与月将：雨水后登明(0)、春分后河魁(1)、谷雨后从魁(2)…
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 2, 20)), 0, reason: '雨水后登明');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 3, 25)), 1, reason: '春分后河魁');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 4, 25)), 2, reason: '谷雨后从魁');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 6, 25)), 4, reason: '夏至后小吉');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 9, 25)), 7, reason: '秋分后天罡');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 12, 25)), 10, reason: '冬至后大吉');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 1, 25)), 11, reason: '大寒后神后');
    });

    test('立春后、雨水前仍属上一中气的月将（不能按节气月推）', () {
      // 2024-02-10 已在寅月（立春 2/4），但雨水在 2/19 → 月将仍是神后(11)
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 2, 10)), 11);
      // 立春前（2024-01-20 仍属丑月）同样是神后
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 1, 20)), 11);
    });

    test('寅月起课月将临亥', () {
      final r = DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      expect(r.yueJiang, equals(0)); // 登明
      expect(r.yueJiangZhi, equals('亥'));
      expect(r.tianPan, contains('亥'));
    });

    test('月将决定天地盘：不同月将天盘不同', () {
      final yin = DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      final mao = DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子', monthZhiIdx: 3);
      expect(yin.tianPan, isNot(equals(mao.tianPan)));
    });
  });

  group('大六壬 - 天地盘（月将加时）', () {
    test('月将加于时支，其余地支顺排', () {
      const hourIdx = 6; // 午时
      final r = DaLiuRenEngine.byHour(hourIdx, 1,
          dayGan: '甲', dayZhi: '子', monthZhiIdx: 2); // 寅月：登明亥将
      final yjZhi = daliurenZhi[(11 - r.yueJiang) % 12];
      expect(r.tianPan[hourIdx], yjZhi, reason: '时支午上应加月将');
      final yjIdx = daliurenZhi.indexOf(yjZhi);
      for (var i = 0; i < 12; i++) {
        final expectZhi = daliurenZhi[(yjIdx + i - hourIdx + 24) % 12];
        expect(r.tianPan[i], expectZhi,
            reason: '地盘${daliurenZhi[i]}上神应为 $expectZhi');
      }
    });

    test('四课：日阳/日阴/辰阳/辰阴（上神与下神配对）', () {
      final r = DaLiuRenEngine.byHour(3, 1,
          dayGan: '壬', dayZhi: '午', monthZhiIdx: 2);
      expect(r.siKeXia[0], '亥', reason: '壬寄亥宫（一课下神）');
      expect(r.siKeXia[2], '午', reason: '三课下神为日支');
      expect(r.siKeShang[0], r.tianPan[11], reason: '一课上神=亥位天盘');
      expect(r.siKeShang[2], r.tianPan[daliurenZhi.indexOf('午')],
          reason: '三课上神=午位天盘');
      expect(r.siKeXia[1], r.siKeShang[0], reason: '二课下神=一课上神');
      expect(r.siKeXia[3], r.siKeShang[2], reason: '四课下神=三课上神');
    });

    test('三传按九宗门取法：常规法初传必为四课上神之一', () {
      final r = DaLiuRenEngine.byHour(0, 1,
          dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      expect(r.shiYong.length, 3);
      expect(r.chuanFa, isNotEmpty);
      if (!r.chuanFa.contains('昴星') &&
          !r.chuanFa.contains('别责') &&
          !r.chuanFa.contains('八专')) {
        expect(r.siKeShang, contains(r.chuChuan));
      }
    });
  });
}
