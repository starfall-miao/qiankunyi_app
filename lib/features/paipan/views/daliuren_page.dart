// 落·乾坤 - 大六壬排盘页（基础版）
import 'package:flutter/material.dart';

/// 十二天将（贵人顺序）
const daliurenGenerals = [
  ('贵人', '吉'), ('螣蛇', '凶'), ('朱雀', '凶'), ('六合', '吉'),
  ('勾陈', '凶'), ('青龙', '吉'), ('天空', '凶'), ('白虎', '凶'),
  ('太常', '吉'), ('玄武', '凶'), ('太阴', '吉'), ('天后', '吉'),
];

/// 十二地支（地盘/月将用）
const daliurenZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// 十二月将（正月起登明）
const daliurenYueJiang = ['登明', '河魁', '从魁', '传送', '小吉', '胜光',
  '太乙', '天罡', '太冲', '功曹', '大吉', '神后'];

/// 大六壬排盘结果（基础：四课三传）
class DaLiuRenResult {
  final int hourIndex;      // 时辰
  final int yueJiang;       // 月将索引(0-11)
  final List<String> shiYong; // 三传（初传/中传/末传）地支
  final String chuChuan;    // 初传
  final String zhongChuan;  // 中传
  final String moChuan;     // 末传
  final String method;

  DaLiuRenResult({
    required this.hourIndex,
    required this.yueJiang,
    required this.shiYong,
    required this.chuChuan,
    required this.zhongChuan,
    required this.moChuan,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
        'hourIndex': hourIndex,
        'yueJiang': yueJiang,
        'shiYong': shiYong,
        'chuChuan': chuChuan,
        'zhongChuan': zhongChuan,
        'moChuan': moChuan,
        'method': method,
      };
}

/// 大六壬引擎（基础简化版）
class DaLiuRenEngine {
  /// 简化起课：以月将加时定三传（不做完整天地盘，供入门展示）
  static DaLiuRenResult byHour(int hourIndex, int month) {
    final yueJiang = (month - 1) % 12; // 月将
    // 三传简化推算：从月将顺数时辰取初传，再顺数得中传、末传
    final start = (yueJiang + hourIndex) % 12;
    final chu = daliurenZhi[start];
    final zhong = daliurenZhi[(start + 2) % 12];
    final mo = daliurenZhi[(start + 4) % 12];
    return DaLiuRenResult(
      hourIndex: hourIndex,
      yueJiang: yueJiang,
      shiYong: [chu, zhong, mo],
      chuChuan: chu,
      zhongChuan: zhong,
      moChuan: mo,
      method: '月将加时（简化）',
    );
  }
}

/// 大六壬排盘页
class DaLiuRenPage extends StatefulWidget {
  const DaLiuRenPage({super.key});
  @override
  State<DaLiuRenPage> createState() => _DaLiuRenPageState();
}

class _DaLiuRenPageState extends State<DaLiuRenPage> {
  int _month = 1;
  int _hour = 0;
  DaLiuRenResult? _result;

  static const _hours = ['子时', '丑时', '寅时', '卯时', '辰时', '巳时',
    '午时', '未时', '申时', '酉时', '戌时', '亥时'];

  void _calc() {
    setState(() => _result = DaLiuRenEngine.byHour(_hour, _month));
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    final t = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('大六壬（入门版）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('大六壬为三式之一，以月将加时、四课三传断吉凶。'
            '本版提供简化起课，完整天地盘、十二天将排布后续完善。',
            style: TextStyle(fontSize: 12, height: 1.6, color: t.withAlpha(160))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _select('月', _month, 12, '月', (v) => setState(() => _month = v + 1))),
          const SizedBox(width: 8),
          Expanded(child: _select('时', _hour, _hours.length, '时', (v) => setState(() => _hour = v))),
        ]),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _calc,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('排盘'),
          style: ElevatedButton.styleFrom(backgroundColor: p, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 12),
        if (_result != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('月将：${daliurenYueJiang[_result!.yueJiang]}（${_result!.method}）',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text('三传', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                Row(children: [
                  _chuan('初传', _result!.chuChuan, p, t, bg, b),
                  const SizedBox(width: 8),
                  _chuan('中传', _result!.zhongChuan, p, t, bg, b),
                  const SizedBox(width: 8),
                  _chuan('末传', _result!.moChuan, p, t, bg, b),
                ]),
                const SizedBox(height: 8),
                Text('十二天将：${daliurenGenerals.map((e) => e.$1).join('、')}',
                    style: TextStyle(fontSize: 11, color: t.withAlpha(140))),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _chuan(String label, String zhi, Color p, Color t, Color bg, Color b) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: b.withAlpha(80))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 11, color: t.withAlpha(130))),
          const SizedBox(height: 2),
          Text(zhi, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p)),
        ]),
      ),
    );
  }

  Widget _select(String label, int value, int count, String suffix, ValueChanged<int> onSel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      DropdownButton<int>(
        value: value,
        isExpanded: true,
        items: List.generate(count, (i) =>
            DropdownMenuItem(value: i,
                child: Text(suffix == '时' ? _hours[i] : '${i + 1}$suffix', style: const TextStyle(fontSize: 13)))),
        onChanged: (v) => v != null ? onSel(v) : null,
      ),
    ]);
  }
}
