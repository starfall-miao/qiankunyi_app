/// 大六壬/小六壬 参考资料数据完整性测试
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:qiankunyi_app/features/reference/data/liuren_reference_data.dart';

void main() {
  test('十二天将齐全且字段完整', () {
    expect(daliurenGeneralDetails.length, 12);
    final names = daliurenGeneralDetails.map((g) => g.name).toSet();
    expect(names, containsAll(['贵人', '螣蛇', '朱雀', '六合', '勾陈', '青龙',
      '天空', '白虎', '太常', '玄武', '太阴', '天后']));
    for (final g in daliurenGeneralDetails) {
      expect(g.goodBad == '吉' || g.goodBad == '凶', isTrue, reason: g.name);
      expect(g.wuxing.isNotEmpty, isTrue, reason: g.name);
      expect(g.xiang.isNotEmpty, isTrue, reason: g.name);
      expect(g.zhu.isNotEmpty, isTrue, reason: g.name);
      expect(g.duan.isNotEmpty, isTrue, reason: g.name);
    }
  });

  test('九宗门课体齐全且带取传规则', () {
    expect(daliurenKeTiDetails.length, 10);
    final names = daliurenKeTiDetails.map((k) => k.name).toSet();
    expect(names, containsAll(['元首', '重审', '知一', '涉害', '遥克',
      '昴星', '别责', '八专', '伏吟', '返吟']));
    for (final k in daliurenKeTiDetails) {
      expect(k.rule.isNotEmpty, isTrue, reason: k.name);
      expect(k.desc.isNotEmpty, isTrue, reason: k.name);
      expect(['吉', '平', '凶'], contains(k.goodBad), reason: k.name);
    }
  });

  test('入门概念覆盖天地盘/四课/三传/月将/贵人/遁干/旬空/神煞', () {
    expect(daliurenConcepts.length, greaterThanOrEqualTo(9));
    final titles = daliurenConcepts.map((c) => c.title).join('|');
    for (final key in ['天地盘', '四课', '三传', '月将', '贵人', '遁干', '旬空', '神煞']) {
      expect(titles.contains(key), isTrue, reason: '缺少概念：$key');
    }
    for (final c in daliurenConcepts) {
      expect(c.content.length, greaterThan(20), reason: c.title);
    }
  });

  test('小六壬六掌诀齐全且带五行/方位/应期', () {
    expect(xiaoliurenPalmDetails.length, 6);
    final names = xiaoliurenPalmDetails.map((p) => p.name).toList();
    expect(names, ['大安', '留连', '速喜', '赤口', '小吉', '空亡']);
    for (final p in xiaoliurenPalmDetails) {
      expect(p.wuxing.isNotEmpty, isTrue, reason: p.name);
      expect(p.direction.isNotEmpty, isTrue, reason: p.name);
      expect(p.xiang.isNotEmpty, isTrue, reason: p.name);
      expect(p.duan.isNotEmpty, isTrue, reason: p.name);
      expect(p.yingQi.isNotEmpty, isTrue, reason: p.name);
      expect(p.goodBad == '吉' || p.goodBad == '凶', isTrue, reason: p.name);
    }
  });
}
