// 六爻纳甲排盘引擎
// 纯 Dart 实现，所有术数规则硬编码，离线运行

import 'dart:math';
import 'package:tyme/tyme.dart' as tyme;
import '../models/yao_model.dart';
import '../models/gua_model.dart';
import '../models/paipan_result.dart';
import 'liuyao_date_helper.dart';

/// 64 卦映射表 [下卦索引][上卦索引] → GuaName
/// 注意：引擎中下标 u 为下卦/内卦索引，l 为上卦/外卦索引。
/// 本表行=下卦，列=上卦。数据由京房八宫生成规则核验确认。
const _hexagramMap = <int, List<GuaName>>{
  // 乾(0)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  0: [
    GuaName.qian, GuaName.guai, GuaName.daYou, GuaName.daZhuang,
    GuaName.xiaoXu, GuaName.xu, GuaName.daXu, GuaName.tai,
  ],
  // 兑(1)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  1: [
    GuaName.lv, GuaName.dui, GuaName.kui, GuaName.guiMei,
    GuaName.zhongFu, GuaName.jie2, GuaName.sun, GuaName.lin,
  ],
  // 离(2)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  2: [
    GuaName.tongRen, GuaName.ge, GuaName.li, GuaName.feng,
    GuaName.jiaRen, GuaName.jiJi, GuaName.bi2, GuaName.mingYi,
  ],
  // 震(3)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  3: [
    GuaName.wuWang, GuaName.sui, GuaName.shiHe, GuaName.zhen,
    GuaName.yi2, GuaName.zhun, GuaName.yi, GuaName.fu,
  ],
  // 巽(4)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  4: [
    GuaName.gou, GuaName.daGuo, GuaName.ding, GuaName.heng,
    GuaName.xun, GuaName.jing, GuaName.gu, GuaName.sheng,
  ],
  // 坎(5)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  5: [
    GuaName.song, GuaName.kun2, GuaName.weiJi, GuaName.jie,
    GuaName.huan, GuaName.kan, GuaName.meng, GuaName.shi,
  ],
  // 艮(6)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  6: [
    GuaName.dun, GuaName.xian, GuaName.lv2, GuaName.xiaoGuo,
    GuaName.jian2, GuaName.jian, GuaName.gen, GuaName.qian2,
  ],
  // 坤(7)为下卦 — 上卦：乾/兑/离/震/巽/坎/艮/坤
  7: [
    GuaName.pi, GuaName.cui, GuaName.jin, GuaName.yu,
    GuaName.guan, GuaName.bi, GuaName.bo, GuaName.kun,
  ],
};

/// 八宫归属及世应位置 [下卦索引][上卦索引] → (宫, 世位, 应位)
/// 注意：引擎中下标 u 为下卦/内卦索引，l 为上卦/外卦索引。
/// 本表行=下卦，列=上卦。数据由京房八宫生成规则（一世→二世→…→游魂→归魂）程序化生成并核验。
final _palaceMap = <int, Map<int, (GuaGong, int, int)>>{
  // 乾(0)为下卦
  0: {
    0: (GuaGong.qian, 5, 2), // 乾 上乾下乾
    1: (GuaGong.kun, 4, 1), // 夬 上兑下乾
    2: (GuaGong.qian, 2, 5), // 大有 上离下乾
    3: (GuaGong.kun, 3, 0), // 大壮 上震下乾
    4: (GuaGong.xun, 0, 3), // 小畜 上巽下乾
    5: (GuaGong.kun, 3, 0), // 需 上坎下乾
    6: (GuaGong.gen, 1, 4), // 大畜 上艮下乾
    7: (GuaGong.kun, 2, 5), // 泰 上坤下乾
  },
  // 兑(1)为下卦
  1: {
    0: (GuaGong.gen, 4, 1), // 履 上乾下兑
    1: (GuaGong.dui, 5, 2), // 兑 上兑下兑
    2: (GuaGong.gen, 3, 0), // 睽 上离下兑
    3: (GuaGong.dui, 2, 5), // 归妹 上震下兑
    4: (GuaGong.gen, 3, 0), // 中孚 上巽下兑
    5: (GuaGong.kan, 0, 3), // 节 上坎下兑
    6: (GuaGong.gen, 2, 5), // 损 上艮下兑
    7: (GuaGong.kun, 1, 4), // 临 上坤下兑
  },
  // 离(2)为下卦
  2: {
    0: (GuaGong.li, 2, 5), // 同人 上乾下离
    1: (GuaGong.kan, 3, 0), // 革 上兑下离
    2: (GuaGong.li, 5, 2), // 离 上离下离
    3: (GuaGong.kan, 4, 1), // 丰 上震下离
    4: (GuaGong.xun, 1, 4), // 家人 上巽下离
    5: (GuaGong.kan, 2, 5), // 既济 上坎下离
    6: (GuaGong.gen, 0, 3), // 贲 上艮下离
    7: (GuaGong.kan, 3, 0), // 明夷 上坤下离
  },
  // 震(3)为下卦
  3: {
    0: (GuaGong.xun, 3, 0), // 无妄 上乾下震
    1: (GuaGong.zhen, 2, 5), // 随 上兑下震
    2: (GuaGong.xun, 4, 1), // 噬嗑 上离下震
    3: (GuaGong.zhen, 5, 2), // 震 上震下震
    4: (GuaGong.xun, 2, 5), // 益 上巽下震
    5: (GuaGong.kan, 1, 4), // 屯 上坎下震
    6: (GuaGong.xun, 3, 0), // 颐 上艮下震
    7: (GuaGong.kun, 0, 3), // 复 上坤下震
  },
  // 巽(4)为下卦
  4: {
    0: (GuaGong.qian, 0, 3), // 姤 上乾下巽
    1: (GuaGong.zhen, 3, 0), // 大过 上兑下巽
    2: (GuaGong.li, 1, 4), // 鼎 上离下巽
    3: (GuaGong.zhen, 2, 5), // 恒 上震下巽
    4: (GuaGong.xun, 5, 2), // 巽 上巽下巽
    5: (GuaGong.zhen, 4, 1), // 井 上坎下巽
    6: (GuaGong.xun, 2, 5), // 蛊 上艮下巽
    7: (GuaGong.zhen, 3, 0), // 升 上坤下巽
  },
  // 坎(5)为下卦
  5: {
    0: (GuaGong.li, 3, 0), // 讼 上乾下坎
    1: (GuaGong.dui, 0, 3), // 困 上兑下坎
    2: (GuaGong.li, 2, 5), // 未济 上离下坎
    3: (GuaGong.zhen, 1, 4), // 解 上震下坎
    4: (GuaGong.li, 4, 1), // 涣 上巽下坎
    5: (GuaGong.kan, 5, 2), // 坎 上坎下坎
    6: (GuaGong.li, 3, 0), // 蒙 上艮下坎
    7: (GuaGong.kan, 2, 5), // 师 上坤下坎
  },
  // 艮(6)为下卦
  6: {
    0: (GuaGong.qian, 1, 4), // 遁 上乾下艮
    1: (GuaGong.dui, 2, 5), // 咸 上兑下艮
    2: (GuaGong.li, 0, 3), // 旅 上离下艮
    3: (GuaGong.dui, 3, 0), // 小过 上震下艮
    4: (GuaGong.gen, 2, 5), // 渐 上巽下艮
    5: (GuaGong.dui, 3, 0), // 蹇 上坎下艮
    6: (GuaGong.gen, 5, 2), // 艮 上艮下艮
    7: (GuaGong.dui, 4, 1), // 谦 上坤下艮
  },
  // 坤(7)为下卦
  7: {
    0: (GuaGong.qian, 2, 5), // 否 上乾下坤
    1: (GuaGong.dui, 1, 4), // 萃 上兑下坤
    2: (GuaGong.qian, 3, 0), // 晋 上离下坤
    3: (GuaGong.zhen, 0, 3), // 豫 上震下坤
    4: (GuaGong.qian, 3, 0), // 观 上巽下坤
    5: (GuaGong.kun, 2, 5), // 比 上坎下坤
    6: (GuaGong.qian, 4, 1), // 剥 上艮下坤
    7: (GuaGong.kun, 5, 2), // 坤 上坤下坤
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
/// 子丑(0↔1)、寅亥(2↔11)、卯戌(3↔10)、辰酉(4↔9)、巳申(5↔8)、午未(6↔7)
const _liuHe = [1, 0, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

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

  /// 机器摇卦（三枚铜钱法）
  ///
  /// 传统概率（每爻以三枚铜钱掷出，背/字组合）：
  /// - 老阳（三背，阳爻动）1/8
  /// - 少阳（二背一字，阳爻静）3/8
  /// - 少阴（一背二字，阴爻静）3/8
  /// - 老阴（三字，阴爻动）1/8
  ///
  /// 即：阳/阴各占 1/2，**动爻概率 1/4**（动爻中老阳/老阴各半）。
  /// 旧实现用「每爻 1/6 独立随机 + 阴阳各半」，动爻概率偏低且分布不符古法。
  static PaipanResult manual({LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final yaos = <YaoModel>[];
    for (int i = 0; i < 6; i++) {
      // 0 → 老阴(阴,动)；1 → 老阳(阳,动)；2-4 → 少阳(阳,静)；5-7 → 少阴(阴,静)
      final r = _random.nextInt(8);
      final bool isYang;
      final bool isMoving;
      if (r == 0) {
        isYang = false;
        isMoving = true; // 老阴
      } else if (r == 1) {
        isYang = true;
        isMoving = true; // 老阳
      } else if (r <= 4) {
        isYang = true;
        isMoving = false; // 少阳
      } else {
        isYang = false;
        isMoving = false; // 少阴
      }
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

  /// 时间起卦（《梅花易数》通行法，与梅花引擎同一规则）
  ///
  /// 上卦 =（年支序数 + 农历月 + 农历日）÷ 8 取余
  /// 下卦 =（年支序数 + 农历月 + 农历日 + 时辰数）÷ 8 取余
  /// 动爻 = 同下卦之和 ÷ 6 取余（余 0 作上爻）
  ///
  /// 修正三处旧缺陷：
  /// 1. 原用「公历年后两位 + 公历月日」，非通行法（应为农历 + 年支序数）；
  /// 2. 原 `(和) % 6` 直接把 0 当初爻，而余 0 传统作**上爻**（1/6 的卦错位一爻）；
  /// 3. 原未把起卦时间传给日辰/月建计算，导致日辰月建取的是"当前时间"。
  static PaipanResult byTime(DateTime time,
      {LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final solar = tyme.SolarDay.fromYmd(time.year, time.month, time.day);
    final lunar = solar.getLunarDay();
    // 农历年干支地支序数（子=0）+1 → 子1…亥12
    final yearBranchIdx = lunar
        .getLunarMonth()
        .getLunarYear()
        .getSixtyCycle()
        .getEarthBranch()
        .getIndex();
    final y = yearBranchIdx + 1;
    final m = lunar.getMonth().abs(); // 闰月按本月计
    final d = lunar.getDay();
    // 时辰数（子1~亥12）：23:00-00:59 归子时，每两小时顺进一位
    final shiChen = ((time.hour + 1) ~/ 2) % 12 + 1;

    final sum = y + m + d;
    final upperIdx = _toTrigramIndex(sum);
    final lowerIdx = _toTrigramIndex(sum + shiChen);
    final movingRaw = (sum + shiChen) % 6;
    // 余 0 作上爻（索引 5），余 1-5 为初至五爻
    final movingIdx = movingRaw == 0 ? 5 : movingRaw - 1;

    return _buildFromTrigrams(upperIdx, lowerIdx, movingIdx, '时间起卦',
        dt: time, school: school);
  }

  /// 数字起卦
  static PaipanResult byNumbers(int a, int b, int c,
      {LiuyaoSchool school = LiuyaoSchool.jingFangJianBan}) {
    final upperIdx = _toTrigramIndex(a);
    final lowerIdx = _toTrigramIndex(b);
    final movingIdx = ((c - 1) % 6 + 6) % 6; // c为动爻序号（1-6），转为0-based（负数安全）
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

    // 藏爻/伏神：本卦缺失的六亲，自本宫首卦（八纯卦）借入
    final fuShen = _calcFuShen(yaos, gong, guaGongWuXing[gong]!);

    // ───── 月令/日令/空亡（基于 tyme4dart） ─────
    final solarDay = tyme.SolarDay.fromYmd(dt.year, dt.month, dt.day);
    final dayGanZhi = dayGanZhiFromTyme(solarDay); // 日柱干支
    final monthGanZhi = monthGanZhiFromTyme(solarDay); // 月柱干支（精确节气月）
    // 月建地支以 tyme 精确节气月（立春换寅月）为准：旧实现用公历月近似，
    // 与同屏显示的精确月柱自相矛盾（如公历2月10日显示月建'卯'但月柱'甲寅'）。
    final preciseMonthZhi =
        monthGanZhi.length >= 2 ? monthGanZhi[1] : '';
    final monthZhi = preciseMonthZhi.isNotEmpty
        ? preciseMonthZhi
        : monthZhiSimple(dt.month);
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

    // 旺衰（根据月令地支五行）
    _applyWangShuaiByZhi(yaos, monthZhi);

    // 刑冲合害
    _calcRelations(yaos);

    // 月破（月建冲爻）、日破/暗动（日辰冲爻）
    _applyYuePo(yaos, monthZhi);
    _applyRiPoAnDong(yaos, dayGanZhi);

    final gua = GuaModel(
      name: guaName,
      gong: gong,
      yaos: yaos,
      shiYaoIndex: shiIdx,
      yingYaoIndex: yingIdx,
    );

    // 变卦：动爻阴阳反转后，必须按**变卦自身的上下卦**重新装纳甲；
    // 六亲仍以本卦卦宫为"我"（传统：变卦六亲随本宫论）。
    final bianGua = _buildBianGua(yaos, gong);

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
      fuShen: fuShen,
    );
  }

  /// 构造变卦。
  ///
  /// 步骤（每一步都会影响后续所有断卦要素，缺一不可）：
  /// 1. 动爻阴阳反转（可多爻动），静爻保持原象；
  /// 2. 由反转后的六爻反推变卦的上下卦（内卦=初二三，外卦=四五六）；
  /// 3. 用**变卦的上下卦**分别取各自的内/外卦纳甲（这是旧实现缺失的一步：
  ///    旧代码直接把本卦的干支/六亲搬到变卦上，导致变卦纳甲与六亲全错）；
  /// 4. 六亲以**本卦卦宫五行**为基准重算（变卦六亲随本宫，如乾宫金卦变出
  ///    丑土仍作父母）；
  /// 5. 世应按变卦自身所属八宫标记。
  static GuaModel? _buildBianGua(List<YaoModel> benYaos, GuaGong benGong) {
    if (!benYaos.any((y) => y.isMoving)) return null;

    // 1) 动爻阴阳反转（只反转结构，不继承本卦的干支/六亲）
    final bianYaos = List.generate(6, (i) {
      final y = benYaos[i];
      return YaoModel(
        yinYang: y.isMoving
            ? (y.yinYang == YaoYinYang.yang ? YaoYinYang.yin : YaoYinYang.yang)
            : y.yinYang,
        position: y.position,
        // 保留动爻标记：界面需要标注哪几爻动了
        isMoving: y.isMoving,
      );
    });

    // 2) 反推变卦上下卦
    final innerMask = _yaosToMask(bianYaos.sublist(0, 3).reversed.toList());
    final outerMask = _yaosToMask(bianYaos.sublist(3, 6).reversed.toList());
    var innerTri = -1;
    var outerTri = -1;
    for (var t = 0; t < _trigramMasks.length; t++) {
      if (_trigramMasks[t] == innerMask) innerTri = t;
      if (_trigramMasks[t] == outerMask) outerTri = t;
    }
    if (innerTri < 0 || outerTri < 0) return null;

    // 3) 变卦自身的纳甲装卦
    final inner = _trigramNaJia[innerTri];
    final outer = _trigramNaJia[outerTri];
    for (var i = 0; i < 3; i++) {
      bianYaos[i].tianGan = _tianGanMap[inner.$1];
      bianYaos[i].diZhi = _diZhiMap[inner.$2[i]];
    }
    for (var i = 0; i < 3; i++) {
      bianYaos[i + 3].tianGan = _tianGanMap[outer.$3];
      bianYaos[i + 3].diZhi = _diZhiMap[outer.$4[i]];
    }

    // 4) 化进神/化退神（仅动爻：比较本爻与变爻地支是否同五行顺进/逆退）
    for (var i = 0; i < 6; i++) {
      if (!benYaos[i].isMoving) continue;
      final from = benYaos[i].diZhi;
      final to = bianYaos[i].diZhi;
      if (from == null || to == null) continue;
      benYaos[i].huaJinTui = _huaJinTuiOf(from, to);
    }

    // 5) 六亲：以本卦卦宫五行为"我"
    _applyLiuQin(bianYaos, guaGongWuXing[benGong]!);

    // 6) 变卦名/所属宫/世应（按变卦自身的八宫归属）
    final name = _hexagramMap[innerTri]![outerTri];
    final palace = _palaceMap[innerTri]![outerTri]!;
    final shiIdx = palace.$2;
    final yingIdx = palace.$3;
    if (shiIdx >= 0 && shiIdx < 6) bianYaos[shiIdx].isShi = true;
    if (yingIdx >= 0 && yingIdx < 6) bianYaos[yingIdx].isYing = true;

    return GuaModel(
      name: name,
      gong: palace.$1,
      yaos: bianYaos,
      shiYaoIndex: shiIdx,
      yingYaoIndex: yingIdx,
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

  static const _liuQinCN = {
    LiuQin.parent: '父母', LiuQin.brother: '兄弟', LiuQin.officer: '官鬼',
    LiuQin.wife: '妻财', LiuQin.child: '子孙',
  };
  static const _diZhiCN2 = {
    DiZhi.zi: '子', DiZhi.chou: '丑', DiZhi.yin: '寅', DiZhi.mao: '卯',
    DiZhi.chen: '辰', DiZhi.si: '巳', DiZhi.wu: '午', DiZhi.wei: '未',
    DiZhi.shen: '申', DiZhi.you: '酉', DiZhi.xu: '戌', DiZhi.hai: '亥',
  };

  /// 计算伏神（藏爻）：本卦缺失的六亲，自本宫首卦（八纯卦）借入。
  ///
  /// 传统规则：取本宫首卦中该六亲之爻为伏神，伏于本卦**同一爻位**之下；
  /// 本卦该爻位的爻为「飞神」。故此处保存：六亲、伏神干支、所伏爻位、
  /// 飞神六亲与干支（便于断卦时看「伏神受飞神生克」）。
  /// 同一六亲在首卦出现两次时取先出现者（初爻侧）。
  static List<FuShenInfo> _calcFuShen(
      List<YaoModel> yaos, GuaGong gong, WuXing gongWx) {
    final present = <LiuQin>{};
    for (final y in yaos) {
      if (y.liuQin != LiuQin.none) present.add(y.liuQin);
    }
    final allLiuQin = [
      LiuQin.parent, LiuQin.brother, LiuQin.officer, LiuQin.wife, LiuQin.child,
    ];
    final missing = allLiuQin.where((l) => !present.contains(l)).toList();
    if (missing.isEmpty) return const [];

    // 本宫首卦 = 该宫八纯卦，纳甲即本卦的八卦纳甲表（八纯卦上下卦同）
    final triIdx = GuaGong.values.indexOf(gong);
    if (triIdx < 0 || triIdx >= _trigramNaJia.length) return const [];
    final najia = _trigramNaJia[triIdx];

    String ganOf(int i) => i < 3 ? najia.$1 : najia.$3;
    String zhiOf(int i) => i < 3 ? najia.$2[i] : najia.$4[i - 3];

    final result = <FuShenInfo>[];
    for (final lq in missing) {
      for (var i = 0; i < 6; i++) {
        final zhi = zhiOf(i);
        final dzWx = _diZhiWuXing[_diZhiMap[zhi]!]!;
        if (_calcLiuQin(gongWx, dzWx) != lq) continue;
        final fei = yaos[i];
        final feiZhi = fei.diZhi == null ? '' : _diZhiCN2[fei.diZhi!]!;
        final feiGan = fei.tianGan == null
            ? ''
            : _tianGanCN2[fei.tianGan!] ?? '';
        result.add(FuShenInfo(
          liuQin: _liuQinCN[lq]!,
          ganZhi: '${ganOf(i)}$zhi',
          yaoIndex: i,
          feiShenLiuQin:
              fei.liuQin == LiuQin.none ? '' : (_liuQinCN[fei.liuQin] ?? ''),
          feiShenGanZhi: '$feiGan$feiZhi',
        ));
        break;
      }
    }
    return result;
  }

  /// 天干枚举 → 中文
  static const _tianGanCN2 = <TianGan, String>{
    TianGan.jia: '甲', TianGan.yi: '乙', TianGan.bing: '丙',
    TianGan.ding: '丁', TianGan.wu: '戊', TianGan.ji: '己',
    TianGan.geng: '庚', TianGan.xin: '辛', TianGan.ren: '壬', TianGan.gui: '癸',
  };

  /// 六亲排布
  static void _applyLiuQin(List<YaoModel> yaos, WuXing gongWuXing) {
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      final yaoWuXing = _diZhiWuXing[yao.diZhi]!;
      yao.liuQin = _calcLiuQin(gongWuXing, yaoWuXing);
    }
  }

  /// 化进神/化退神判定。
  ///
  /// 规则：本爻与变爻**同五行**且地支按下列顺序顺进为进神，逆退为退神：
  /// 亥→子（水）、寅→卯（木）、巳→午（火）、申→酉（金）、
  /// 丑→辰→未→戌→丑（土，四库顺行）。
  /// 不同五行或同五行但非相邻顺逆者，不做化进/化退标记。
  static HuaJinTui? _huaJinTuiOf(DiZhi from, DiZhi to) {
    const jinPairs = <(DiZhi, DiZhi)>[
      (DiZhi.hai, DiZhi.zi),
      (DiZhi.yin, DiZhi.mao),
      (DiZhi.si, DiZhi.wu),
      (DiZhi.shen, DiZhi.you),
      (DiZhi.chou, DiZhi.chen),
      (DiZhi.chen, DiZhi.wei),
      (DiZhi.wei, DiZhi.xu),
      (DiZhi.xu, DiZhi.chou),
    ];
    for (final p in jinPairs) {
      if (p.$1 == from && p.$2 == to) return HuaJinTui.jin;
      if (p.$1 == to && p.$2 == from) return HuaJinTui.tui;
    }
    return null;
  }

  /// 月破：月建地支冲爻支（如子月见午爻、寅月见申爻）。
  /// 月破是地支与月建的关系，不论动静皆可标记；月破之爻多主伤病、离散、
  /// 事难成（得日辰生扶或动而他爻生扶可解）。
  static void _applyYuePo(List<YaoModel> yaos, String monthZhi) {
    if (monthZhi.length != 1) return;
    const chongMap = {'子':'午','丑':'未','寅':'申','卯':'酉','辰':'戌','巳':'亥'};
    final zhiOf = Map.fromEntries(
        _diZhiMap.entries.map((e) => MapEntry(e.value, e.key)));
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      final zhi = zhiOf[yao.diZhi];
      if (zhi == null) continue;
      yao.isYuePo = chongMap[monthZhi] == zhi;
    }
  }

  /// 日破/暗动：日辰地支冲爻，旺相为暗动、休囚为日破。
  /// 仅论**静爻**：暗动（旺相静爻受日冲而动）、日破（休囚静爻受日冲而破）
  /// 都是静爻概念；动爻本已发动，受日冲不按暗动/日破标记。
  static void _applyRiPoAnDong(List<YaoModel> yaos, String dayGanZhi) {
    if (dayGanZhi.length < 2) return;
    final dayZhi = dayGanZhi.substring(1);
    const chongMap = {'子':'午','丑':'未','寅':'申','卯':'酉','辰':'戌','巳':'亥'};
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      if (yao.isMoving) continue; // 动爻不论暗动/日破
      final dzName = _diZhiMap.entries
          .firstWhere((e) => e.value == yao.diZhi, orElse: () => MapEntry('', DiZhi.zi))
          .key;
      // 日支冲爻支
      final isChong = chongMap[dayZhi] == dzName || chongMap[dzName] == dayZhi;
      if (!isChong) continue;
      // 旺相→暗动，休囚→日破
      final ws = yao.wangShuai;
      final wangXiang = ws == WangShuaiLevel.wang || ws == WangShuaiLevel.xiang;
      yao.isAnDong = wangXiang;
      yao.isRiPo = !wangXiang;
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

      // 六冲（已在下方 j 循环中配对标记，此处无需自检）

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
          final matched = yaos.where((y) =>
            y.diZhi != null && ju.contains(_diZhiIndex[y.diZhi!]));
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
    // 日干索引：基准点 1900-01-01 为甲戌日（日干=甲=0，非甲子日，但日干同为甲），
    // 此处仅需日干索引用于六神起例，diff % 10 结果正确。
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

  /// 月建地支 → 月令五行索引（0木 1火 2金 3水 4土）
  /// 用于以精确节气月（月柱地支）判定旺衰，避免公历月近似误差：
  /// 寅卯=木(0)、巳午=火(1)、申酉=金(2)、亥子=水(3)、辰戌丑未=土(4)。
  static int _monthWuXingByZhi(String monthZhi) {
    const map = <String, int>{
      '寅': 0, '卯': 0,
      '巳': 1, '午': 1,
      '申': 2, '酉': 2,
      '亥': 3, '子': 3,
      '辰': 4, '戌': 4, '丑': 4, '未': 4,
    };
    return map[monthZhi] ?? 4;
  }

  /// 旺衰表：五行 → [旺, 相, 休, 囚, 死]
  /// 顺序：木火金水土（索引 0=木 1=火 2=金 3=水 4=土）
  /// 规则：当令者旺、我生者相、生我者休、克我者囚、我克者死。
  /// 注：此前火/金/水/土四行整体错乱（囚死互换、相休错位），
  /// 与 bazi_engine 同一口诀的实现相互矛盾，已按标准口诀重建。
  static const _wangShuaiTable = <int, List<WangShuaiLevel>>{
    0: [ // 木月：木旺 火相 金囚 水休 土死
      WangShuaiLevel.wang,
      WangShuaiLevel.xiang,
      WangShuaiLevel.qiu,
      WangShuaiLevel.xiu,
      WangShuaiLevel.si,
    ],
    1: [ // 火月：木休 火旺 金死 水囚 土相
      WangShuaiLevel.xiu,
      WangShuaiLevel.wang,
      WangShuaiLevel.si,
      WangShuaiLevel.qiu,
      WangShuaiLevel.xiang,
    ],
    2: [ // 金月：木死 火囚 金旺 水相 土休
      WangShuaiLevel.si,
      WangShuaiLevel.qiu,
      WangShuaiLevel.wang,
      WangShuaiLevel.xiang,
      WangShuaiLevel.xiu,
    ],
    3: [ // 水月：木相 火死 金休 水旺 土囚
      WangShuaiLevel.xiang,
      WangShuaiLevel.si,
      WangShuaiLevel.xiu,
      WangShuaiLevel.wang,
      WangShuaiLevel.qiu,
    ],
    4: [ // 土月：木囚 火休 金相 水死 土旺
      WangShuaiLevel.qiu,
      WangShuaiLevel.xiu,
      WangShuaiLevel.xiang,
      WangShuaiLevel.si,
      WangShuaiLevel.wang,
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

  /// 应用旺衰（以月建地支五行判定）
  static void _applyWangShuaiByZhi(List<YaoModel> yaos, String monthZhi) {
    final monthIdx = _monthWuXingByZhi(monthZhi);
    final table = _wangShuaiTable[monthIdx]!;
    for (final yao in yaos) {
      if (yao.diZhi == null) continue;
      final dzIdx = _diZhiIndex[yao.diZhi!]!;
      final wxIdx = _diZhiWuXingIdx[dzIdx]!;
      yao.wangShuai = table[wxIdx];
    }
  }

}
