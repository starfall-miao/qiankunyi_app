/// 六爻日期辅助 — 基于 tyme4dart 的月令/日令/空亡计算
///
/// 离线硬编码，无外部依赖
library;

import 'package:tyme/tyme.dart' as tyme;

/// 地支名列表
const diZhiNames = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];

/// 天干名
const tianGanNames = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];

/// 六十甲子名
final liuShiJiaZi = List.generate(60, (i) {
  return '${tianGanNames[i % 10]}${diZhiNames[i % 12]}';
});

/// 地支索引（0子~11亥）
final _diZhiIdx = <String, int>{
  '子':0,'丑':1,'寅':2,'卯':3,'辰':4,'巳':5,
  '午':6,'未':7,'申':8,'酉':9,'戌':10,'亥':11,
};

/// 月建表：公历月 → 月建地支名（正月寅、二月卯…）
/// 注意：此处使用简化近似，精确月建应以节气分界
const _monthJian = [
  '寅','卯','辰','巳','午','未','申','酉','戌','亥','子','丑',
];

/// 旬空表：[旬首日干支索引] → (空亡地支1索引, 空亡地支2索引)
/// 旬首：甲子(0), 甲戌(10), 甲申(20), 甲午(30), 甲辰(40), 甲寅(50)
const _xunKongTable = <int, (int, int)>{
   0: (10, 11), // 甲子旬 → 戌亥空
  10: ( 8,  9), // 甲戌旬 → 申酉空
  20: ( 6,  7), // 甲申旬 → 午未空
  30: ( 4,  5), // 甲午旬 → 辰巳空
  40: ( 2,  3), // 甲辰旬 → 寅卯空
  50: ( 0,  1), // 甲寅旬 → 子丑空
};

/// 获取月建地支名（基于公历月份，简版近似）
/// 京房简版使用此方法
String monthZhiSimple(int month) {
  if (month < 1 || month > 12) return '子';
  return _monthJian[month - 1];
}

/// 获取日柱干支名（基于 tyme4dart 的 SolarDay）
/// 返回如 "甲子"
String dayGanZhiFromTyme(tyme.SolarDay solarDay) {
  final scd = solarDay.getSixtyCycleDay();
  final dayGan = scd.getSixtyCycle().getHeavenStem().getName();
  final dayZhi = scd.getSixtyCycle().getEarthBranch().getName();
  return '$dayGan$dayZhi';
}

/// 获取日干支索引（0~59）
int dayGanZhiIndex(tyme.SolarDay solarDay) {
  return solarDay.getSixtyCycleDay().getSixtyCycle().getIndex();
}

/// 计算旬空地支集合
/// 返回两个空亡的地支名列表
List<String> calcKongWang(int dayGanZhiIdx) {
  // 找到旬首（能被10整除的索引）
  final xunShou = dayGanZhiIdx - (dayGanZhiIdx % 10);
  final pair = _xunKongTable[xunShou];
  if (pair == null) return [];
  return [diZhiNames[pair.$1], diZhiNames[pair.$2]];
}

/// 判断指定地支是否在旬空中
bool isKongWang(String diZhi, List<String> kongWangList) {
  return kongWangList.contains(diZhi);
}

/// 获取月柱干支名（基于 tyme4dart 的 SolarDay）
String monthGanZhiFromTyme(tyme.SolarDay solarDay) {
  final scd = solarDay.getSixtyCycleDay();
  return scd.getMonth().getName();
}

/// 获取地支索引，用于旺衰计算
int diZhiToIndex(String dz) => _diZhiIdx[dz] ?? 0;
