/// 八字全逻辑链核验测试
///
/// 用独立的规则实现校验：干支纪年/月/日（tyme）、五鼠遁时柱、十神、
/// 藏干、纳音、五行旺衰、八宫…（八字部分）、大运顺逆与起运、旬空。
library;

import 'package:test/test.dart';
import 'package:tyme/tyme.dart' as tyme;

import 'package:qiankunyi_app/features/paipan/engines/bazi_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/bazi_models.dart';
import 'package:qiankunyi_app/features/reference/data/reference_data.dart';

const _gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
const _zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

// ───────────── 独立参考数据 ─────────────

/// 藏干（本气/中气/余气）
const _cangGan = <String, List<String>>{
  '子': ['癸'], '丑': ['己', '癸', '辛'], '寅': ['甲', '丙', '戊'],
  '卯': ['乙'], '辰': ['戊', '乙', '癸'], '巳': ['丙', '庚', '戊'],
  '午': ['丁', '己'], '未': ['己', '丁', '乙'], '申': ['庚', '壬', '戊'],
  '酉': ['辛'], '戌': ['戊', '辛', '丁'], '亥': ['壬', '甲'],
};

/// 五行
const _ganWx = {
  '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
  '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
};

/// 天干阴阳（阳=true）
const _ganYang = {
  '甲': true, '乙': false, '丙': true, '丁': false, '戊': true,
  '己': false, '庚': true, '辛': false, '壬': true, '癸': false,
};

const _sheng = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'};
const _ke = {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'};

/// 十神（独立实现）
String _shiShen(String dayGan, String targetGan) {
  final dWx = _ganWx[dayGan]!, tWx = _ganWx[targetGan]!;
  final sameYy = _ganYang[dayGan] == _ganYang[targetGan];
  if (dWx == tWx) return sameYy ? '比肩' : '劫财';
  if (_sheng[dWx] == tWx) return sameYy ? '食神' : '伤官';
  if (_sheng[tWx] == dWx) return sameYy ? '偏印' : '正印';
  if (_ke[dWx] == tWx) return sameYy ? '偏财' : '正财';
  return sameYy ? '七杀' : '正官';
}

/// 五鼠遁（独立实现）：子时起干
String _hourGz(String dayGan, int hourIdx) {
  final startGanIdx = (_gan.indexOf(dayGan) % 5) * 2;
  return '${_gan[(startGanIdx + hourIdx) % 10]}${_zhi[hourIdx]}';
}

void main() {
  group('藏干（十二支本气/中气/余气）', () {
    test('十二支藏干与通行藏干表一致', () {
      final wrong = <String>[];
      for (final z in _zhi) {
        final expectList = _cangGan[z]!;
        final actual = BaiZiEngine.cangGanOf(z);
        final actualList = <String>[];
        for (final k in ['本气', '中气', '余气']) {
          final v = actual[k];
          if (v != null && v != '无') actualList.add(v);
        }
        if (actualList.join() != expectList.join()) {
          wrong.add('$z: 期望 $expectList 实际 $actualList');
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  group('十神（10 日干 × 10 目标天干）', () {
    test('100 组合十神全部正确', () {
      final wrong = <String>[];
      for (final d in _gan) {
        for (final t in _gan) {
          final expect = _shiShen(d, t);
          final actual = BaiZiEngine.shiShenOf(d, t);
          if (actual != expect) wrong.add('日干$d 对 $t: 期望 $expect 实际 $actual');
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  group('五鼠遁（10 日干 × 12 时辰）', () {
    test('120 组合时柱全部正确', () {
      final wrong = <String>[];
      for (final d in _gan) {
        for (var h = 0; h < 12; h++) {
          final expect = _hourGz(d, h);
          final actual = BaiZiEngine.hourGanZhiOf('${d}子', h);
          if (actual != expect) wrong.add('日干$d ${_zhi[h]}时: 期望 $expect 实际 $actual');
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });

    test('甲己日起甲子、乙庚日起丙子、丙辛日起戊子、丁壬日起庚子、戊癸日起壬子', () {
      expect(BaiZiEngine.hourGanZhiOf('甲子', 0), '甲子');
      expect(BaiZiEngine.hourGanZhiOf('己卯', 0), '甲子');
      expect(BaiZiEngine.hourGanZhiOf('乙丑', 0), '丙子');
      expect(BaiZiEngine.hourGanZhiOf('庚午', 0), '丙子');
      expect(BaiZiEngine.hourGanZhiOf('丙寅', 0), '戊子');
      expect(BaiZiEngine.hourGanZhiOf('辛未', 0), '戊子');
      expect(BaiZiEngine.hourGanZhiOf('丁卯', 0), '庚子');
      expect(BaiZiEngine.hourGanZhiOf('壬申', 0), '庚子');
      expect(BaiZiEngine.hourGanZhiOf('戊辰', 0), '壬子');
      expect(BaiZiEngine.hourGanZhiOf('癸酉', 0), '壬子');
    });
  });

  group('四柱干支（与 tyme 万年历一致）', () {
    test('2024 年每月中旬午时排盘，年月日柱与 tyme 节气干支相同', () {
      final wrong = <String>[];
      for (var m = 1; m <= 12; m++) {
        final birth = DateTime(2024, m, 15, 12);
        final r = BaiZiEngine.calc(birth: birth, isMale: true, hourIndex: 6);
        final solar = tyme.SolarDay.fromYmd(birth.year, birth.month, birth.day);
        final scd = solar.getSixtyCycleDay();
        final expectYear = scd.getYear().getName();
        final expectMonth = scd.getMonth().getName();
        final expectDay = scd.getSixtyCycle().getName();
        if (r.yearZhu.ganZhi != expectYear) {
          wrong.add('${birth.month}月 年柱: 期望 $expectYear 实际 ${r.yearZhu.ganZhi}');
        }
        if (r.monthZhu.ganZhi != expectMonth) {
          wrong.add('${birth.month}月 月柱: 期望 $expectMonth 实际 ${r.monthZhu.ganZhi}');
        }
        if (r.dayZhu.ganZhi != expectDay) {
          wrong.add('${birth.month}月 日柱: 期望 $expectDay 实际 ${r.dayZhu.ganZhi}');
        }
        // 时柱 = 五鼠遁(日干, 午时=6)
        final expectHour = _hourGz(expectDay[0], 6);
        if (r.hourZhu.ganZhi != expectHour) {
          wrong.add('${birth.month}月 时柱: 期望 $expectHour 实际 ${r.hourZhu.ganZhi}');
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });

    test('立春前后的年柱切换（2024-02-04 立春）', () {
      final before = BaiZiEngine.calc(
          birth: DateTime(2024, 2, 1, 12), isMale: true, hourIndex: 6);
      final after = BaiZiEngine.calc(
          birth: DateTime(2024, 2, 10, 12), isMale: true, hourIndex: 6);
      expect(before.yearZhu.ganZhi, '癸卯', reason: '立春前仍属癸卯年');
      expect(after.yearZhu.ganZhi, '甲辰', reason: '立春后属甲辰年');
    });
  });

  group('交节精确时刻（立春/节气日）', () {
    /// 用 tyme 直接取交节时刻（独立于引擎）
    tyme.SolarTime termTime(int year, String name) =>
        tyme.SolarTerm.fromName(year, name).getJulianDay().getSolarTime();

    test('立春当日交节前后年柱/月柱切换（2024 立春）', () {
      final t = termTime(2024, '立春');
      final before = t.getJulianDay().getDay() - 1.0 / 24; // 交节前 1 小时
      String two(int v) => v.toString().padLeft(2, '0');
      final fmt = (double jd) {
        final st = tyme.JulianDay(jd).getSolarTime();
        return DateTime(st.getYear(), st.getMonth(), st.getDay(),
            st.getHour(), st.getMinute());
      };
      final beforeDt = fmt(before);
      final afterDt = fmt(t.getJulianDay().getDay() + 1.0 / 24);

      final rBefore = BaiZiEngine.calc(
          birth: beforeDt, isMale: true, hourIndex: 6, preciseTime: true);
      final rAfter = BaiZiEngine.calc(
          birth: afterDt, isMale: true, hourIndex: 6, preciseTime: true);

      expect(rBefore.yearZhu.ganZhi, '癸卯', reason: '交节前仍属癸卯年');
      expect(rBefore.monthZhu.ganZhi, '乙丑', reason: '交节前仍属丑月');
      expect(rAfter.yearZhu.ganZhi, '甲辰', reason: '交节后属甲辰年');
      expect(rAfter.monthZhu.ganZhi, '丙寅', reason: '交节后属寅月');
      // 日柱不因交节而改变（同一天）
      expect(rBefore.dayZhu.ganZhi, rAfter.dayZhu.ganZhi);
      // 用 preciseTime=false 时按日粒度（当天即换柱）
      final rLoose = BaiZiEngine.calc(
          birth: beforeDt, isMale: true, hourIndex: 6, preciseTime: false);
      expect(rLoose.yearZhu.ganZhi, '甲辰', reason: '无精确时刻时按日粒度换柱');
      // 未使用变量告警规避
      expect(two(1), '01');
    });

    test('非交节日不受精确时刻影响', () {
      final a = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 3), isMale: true, hourIndex: 2, preciseTime: true);
      final b = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 9), isMale: true, hourIndex: 2, preciseTime: true);
      expect(a.yearZhu.ganZhi, b.yearZhu.ganZhi);
      expect(a.monthZhu.ganZhi, b.monthZhu.ganZhi);
    });
  });

  group('晚子时换日（23:00-23:59 出生）', () {
    final solar = tyme.SolarDay.fromYmd(2024, 5, 10);
    final sameDay = solar.getSixtyCycleDay().getSixtyCycle().getName();
    final nextDay = solar.next(1).getSixtyCycleDay().getSixtyCycle().getName();

    test('开启换日：日柱取次日、时柱用次日日干起子时', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 5, 10, 23, 30),
        isMale: true,
        hourIndex: 0,
        preciseTime: true,
        wanZiShi: true,
      );
      expect(r.dayZhu.ganZhi, nextDay);
      expect(r.hourZhu.ganZhi, _hourGz(nextDay[0], 0));
    });

    test('关闭换日：按当日（子正换日派）', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 5, 10, 23, 30),
        isMale: true,
        hourIndex: 0,
        preciseTime: true,
        wanZiShi: false,
      );
      expect(r.dayZhu.ganZhi, sameDay);
      expect(r.hourZhu.ganZhi, _hourGz(sameDay[0], 0));
    });

    test('早子时（00:30）不换日', () {
      final r = BaiZiEngine.calc(
        birth: DateTime(2024, 5, 11, 0, 30),
        isMale: true,
        hourIndex: 0,
        preciseTime: true,
        wanZiShi: true,
      );
      expect(r.dayZhu.ganZhi, nextDay);
    });
  });

  group('大运（顺逆与起运）', () {
    /// 检查大运干支是否自月柱起顺/逆连续排列
    void expectDirection(BaziResult r, {required bool forward}) {
      final monthGanIdx = _gan.indexOf(r.monthZhu.tianGan);
      final monthZhiIdx = _zhi.indexOf(r.monthZhu.diZhi);
      for (var i = 0; i < r.daYun.length; i++) {
        final d = r.daYun[i];
        final gi = forward
            ? (monthGanIdx + i) % 10
            : ((monthGanIdx - i) % 10 + 10) % 10;
        final zi = forward
            ? (monthZhiIdx + i) % 12
            : ((monthZhiIdx - i) % 12 + 12) % 12;
        expect(d.ganZhi, '${_gan[gi]}${_zhi[zi]}',
            reason: '第${i + 1}步大运应为 ${_gan[gi]}${_zhi[zi]}，实际 ${d.ganZhi}');
      }
    }

    test('阳年男顺排、阳年女逆排、阴年男逆排、阴年女顺排', () {
      // 2024 甲辰年（阳年）
      final yangMale = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 12), isMale: true, hourIndex: 6);
      final yangFemale = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 12), isMale: false, hourIndex: 6);
      expectDirection(yangMale, forward: true);
      expectDirection(yangFemale, forward: false);

      // 2023 癸卯年（阴年）
      final yinMale = BaiZiEngine.calc(
          birth: DateTime(2023, 6, 15, 12), isMale: true, hourIndex: 6);
      final yinFemale = BaiZiEngine.calc(
          birth: DateTime(2023, 6, 15, 12), isMale: false, hourIndex: 6);
      expectDirection(yinMale, forward: false);
      expectDirection(yinFemale, forward: true);
    });

    test('起运年龄为 0-10 岁之间且每步递增 10 年', () {
      final r = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 12), isMale: true, hourIndex: 6);
      expect(r.daYun, isNotEmpty);
      expect(r.daYun.first.startAge, inInclusiveRange(0, 10));
      for (var i = 1; i < r.daYun.length; i++) {
        expect(r.daYun[i].startAge - r.daYun[i - 1].startAge, 10);
      }
    });

    test('大运纳音与干支匹配', () {
      final r = BaiZiEngine.calc(
          birth: DateTime(2024, 6, 15, 12), isMale: true, hourIndex: 6);
      for (final d in r.daYun) {
        final expected =
            getNaYin(_gan.indexOf(d.tianGan), _zhi.indexOf(d.diZhi))?.naYin;
        expect(d.naYin, expected, reason: '${d.ganZhi} 纳音应为 $expected');
      }
    });
  });

  group('五行旺衰与旬空', () {
    test('旺衰表：当令者旺、我生者相、生我者休、克我者囚、我克者死', () {
      // 寅月（木旺）：木旺 火相 水休 金囚 土死
      final ws = BaiZiEngine.wangShuaiOf('寅');
      expect(ws['木'], '旺');
      expect(ws['火'], '相');
      expect(ws['水'], '休');
      expect(ws['金'], '囚');
      expect(ws['土'], '死');
      // 巳月（火旺）：火旺 土相 木休 水囚 金死
      final ws2 = BaiZiEngine.wangShuaiOf('巳');
      expect(ws2['火'], '旺');
      expect(ws2['土'], '相');
      expect(ws2['木'], '休');
      expect(ws2['水'], '囚');
      expect(ws2['金'], '死');
    });

    test('旬空：日柱旬首对应空亡两支', () {
      final wrong = <String>[];
      for (var m = 1; m <= 12; m++) {
        final birth = DateTime(2024, m, 10, 12);
        final r = BaiZiEngine.calc(birth: birth, isMale: true, hourIndex: 6);
        final solar = tyme.SolarDay.fromYmd(birth.year, birth.month, birth.day);
        final cycleIdx = solar.getSixtyCycleDay().getSixtyCycle().getIndex();
        final shouIdx = cycleIdx - (cycleIdx % 10);
        final shouZhi = _zhi[shouIdx % 12];
        final miss1 = _zhi[(_zhi.indexOf(shouZhi) + 10) % 12];
        final miss2 = _zhi[(_zhi.indexOf(shouZhi) + 11) % 12];
        final expect = [miss1, miss2]..sort();
        final actual = r.kongWang.toList()..sort();
        if (expect.join() != actual.join()) {
          wrong.add('$birth 日柱${r.dayZhu.ganZhi}: 期望 $expect 实际 $actual');
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });
}
