// 落·乾坤 - 小六壬排盘页
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/save_image_dialog.dart';

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
  final _shotKey = GlobalKey();

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

  /// 保存结果图片
  Future<void> _saveImage() async {
    try {
      final boundary =
          _shotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!mounted) return;
      final savedPath = await saveImageWithDialog(
        context: context,
        pngBytes: pngBytes,
        defaultFileName: buildImageFileName(
            '小六壬_${_result?.resultPalm.name ?? "结果"}'),
      );
      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
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
          // 输入区 Card（与六爻梅花一致）
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
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

          // 月日时输入（ChoiceChip 风格，与六爻梅花一致）
          if (_method == 0) ...[
            Text('月份', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(12, (i) {
                final sel = _month == i + 1;
                return ChoiceChip(
                  label: Text(_months[i], style: TextStyle(fontSize: 11, color: sel ? p : t)),
                  selected: sel,
                  onSelected: (_) => setState(() => _month = i + 1),
                  selectedColor: p.withAlpha(40),
                  backgroundColor: bg,
                  side: BorderSide(color: sel ? p : b, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  visualDensity: VisualDensity.compact,
                );
              }),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _select('日期', _day, List.generate(30, (i) => '${i + 1}日'), (v) => setState(() => _day = v + 1))),
              const SizedBox(width: 8),
              Expanded(child: _select('时辰', _hour, _hours, (v) => setState(() => _hour = v))),
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
              ],  // Card 内 Column children
            ),  // Column
          ),  // Padding
        ),  // Card
          const SizedBox(height: 12),

          // 结果
          if (_result != null) ...[
            RepaintBoundary(
              key: _shotKey,
              child: _resultCard(_result!, p, t, b, isDark),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('保存卦例'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: _saveImage,
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('保存图片'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
            ]),
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
      child: InkWell(
        onTap: () => _showPalmDetail(r),
        borderRadius: BorderRadius.circular(12),
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
          // 象义
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
          if (palm.direction.isNotEmpty || palm.advice.isNotEmpty) ...[
            const SizedBox(height: 10),
            // 方位
            Row(children: [
              Icon(Icons.explore_outlined, size: 14, color: color),
              const SizedBox(width: 6),
              Text('方位：${palm.direction} · 五行：${palm.element}',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.withAlpha(190))),
            ]),
            const SizedBox(height: 6),
            // 断语
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Text('断语：${palm.advice}',
                  style: TextStyle(fontSize: 12.5, height: 1.6, color: t.withAlpha(190))),
            ),
          ],
        ]),
        ),
      ),
    );
  }

  /// 掌诀详情弹窗
  void _showPalmDetail(XiaoLiuRenResult r) {
    final palm = r.resultPalm;
    final color = _palmColor(palm.goodBad);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${palm.name}（${palm.goodBad}）',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('五行：${palm.element} · 方位：${palm.direction}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('象义', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(palm.meaning, style: const TextStyle(fontSize: 13, height: 1.6)),
            const SizedBox(height: 10),
            Text('断语', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(palm.advice, style: const TextStyle(fontSize: 13, height: 1.6)),
            const SizedBox(height: 10),
            Text('起课：${r.month}月${r.day}日 ${['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'][r.hour]}时 · ${r.method}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
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
