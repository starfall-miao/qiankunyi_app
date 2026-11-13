/// 六爻全逻辑链核验测试
///
/// 目的：用**独立于引擎实现的参考数据/规则**逐环节校验 64 卦装卦结果，
/// 覆盖：卦名、八宫归属、世应、纳甲（天干+地支）、六亲、变卦（384 组合）、
/// 旬空、六神、日破暗动、伏神。任何一环出错都会在此暴露。
///
/// 参考数据来源：京房八宫装卦表 / 十翼纳甲口诀（乾纳甲壬、坤纳乙癸、震纳庚、
/// 巽纳辛、坎纳戊、离纳己、艮纳丙、兑纳丁），与本项目引擎代码无关。
library;

import 'package:test/test.dart';
import 'package:tyme/tyme.dart' as tyme;

import 'package:qiankunyi_app/features/cases/models/case_models.dart';
import 'package:qiankunyi_app/features/reference/data/reference_data.dart';
import 'package:qiankunyi_app/features/paipan/engines/liuyao_engine.dart';
import 'package:qiankunyi_app/features/paipan/engines/meihua_engine.dart';
import 'package:qiankunyi_app/features/paipan/models/gua_model.dart';
import 'package:qiankunyi_app/features/paipan/models/paipan_result.dart';
import 'package:qiankunyi_app/features/paipan/models/yao_model.dart';

// ───────────────────────── 参考数据（独立于引擎） ─────────────────────────

/// 八卦编号约定：1乾 2兑 3离 4震 5巽 6坎 7艮 8坤（与 byNumbers 入参一致）
const _triNames = ['乾', '兑', '离', '震', '巽', '坎', '艮', '坤'];

/// 八卦纳甲：内卦(下卦)三爻、外卦(上卦)三爻的干支（自初爻起）
const _naJia = <String, (String, List<String>, String, List<String>)>{
  '乾': ('甲', ['子', '寅', '辰'], '壬', ['午', '申', '戌']),
  '兑': ('丁', ['巳', '卯', '丑'], '丁', ['亥', '酉', '未']),
  '离': ('己', ['卯', '丑', '亥'], '己', ['酉', '未', '巳']),
  '震': ('庚', ['子', '寅', '辰'], '庚', ['午', '申', '戌']),
  '巽': ('辛', ['丑', '亥', '酉'], '辛', ['未', '巳', '卯']),
  '坎': ('戊', ['寅', '辰', '午'], '戊', ['申', '戌', '子']),
  '艮': ('丙', ['辰', '午', '申'], '丙', ['戌', '子', '寅']),
  '坤': ('乙', ['未', '巳', '卯'], '癸', ['丑', '亥', '酉']),
};

/// 64 卦名矩阵：行=上卦（1乾…8坤），列=下卦（1乾…8坤）
const _nameMatrix = <List<String>>[
  // 上乾
  ['乾为天', '天泽履', '天火同人', '天雷无妄', '天风姤', '天水讼', '天山遁', '天地否'],
  // 上兑
  ['泽天夬', '兑为泽', '泽火革', '泽雷随', '泽风大过', '泽水困', '泽山咸', '泽地萃'],
  // 上离
  ['火天大有', '火泽睽', '离为火', '火雷噬嗑', '火风鼎', '火水未济', '火山旅', '火地晋'],
  // 上震
  ['雷天大壮', '雷泽归妹', '雷火丰', '震为雷', '雷风恒', '雷水解', '雷山小过', '雷地豫'],
  // 上巽
  ['风天小畜', '风泽中孚', '风火家人', '风雷益', '巽为风', '风水涣', '风山渐', '风地观'],
  // 上坎
  ['水天需', '水泽节', '水火既济', '水雷屯', '水风井', '坎为水', '水山蹇', '水地比'],
  // 上艮
  ['山天大畜', '山泽损', '山火贲', '山雷颐', '山风蛊', '山水蒙', '艮为山', '山地剥'],
  // 上坤
  ['地天泰', '地泽临', '地火明夷', '地雷复', '地风升', '地水师', '地山谦', '坤为地'],
];

/// 京房八宫表：宫 → 八卦（含宫内顺序：纯卦、一世…五世、游魂、归魂）
/// 宫内第 1 个为八纯卦（世6），第 2-6 个世位 1-5，第 7 个游魂（世4），第 8 个归魂（世3）
const _palaces = <String, List<String>>{
  '乾': ['乾为天', '天风姤', '天山遁', '天地否', '风地观', '山地剥', '火地晋', '火天大有'],
  '兑': ['兑为泽', '泽水困', '泽地萃', '泽山咸', '水山蹇', '地山谦', '雷山小过', '雷泽归妹'],
  '离': ['离为火', '火山旅', '火风鼎', '火水未济', '山水蒙', '风水涣', '天水讼', '天火同人'],
  '震': ['震为雷', '雷地豫', '雷水解', '雷风恒', '地风升', '水风井', '泽风大过', '泽雷随'],
  '巽': ['巽为风', '风天小畜', '风火家人', '风雷益', '天雷无妄', '火雷噬嗑', '山雷颐', '山风蛊'],
  '坎': ['坎为水', '水泽节', '水雷屯', '水火既济', '泽火革', '雷火丰', '地火明夷', '地水师'],
  '艮': ['艮为山', '山火贲', '山天大畜', '山泽损', '火泽睽', '天泽履', '风泽中孚', '风山渐'],
  '坤': ['坤为地', '地雷复', '地泽临', '地天泰', '雷天大壮', '泽天夬', '水天需', '水地比'],
};

/// 宫 → 五行
const _gongWuXing = {
  '乾': '金', '兑': '金', '离': '火', '震': '木',
  '巽': '木', '坎': '水', '艮': '土', '坤': '土',
};

/// 卦名 → (宫, 世爻序号 1-6)
Map<String, (String, int)> _buildPalaceIndex() {
  const shiBySlot = [6, 1, 2, 3, 4, 5, 4, 3]; // 纯卦/一世…五世/游魂/归魂
  final m = <String, (String, int)>{};
  _palaces.forEach((gong, guas) {
    for (var i = 0; i < guas.length; i++) {
      m[guas[i]] = (gong, shiBySlot[i]);
    }
  });
  return m;
}

final _palaceIndex = _buildPalaceIndex();

/// 五行相生（独立实现）
String _sheng(String w) => const {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'}[w]!;

/// 五行相克（独立实现）
String _ke(String w) => const {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'}[w]!;

/// 六亲：以宫五行为「我」
String _liuQin(String gongWx, String yaoWx) {
  if (gongWx == yaoWx) return '兄弟';
  if (_sheng(gongWx) == yaoWx) return '子孙';
  if (_sheng(yaoWx) == gongWx) return '父母';
  if (_ke(gongWx) == yaoWx) return '妻财';
  if (_ke(yaoWx) == gongWx) return '官鬼';
  return '未知';
}

/// 地支 → 五行
const _zhiWuXing = {
  '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
  '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
};

/// 地支 → 六冲
const _chong = {
  '子': '午', '丑': '未', '寅': '申', '卯': '酉', '辰': '戌', '巳': '亥',
  '午': '子', '未': '丑', '申': '寅', '酉': '卯', '戌': '辰', '亥': '巳',
};

/// 地支中文（索引 0=子）
const _zhis = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// 六神循环
const _liushenCycle = ['青龙', '朱雀', '勾陈', '螣蛇', '白虎', '玄武'];

/// 日干 → 六神起始（甲乙青龙、丙丁朱雀、戊勾陈、己螣蛇、庚辛白虎、壬癸玄武）
String _liushenStart(String gan) {
  if (gan == '甲' || gan == '乙') return '青龙';
  if (gan == '丙' || gan == '丁') return '朱雀';
  if (gan == '戊') return '勾陈';
  if (gan == '己') return '螣蛇';
  if (gan == '庚' || gan == '辛') return '白虎';
  return '玄武';
}

// ───────────────────────── 工具 ─────────────────────────

/// 用 上卦/下卦 编号（1乾…8坤）+ 动爻（0-5，-1 无动）构造排盘
PaipanResult _paipan(int upper, int lower, {int moving = -1, DateTime? time}) {
  final yaos = <YaoModel>[];
  const triYang = {
    '乾': [true, true, true],
    '兑': [true, true, false],
    '离': [true, false, true],
    '震': [true, false, false],
    '巽': [false, true, true],
    '坎': [false, true, false],
    '艮': [false, false, true],
    '坤': [false, false, false],
  };
  final low = triYang[_triNames[lower - 1]]!;
  final up = triYang[_triNames[upper - 1]]!;
  for (var i = 0; i < 3; i++) {
    yaos.add(YaoModel(
      yinYang: low[i] ? YaoYinYang.yang : YaoYinYang.yin,
      position: YaoPosition.values[i],
      isMoving: moving == i,
    ));
  }
  for (var i = 0; i < 3; i++) {
    yaos.add(YaoModel(
      yinYang: up[i] ? YaoYinYang.yang : YaoYinYang.yin,
      position: YaoPosition.values[i + 3],
      isMoving: moving == i + 3,
    ));
  }
  return LiuYaoEngine.fromYaos(yaos,
      time: time ?? DateTime(2024, 3, 20, 12)); // 春分后：卯月
}

String _zhiOf(YaoModel y) {
  const m = {
    DiZhi.zi: '子', DiZhi.chou: '丑', DiZhi.yin: '寅', DiZhi.mao: '卯',
    DiZhi.chen: '辰', DiZhi.si: '巳', DiZhi.wu: '午', DiZhi.wei: '未',
    DiZhi.shen: '申', DiZhi.you: '酉', DiZhi.xu: '戌', DiZhi.hai: '亥',
  };
  return m[y.diZhi]!;
}

String _ganOf(YaoModel y) {
  const m = {
    TianGan.jia: '甲', TianGan.yi: '乙', TianGan.bing: '丙', TianGan.ding: '丁',
    TianGan.wu: '戊', TianGan.ji: '己', TianGan.geng: '庚', TianGan.xin: '辛',
    TianGan.ren: '壬', TianGan.gui: '癸',
  };
  return m[y.tianGan]!;
}

const _liuQinCN = {
  LiuQin.parent: '父母', LiuQin.brother: '兄弟', LiuQin.officer: '官鬼',
  LiuQin.wife: '妻财', LiuQin.child: '子孙',
};

/// 按上下卦（八卦名）与动爻位置推导期望的六爻干支
List<String> _expectedGanZhi(String lowerTri, String upperTri) {
  final low = _naJia[lowerTri]!;
  final up = _naJia[upperTri]!;
  return [
    '${low.$1}${low.$2[0]}', '${low.$1}${low.$2[1]}', '${low.$1}${low.$2[2]}',
    '${up.$3}${up.$4[0]}', '${up.$3}${up.$4[1]}', '${up.$3}${up.$4[2]}',
  ];
}

void main() {
  naYinGroup();

  // ───────────────────── 1. 64 卦名 ─────────────────────
  group('64 卦名（上下卦组合）', () {
    test('全部 64 组合卦名正确', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          final r = _paipan(upper, lower);
          final actual = guaNameCN[r.benGua.name]!;
          final expectName = _nameMatrix[upper - 1][lower - 1];
          if (actual != expectName) {
            wrong.add('${_triNames[upper - 1]}上${_triNames[lower - 1]}下: '
                '期望 $expectName 实际 $actual');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 2. 八宫归属与世应 ─────────────────────
  group('八宫归属与世应', () {
    test('64 卦宫位正确', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          final r = _paipan(upper, lower);
          final name = guaNameCN[r.benGua.name]!;
          final expectGong = _palaceIndex[name]!.$1;
          final gongName = _gongCN(r.benGua.gong);
          if (gongName != expectGong) {
            wrong.add('$name: 期望 $expectGong 宫 实际 $gongName 宫');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });

    test('64 卦世应位置正确（世 1-6，应=世±3）', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          final r = _paipan(upper, lower);
          final name = guaNameCN[r.benGua.name]!;
          final expectShi = _palaceIndex[name]!.$2; // 1-based
          final expectYing = (expectShi + 2) % 6 + 1; // 世3→应6、世4→应1…
          if (r.benGua.shiYaoIndex + 1 != expectShi) {
            wrong.add('$name 世位: 期望 $expectShi 实际 ${r.benGua.shiYaoIndex + 1}');
          }
          if (r.benGua.yingYaoIndex + 1 != expectYing) {
            wrong.add('$name 应位: 期望 $expectYing 实际 ${r.benGua.yingYaoIndex + 1}');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 3. 纳甲（本卦） ─────────────────────
  group('纳甲（本卦 64 卦逐爻干支）', () {
    test('64 卦纳甲干支正确', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          final r = _paipan(upper, lower);
          final name = guaNameCN[r.benGua.name]!;
          final expectGz =
              _expectedGanZhi(_triNames[lower - 1], _triNames[upper - 1]);
          for (var i = 0; i < 6; i++) {
            final actual = '${_ganOf(r.benGua.yaos[i])}${_zhiOf(r.benGua.yaos[i])}';
            if (actual != expectGz[i]) {
              wrong.add('$name 第${i + 1}爻: 期望 ${expectGz[i]} 实际 $actual');
            }
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 4. 六亲（本卦） ─────────────────────
  group('六亲（以本卦卦宫为基准）', () {
    test('64 卦六亲正确', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          final r = _paipan(upper, lower);
          final name = guaNameCN[r.benGua.name]!;
          final gong = _palaceIndex[name]!.$1;
          final gongWx = _gongWuXing[gong]!;
          for (var i = 0; i < 6; i++) {
            final zhi = _zhiOf(r.benGua.yaos[i]);
            final expectLq = _liuQin(gongWx, _zhiWuXing[zhi]!);
            final actualLq = _liuQinCN[r.benGua.yaos[i].liuQin];
            if (actualLq != expectLq) {
              wrong.add('$name($gong宫$gongWx) 第${i + 1}爻 $zhi: '
                  '期望 $expectLq 实际 $actualLq');
            }
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 5. 变卦（384 组合） ─────────────────────
  group('变卦装卦（64 卦 × 6 动爻）', () {
    test('384 种动爻组合的变卦名/纳甲/六亲/世应均正确', () {
      final wrong = <String>[];
      for (var upper = 1; upper <= 8; upper++) {
        for (var lower = 1; lower <= 8; lower++) {
          for (var moving = 0; moving < 6; moving++) {
            final r = _paipan(upper, lower, moving: moving);
            final bian = r.bianGua;
            final benName = guaNameCN[r.benGua.name]!;
            if (bian == null) {
              wrong.add('$benName 动${moving + 1}爻: 变卦为空');
              continue;
            }
            // 期望：动爻阴阳反转后重新确定上下卦
            final lowYang = _triYangPattern(_triNames[lower - 1]);
            final upYang = _triYangPattern(_triNames[upper - 1]);
            final flipped = <bool>[
              ...lowYang, ...upYang,
            ];
            flipped[moving] = !flipped[moving];
            final newLower = _triFromPattern(flipped.sublist(0, 3));
            final newUpper = _triFromPattern(flipped.sublist(3, 6));
            final expectName = _nameMatrix[
                _triNames.indexOf(newUpper)][_triNames.indexOf(newLower)];
            final actualName = guaNameCN[bian.name]!;
            if (actualName != expectName) {
              wrong.add('$benName 动${moving + 1}爻 → 期望变卦 $expectName 实际 $actualName');
              continue;
            }
            // 变卦纳甲：按变卦自身上下卦
            final expectGz = _expectedGanZhi(newLower, newUpper);
            for (var i = 0; i < 6; i++) {
              final actual = '${_ganOf(bian.yaos[i])}${_zhiOf(bian.yaos[i])}';
              if (actual != expectGz[i]) {
                wrong.add('$benName 动${moving + 1}爻 变卦$expectName '
                    '第${i + 1}爻纳甲: 期望 ${expectGz[i]} 实际 $actual');
              }
            }
            // 变卦六亲：以**本卦**卦宫五行论
            final benGong = _palaceIndex[benName]!.$1;
            final benGongWx = _gongWuXing[benGong]!;
            for (var i = 0; i < 6; i++) {
              final zhi = _zhiOf(bian.yaos[i]);
              final expectLq = _liuQin(benGongWx, _zhiWuXing[zhi]!);
              final actualLq = _liuQinCN[bian.yaos[i].liuQin];
              if (actualLq != expectLq) {
                wrong.add('$benName 动${moving + 1}爻 变卦$expectName '
                    '第${i + 1}爻 $zhi 六亲: 期望 $expectLq（本宫$benGong$benGongWx）实际 $actualLq');
              }
            }
            // 变卦世应：按变卦自身八宫
            final expectShi = _palaceIndex[expectName]!.$2;
            final expectYing = (expectShi + 2) % 6 + 1;
            if (bian.shiYaoIndex + 1 != expectShi) {
              wrong.add('$benName 动${moving + 1}爻 变卦$expectName 世位: '
                  '期望 $expectShi 实际 ${bian.shiYaoIndex + 1}');
            }
            if (bian.yingYaoIndex + 1 != expectYing) {
              wrong.add('$benName 动${moving + 1}爻 变卦$expectName 应位: '
                  '期望 $expectYing 实际 ${bian.yingYaoIndex + 1}');
            }
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.take(40).join('\n'));
    });

    test('无动爻时无变卦', () {
      final r = _paipan(1, 1);
      expect(r.bianGua, isNull);
    });

    test('多爻动时变卦为全部动爻反转之卦（乾为天动初二 → 天山遁）', () {
      final yaos = List.generate(
        6,
        (i) => YaoModel(
          yinYang: YaoYinYang.yang,
          position: YaoPosition.values[i],
          isMoving: i < 2, // 初、二爻动
        ),
      );
      final r = LiuYaoEngine.fromYaos(yaos, time: DateTime(2024, 3, 20, 12));
      expect(guaNameCN[r.benGua.name], '乾为天');
      expect(guaNameCN[r.bianGua!.name], '天山遁');
      // 下卦变艮：丙辰、丙午、丙申
      expect(_zhiOf(r.bianGua!.yaos[0]), '辰');
      expect(_zhiOf(r.bianGua!.yaos[1]), '午');
      expect(_zhiOf(r.bianGua!.yaos[2]), '申');
      expect(_ganOf(r.bianGua!.yaos[0]), '丙');
    });
  });

  // ───────────────────── 6. 旬空 ─────────────────────
  group('旬空（按日柱旬首独立推算）', () {
    test('2024 年各月抽样日期旬空正确', () {
      final wrong = <String>[];
      for (var m = 1; m <= 12; m++) {
        final time = DateTime(2024, m, 15, 12);
        final r = LiuYaoEngine.fromYaos(
          List.generate(
            6,
            (i) => YaoModel(
                yinYang: YaoYinYang.yang, position: YaoPosition.values[i]),
          ),
          time: time,
        );
        // 独立推算：tyme 取日柱 → 六十甲子序号 → 旬首 → 缺的两支
        final solar = tyme.SolarDay.fromYmd(time.year, time.month, time.day);
        final dayGz = solar.getSixtyCycleDay().getSixtyCycle().getName();
        final gzList = <String>[];
        for (final g in _jiaZi60()) {
          gzList.add(g);
        }
        final idx = gzList.indexOf(dayGz);
        final shouIdx = idx - (idx % 10);
        final shouZhiIdx = _zhis.indexOf(
            gzList[shouIdx][1]);
        final miss1 = _zhis[(shouZhiIdx + 10) % 12];
        final miss2 = _zhis[(shouZhiIdx + 11) % 12];
        final expectKong = [miss1, miss2]..sort();
        final actualKong = (r.kongWang ?? []).toList()..sort();
        if (expectKong.join() != actualKong.join()) {
          wrong.add('$time 日柱$dayGz: 期望空 $expectKong 实际 $actualKong');
        }
        // 空亡爻标记一致性
        for (final y in r.benGua.yaos) {
          final zhi = _zhiOf(y);
          final shouldKong = expectKong.contains(zhi);
          if (y.isKongWang != shouldKong) {
            wrong.add('$time 第${y.position.index + 1}爻$zhi 空亡标记错误');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 7. 六神 ─────────────────────
  group('六神（按日干起例）', () {
    test('连续 10 天覆盖十个日干，六神排布正确', () {
      final wrong = <String>[];
      // 2024-03-01 起连续 10 天覆盖 10 个日干
      for (var d = 1; d <= 10; d++) {
        final time = DateTime(2024, 3, d, 12);
        final r = LiuYaoEngine.fromYaos(
          List.generate(
            6,
            (i) => YaoModel(
                yinYang: YaoYinYang.yang, position: YaoPosition.values[i]),
          ),
          time: time,
        );
        final solar = tyme.SolarDay.fromYmd(time.year, time.month, time.day);
        final gan = solar.getSixtyCycleDay().getSixtyCycle().getName()[0];
        final start = _liushenStart(gan);
        final startIdx = _liushenCycle.indexOf(start);
        for (var i = 0; i < 6; i++) {
          final expectLs = _liushenCycle[(startIdx + i) % 6];
          final actualLs = _liushenCN(r.benGua.yaos[i].liuShen);
          if (expectLs != actualLs) {
            wrong.add('$time 日干$gan 第${i + 1}爻: 期望 $expectLs 实际 $actualLs');
          }
        }
      }
      expect(wrong, isEmpty, reason: wrong.join('\n'));
    });
  });

  // ───────────────────── 8. 日破 / 暗动 ─────────────────────
  group('日破与暗动', () {
    test('静爻被日支冲：旺相为暗动、休囚为日破；动爻不标', () {
      var checked = 0;
      for (var d = 1; d <= 20; d++) {
        final time = DateTime(2024, 4, d, 12);
        final r = LiuYaoEngine.fromYaos(
          List.generate(
            6,
            (i) => YaoModel(
              yinYang: YaoYinYang.yang,
              position: YaoPosition.values[i],
              isMoving: i == 5, // 上爻动
            ),
          ),
          time: time,
        );
        final solar = tyme.SolarDay.fromYmd(time.year, time.month, time.day);
        final dayZhi =
            solar.getSixtyCycleDay().getSixtyCycle().getName()[1];
        for (final y in r.benGua.yaos) {
          final zhi = _zhiOf(y);
          final chong = _chong[dayZhi] == zhi;
          if (y.isMoving) {
            expect(y.isAnDong, isFalse, reason: '动爻不应标暗动');
            expect(y.isRiPo, isFalse, reason: '动爻不应标日破');
            continue;
          }
          if (!chong) {
            expect(y.isAnDong || y.isRiPo, isFalse,
                reason: '$zhi 未受日冲却标了暗动/日破');
            continue;
          }
          checked++;
          final wangXiang = y.wangShuai == WangShuaiLevel.wang ||
              y.wangShuai == WangShuaiLevel.xiang;
          if (wangXiang) {
            expect(y.isAnDong, isTrue, reason: '$zhi 旺相受冲应为暗动');
            expect(y.isRiPo, isFalse);
          } else {
            expect(y.isRiPo, isTrue, reason: '$zhi 休囚受冲应为日破');
            expect(y.isAnDong, isFalse);
          }
        }
      }
      expect(checked, greaterThan(0), reason: '样本中应至少出现一次日冲静爻');
    });
  });

  // ───────────────────── 9. 月破 ─────────────────────
  group('月破（月建冲爻）', () {
    test('子月：乾为天的午爻为月破，其余不受冲', () {
      // 2023-12-20 大雪后属子月
      final r = LiuYaoEngine.fromYaos(
        List.generate(
          6,
          (i) => YaoModel(
              yinYang: YaoYinYang.yang, position: YaoPosition.values[i]),
        ),
        time: DateTime(2023, 12, 20, 12),
      );
      expect(r.monthZhi, '子');
      for (final y in r.benGua.yaos) {
        final zhi = _zhiOf(y);
        expect(y.isYuePo, zhi == '午',
            reason: '子月冲午：仅午爻应标月破（$zhi 实际 ${y.isYuePo}）');
      }
    });

    test('寅月：申爻为月破', () {
      final r = LiuYaoEngine.fromYaos(
        List.generate(
          6,
          (i) => YaoModel(
              yinYang: YaoYinYang.yang, position: YaoPosition.values[i]),
        ),
        time: DateTime(2024, 2, 20, 12), // 寅月
      );
      expect(r.monthZhi, '寅');
      final shenYao = r.benGua.yaos.firstWhere((y) => _zhiOf(y) == '申');
      expect(shenYao.isYuePo, isTrue);
      final wuYao = r.benGua.yaos.firstWhere((y) => _zhiOf(y) == '午');
      expect(wuYao.isYuePo, isFalse);
    });

    test('月破随序列化往返保留', () {
      final r = LiuYaoEngine.fromYaos(
        List.generate(
          6,
          (i) => YaoModel(
              yinYang: YaoYinYang.yang, position: YaoPosition.values[i]),
        ),
        time: DateTime(2023, 12, 20, 12),
      );
      final back = PaipanResult.fromJson(r.toJson());
      final wu = back.benGua.yaos.firstWhere((y) => _zhiOf(y) == '午');
      expect(wu.isYuePo, isTrue);
    });
  });

  // ───────────────────── 9. 伏神（藏爻） ─────────────────────
  group('伏神（本宫首卦借入缺爻六亲）', () {
    test('天风姤（乾宫）缺妻财 → 伏神为妻财寅木', () {
      final r = _paipan(1, 5); // 上乾下巽 = 天风姤
      expect(guaNameCN[r.benGua.name], '天风姤');
      final present = r.benGua.yaos.map((y) => _liuQinCN[y.liuQin]).toSet();
      expect(present.contains('妻财'), isFalse, reason: '姤卦无妻财，应伏神借入');
      expect(r.hiddenFuShen, isNotEmpty);
      expect(r.hiddenFuShen.first, contains('妻财'));
      expect(r.hiddenFuShen.first, contains('寅'));
    });

    test('六亲齐全的卦无伏神', () {
      final r = _paipan(1, 1); // 乾为天：父母/兄弟/官鬼/子孙齐（无妻财？）
      // 乾为天六亲：子水子孙、寅木妻财、辰土父母、午火官鬼、申金兄弟、戌土父母 → 齐全
      expect(r.hiddenFuShen, isEmpty);
    });
  });

  // ───────────────────── 10. 机器摇卦（三枚铜钱概率） ─────────────────────
  group('机器摇卦概率（三枚铜钱法）', () {
    test('动爻概率≈1/4，阴阳各≈1/2', () {
      var moving = 0;
      var yang = 0;
      const rounds = 600; // 3600 爻
      for (var i = 0; i < rounds; i++) {
        final r = LiuYaoEngine.manual();
        for (final y in r.benGua.yaos) {
          if (y.isMoving) moving++;
          if (y.yinYang == YaoYinYang.yang) yang++;
        }
      }
      final total = rounds * 6;
      final movingRate = moving / total;
      final yangRate = yang / total;
      expect(movingRate, closeTo(0.25, 0.03),
          reason: '三枚铜钱法的动爻概率应为 1/4，实际 $movingRate');
      expect(yangRate, closeTo(0.5, 0.03),
          reason: '阴阳各半，实际 $yangRate');
    });
  });

  // ───────────────────── 11. 时间起卦（梅花通行法） ─────────────────────
  group('时间起卦（年支+农历月日+时辰数）', () {
    test('六爻与梅花时间起卦规则一致且与独立推算相符', () {
      final samples = [
        DateTime(2024, 6, 15, 14, 30),
        DateTime(2025, 1, 3, 23, 10), // 晚子时
        DateTime(2023, 12, 31, 0, 5),
        DateTime(2026, 2, 17, 8, 0), // 春节附近
      ];
      for (final time in samples) {
        final solar = tyme.SolarDay.fromYmd(time.year, time.month, time.day);
        final lunar = solar.getLunarDay();
        final y = lunar
                .getLunarMonth()
                .getLunarYear()
                .getSixtyCycle()
                .getEarthBranch()
                .getIndex() +
            1;
        final m = lunar.getMonth().abs();
        final d = lunar.getDay();
        final h = ((time.hour + 1) ~/ 2) % 12 + 1;
        final sum = y + m + d;
        final upperIdx = (sum % 8) == 0 ? 7 : (sum % 8) - 1;
        final lowerIdx = ((sum + h) % 8) == 0 ? 7 : ((sum + h) % 8) - 1;
        final movingRaw = (sum + h) % 6;
        final movingIdx = movingRaw == 0 ? 5 : movingRaw - 1;

        final liuyao = LiuYaoEngine.byTime(time);
        final meihua = MeihuaEngine.fromDateTime(time);

        final expectName = _nameMatrix[upperIdx][lowerIdx];
        expect(guaNameCN[liuyao.benGua.name], expectName,
            reason: '$time 六爻时间起卦');
        expect(guaNameCN[meihua.benGua.name], expectName,
            reason: '$time 梅花时间起卦（应与六爻同法）');
        // 动爻位置
        final movingList =
            liuyao.benGua.yaos.asMap().entries.where((e) => e.value.isMoving).toList();
        expect(movingList.length, 1, reason: '时间起卦应恰有一个动爻');
        expect(movingList.first.key, movingIdx,
            reason: '$time 动爻应为第${movingIdx + 1}爻');
        // 日辰/月建必须取自起卦时间而非"当前时间"
        final gz = solar.getSixtyCycleDay().getSixtyCycle().getName();
        expect(liuyao.dayGanZhi, gz, reason: '$time 日辰应等于当日日柱');
      }
    });

    test('梅花时间起卦的互卦/变卦可正常生成', () {
      final r = MeihuaEngine.fromDateTime(DateTime(2024, 6, 15, 14, 30));
      expect(r.huGua, isNotNull);
      expect(r.bianGua, isNotNull);
    });
  });

  // ───────────────────── 10. 梅花：互卦与体用 ─────────────────────
  group('梅花易数（互卦/体用）', () {
    // MeihuaEngine 八卦索引：0乾 1兑 2离 3震 4巽 5坎 6艮 7坤
    test('水雷屯（上坎下震）互卦为山地剥', () {
      final r = MeihuaEngine.fromTrigrams(5, 3, 0);
      expect(guaNameCN[r.benGua.name], '水雷屯');
      expect(guaNameCN[r.huGua!.name], '山地剥');
    });

    test('体用：屯卦初爻动（用为下卦震木、体为上卦坎水）→ 体生用', () {
      final r = MeihuaEngine.fromTrigrams(5, 3, 0);
      expect(MeihuaEngine.getTiYong(r), contains('体生用'));
    });

    test('体用：屯卦四爻动（用为上卦坎水、体为下卦震木）→ 用生体', () {
      final r = MeihuaEngine.fromTrigrams(5, 3, 3);
      expect(MeihuaEngine.getTiYong(r), contains('用生体'));
    });

    test('梅花变卦：屯卦初爻动 → 下卦震翻初爻为坤，得上坎下坤（水地比）', () {
      final r = MeihuaEngine.fromTrigrams(5, 3, 0);
      // 震☳（阳阴阴）初爻动 → 阴阳阴 = 坎☵？实际：翻初爻 → 阴阴阴 = 坤
      // 震=阳阴阴，翻初(阳→阴) → 阴阴阴 = 坤 → 上坎下坤 = 水地比
      expect(guaNameCN[r.bianGua!.name], '水地比');
    });
  });
}

// ───────────────────────── 辅助 ─────────────────────────

List<bool> _triYangPattern(String tri) {
  switch (tri) {
    case '乾':
      return [true, true, true];
    case '兑':
      return [true, true, false];
    case '离':
      return [true, false, true];
    case '震':
      return [true, false, false];
    case '巽':
      return [false, true, true];
    case '坎':
      return [false, true, false];
    case '艮':
      return [false, false, true];
    default:
      return [false, false, false]; // 坤
  }
}

String _triFromPattern(List<bool> p) {
  for (final tri in _triNames) {
    final pat = _triYangPattern(tri);
    if (pat[0] == p[0] && pat[1] == p[1] && pat[2] == p[2]) return tri;
  }
  return '坤';
}

String _gongCN(GuaGong g) {
  const m = {
    GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离', GuaGong.zhen: '震',
    GuaGong.xun: '巽', GuaGong.kan: '坎', GuaGong.gen: '艮', GuaGong.kun: '坤',
  };
  return m[g]!;
}

String _liushenCN(LiuShen? s) {
  const m = {
    LiuShen.qingLong: '青龙', LiuShen.zhuQue: '朱雀', LiuShen.gouChen: '勾陈',
    LiuShen.tengShe: '螣蛇', LiuShen.baiHu: '白虎', LiuShen.xuanWu: '玄武',
  };
  return m[s] ?? '无';
}

/// 六十甲子（独立生成，避免依赖引擎）
List<String> _jiaZi60() {
  const gans = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  final out = <String>[];
  for (var i = 0; i < 60; i++) {
    out.add('${gans[i % 10]}${_zhis[i % 12]}');
  }
  return out;
}

// ───────────────────── 八字：纳音（六十甲子） ─────────────────────
void naYinGroup() {
  const gans = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  // 六十甲子纳音：每两个干支共用一纳音
  const naYinPairs = <((String, String), String)>[
    (('甲子', '乙丑'), '海中金'), (('丙寅', '丁卯'), '炉中火'),
    (('戊辰', '己巳'), '大林木'), (('庚午', '辛未'), '路旁土'),
    (('壬申', '癸酉'), '剑锋金'), (('甲戌', '乙亥'), '山头火'),
    (('丙子', '丁丑'), '涧下水'), (('戊寅', '己卯'), '城头土'),
    (('庚辰', '辛巳'), '白蜡金'), (('壬午', '癸未'), '杨柳木'),
    (('甲申', '乙酉'), '泉中水'), (('丙戌', '丁亥'), '屋上土'),
    (('戊子', '己丑'), '霹雳火'), (('庚寅', '辛卯'), '松柏木'),
    (('壬辰', '癸巳'), '长流水'), (('甲午', '乙未'), '沙中金'),
    (('丙申', '丁酉'), '山下火'), (('戊戌', '己亥'), '平地木'),
    (('庚子', '辛丑'), '壁上土'), (('壬寅', '癸卯'), '金箔金'),
    (('甲辰', '乙巳'), '覆灯火'), (('丙午', '丁未'), '天河水'),
    (('戊申', '己酉'), '大驿土'), (('庚戌', '辛亥'), '钗钏金'),
    (('壬子', '癸丑'), '桑柘木'), (('甲寅', '乙卯'), '大溪水'),
    (('丙辰', '丁巳'), '沙中土'), (('戊午', '己未'), '天上火'),
    (('庚申', '辛酉'), '石榴木'), (('壬戌', '癸亥'), '大海水'),
  ];

  test('六十甲子纳音全部正确', () {
    final wrong = <String>[];
    for (final (gzPair, expectNaYin) in naYinPairs) {
      for (final gz in [gzPair.$1, gzPair.$2]) {
        final ganIdx = gans.indexOf(gz[0]);
        final zhiIdx = _zhis.indexOf(gz[1]);
        final actual = getNaYin(ganIdx, zhiIdx)?.naYin;
        if (actual != expectNaYin) {
          wrong.add('$gz: 期望 $expectNaYin 实际 $actual');
        }
      }
    }
    expect(wrong, isEmpty, reason: wrong.join('\n'));
  });
}
