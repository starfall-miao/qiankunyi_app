// 落·乾坤 - 小六壬排盘页
import 'package:flutter/material.dart';

import '../../cases/providers/case_provider.dart';
import '../../cases/models/case_models.dart';
import '../engines/xiaoliuren_engine.dart';

/// 小六壬排盘页
class XiaoLiuRenPage extends StatefulWidget {
  const XiaoLiuRenPage({super.key});
  @override
  State<XiaoLiuRenPage> createState() => _XiaoLiuRenPageState();
}

class _XiaoLiuRenPageState extends State<XiaoLiuRenPage> {
  int _method = 0; // 0月日时 1随机 2数字
  int _month = 1;
  int _day = 1;
  int _hour = 0;
  final _n1 = TextEditingController(text: '3');
  final _n2 = TextEditingController(text: '5');
  final _n3 = TextEditingController(text: '7');
  XiaoLiuRenResult? _result;

  static const _months = ['正月', '二月', '三月', '四月', '五月', '六月',
    '七月', '八月', '九月', '十月', '冬月', '腊月'];
  static const _hours = ['子时', '丑时', '寅时', '卯时', '辰时', '巳时',
    '午时', '未时', '申时', '酉时', '戌时', '亥时'];

  @override
  void dispose() {
    _n1.dispose(); _n2.dispose(); _n3.dispose();
    super.dispose();
  }

  Color _palmColor(String gb) {
    if (gb == '吉') return const Color(0xFF2E7D32);
    if (gb == '凶') return const Color(0xFFC62828);
    return const Color(0xFFEF6C00);
  }

  void _calc() {
    XiaoLiuRenResult r;
    switch (_method) {
      case 0:
        r = XiaoLiuRenEngine.byMonthDayHour(_month, _day, _hour);
        break;
      case 1:
        r = XiaoLiuRenEngine.random();
        break;
      default:
        final n1 = int.tryParse(_n1.text) ?? 1;
        final n2 = int.tryParse(_n2.text) ?? 1;
        final n3 = int.tryParse(_n3.text) ?? 1;
        r = XiaoLiuRenEngine.byNumbers(n1, n2, n3);
    }
    setState(() => _result = r);
  }

  void _save() {
    final r = _result;
    if (r == null) return;
    final cm = CaseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '小六壬 · ${r.resultPalm.name}',
      guaName: r.resultPalm.name,
      guaGong: r.resultPalm.element,
      method: '小六壬（${r.method}）',
      paipanData: '{"xiaoLiuRen":${_jsonEncode(r)}}',
      caseType: CaseType.liuyao,
    );
    context.read<CaseProvider>().addCase(cm);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存到卦例库')),
    );
  }

  String _jsonEncode(XiaoLiuRenResult r) {
    final m = r.toJson();
    return m.entries.map((e) => '"${e.key}":${e.value}').join(',');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 起课方式
          Wrap(
            spacing: 8,
            children: List.generate(3, (i) {
              final labels = ['月日时起课', '随机起课', '数字起课'];
              return ChoiceChip(
                label: Text(labels[i], style: TextStyle(fontSize: 12, color: _method == i ? p : t)),
                selected: _method == i,
                onSelected: (_) => setState(() => _method = i),
                selectedColor: p.withAlpha(40),
                backgroundColor: bg,
                side: BorderSide(color: _method == i ? p : b, width: 1),
              );
            }),
          ),
          const SizedBox(height: 12),

          // 月日时输入
          if (_method == 0) ...[
            Row(children: [
              Expanded(child: _select('月', _month, _months, (v) => setState(() => _month = v + 1))),
              const SizedBox(width: 8),
              Expanded(child: _select('日', _day, List.generate(30, (i) => '${i + 1}日'), (v) => setState(() => _day = v + 1))),
              const SizedBox(width: 8),
              Expanded(child: _select('时', _hour, _hours, (v) => setState(() => _hour = v))),
            ]),
          ] else if (_method == 2) ...[
            Row(children: [
              Expanded(child: TextField(controller: _n1, decoration: const InputDecoration(labelText: '数一', isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _n2, decoration: const InputDecoration(labelText: '数二', isDense: true), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _n3, decoration: const InputDecoration(labelText: '数三', isDense: true), keyboardType: TextInputType.number)),
            ]),
          ],

          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _calc,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('排盘'),
            style: ElevatedButton.styleFrom(backgroundColor: p, foregroundColor: Colors.white),
          ),

          const SizedBox(height: 12),

          // 结果
          if (_result != null) ...[
            _resultCard(_result!, p, t, b, isDark),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text('保存卦例'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _select(String label, int value, List<String> options, ValueChanged<int> onSel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      DropdownButton<int>(
        value: value,
        isExpanded: true,
        items: List.generate(options.length, (i) =>
            DropdownMenuItem(value: i, child: Text(options[i], style: const TextStyle(fontSize: 13)))),
        onChanged: (v) => v != null ? onSel(v) : null,
      ),
    ]);
  }

  Widget _resultCard(XiaoLiuRenResult r, Color p, Color t, Color b, bool dark) {
    final palm = r.resultPalm;
    final color = _palmColor(palm.goodBad);
    final bg = dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('最终落位：', style: TextStyle(fontSize: 14, color: t.withAlpha(150))),
            Text('${palm.name}（${palm.goodBad}）',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 6),
          Text('五行：${palm.element} · 起课方式：${r.method}',
              style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          const SizedBox(height: 8),
          // 三盘掌诀
          Row(children: [
            _miniPalm('月', r.monthPalm, p, t, bg, b),
            const SizedBox(width: 6),
            _miniPalm('日', r.dayPalm, p, t, bg, b),
            const SizedBox(width: 6),
            _miniPalm('时', palm, p, t, bg, b),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(50)),
            ),
            child: Text(palm.meaning,
                style: TextStyle(fontSize: 13, height: 1.6, color: t.withAlpha(200))),
          ),
        ]),
      ),
    );
  }

  Widget _miniPalm(String label, XiaoLiuRenName n, Color p, Color t, Color bg, Color b) {
    final color = _palmColor(n.goodBad);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: b.withAlpha(80))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 11, color: t.withAlpha(130))),
          const SizedBox(height: 2),
          Text(n.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }
}
