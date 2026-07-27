/// 梅花易数参考资料
///
/// 包含体用生克规则、八卦五行、起卦方法说明等
library;

import 'package:flutter/material.dart';

/// 体用生克条目
class TiYongRule {
  final String name;
  final String description;
  final String verdict;
  final IconData icon;
  final Color color;

  const TiYongRule({
    required this.name,
    required this.description,
    required this.verdict,
    required this.icon,
    required this.color,
  });
}

/// 八卦五行信息
class TrigramInfo {
  final String name;
  final String symbol;
  final String wuXing;
  final int number;
  final String yinYang;

  const TrigramInfo({
    required this.name,
    required this.symbol,
    required this.wuXing,
    required this.number,
    required this.yinYang,
  });
}

/// 体用生克规则列表
const tiYongRules = <TiYongRule>[
  TiYongRule(
    name: '体用比和',
    description: '体卦与用卦五行相同',
    verdict: '谋为吉利，事必顺遂，百事皆宜',
    icon: Icons.check_circle_outline,
    color: Color(0xFF2E7D32),
  ),
  TiYongRule(
    name: '用生体',
    description: '用卦五行生体卦五行',
    verdict: '有进益之喜，得贵人助，事易成',
    icon: Icons.trending_up,
    color: Color(0xFF2E7D32),
  ),
  TiYongRule(
    name: '体生用',
    description: '体卦五行生用卦五行',
    verdict: '有耗失之患，事费力，需付出代价',
    icon: Icons.call_made,
    color: Color(0xFF1565C0),
  ),
  TiYongRule(
    name: '体克用',
    description: '体卦五行克用卦五行',
    verdict: '劳心费力但可成，虽胜有劳',
    icon: Icons.auto_fix_high,
    color: Color(0xFFEF6C00),
  ),
  TiYongRule(
    name: '用克体',
    description: '用卦五行克体卦五行',
    verdict: '凶险多阻，事难成，宜守不宜攻',
    icon: Icons.warning_amber_outlined,
    color: Color(0xFFD32F2F),
  ),
];

/// 八卦对应表
const trigramInfos = <TrigramInfo>[
  TrigramInfo(name: '乾', symbol: '☰', wuXing: '金', number: 1, yinYang: '阳'),
  TrigramInfo(name: '兑', symbol: '☱', wuXing: '金', number: 2, yinYang: '阴'),
  TrigramInfo(name: '离', symbol: '☲', wuXing: '火', number: 3, yinYang: '阴'),
  TrigramInfo(name: '震', symbol: '☳', wuXing: '木', number: 4, yinYang: '阳'),
  TrigramInfo(name: '巽', symbol: '☴', wuXing: '木', number: 5, yinYang: '阴'),
  TrigramInfo(name: '坎', symbol: '☵', wuXing: '水', number: 6, yinYang: '阳'),
  TrigramInfo(name: '艮', symbol: '☶', wuXing: '土', number: 7, yinYang: '阳'),
  TrigramInfo(name: '坤', symbol: '☷', wuXing: '土', number: 8, yinYang: '阴'),
];

/// 五行生克关系说明
const wuXingShengKe = [
  '木生火、火生土、土生金、金生水、水生木',
  '木克土、土克水、水克火、火克金、金克木',
];

/// 起卦方法说明
const qiGuaMethods = [
  '三数起卦：取三个数字（如 123），第一数除 8 余数为上卦，第二数除 8 余数为下卦，第三数除 6 余数为动爻。',
  '时间起卦：以年月日时四数，年+月+日为第一数定上卦，时为第二数定下卦，四数和为动爻。',
  '物象起卦：根据所见之物象对应八卦（乾为天、坤为地、震为雷…），取上下卦起卦。',
  '声音起卦：以听到的声音数量或方位起卦。',
];

/// 卦气旺衰说明
const guaQiWangShuai = [
  '春季（寅卯月）：震、巽（木）旺，离（火）相，乾兑（金）囚，坎（水）休，坤艮（土）死',
  '夏季（巳午月）：离（火）旺，坤艮（土）相，震巽（木）休，乾兑（金）囚，坎（水）死',
  '秋季（申酉月）：乾兑（金）旺，坎（水）相，坤艮（土）囚，离（火）休，震巽（木）死',
  '冬季（亥子月）：坎（水）旺，震巽（木）相，乾兑（金）休，坤艮（土）囚，离（火）死',
  '四季月（辰戌丑未月）：坤艮（土）旺，乾兑（金）相，离（火）休，震巽（木）囚，坎（水）死',
];
