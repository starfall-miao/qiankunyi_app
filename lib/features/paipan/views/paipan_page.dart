// 排盘主页 — 国风紧凑版
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../providers/paipan_provider.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import '../models/yao_model.dart';
import 'gua_widget.dart';
import 'meihua_widget.dart';

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
  DateTime _selectedTime = DateTime.now();

  @override
  void dispose() {
    _numACtrl.dispose();
    _numBCtrl.dispose();
    _numCCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final p = tp.colorSchemeType.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    final c = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: isDark ? null : p,
        foregroundColor: isDark ? null : const Color(0xFFF5F0EB),
        elevation: 0,
        title: Text('落·乾坤  ${_tabIndex == 0 ? "六爻" : "梅花"}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB))),
        actions: [
          IconButton(
            icon: Icon(tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB)),
            onPressed: () => tp.toggleTheme(),
          ),
        ],
      ),
      body: _tabIndex == 0
          ? _liuyaoBody(context, p, t, b, c, isDark)
          : _meihuaBody(context, p, t, b, c, isDark),
    );
  }

  // ── 六爻 ──

  Widget _liuyaoBody(BuildContext context, Color p, Color t, Color b, Color c, bool d) {
    final pr = context.watch<PaipanProvider>();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _timeRow(p, t, b, c),
        const SizedBox(height: 6),
        _tabRow(p, t, b, c, d),
        const SizedBox(height: 6),
        _methodRow(p, t, b, c, d),
        const SizedBox(height: 6),
        if (_liuyaoMethod == 0) _manualRow(p, t, b, c, d),
        if (_liuyaoMethod == 1) _info(Icons.shuffle, '由系统模拟摇铜钱，随机生成六爻', p, t, b, c),
        if (_liuyaoMethod == 2) _info(Icons.date_range, '以当前选中时间的年月日时数字起卦', p, t, b, c),
        const SizedBox(height: 6),
        _btn('起卦', p, () => _submitLiuyao(pr)),
        const SizedBox(height: 8),
        if (pr.currentResult != null && pr.lastMethod == 'liuyao')
          ..._liuyaoResult(pr.currentResult!)
        else
          _empty(p, t, d),
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
          yinYang: (v == _YaoInput.shaoYang || v == _YaoInput.laoYang) ? YaoYinYang.yang : YaoYinYang.yin,
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

  List<Widget> _liuyaoResult(PaipanResult r) {
    return [
      GuaWidget(gua: r.benGua),
      if (r.bianGua != null) ...[const SizedBox(height: 6), GuaWidget(gua: r.bianGua!)],
      if (r.huGua != null) ...[const SizedBox(height: 6), GuaWidget(gua: r.huGua!)],
      const SizedBox(height: 8),
      Center(
        child: TextButton.icon(
          onPressed: () => context.read<PaipanProvider>().clearResult(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('清空排盘'),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  // ── 梅花 ──

  Widget _meihuaBody(BuildContext context, Color p, Color t, Color b, Color c, bool d) {
    final pr = context.watch<PaipanProvider>();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _timeRow(p, t, b, c),
        const SizedBox(height: 6),
        _tabRow(p, t, b, c, d),
        const SizedBox(height: 6),
        _meihuaMethodRow(p, t, b, c, d),
        const SizedBox(height: 6),
        if (_meihuaMethod == 0) _meihuaNumRow(p, t, b, c, d),
        if (_meihuaMethod == 1) _info(Icons.date_range, '以当前选中时间的年月日数字起卦', p, t, b, c),
        const SizedBox(height: 6),
        _btn('起卦', p, () => _submitMeihua(pr)),
        const SizedBox(height: 8),
        if (pr.currentResult != null && pr.lastMethod == 'meihua')
          MeihuaResultWidget(result: pr.currentResult!)
        else
          _empty(p, t, d),
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

  // ── 通用组件 ──

  Widget _timeRow(Color p, Color t, Color b, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Row(children: [
        Icon(Icons.access_time, size: 14, color: p),
        const SizedBox(width: 6),
        Text('${_selectedTime.year}年${_selectedTime.month}月${_selectedTime.day}日 '
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: t)),
        const Spacer(),
        GestureDetector(
          onTap: () => _pickDateTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: p.withAlpha(25), borderRadius: BorderRadius.circular(4)),
            child: Text('修改', style: TextStyle(fontSize: 11, color: p)),
          ),
        ),
      ]),
    );
  }

  Widget _tabRow(Color p, Color t, Color b, Color c, bool d) {
    return Container(
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Row(children: [
        _tab('六爻（铜钱）', 0, p, d),
        _tab('梅花易数', 1, p, d),
      ]),
    );
  }

  Widget _tab(String label, int idx, Color p, bool d) {
    final sel = _tabIndex == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: sel ? p.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                color: sel ? p : const Color(0xFF888888))),
      ),
    ));
  }

  Widget _methodRow(Color p, Color t, Color b, Color c, bool d) {
    final ms = ['手工摇卦', '机器摇卦', '时间起卦'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Row(children: List.generate(3, (i) {
        final sel = _liuyaoMethod == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _liuyaoMethod = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              color: sel ? p.withAlpha(25) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sel ? p : b.withAlpha(80)),
            ),
            child: Text(ms[i], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    color: sel ? p : (d ? const Color(0xFFBBBBBB) : const Color(0xFF666666)))),
          ),
        ));
      })),
    );
  }

  Widget _manualRow(Color p, Color t, Color b, Color c, bool d) {
    final pos = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    final opts = [_YaoInput.shaoYin, _YaoInput.shaoYang, _YaoInput.laoYin, _YaoInput.laoYang];
    final lbs = ['少阴', '少阳', '老阴', '老阳'];
    final syms = ['- -', '———', '- -×', '———○'];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.pan_tool_outlined, size: 14, color: p),
          const SizedBox(width: 4),
          Text('逐爻选择（点击切换）', style: TextStyle(fontSize: 12, color: t, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        ...List.generate(6, (i) {
          final idx = 5 - i;
          final v = _manualYaos[idx];
          final mv = v == _YaoInput.laoYin || v == _YaoInput.laoYang;
          final yg = v == _YaoInput.shaoYang || v == _YaoInput.laoYang;
          return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
            SizedBox(width: 36, child: Text(pos[i], style: TextStyle(fontSize: 12, color: t))),
            SizedBox(width: 40, child: Text(syms[idx],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: mv ? (yg ? const Color(0xFFD4A574) : const Color(0xFF8B4513))
                              : (yg ? const Color(0xFF3E2723) : const Color(0xFF8D6E63))))),
            const SizedBox(width: 4),
            Expanded(child: Row(children: List.generate(4, (j) {
              final s = v == opts[j];
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _manualYaos[idx] = opts[j]),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  margin: EdgeInsets.only(right: j < 3 ? 2 : 0),
                  decoration: BoxDecoration(
                    color: s ? p.withAlpha(25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: s ? p : b),
                  ),
                  child: Text(lbs[j], textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10,
                          fontWeight: s ? FontWeight.bold : FontWeight.normal,
                          color: s ? p : (d ? const Color(0xFF999999) : const Color(0xFF888888)))),
                ),
              ));
            }))),
          ]));
        }),
      ]),
    );
  }

  Widget _meihuaMethodRow(Color p, Color t, Color b, Color c, bool d) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Row(children: List.generate(2, (i) {
        final sel = _meihuaMethod == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _meihuaMethod = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            margin: EdgeInsets.only(right: i == 0 ? 4 : 0),
            decoration: BoxDecoration(
              color: sel ? p.withAlpha(25) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sel ? p : b.withAlpha(80)),
            ),
            child: Text(['三数起卦', '日期起卦'][i], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    color: sel ? p : (d ? const Color(0xFFBBBBBB) : const Color(0xFF666666)))),
          ),
        ));
      })),
    );
  }

  Widget _meihuaNumRow(Color p, Color t, Color b, Color c, bool d) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.numbers, size: 14, color: p),
          const SizedBox(width: 4),
          Text('输入三个数字', style: TextStyle(fontSize: 12, color: t, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _field('A', _numACtrl, '0~9'),
          const SizedBox(width: 6),
          _field('B', _numBCtrl, '0~9'),
          const SizedBox(width: 6),
          _field('C', _numCCtrl, '0~9'),
        ]),
      ]),
    );
  }

  Widget _info(IconData ic, String txt, Color p, Color t, Color b, Color c) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: b)),
      child: Row(children: [
        Icon(ic, size: 14, color: p),
        const SizedBox(width: 4),
        Expanded(child: Text(txt, style: TextStyle(fontSize: 12, color: t))),
      ]),
    );
  }

  Widget _btn(String label, Color p, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: p, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _empty(Color p, Color t, bool d) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(60)),
          const SizedBox(height: 12),
          Text('选择排盘方式后点「起卦」', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Expanded(
      child: TextField(
        controller: ctrl, keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label, hintText: hint, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context, initialDate: _selectedTime,
      firstDate: DateTime(1900), lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time == null) return;
    setState(() => _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }
}
