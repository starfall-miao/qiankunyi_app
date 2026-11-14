/// 卦例类型 / 大六壬序列化 / AI 后台管理器 基础测试
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:qiankunyi_app/core/services/ai_solve_manager.dart';
import 'package:qiankunyi_app/features/cases/models/case_models.dart';
import 'package:qiankunyi_app/features/paipan/engines/daliuren_engine.dart';

void main() {
  group('大六壬结果序列化', () {
    test('toJson → fromJson 往返保留新字段', () {
      final r = DaLiuRenEngine.byHour(3, 1,
          dayGan: '甲',
          dayZhi: '子',
          monthZhiIdx: 2,
          yearGanZhi: '甲辰',
          monthGanZhi: '丙寅');
      final back = DaLiuRenResult.fromJson(r.toJson());
      expect(back.siZhu, equals(r.siZhu));
      expect(back.xunKong, equals(r.xunKong));
      expect(back.keTi, equals(r.keTi));
      expect(back.chuanDunGan, equals(r.chuanDunGan));
      expect(back.shenSha, equals(r.shenSha));
      expect(back.siKeShang, equals(r.siKeShang));
      expect(back.siKeXia, equals(r.siKeXia));
      expect(back.keLiuQin, equals(r.keLiuQin));
      expect(back.chuanRelation, equals(r.chuanRelation));
      // 四柱：年月来自入参、日柱由日干支、时柱五鼠遁
      expect(back.siZhu[0], '甲辰');
      expect(back.siZhu[1], '丙寅');
      expect(back.siZhu[2], '甲子');
      expect(back.siZhu[3].length, 2);
    });

    test('旧数据（缺新字段）可解析且不抛异常', () {
      final legacy = {
        'hourIndex': 3,
        'yueJiang': 0,
        'yueJiangZhi': '亥',
        'tianPan': ['子', '丑'],
        'siKe': ['午', '亥', '子', '丑'],
        'shiYong': ['午', '亥', '子'],
        'chuChuan': '午',
        'zhongChuan': '亥',
        'moChuan': '子',
        'chuanFa': '贼克法（三课贼）',
        'guiRen': '丑',
        'tianJiang': ['贵人'],
        'method': '月将加时',
      };
      final r = DaLiuRenResult.fromJson(legacy);
      expect(r.siKeShang, ['午', '亥', '子', '丑']);
      expect(r.siZhu, isEmpty);
      expect(r.keTi, '');
    });
  });

  group('卦例类型（小六壬/大六壬）', () {
    test('新类型可序列化往返', () {
      for (final type in [CaseType.xiaoliuren, CaseType.daliuren]) {
        final c = CaseModel(
          id: 1,
          title: 't',
          guaName: '大安',
          guaGong: '木',
          method: '小六壬（月日时）',
          paipanData: '{}',
          caseType: type,
        );
        final back = CaseModel.fromMap(c.toMap());
        expect(back.caseType, type);
      }
    });

    test('未知类型回退为六爻（旧数据兼容）', () {
      final c = CaseModel.fromMap({
        'id': 2,
        'title': 't',
        'guaName': '乾为天',
        'guaGong': '乾',
        'method': '机器摇卦',
        'paipanData': '{}',
        'caseType': 'unknownType',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2024, 1, 1).toIso8601String(),
      });
      expect(c.caseType, CaseType.liuyao);
    });
  });

  group('AI 后台解卦管理器', () {
    test('初始状态：无任务', () {
      final m = AiSolveManager.instance;
      expect(m.isSolving(999999), isFalse);
      expect(m.jobOf(999999), isNull);
      expect(m.solvingIds.contains(999999), isFalse);
    });

    test('cancel 不存在的任务为无操作', () {
      final m = AiSolveManager.instance;
      expect(() => m.cancel(999999), returnsNormally);
      expect(m.isSolving(999999), isFalse);
    });

    test('clearFinished 不存在的任务为无操作', () {
      final m = AiSolveManager.instance;
      expect(() => m.clearFinished(999999), returnsNormally);
    });
  });
}
