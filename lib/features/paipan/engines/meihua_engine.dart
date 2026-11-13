// 梅花易数排盘引擎
// 纯 Dart 实现，所有术数规则硬编码，离线运行

import 'package:tyme/tyme.dart' as tyme;

import '../models/yao_model.dart';
import '../models/gua_model.dart';
import '../models/paipan_result.dart';

/// 数字 → 八卦索引（0-7 对应 乾兑离震巽坎艮坤）
int _numToTrigram(int num) {
  final r = num % 8;
  if (r == 0) return 7; // 8→坤
  return r - 1;
}

/// 八卦 → 三爻阴阳模式（从初爻到上爻）
List<YaoYinYang> _trigramYaos(int triIdx) {
  // 八卦从下到上的爻模式：0阴/1阳
  const patterns = [
    [1, 1, 1], // 0乾 ☰
    [1, 1, 0], // 1兑 ☱
    [1, 0, 1], // 2离 ☲
    [1, 0, 0], // 3震 ☳
    [0, 1, 1], // 4巽 ☴
    [0, 1, 0], // 5坎 ☵
    [0, 0, 1], // 6艮 ☶
    [0, 0, 0], // 7坤 ☷
  ];
  return patterns[triIdx].map((v) => v == 1 ? YaoYinYang.yang : YaoYinYang.yin).toList();
}

/// 六十四卦映射表 [上卦索引][下卦索引] → GuaName
/// 与 liuyao_engine 的 _hexagramMap 互为转置关系。
/// 数据由京房八宫生成规则程序化核验。
const _guaMap = <int, List<GuaName>>{
  // 乾(0)为上卦
  0: [
    GuaName.qian, GuaName.lv, GuaName.tongRen, GuaName.wuWang,
    GuaName.gou, GuaName.song, GuaName.dun, GuaName.pi,
  ],
  // 兑(1)为上卦
  1: [
    GuaName.guai, GuaName.dui, GuaName.ge, GuaName.sui,
    GuaName.daGuo, GuaName.kun2, GuaName.xian, GuaName.cui,
  ],
  // 离(2)为上卦
  2: [
    GuaName.daYou, GuaName.kui, GuaName.li, GuaName.feng,
    GuaName.ding, GuaName.weiJi, GuaName.lv2, GuaName.jin,
  ],
  // 震(3)为上卦
  3: [
    GuaName.daZhuang, GuaName.guiMei, GuaName.shiHe, GuaName.zhen,
    GuaName.heng, GuaName.jie, GuaName.xiaoGuo, GuaName.yu,
  ],
  // 巽(4)为上卦
  4: [
    GuaName.xiaoXu, GuaName.zhongFu, GuaName.jiaRen, GuaName.yi2,
    GuaName.xun, GuaName.huan, GuaName.jian2, GuaName.guan,
  ],
  // 坎(5)为上卦
  5: [
    GuaName.xu, GuaName.jie2, GuaName.jiJi, GuaName.zhun,
    GuaName.jing, GuaName.kan, GuaName.jian, GuaName.bi,
  ],
  // 艮(6)为上卦
  6: [
    GuaName.daXu, GuaName.sun, GuaName.bi2, GuaName.yi,
    GuaName.gu, GuaName.meng, GuaName.gen, GuaName.bo,
  ],
  // 坤(7)为上卦
  7: [
    GuaName.tai, GuaName.lin, GuaName.mingYi, GuaName.fu,
    GuaName.sheng, GuaName.shi, GuaName.qian2, GuaName.kun,
  ],
};

/// 下卦对应本宫（梅花易数简化用下卦为宫）
const _xiaGuaGong = [
  GuaGong.qian, GuaGong.dui, GuaGong.li, GuaGong.zhen,
  GuaGong.xun, GuaGong.kan, GuaGong.gen, GuaGong.kun,
];

/// 梅花易数排盘引擎
class MeihuaEngine {
  /// 数字起卦：两个数字定上下卦，可选第三个数字定动爻（1=初爻，6=上爻）
  static PaipanResult fromNumbers(int num1, int num2, [int? num3]) {
    final upper = _numToTrigram(num1);
    final lower = _numToTrigram(num2);
    // 动爻：余 0 作 6→上爻(索引5)，余 1→初爻(索引0)，…余 5→五爻(索引4)
    final movingRaw = (num3 ?? (num1 + num2)) % 6;
    final moving = movingRaw == 0 ? 5 : movingRaw - 1;
    return _buildGua(upper, lower, moving, '数字起卦');
  }

  /// 时间起卦（《梅花易数》通行法）
  ///
  /// 上卦 =（年支序数 + 农历月 + 农历日）÷ 8 取余
  /// 下卦 =（年支序数 + 农历月 + 农历日 + 时辰数）÷ 8 取余
  /// 动爻 = 同下卦之和 ÷ 6 取余（余 0 作上爻）
  ///
  /// 其中年支序数按**农历年**（春节换年）的干支地支取 子1…亥12；
  /// 月/日取**农历**（闰月按本月计）；时辰数 子1…亥12（23:00 起为子时）。
  /// 旧实现用「公历年后两位 + 公历月日」，与原著规则不符，已更正。
  static PaipanResult fromDateTime(DateTime dt) {
    final solar = tyme.SolarDay.fromYmd(dt.year, dt.month, dt.day);
    final lunar = solar.getLunarDay();
    // 农历年干支 → 地支序数（子=0 → +1 得 子1…亥12）
    final yearBranchIdx =
        lunar.getLunarMonth().getLunarYear().getSixtyCycle().getEarthBranch().getIndex();
    final y = yearBranchIdx + 1;
    // 农历月：闰月以负数表示，按本月计（取绝对值）
    final m = lunar.getMonth().abs();
    final d = lunar.getDay();
    // 时辰数（子1~亥12）：23:00-00:59 归子时，每两小时顺进一位
    final h = ((dt.hour + 1) ~/ 2) % 12 + 1;

    final sum = y + m + d;
    final upper = _numToTrigram(sum);
    final lower = _numToTrigram(sum + h);
    final movingRaw = (sum + h) % 6;
    final moving = movingRaw == 0 ? 5 : movingRaw - 1;
    return _buildGua(upper, lower, moving, '时间起卦');
  }

  /// 物象起卦：直接指定上下卦和动爻
  ///
  /// 入参防御：上下卦索引限定 0-7（乾兑离震巽坎艮坤），动爻限定 0-5；
  /// 越界时收敛到合法范围，避免调用方传错直接抛 RangeError 崩溃。
  static PaipanResult fromTrigrams(int upperTri, int lowerTri, [int movingYao = 0]) {
    return _buildGua(
      upperTri.clamp(0, 7),
      lowerTri.clamp(0, 7),
      movingYao.clamp(0, 5),
      '物象起卦',
    );
  }

  /// 核心：构建排盘结果
  static PaipanResult _buildGua(int upper, int lower, int movingYao, String method) {
    final guaName = _guaMap[upper]![lower];
    final gong = _xiaGuaGong[lower];

    // 构建本卦六爻
    final benYao = _buildYaos(upper, lower, movingYao);
    final benGua = GuaModel(
      name: guaName,
      gong: gong,
      yaos: benYao,
      shiYaoIndex: 0,
      yingYaoIndex: 3,
    );

    // 构建变卦
    final bianYaos = _buildBianYaos(benYao, movingYao);
    GuaModel? bianGua;
    if (bianYaos != null) {
      bianGua = GuaModel(
        name: _findGuaNameFromYaos(bianYaos),
        gong: gong,
        yaos: bianYaos,
        shiYaoIndex: 0,
        yingYaoIndex: 3,
      );
    }

    // 构建互卦（本卦二三四爻为下卦，三四五爻为上卦）
    final huGua = _buildHuGua(benYao, gong);

    return PaipanResult(
      benGua: benGua,
      bianGua: bianGua,
      huGua: huGua,
      paipanTime: DateTime.now(),
      method: method,
    );
  }

  /// 从上下卦和动爻构建六个爻
  static List<YaoModel> _buildYaos(int upper, int lower, int movingYao) {
    final upperYaos = _trigramYaos(upper);
    final lowerYaos = _trigramYaos(lower);
    final allYaos = [...lowerYaos, ...upperYaos]; // 初到上：下卦+上卦

    return List.generate(6, (i) => YaoModel(
      yinYang: allYaos[i],
      position: YaoPosition.values[i],
      isMoving: i == movingYao,
    ));
  }

  /// 构建变卦爻（动爻阴阳翻转）
  static List<YaoModel>? _buildBianYaos(List<YaoModel> benYao, int movingYao) {
    final hasMoving = benYao.any((y) => y.isMoving);
    if (!hasMoving) return null;

    return List.generate(6, (i) {
      final y = benYao[i];
      return YaoModel(
        yinYang: i == movingYao
            ? (y.yinYang == YaoYinYang.yang ? YaoYinYang.yin : YaoYinYang.yang)
            : y.yinYang,
        position: YaoPosition.values[i],
        isMoving: false,
      );
    });
  }

  /// 从爻列表反推卦名
  static GuaName _findGuaNameFromYaos(List<YaoModel> yaos) {
    final lowerMask = _yaoMask(yaos.sublist(0, 3));
    final upperMask = _yaoMask(yaos.sublist(3, 6));
    return _guaMap[upperMask]![lowerMask];
  }

  /// 爻列表 → 0-7 八卦索引
  /// 注意：mask 的 bit2=初爻、bit1=二爻、bit0=三爻，乾111→mask=7→索引0。
  static int _yaoMask(List<YaoModel> yaos) {
    int mask = 0;
    for (int i = 0; i < 3; i++) {
      if (yaos[i].yinYang == YaoYinYang.yang) mask |= (1 << (2 - i));
    }
    // 000→7(坤), 001→6(艮), 010→5(坎), 011→4(巽), 100→3(震), 101→2(离), 110→1(兑), 111→0(乾)
    const map = [7, 6, 5, 4, 3, 2, 1, 0];
    return map[mask];
  }

  /// 构建互卦（二三四爻为下卦，三四五爻为上卦）
  static GuaModel _buildHuGua(List<YaoModel> benYao, GuaGong gong) {
    // 互卦取本卦二、三、四爻为下卦，三、四、五爻为上卦
    final lowerHu = benYao.sublist(1, 4); // 二、三、四爻
    final upperHu = benYao.sublist(2, 5); // 三、四、五爻
    final allHu = [...lowerHu, ...upperHu];

    final lowerMask = _yaoMask(lowerHu);
    final upperMask = _yaoMask(upperHu);
    final huName = _guaMap[upperMask]![lowerMask];

    return GuaModel(
      name: huName,
      gong: gong,
      yaos: allHu,
      shiYaoIndex: 0,
      yingYaoIndex: 3,
    );
  }

  /// 八卦名与五行（索引 0乾…7坤）
  static const _triNames = ['乾', '兑', '离', '震', '巽', '坎', '艮', '坤'];
  static const _triWx = ['金', '金', '火', '木', '木', '水', '土', '土'];

  /// 取卦的上下卦信息（供界面标注）：上卦/下卦的卦名与五行
  static ({String upperName, String upperWx, String lowerName, String lowerWx})
      trigramInfo(GuaModel gua) {
    final lowerIdx = _yaoMask(gua.yaos.sublist(0, 3));
    final upperIdx = _yaoMask(gua.yaos.sublist(3, 6));
    return (
      upperName: _triNames[upperIdx],
      upperWx: _triWx[upperIdx],
      lowerName: _triNames[lowerIdx],
      lowerWx: _triWx[lowerIdx],
    );
  }

  /// 动爻信息：第几爻（1-6）与所在卦（true=上卦）
  static ({int index, bool inUpper})? movingYaoInfo(GuaModel gua) {
    final i = gua.yaos.indexWhere((y) => y.isMoving);
    if (i < 0) return null;
    return (index: i, inUpper: i >= 3);
  }

  /// 获取体用生克关系描述
  static String getTiYong(PaipanResult result) {
    final yaos = result.benGua.yaos;
    final movingIdx = yaos.indexWhere((y) => y.isMoving);

    // 无动爻则无变
    if (movingIdx == -1) return '无动爻，体用未分';

    // 动爻所在卦为用卦（有动爻者为用），另一卦为体卦
    // 下卦(内卦)：初、二、三爻（索引0-2）
    // 上卦(外卦)：四、五、上爻（索引3-5）
    final tiGua = movingIdx < 3 ? '上卦' : '下卦';
    final yongGua = movingIdx < 3 ? '下卦' : '上卦';

    // 获取体卦和用卦的五行
    final tiIdx = movingIdx < 3
        ? _yaoMask(result.benGua.yaos.sublist(3, 6))
        : _yaoMask(result.benGua.yaos.sublist(0, 3));
    final yongIdx = movingIdx < 3
        ? _yaoMask(result.benGua.yaos.sublist(0, 3))
        : _yaoMask(result.benGua.yaos.sublist(3, 6));

    final tiWx = _triWuXing(tiIdx);
    final yongWx = _triWuXing(yongIdx);

    String relation;
    if (tiWx == yongWx) {
      relation = '体用比和，事必顺遂';
    } else if (_sheng(tiWx) == yongWx) {
      relation = '体生用，有耗损之象';
    } else if (_sheng(yongWx) == tiWx) {
      relation = '用生体，有进益之喜';
    } else if (_ke(tiWx) == yongWx) {
      relation = '体克用，劳心费力但可成';
    } else {
      relation = '用克体，凶险多阻';
    }

    return '体卦：$tiGua(${_wxName(tiWx)}) 用卦：$yongGua(${_wxName(yongWx)}) — $relation';
  }

  /// 变卦体用：动爻所在的卦「化出」的卦为用卦，另一卦仍为体卦（体卦不变）。
  ///
  /// 梅花断法：本卦看体用生克 → 互卦看过程 → **变卦看结果**。变卦中用卦已
  /// 变为新卦，体卦不变，两者生克即事之结局（用生体/体克用为吉，用克体为凶）。
  static String getBianTiYong(PaipanResult result) {
    final bian = result.bianGua;
    if (bian == null) return '无变卦，不论变卦体用';
    final movingIdx = result.benGua.yaos.indexWhere((y) => y.isMoving);
    if (movingIdx == -1) return '无动爻，不论变卦体用';

    // 动爻在下卦 → 化出的是下卦（用），体为上卦；反之体为下卦
    final movingInLower = movingIdx < 3;
    final yongIdx = movingInLower
        ? _yaoMask(bian.yaos.sublist(0, 3))
        : _yaoMask(bian.yaos.sublist(3, 6));
    final tiIdx = movingInLower
        ? _yaoMask(bian.yaos.sublist(3, 6))
        : _yaoMask(bian.yaos.sublist(0, 3));

    final tiWx = _triWuXing(tiIdx);
    final yongWx = _triWuXing(yongIdx);

    String relation;
    if (tiWx == yongWx) {
      relation = '体用比和，事终顺遂';
    } else if (_sheng(tiWx) == yongWx) {
      relation = '体生用，事后耗损、付出多于所得';
    } else if (_sheng(yongWx) == tiWx) {
      relation = '用生体，事终有进益、得助';
    } else if (_ke(tiWx) == yongWx) {
      relation = '体克用，事可成但费心力';
    } else {
      relation = '用克体，事终不利、多阻';
    }

    final bianName = guaNameCNLocal(bian.name);
    return '变卦体用（$bianName）：用卦(${_wxName(yongWx)}) 体卦(${_wxName(tiWx)}) — $relation';
  }

  /// 卦名中文：统一使用 gua_model.dart 的 guaNameCN（单一来源）
  static String guaNameCNLocal(GuaName name) => guaNameCN[name] ?? name.name;

  /// 八卦五行
  static WuXing _triWuXing(int triIdx) {
    const wx = [
      WuXing.jin,   // 乾
      WuXing.jin,   // 兑
      WuXing.huo,   // 离
      WuXing.mu,    // 震
      WuXing.mu,    // 巽
      WuXing.shui,  // 坎
      WuXing.tu,    // 艮
      WuXing.tu,    // 坤
    ];
    return wx[triIdx];
  }

  static WuXing _sheng(WuXing w) {
    switch (w) {
      case WuXing.jin: return WuXing.shui;
      case WuXing.shui: return WuXing.mu;
      case WuXing.mu: return WuXing.huo;
      case WuXing.huo: return WuXing.tu;
      case WuXing.tu: return WuXing.jin;
    }
  }

  static WuXing _ke(WuXing w) {
    switch (w) {
      case WuXing.jin: return WuXing.mu;
      case WuXing.mu: return WuXing.tu;
      case WuXing.tu: return WuXing.shui;
      case WuXing.shui: return WuXing.huo;
      case WuXing.huo: return WuXing.jin;
    }
  }

  static String _wxName(WuXing w) {
    switch (w) {
      case WuXing.jin: return '金';
      case WuXing.mu: return '木';
      case WuXing.shui: return '水';
      case WuXing.huo: return '火';
      case WuXing.tu: return '土';
    }
  }
}
