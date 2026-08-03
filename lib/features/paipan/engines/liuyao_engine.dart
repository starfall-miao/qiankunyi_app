// 六爻纳甲排盘引擎
// 纯 Dart 实现，所有术数规则硬编码，离线运行

import 'dart:math';
import 'package:tyme/tyme.dart' as tyme;
import '../models/yao_model.dart';
import '../models/gua_model.dart';
import '../models/paipan_result.dart';
import 'liuyao_date_helper.dart';

/// 64 卦映射表 [上卦索引][下卦索引] → GuaName
const _hexagramMap = <int, List<GuaName>>{
  // 乾(0)为上卦
  0: [
    GuaName.qian, GuaName.guai, GuaName.daYou, GuaName.daZhuang,
    GuaName.xiaoXu, GuaName.xu, GuaName.daXu, GuaName.tai,
  ],
  // 兑(1)为上卦
  1: [
    GuaName.lv2, GuaName.dui, GuaName.kui, GuaName.guiMei,
    GuaName.zhongFu, GuaName.jie2, GuaName.sun, GuaName.lin,
  ],
  // 离(2)为上卦
  2: [
    GuaName.tongRen, GuaName.ge, GuaName.li, GuaName.feng,
    GuaName.jiaRen, GuaName.jiJi, GuaName.bi2, GuaName.mingYi,
  ],
  // 震(3)为上卦
  3: [
    GuaName.wuWang, GuaName.sui, GuaName.shiHe, GuaName.zhen,
    GuaName.yi, GuaName.zhun, GuaName.fu, GuaName.yu,
  ],
  // 巽(4)为上卦
  4: [
    GuaName.gou, GuaName.daGuo, GuaName.ding, GuaName.heng,
    GuaName.xun, GuaName.jing, GuaName.sheng, GuaName.gu,
  ],
  // 坎(5)为上卦
  5: [
    GuaName.song, GuaName.kun2, GuaName.weiJi, GuaName.jie,
    GuaName.huan, GuaName.kan, GuaName.meng, GuaName.shi,
  ],
  // 艮(6)为上卦
  6: [
    GuaName.dun, GuaName.xian, GuaName.lv, GuaName.jian,
    GuaName.jian2, GuaName.jiJi, GuaName.gen, GuaName.bi,
  ],
  // 坤(7)为上卦
  7: [
    GuaName.pi, GuaName.cui, GuaName.jin, GuaName.yu,
    GuaName.guan, GuaName.bo, GuaName.qian2, GuaName.kun,
  ],
};

/// 八宫归属及世应位置 {(上卦,下卦) → (宫,世位,应位)}
final _palaceMap = <int, Map<int, (GuaGong, int, int)>>{
  // 数据格式: 上卦索引 → {下卦索引 → (所属宫, 世爻位置, 应爻位置)}
  0: {
    0: (GuaGong.qian, 5, 2),    // 乾为天 - 八纯 - 世在上爻(5) 应在三爻(2)
    1: (GuaGong.qian, 0, 3),    //  一世卦 - 世在初爻  应在四爻
    4: (GuaGong.qian, 1, 4),    //  二世卦
    7: (GuaGong.qian, 2, 5),    //  三世卦
    3: (GuaGong.qian, 3, 0),    //  四世卦
    6: (GuaGong.qian, 4, 1),    //  五世卦
    2: (GuaGong.qian, 3, 0),    //  游魂 - 世在四爻
    5: (GuaGong.qian, 2, 5),    //  归魂 - 世在三爻
  },
  7: {
    7: (GuaGong.kun, 5, 2),     // 坤为地
    3: (GuaGong.kun, 0, 3),
    2: (GuaGong.kun, 1, 4),
    0: (GuaGong.kun, 2, 5),
    4: (GuaGong.kun, 3, 0),
    5: (GuaGong.kun, 4, 1),
    6: (GuaGong.kun, 3, 0),
    1: (GuaGong.kun, 2, 5),
  },
  3: {
    3: (GuaGong.zhen, 5, 2),
    7: (GuaGong.zhen, 0, 3),
    5: (GuaGong.zhen, 1, 4),
    4: (GuaGong.zhen, 2, 5),
    0: (GuaGong.zhen, 3, 0),
    6: (GuaGong.zhen, 4, 1),
    2: (GuaGong.zhen, 3, 0),
    1: (GuaGong.zhen, 2, 5),
  },
  4: {
    4: (GuaGong.xun, 5, 2),
    0: (GuaGong.xun, 0, 3),
    2: (GuaGong.xun, 1, 4),
    3: (GuaGong.xun, 2, 5),
    7: (GuaGong.xun, 3, 0),
    5: (GuaGong.xun, 4, 1),
    6: (GuaGong.xun, 3, 0),
    1: (GuaGong.xun, 2, 5),
  },
  5: {
    5: (GuaGong.kan, 5, 2),
    1: (GuaGong.kan, 0, 3),
    3: (GuaGong.kan, 1, 4),
    4: (GuaGong.kan, 2, 5),
    2: (GuaGong.kan, 3, 0),
    6: (GuaGong.kan, 4, 1),
    7: (GuaGong.kan, 3, 0),
    0: (GuaGong.kan, 2, 5),
  },
  2: {
    2: (GuaGong.li, 5, 2),
    0: (GuaGong.li, 0, 3),
    1: (GuaGong.li, 1, 4),
    3: (GuaGong.li, 2, 5),
    4: (GuaGong.li, 3, 0),
    5: (GuaGong.li, 4, 1),
    7: (GuaGong.li, 3, 0),
    6: (GuaGong.li, 2, 5),
  },
  6: {
    6: (GuaGong.gen, 5, 2),
    2: (GuaGong.gen, 0, 3),
    0: (GuaGong.gen, 1, 4),
    1: (GuaGong.gen, 2, 5),
    4: (GuaGong.gen, 3, 0),
    3: (GuaGong.gen, 4, 1),
    5: (GuaGong.gen, 3, 0),
    7: (GuaGong.gen, 2, 5),
  },
  1: {
    1: (GuaGong.dui, 5, 2),
    5: (GuaGong.dui, 0, 3),
    7: (GuaGong.dui, 1, 4),
    3: (GuaGong.dui, 2, 5),
    4: (GuaGong.dui, 3, 0),
    6: (GuaGong.dui, 4, 1),
    0: (GuaGong.dui, 3, 0),
    2: (GuaGong.dui, 2, 5),
  },
};

/// 八卦三爻掩码表 [乾→坤]（0=乾111→7, 1=兑110→6, ... 7=坤000→0）
const _trigramMasks = [7, 6, 5, 4, 3, 2, 1, 0];

/// 八卦纳甲（京房装卦）：索引顺序 0乾 1兑 2离 3震 4巽 5坎 6艮 7坤（与
/// [_trigramMasks] / triPatterns 一致）。每卦记录 (内卦干, 内卦3支,
/// 外卦干, 外卦3支)。
/// 注意：纳甲装卦必须按**所在卦的实际上下卦**分别取各自的内/外卦纳甲，
/// 不能用"八纯卦"按宫套序列——非纯卦（如上清下坎等）时上下卦不同，
/// 宫固定序列会推错干支，进而连累六亲、世应、旺衰、空亡、刑冲等整卦结果。
const _trigramNaJia = <(String, List<String>, String, List<String>)>[
  ('甲', ['子', '寅', '辰'], '壬', ['午', '申', '戌']), // 乾
  ('丁', ['巳', '卯', '丑'], '丁', ['亥', '酉', '未']), // 兑
  ('己', ['卯', '丑', '亥'], '己', ['酉', '未', '巳']), // 离
  ('庚', ['子', '寅', '辰'], '庚', ['午', '申', '戌']), // 震
  ('辛', ['丑', '亥', '酉'], '辛', ['未', '巳', '卯']), // 巽
  ('戊', ['寅', '辰', '午'], '戊', ['申', '戌', '子']), // 坎
  ('丙', ['辰', '午', '申'], '丙', ['戌', '子', '寅']), // 艮
  ('乙', ['未', '巳', '卯'], '癸', ['丑', '亥', '酉']), // 坤
];

/// 天干 → TianGan 映射
final _tianGanMap = <String, TianGan>{
  '甲': TianGan.jia, '乙': TianGan.yi, '丙': TianGan.bing, '丁': TianGan.ding,
  '戊': TianGan.wu, '己': TianGan.ji, '庚': TianGan.geng, '辛': TianGan.xin,
  '壬': TianGan.ren, '癸': TianGan.gui,
};

/// 地支 → DiZhi 映射
final _diZhiMap = <String, DiZhi>{
  '子': DiZhi.zi, '丑': DiZhi.chou, '寅': DiZhi.yin, '卯': DiZhi.mao,
  '辰': DiZhi.chen, '巳': DiZhi.si, '午': DiZhi.wu, '未': DiZhi.wei,
  '申': DiZhi.shen, '酉': DiZhi.you, '戌': DiZhi.xu, '亥': DiZhi.hai,
};

/// 地支五行
final _diZhiWuXing = <DiZhi, WuXing>{
  DiZhi.zi: WuXing.shui,
  DiZhi.chou: WuXing.tu,
  DiZhi.yin: WuXing.mu,
  DiZhi.mao: WuXing.mu,
  DiZhi.chen: WuXing.tu,
  DiZhi.si: WuXing.huo,
  DiZhi.wu: WuXing.huo,
  DiZhi.wei: WuXing.tu,
  DiZhi.shen: WuXing.jin,
  DiZhi.you: WuXing.jin,
  DiZhi.xu: WuXing.tu,
  DiZhi.hai: WuXing.shui,
};

/// 地支索引
final _diZhiIndex = <DiZhi, int>{
  DiZhi.zi: 0, DiZhi.chou: 1, DiZhi.yin: 2, DiZhi.mao: 3,
  DiZhi.chen: 4, DiZhi.si: 5, DiZhi.wu: 6, DiZhi.wei: 7,
  DiZhi.shen: 8, DiZhi.you: 9, DiZhi.xu: 10, DiZhi.hai: 11,
};

/// 六合表 (地支索引 → 合的地支索引)
const _liuHe = [6, 5, 11, 10, 9, 1, 0, 11, 10, 4, 3, 2];
// 子丑合: 0↔1, 寅亥合: 2↔11, 卯戌合: 3↔10, 辰酉合: 4↔9, 巳申合: 5↔8, 午未合: 6↔7

/// 六冲表
const _liuChong = [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5];

/// 三刑：寅巳申三刑
const _sanXingGroup1 = [2, 5, 8]; // 寅巳申
/// 三刑：丑未戌三刑
const _sanXingGroup2 = [1, 7, 10]; // 丑未戌
/// 自刑：辰午酉亥
const _ziXing = [4, 6, 9, 11]; // 辰午酉亥自刑

/// 六害表
const _liuHai = [7, 6, 5, 4, 3, 2, 1, 0, 11, 10, 9, 8];

/// 三合局
const _sanHeJu = [
  [0, 4, 8],   // 申子辰（水）
  [2, 6, 10],  // 寅午戌（火）
  [1, 5, 9],   // 巳酉丑（金）
  [3, 7, 11],  // 亥卯未（木）
];

/// 地支 → 地支名
const _diZhiName = [
  '子', '丑', '寅', '卯', '辰', '巳',
  '午', '未', '申', '酉', '戌', '亥',
];

/// 六爻纳甲排盘引擎
class LiuYaoEngine {
  static final _random = Random();

  /// 手动摇卦
  static PaipanResult manual({LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final yaos = <YaoModel>[];
    for (int i = 0; i < 6; i++) {
      final isYang = _random.nextBool();
      final isMoving = _random.nextInt(6) == 0;
      yaos.add(YaoModel(
        yinYang: isYang ? YaoYinYang.yang : YaoYinYang.yin,
        position: YaoPosition.values[i],
        isMoving: isMoving,
      ));
    }
    return _buildResult(yaos, '机器摇卦', school: school);
  }

  /// 从爻列表构建排盘结果（手工输入用）
  static PaipanResult fromYaos(List<YaoModel> yaos,
      {DateTime? time, LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    return _buildResult(yaos, '手工摇卦', dt: time, school: school);
  }

  /// 时间起卦
  static PaipanResult byTime(DateTime time,
      {LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final year = time.year % 100;
    final month = time.month;
    final day = time.day;
    final hour = time.hour;
    // 时辰数（子1~亥12）
    final shiChen = ((hour + 1) ~/ 2).clamp(1, 12);

    final upperIdx = _toTrigramIndex(year + month + day);
    final lowerIdx = _toTrigramIndex(shiChen);
    final movingIdx = (year + month + day + shiChen) % 6;

    return _buildFromTrigrams(upperIdx, lowerIdx, movingIdx, '时间起卦', school: school);
  }

  /// 数字起卦
  static PaipanResult byNumbers(int a, int b, int c,
      {LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final upperIdx = _toTrigramIndex(a);
    final lowerIdx = _toTrigramIndex(b);
    final movingIdx = (c - 1) % 6; // c为动爻序号（1-6），转为0-based
    return _buildFromTrigrams(upperIdx, lowerIdx, movingIdx, '数字起卦', school: school);
  }

  /// 数字 → 八卦索引（0=乾 ~ 7=坤）
  static int _toTrigramIndex(int num) {
    final r = num % 8;
    return r == 0 ? 7 : r - 1;
  }

  /// 由上下卦构建排盘结果
  static PaipanResult _buildFromTrigrams(
      int upperIdx, int lowerIdx, int movingYaoIdx, String method,
      {DateTime? dt, LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    // 八卦爻模式：从初爻到上爻（0~2为下卦/内卦，3~5为上卦/外卦）
    const triPatterns = [
      [1, 1, 1], // 0乾
      [1, 1, 0], // 1兑
      [1, 0, 1], // 2离
      [1, 0, 0], // 3震
      [0, 1, 1], // 4巽
      [0, 1, 0], // 5坎
      [0, 0, 1], // 6艮
      [0, 0, 0], // 7坤
    ];
    final lowerPat = triPatterns[lowerIdx];
    final upperPat = triPatterns[upperIdx];

    final yaos = List.generate(6, (i) {
      final isUpper = i >= 3;
      final pat = isUpper ? upperPat : lowerPat;
      final vy = pat[isUpper ? i - 3 : i];
      return YaoModel(
        yinYang: vy == 1 ? YaoYinYang.yang : YaoYinYang.yin,
        position: YaoPosition.values[i],
        isMoving: i == movingYaoIdx,
      );
    });

    return _buildResult(yaos, method, dt: dt, school: school);
  }

  /// 从爻数据构建完整排盘结果
  static PaipanResult _buildResult(List<YaoModel> yaos, String method,
      {DateTime? dt, LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    dt ??= DateTime.now();
    // 从六个爻反推上下卦掩码
    final upperMask = _yaosToMask(yaos.sublist(0, 3).reversed.toList());
    final lowerMask = _yaosToMask(yaos.sublist(3, 6).reversed.toList());

    var guaName = GuaName.qian;
    var gong = GuaGong.qian;
    var shiIdx = 5;
    var yingIdx = 2;
    // 本卦实际构成的上/下卦（八卦索引）。注意：upperMask/lowerMask 变量名
    // 与卦名相反（upperMask 实为初二三爻=下卦/内卦），此处仅取其索引。
    // 用于按实际上下卦执行纳甲装卦。
    var innerTriIdx = 0;
    var outerTriIdx = 0;

    // 通过掩码查找对应的卦名
    for (int u = 0; u < _trigramMasks.length; u++) {
      if (_trigramMasks[u] != upperMask) continue;
      for (int l = 0; l < _trigramMasks.length; l++) {
        if (_trigramMasks[l] != lowerMask) continue;
        innerTriIdx = u; // 下卦/内卦（初二三爻所在卦）
        outerTriIdx = l; // 上卦/外卦（四五六爻所在卦）
        if (u < _hexagramMap.length && l < (_palaceMap[u]?.length ?? 0)) {
          guaName = _hexagramMap[u]![l];
          final palace = _palaceMap[u]![l]!;
          gong = palace.$1;
          shiIdx = palace.$2;
          yingIdx = palace.$3;
        }
        break;
      }
      break;
    }

    // 标记世应
    if (shiIdx >= 0 && shiIdx < yaos.length) yaos[shiIdx].isShi = true;
    if (yingIdx >= 0 && yingIdx < yaos.length) yaos[yingIdx].isYing = true;

    // 纳甲装卦：内三爻(初二三)用内卦(下卦)的内卦纳甲，外三爻(四五六)用
    // 外卦(上卦)的外卦纳甲。修复旧按"宫"套纯卦序列导致非纯卦干支推错的问题。
    final inner = _trigramNaJia[innerTriIdx];
    final outer = _trigramNaJia[outerTriIdx];
    for (int i = 0; i < 3; i++) {
      yaos[i].tianGan = _tianGanMap[inner.$1];
      yaos[i].diZhi = _diZhiMap[inner.$2[i]];
    }
    for (int i = 0; i < 3; i++) {
      yaos[i + 3].tianGan = _tianGanMap[outer.$3];
      yaos[i + 3].diZhi = _diZhiMap[outer.$4[i]];
    }

    // 六亲排布
    _applyLiuQin(yaos, guaGongWuXing[gong]!);

    // ───── 月令/日令/空亡（基于 tyme4dart） ─────
    final solarDay = tyme.SolarDay.fromYmd(dt.year, dt.month, dt.day);
    final monthZhi = monthZhiSimple(dt.month); // 月建地支
    final dayGanZhi = dayGanZhiFromTyme(solarDay); // 日柱干支
    final monthGanZhi = monthGanZhiFromTyme(solarDay); // 月柱干支
    final dayGzIdx = dayGanZhiIndex(solarDay); // 日干支索引
    final kongWangList = calcKongWang(dayGzIdx); // 旬空列表

    // 标记空亡
    for (final yao in yaos) {
      if (yao.diZhi != null) {
        final dzName = _diZhiMap.entries
            .firstWhere((e) => e.value == yao.diZhi, orElse: () => MapEntry('', DiZhi.zi))
            .key;
        yao.isKongWang = kongWangList.contains(dzName);
      }
    }

    // 六神（根据日干）
    _applyLiuShen(yaos, _dayGanIndex(dt));

    // 旺衰（根据月令）
    _applyWangShuai(yaos, dt.month);

    // 刑冲合害
    _calcRelations(yaos);

    final gua = GuaModel(
      name: guaName,
      gong: gong,
      yaos: yaos,
      shiYaoIndex: shiIdx,
      yingYaoIndex: yingIdx,
    );

    // 变卦：动爻阴阳反转
    final movingYao = yaos.indexWhere((y) => y.isMoving);
    GuaModel? bianGua;
    if (movingYao >= 0) {
      final bianYaos = yaos.map((y) {
        if (y.isMoving) {
          return YaoModel(
            yinYang: y.yinYang == YaoYinYang.yang ? YaoYinYang.yin : YaoYinYang.yang,
            position: y.position,
            isMoving: false,
            tianGan: y.tianGan,
            diZhi: y.diZhi,
            liuQin: y.liuQin,
            isShi: y.isShi,
            isYing: y.isYing,
          );
        }
        return YaoModel(
          yinYang: y.yinYang,
          position: y.position,
          tianGan: y.tianGan,
          diZhi: y.diZhi,
          liuQin: y.liuQin,
          isShi: y.isShi,
          isYing: y.isYing,
        );
      }).toList();
      bianGua = _restoreGua(bianYaos);
    }

    return PaipanResult(
      benGua: gua,
      bianGua: bianGua,
      paipanTime: dt,
      method: method,
      school: school,
      monthZhi: monthZhi,
      monthGanZhi: monthGanZhi,
      dayGanZhi: dayGanZhi,
      kongWang: kongWangList,
    );
  }

  /// 爻列表 → 二进制掩码
  static int _yaosToMask(List<YaoModel> yaos) {
    int mask = 0;
    for (int i = 0; i < yaos.length; i++) {
      if (yaos[i].yinYang == YaoYinYang.yang) {
        mask |= (1 << i);
      }
    }
    return mask;
  }

  /// 六亲排布
  static void _applyLiuQin(List<YaoModel> yaos, WuXing gongWuXing) {
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      final yaoWuXing = _diZhiWuXing[yao.diZhi]!;
      yao.liuQin = _calcLiuQin(gongWuXing, yaoWuXing);
    }
  }

  /// 计算六亲：以宫五行为"我"
  static LiuQin _calcLiuQin(WuXing wo, WuXing bi) {
    if (wo == bi) return LiuQin.brother;
    // 生克关系：金→水→木→火→土→金
    if (_sheng(wo) == bi) return LiuQin.child;      // 我生者为子孙
    if (_sheng(bi) == wo) return LiuQin.parent;     // 生我者为父母
    if (_ke(wo) == bi) return LiuQin.wife;           // 我克者为妻财
    if (_ke(bi) == wo) return LiuQin.officer;        // 克我者为官鬼
    return LiuQin.none;
  }

  /// 五行相生：某行生谁
  static WuXing _sheng(WuXing w) {
    switch (w) {
      case WuXing.jin: return WuXing.shui;
      case WuXing.shui: return WuXing.mu;
      case WuXing.mu: return WuXing.huo;
      case WuXing.huo: return WuXing.tu;
      case WuXing.tu: return WuXing.jin;
    }
  }

  /// 五行相克：某行克谁
  static WuXing _ke(WuXing w) {
    switch (w) {
      case WuXing.jin: return WuXing.mu;
      case WuXing.mu: return WuXing.tu;
      case WuXing.tu: return WuXing.shui;
      case WuXing.shui: return WuXing.huo;
      case WuXing.huo: return WuXing.jin;
    }
  }

  /// 刑冲合害计算
  static void _calcRelations(List<YaoModel> yaos) {
    for (int i = 0; i < 6; i++) {
      if (yaos[i].diZhi == null) continue;
      final zi = _diZhiIndex[yaos[i].diZhi!]!;

      // 六冲
      if (_diZhiIndex[yaos[i].diZhi!] == _liuChong[zi]) {
        yaos[i].isChong = true;
      }

      // 六合（需成对）
      for (int j = i + 1; j < 6; j++) {
        if (yaos[j].diZhi == null) continue;
        final zj = _diZhiIndex[yaos[j].diZhi!]!;
        if (_liuHe[zi] == zj) {
          yaos[i].isHe = true;
          yaos[j].isHe = true;
        }
        if (_liuChong[zi] == zj) {
          yaos[i].isChong = true;
          yaos[j].isChong = true;
        }
        if (_liuHai[zi] == zj) {
          yaos[i].isHai = true;
          yaos[j].isHai = true;
        }
        // 三刑
        if (_sanXingGroup1.contains(zi) && _sanXingGroup1.contains(zj)) {
          yaos[i].isXing = true;
          yaos[j].isXing = true;
        }
        if (_sanXingGroup2.contains(zi) && _sanXingGroup2.contains(zj)) {
          yaos[i].isXing = true;
          yaos[j].isXing = true;
        }
      }

      // 自刑
      if (_ziXing.contains(zi)) {
        yaos[i].isXing = true;
      }

      // 三合局
      for (final ju in _sanHeJu) {
        if (ju.contains(zi)) {
          var matched = yaos.where((y) =>
            y.diZhi != null && ju.contains(_diZhiIndex[y.diZhi!]));
          if (matched.length >= 2 && !matched.contains(yaos[i])) {
            matched = yaos.where((y) =>
              y.diZhi != null && ju.contains(_diZhiIndex[y.diZhi!]));
          }
          if (matched.length >= 3) {
            final names = matched.map((y) => _diZhiName[_diZhiIndex[y.diZhi!]!]).toList();
            for (final y in matched) {
              y.sanHeJu = names;
            }
          }
        }
      }
    }
  }

  // ──────────── 六神排布 ────────────

  /// 日干索引 → 六神起始位置
  static const _liuShenStarts = <int, LiuShen>{
    0: LiuShen.qingLong, // 甲
    1: LiuShen.qingLong, // 乙
    2: LiuShen.zhuQue,   // 丙
    3: LiuShen.zhuQue,   // 丁
    4: LiuShen.gouChen,  // 戊
    5: LiuShen.tengShe,  // 己
    6: LiuShen.baiHu,    // 庚
    7: LiuShen.baiHu,    // 辛
    8: LiuShen.xuanWu,   // 壬
    9: LiuShen.xuanWu,   // 癸
  };

  /// 六神循环顺序
  static const _liuShenCycle = [
    LiuShen.qingLong,
    LiuShen.zhuQue,
    LiuShen.gouChen,
    LiuShen.tengShe,
    LiuShen.baiHu,
    LiuShen.xuanWu,
  ];

  /// 计算排盘时间的日干索引（0甲~9癸）
  static int _dayGanIndex(DateTime dt) {
    // 日干支计算：基准点 1900-01-01 为甲子日（日干=0，日支=0）
    final base = DateTime(1900, 1, 1);
    final diff = dt.difference(base).inDays;
    return ((diff % 10) + 10) % 10;
  }

  /// 应用六神
  static void _applyLiuShen(List<YaoModel> yaos, int dayGanIdx) {
    final start = _liuShenStarts[dayGanIdx] ?? LiuShen.qingLong;
    final startIdx = _liuShenCycle.indexOf(start);
    for (int i = 0; i < yaos.length; i++) {
      yaos[i].liuShen = _liuShenCycle[(startIdx + i) % 6];
    }
  }

  // ──────────── 旺衰排布 ────────────

  /// 月令五行索引：寅卯=木月(0), 巳午=火月(1), 申酉=金月(2),
  /// 亥子=水月(3), 辰戌丑未=土月(4)
  static int _monthWuXing(int month) {
    if (month >= 2 && month <= 3) return 0; // 寅卯木
    if (month >= 4 && month <= 5) return 1; // 巳午火
    if (month >= 7 && month <= 8) return 2; // 申酉金
    if (month >= 10 && month <= 11) return 3; // 亥子水
    return 4; // 辰戌丑未土
  }

  /// 旺衰表：五行 → [旺, 相, 休, 囚, 死]
  /// 顺序：木火金水土
  static const _wangShuaiTable = <int, List<WangShuaiLevel>>{
    0: [ // 木月旺
      WangShuaiLevel.wang,   // 木旺
      WangShuaiLevel.xiang,  // 火相
      WangShuaiLevel.qiu,    // 金囚
      WangShuaiLevel.xiu,    // 水休
      WangShuaiLevel.si,     // 土死
    ],
    1: [ // 火月旺
      WangShuaiLevel.si,     // 木死
      WangShuaiLevel.wang,   // 火旺
      WangShuaiLevel.xiang,  // 土相
      WangShuaiLevel.qiu,    // 金囚
      WangShuaiLevel.xiu,    // 水休
    ],
    2: [ // 金月旺
      WangShuaiLevel.qiu,    // 木囚
      WangShuaiLevel.si,     // 火死
      WangShuaiLevel.wang,   // 金旺
      WangShuaiLevel.xiang,  // 水相
      WangShuaiLevel.xiu,    // 土休
    ],
    3: [ // 水月旺
      WangShuaiLevel.xiu,    // 木休
      WangShuaiLevel.qiu,    // 火囚
      WangShuaiLevel.si,     // 金死
      WangShuaiLevel.wang,   // 水旺
      WangShuaiLevel.xiang,  // 土相
    ],
    4: [ // 土月旺
      WangShuaiLevel.xiang,  // 木相
      WangShuaiLevel.xiu,    // 火休
      WangShuaiLevel.si,     // 金死
      WangShuaiLevel.qiu,    // 水囚
      WangShuaiLevel.wang,   // 土旺
    ],
  };

  /// 地支五行索引：0木 1火 2金 3水 4土
  static const _diZhiWuXingIdx = <int, int>{
    0: 3, // 子水
    1: 4, // 丑土
    2: 0, // 寅木
    3: 0, // 卯木
    4: 4, // 辰土
    5: 1, // 巳火
    6: 1, // 午火
    7: 4, // 未土
    8: 2, // 申金
    9: 2, // 酉金
    10: 4, // 戌土
    11: 3, // 亥水
  };

  /// 应用旺衰
  static void _applyWangShuai(List<YaoModel> yaos, int month) {
    final monthIdx = _monthWuXing(month);
    final table = _wangShuaiTable[monthIdx]!;
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      final dzIdx = _diZhiIndex[yao.diZhi!]!;
      final wxIdx = _diZhiWuXingIdx[dzIdx]!;
      yao.wangShuai = table[wxIdx];
    }
  }

  // ──────────── 从爻重建卦 ────────────

  /// 从爻列表重建卦（用于变卦）
  static GuaModel _restoreGua(List<YaoModel> yaos) {
    final upperMask = _yaosToMask(yaos.sublist(0, 3).reversed.toList());
    final lowerMask = _yaosToMask(yaos.sublist(3, 6).reversed.toList());
    for (int u = 0; u < _trigramMasks.length; u++) {
      if (_trigramMasks[u] != upperMask) continue;
      for (int l = 0; l < _trigramMasks.length; l++) {
        if (_trigramMasks[l] != lowerMask) continue;
        if (u < _hexagramMap.length && l < (_palaceMap[u]?.length ?? 0)) {
          final name = _hexagramMap[u]![l];
          final palace = _palaceMap[u]![l]!;
          return GuaModel(
            name: name,
            gong: palace.$1,
            yaos: yaos,
            shiYaoIndex: palace.$2,
            yingYaoIndex: palace.$3,
          );
        }
      }
    }
    return GuaModel(
      name: GuaName.qian,
      gong: GuaGong.qian,
      yaos: yaos,
      shiYaoIndex: 5,
      yingYaoIndex: 2,
    );
  }
}
