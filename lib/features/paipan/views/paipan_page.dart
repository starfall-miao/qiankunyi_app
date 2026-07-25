// 排盘主页 — 调试版（最小化验证能否渲染）
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../providers/paipan_provider.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import '../models/gua_model.dart';
import '../models/yao_model.dart';
import 'gua_widget.dart';

enum _YaoInput { shaoYin, shaoYang, laoYin, laoYang }

class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});
  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

class _PaipanPageState extends State<PaipanPage> {
  int _tabIndex = 0;
  int _liuyaoMethod = 0;
  final _manualYaos = List<_YaoInput>.filled(6, _YaoInput.shaoYin);
  int _meihuaMethod = 0;
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();
  final DateTime _selectedTime = DateTime.now();

  @override
  void dispose() {
    _numACtrl.dispose();
    _numBCtrl.dispose();
    _numCCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _buildPage(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.read<ThemeProvider>();
    final pr = context.read<PaipanProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final p = tp.colorSchemeType.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: isDark ? null : p,
        foregroundColor: isDark ? null : const Color(0xFFF5F0EB),
        elevation: 0,
        title: Text('排盘 · ${_tabIndex == 0 ? "六爻" : "梅花"}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB)),
            onPressed: () => tp.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 调试确认条
          Container(
            color: Colors.green.shade100,
            padding: const EdgeInsets.all(8),
            child: Text('✅ 页面渲染正常',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          ),
          // Tab 行
          Row(children: [
            _tabBtn('六爻（铜钱）', 0, p, isDark),
            _tabBtn('梅花易数', 1, p, isDark),
          ]),
          const Divider(height: 1),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _tabIndex == 0
                  ? _liuyaoContent(context, pr, p, t, isDark)
                  : _meihuaContent(context, pr, p, t, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx, Color p, bool dark) {
    final sel = _tabIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: sel ? p.withAlpha(20) : Colors.transparent,
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? p : (dark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  // ── 六爻内容 ──

  Widget _liuyaoContent(BuildContext context, PaipanProvider pr, Color p, Color t, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(3, (i) {
            final labels = ['手工摇卦', '机器摇卦', '时间起卦'];
            final sel = _liuyaoMethod == i;
            return ChoiceChip(
              label: Text(labels[i], style: const TextStyle(fontSize: 12)),
              selected: sel,
              onSelected: (v) => setState(() => _liuyaoMethod = i),
              selectedColor: p.withAlpha(30),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (_liuyaoMethod == 0) ..._buildManualSelector(p, t, dark),
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => _submitLiuyao(pr),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('起卦', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (pr.currentResult != null && pr.lastMethod == 'liuyao') ...[
          _guaCard('本卦', pr.currentResult!.benGua),
          if (pr.currentResult!.bianGua != null) _guaCard('变卦', pr.currentResult!.bianGua!),
          if (pr.currentResult!.huGua != null) _guaCard('互卦', pr.currentResult!.huGua!),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => pr.clearResult(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('清空排盘'),
            ),
          ),
        ] else
          _emptyHint(p, t),
      ],
    );
  }

  void _submitLiuyao(PaipanProvider pr) {
    PaipanResult r;
    if (_liuyaoMethod == 0) {
      final ys = <YaoModel>[];
      for (int i = 0; i < 6; i++) {
        final v = _manualYaos[i];
        ys.add(YaoModel(
          yinYang: (v == _YaoInput.shaoYang || v == _YaoInput.laoYang)
              ? YaoYinYang.yang : YaoYinYang.yin,
          position: YaoPosition.values[5 - i],
          isMoving: v == _YaoInput.laoYin || v == _YaoInput.laoYang,
        ));
      }
      r = LiuYaoEngine.fromYaos(ys, time: _selectedTime);
    } else if (_liuyaoMethod == 1) {
      r = LiuYaoEngine.manual();
    } else {
      r = LiuYaoEngine.byTime(_selectedTime);
    }
    pr.setResult(r, method: 'liuyao');
  }

  // ── 手工摇卦选择器 ──

  List<Widget> _buildManualSelector(Color p, Color t, bool dark) {
    final pos = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    final opts = [_YaoInput.shaoYin, _YaoInput.shaoYang, _YaoInput.laoYin, _YaoInput.laoYang];
    final lbs = ['少阴', '少阳', '老阴', '老阳'];
    final syms = ['- -', '———', '- -×', '———○'];

    return [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dark ? const Color(0xFF444444) : const Color(0xFFE0D5C8)),
        ),
        child: Column(
          children: List.generate(6, (i) {
            final idx = 5 - i;
            final v = _manualYaos[idx];
            final mv = v == _YaoInput.laoYin || v == _YaoInput.laoYang;
            final yg = v == _YaoInput.shaoYang || v == _YaoInput.laoYang;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                SizedBox(width: 32, child: Text(pos[i], style: TextStyle(fontSize: 12, color: t))),
                SizedBox(width: 36, child: Text(syms[v.index],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                        color: mv ? (yg ? const Color(0xFFD4A574) : const Color(0xFF8B4513))
                                  : (yg ? const Color(0xFF3E2723) : const Color(0xFF8D6E63))))),
                const Spacer(),
                ...List.generate(4, (j) {
                  final s = v == opts[j];
                  return GestureDetector(
                    onTap: () => setState(() => _manualYaos[idx] = opts[j]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: s ? p.withAlpha(25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: s ? p : (dark ? const Color(0xFF444444) : const Color(0xFFE0D5C8))),
                      ),
                      child: Text(lbs[j],
                          style: TextStyle(fontSize: 10,
                              fontWeight: s ? FontWeight.bold : FontWeight.normal,
                              color: s ? p : (dark ? Colors.grey.shade400 : Colors.grey.shade600))),
                    ),
                  );
                }),
              ]),
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  // ── 梅花内容 ──

  Widget _meihuaContent(BuildContext context, PaipanProvider pr, Color p, Color t, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(2, (i) {
            final labels = ['三数起卦', '日期起卦'];
            final sel = _meihuaMethod == i;
            return ChoiceChip(
              label: Text(labels[i], style: const TextStyle(fontSize: 12)),
              selected: sel,
              onSelected: (v) => setState(() => _meihuaMethod = i),
              selectedColor: p.withAlpha(30),
            );
          }),
        ),
        const SizedBox(height: 8),
        if (_meihuaMethod == 0) ...[
          Row(children: [
            Expanded(child: TextField(
              controller: _numACtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'A', hintText: '0~9', isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _numBCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'B', hintText: '0~9', isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _numCCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'C', hintText: '0~9', isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
            )),
          ]),
        ],
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => _submitMeihua(pr),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('起卦', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (pr.currentResult != null && pr.lastMethod == 'meihua') ...[
          _guaCard('本卦', pr.currentResult!.benGua),
          if (pr.currentResult!.bianGua != null) _guaCard('变卦', pr.currentResult!.bianGua!),
          if (pr.currentResult!.huGua != null) _guaCard('互卦', pr.currentResult!.huGua!),
          if (pr.currentResult!.benGua.yaos.length >= 6)
            _buildTiYong(pr.currentResult!),
          Center(
            child: TextButton.icon(
              onPressed: () => pr.clearResult(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('清空排盘'),
            ),
          ),
        ] else
          _emptyHint(p, t),
      ],
    );
  }

  void _submitMeihua(PaipanProvider pr) {
    PaipanResult r;
    if (_meihuaMethod == 0) {
      r = MeihuaEngine.fromNumbers(
        int.tryParse(_numACtrl.text) ?? 0,
        int.tryParse(_numBCtrl.text) ?? 0,
        int.tryParse(_numCCtrl.text) ?? 0,
      );
    } else {
      r = MeihuaEngine.fromDateTime(_selectedTime);
    }
    pr.setResult(r, method: 'meihua');
  }

  // ── 通用 ──

  Widget _guaCard(String label, GuaModel gua) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          GuaWidget(gua: gua, showFooter: true),
        ],
      ),
    );
  }

  Widget _buildTiYong(PaipanResult result) {
    final tiYong = MeihuaEngine.getTiYong(result);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF2E7D32).withAlpha(80)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(tiYong, style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)))),
      ]),
    );
  }

  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(60)),
        const SizedBox(height: 12),
        Text('选择排盘方式后点「起卦」', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
      ]),
    );
  }
}
