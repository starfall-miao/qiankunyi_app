/// 大六壬引擎测试：天地盘 / 四课 / 三传（九宗门）/ 十二天将
///
/// 采用「独立重建 + 不变式」验证：
/// - 天地盘、四课结构、天将排布按定义在测试内独立重建后逐项比对；
/// - 三传逐支校验取传法的结构不变式（如贼克法必有中传=初传上神），
///   并覆盖伏吟/返吟等特殊课体。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:qiankunyi_app/features/paipan/engines/daliuren_engine.dart';

const _zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
int _z(String zh) => _zhi.indexOf(zh);

/// 独立重建天盘：天盘[i] = 月将支 + (i - 时支)
List<String> _tianPanOf(String yjZhi, int hourIdx) => List.generate(
      12,
      (i) => _zhi[(_z(yjZhi) + i - hourIdx + 24) % 12],
    );

/// 十干寄宫
const _jiGong = {
  '甲': '寅', '乙': '辰', '丙': '巳', '丁': '未', '戊': '巳',
  '己': '未', '庚': '申', '辛': '戌', '壬': '亥', '癸': '丑',
};

void main() {
  group('天地盘（月将加时）', () {
    test('月将加于时支，其余顺布且十二支不重', () {
      final r = DaLiuRenEngine.byHour(6, 1,
          dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      final tp = _tianPanOf(r.yueJiangZhi, 6);
      expect(r.tianPan, equals(tp));
      expect(r.tianPan[6], r.yueJiangZhi, reason: '时支午上应加月将');
      expect(r.tianPan.toSet().length, 12);
    });

    test('月将索引与地支互转', () {
      expect(daliurenYueJiang[0], '登明');
      expect(_zhi[DaLiuRenEngine.yueJiangZhiIndex(0)], '亥');
      expect(_zhi[DaLiuRenEngine.yueJiangZhiIndex(11)], '子');
    });
  });

  group('四课结构', () {
    test('一课日阳、二课日阴、三课辰阳、四课辰阴（上/下神关系）', () {
      final r = DaLiuRenEngine.byHour(3, 1,
          dayGan: '壬', dayZhi: '午', monthZhiIdx: 2);
      final tp = r.tianPan;
      String tian(String zh) => tp[_z(zh)];
      final gong = _jiGong['壬']!; // 亥

      expect(r.siKeXia[0], gong, reason: '一课下神为日干寄宫');
      expect(r.siKeShang[0], tian(gong), reason: '一课上神=寄宫上神');
      expect(r.siKeXia[1], r.siKeShang[0], reason: '二课下神=一课上神');
      expect(r.siKeShang[1], tian(r.siKeShang[0]),
          reason: '二课上神=一课上神之上神');
      expect(r.siKeXia[2], '午', reason: '三课下神为日支');
      expect(r.siKeShang[2], tian('午'), reason: '三课上神=日支上神');
      expect(r.siKeXia[3], r.siKeShang[2], reason: '四课下神=三课上神');
      expect(r.siKeShang[3], tian(r.siKeShang[2]),
          reason: '四课上神=三课上神之上神');
    });

    test('十干寄宫正确', () {
      for (final g in _jiGong.keys) {
        final r =
            DaLiuRenEngine.byHour(0, 1, dayGan: g, dayZhi: '子', monthZhiIdx: 2);
        expect(r.siKeXia[0], _jiGong[g], reason: '$g 日寄宫应为 ${_jiGong[g]}');
      }
    });
  });

  group('十二天将（贵人起布 + 顺逆）', () {
    test('贵人临位为贵人，顺逆按所临地盘位阴阳', () {
      for (var h = 0; h < 12; h++) {
        for (final g in ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']) {
          final r = DaLiuRenEngine.byHour(h, 1,
              dayGan: g, dayZhi: '子', monthZhiIdx: 2);
          final gongIdx = r.tianPan.indexOf(r.guiRen);
          expect(gongIdx, greaterThanOrEqualTo(0));
          expect(r.guiRenGong, _zhi[gongIdx]);
          expect(r.tianJiang[gongIdx], '贵人', reason: '贵人宫应临贵人');
          final expectShun = gongIdx % 2 == 0;
          expect(r.shunBu, expectShun);
          for (var i = 0; i < 12; i++) {
            final k = expectShun
                ? (i - gongIdx + 12) % 12
                : (gongIdx - i + 12) % 12;
            expect(r.tianJiang[i], daliurenGenerals[k].$1,
                reason: '$g日${_zhi[h]}时 地盘${_zhi[i]}天将排布应顺/逆');
          }
        }
      }
    });
  });

  group('三传（九宗门）不变式', () {
    bool isYangGan(String g) => _yangGans.indexOf(g) % 2 == 0;

    test('九宗门任取一法，且传法与三传结构自洽', () {
      final faSet = <String>{};
      for (var h = 0; h < 12; h++) {
        for (var yj = 0; yj < 12; yj++) {
          for (final g in _yangGans) {
            for (final z in ['子', '午', '卯']) {
              final r = DaLiuRenEngine.byHour(h, 1,
                  dayGan: g, dayZhi: z, yueJiangIdx: yj);
              final tp = r.tianPan;
              String tian(String zh) => tp[_z(zh)];
              faSet.add(r.chuanFa);
              expect(r.shiYong.length, 3);
              for (final s in r.shiYong) {
                expect(_zhi, contains(s));
              }

              final isFuYin =
                  List.generate(12, (i) => tp[i] == _zhi[i]).every((e) => e);
              final isFanYin = List.generate(
                      12, (i) => _z(tp[i]) == (i + 6) % 12)
                  .every((e) => e);
              expect(r.chuanFa.contains('伏吟'), isFuYin,
                  reason: '$g日${_zhi[h]}时月将${daliurenYueJiang[yj]}：伏吟判定应与天地盘一致');
              expect(r.chuanFa.contains('返吟'), isFanYin);

              if (isFuYin) {
                final expectChu =
                    isYangGan(g) ? r.siKeShang[0] : r.siKeShang[2];
                expect(r.chuChuan, expectChu,
                    reason: '伏吟：阳日取干上神、阴日取支上神');
                expect(r.zhongChuan, _xingOf(r.chuChuan));
                expect(r.moChuan, _xingOf(r.zhongChuan));
              } else if (isFanYin) {
                expect(r.zhongChuan, r.siKeShang[2], reason: '返吟中传取支上神');
                expect(r.moChuan, r.siKeShang[0], reason: '返吟末传取干上神');
              } else if (r.chuanFa.contains('昴星')) {
                final expectChu = isYangGan(g) ? tian('酉') : tian('卯');
                expect(r.chuChuan, expectChu,
                    reason: '昴星：阳日取酉上神、阴日取卯上神');
              } else if (r.chuanFa.contains('别责') ||
                  r.chuanFa.contains('八专')) {
                expect(r.zhongChuan, r.siKeShang[0]);
                expect(r.moChuan, r.siKeShang[0]);
              } else {
                expect(r.zhongChuan, tian(r.chuChuan),
                    reason: '${r.chuanFa} 中传应为初传上神');
                expect(r.moChuan, tian(r.zhongChuan),
                    reason: '${r.chuanFa} 末传应为中传上神');
                expect(r.siKeShang, contains(r.chuChuan));
              }
            }
          }
        }
      }
      expect(
          faSet.any((f) =>
              f.contains('贼克') || f.contains('比用') || f.contains('涉害')),
          isTrue,
          reason: '样本应覆盖贼克/比用/涉害');
      expect(faSet.any((f) => f.contains('伏吟')), isTrue);
      expect(faSet.any((f) => f.contains('返吟')), isTrue);
    });

    test('贼克法：初传取有克之课的上神', () {
      var checked = 0;
      for (var h = 0; h < 12 && checked < 20; h++) {
        for (var yj = 0; yj < 12 && checked < 20; yj++) {
          final r = DaLiuRenEngine.byHour(h, 1,
              dayGan: '甲', dayZhi: '子', yueJiangIdx: yj);
          if (!r.chuanFa.contains('贼克')) continue;
          final idx = r.siKeShang.indexOf(r.chuChuan);
          expect(idx, greaterThanOrEqualTo(0));
          checked++;
        }
      }
      expect(checked, greaterThan(0), reason: '样本中应出现贼克法');
    });

    test('伏吟课：阳日取干上神为初传', () {
      // 时支与月将支相同（午时 + 胜光午将）→ 天地盘重合
      final r = DaLiuRenEngine.byHour(6, 1,
          dayGan: '甲', dayZhi: '子', yueJiangIdx: 5);
      expect(r.chuanFa, contains('伏吟'));
      expect(r.chuChuan, r.siKeShang[0]);
    });

    test('返吟课：天地盘全冲，中末传取支上神/干上神', () {
      // 时支子 + 午将（相差六位）→ 天盘全冲
      final r = DaLiuRenEngine.byHour(0, 1,
          dayGan: '甲', dayZhi: '子', yueJiangIdx: 5);
      expect(r.chuanFa, contains('返吟'));
      expect(r.zhongChuan, r.siKeShang[2]);
      expect(r.moChuan, r.siKeShang[0]);
    });
  });

  group('六亲（以日干为我）', () {
    const ganWx = {
      '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
      '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
    };
    const zhiWx = {
      '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
      '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
    };
    const sheng = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'};
    const ke = {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'};

    String expectLiuQin(String gan, String zhi) {
      final wo = ganWx[gan]!;
      final bi = zhiWx[zhi]!;
      if (wo == bi) return '兄弟';
      if (sheng[wo] == bi) return '子孙';
      if (sheng[bi] == wo) return '父母';
      if (ke[wo] == bi) return '妻财';
      return '官鬼';
    }

    test('10 日干 × 12 地支 = 120 组合六亲正确', () {
      final wrong = <String>[];
      for (final g in ganWx.keys) {
        for (final z in zhiWx.keys) {
          final actual = DaLiuRenEngine.liuQinOf(g, z);
          final expected = expectLiuQin(g, z);
          if (actual != expected) {
            wrong.add('$g日 $z：期望 $expected 实际 $actual');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });

    test('排盘结果按日干给出四课/三传六亲', () {
      final r = DaLiuRenEngine.byHour(3, 1,
          dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      expect(r.keLiuQin.length, 4);
      expect(r.chuanLiuQin.length, 3);
      for (var i = 0; i < 4; i++) {
        expect(r.keLiuQin[i], DaLiuRenEngine.liuQinOf('甲', r.siKeShang[i]));
      }
      for (var i = 0; i < 3; i++) {
        expect(r.chuanLiuQin[i],
            DaLiuRenEngine.liuQinOf('甲', r.shiYong[i]));
      }
    });

    test('天将反查：天盘支所临天将', () {
      final r = DaLiuRenEngine.byHour(3, 1,
          dayGan: '甲', dayZhi: '子', monthZhiIdx: 2);
      for (final z in r.siKeShang) {
        final jiang = DaLiuRenEngine.tianJiangOf(r, z);
        final pos = r.tianPan.indexOf(z);
        expect(jiang, r.tianJiang[pos]);
      }
    });
  });

  group('月将（中气换将）', () {
    test('按最近已过中气定月将', () {
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 2, 20)), 0,
          reason: '雨水后登明');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 3, 25)), 1,
          reason: '春分后河魁');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 12, 25)), 10,
          reason: '冬至后大吉');
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 1, 25)), 11,
          reason: '大寒后神后');
    });

    test('立春后雨水前仍属上一中气之月将', () {
      expect(DaLiuRenEngine.yueJiangOf(DateTime(2024, 2, 10)), 11);
    });
  });

  group('贵人昼夜（卯酉分界）', () {
    test('卯至申用阳贵、酉至寅用阴贵', () {
      expect(DaLiuRenEngine.calcGuiRen('甲', 3), '丑'); // 卯时昼
      expect(DaLiuRenEngine.calcGuiRen('甲', 8), '丑'); // 申时昼
      expect(DaLiuRenEngine.calcGuiRen('甲', 9), '未'); // 酉时夜
      expect(DaLiuRenEngine.calcGuiRen('甲', 2), '未'); // 寅时夜
    });
  });
}

const _yangGans = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

/// 三刑（自刑取冲）
String _xingOf(String zh) {
  const m = {
    '子': '卯', '卯': '子', '寅': '巳', '巳': '申', '申': '寅',
    '丑': '戌', '戌': '未', '未': '丑',
  };
  return m[zh] ?? _zhi[(_z(zh) + 6) % 12];
}
