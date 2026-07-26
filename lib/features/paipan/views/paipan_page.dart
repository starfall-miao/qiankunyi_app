// 排盘主页 — 全功能版
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/logger.dart';
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
  final _log = Logger.instance;
  int _tabIndex = 0;
  int _liuyaoMethod = 0;
  final _manualYaos = List<_YaoInput>.filled(6, _YaoInput.shaoYin);
  int _meihuaMethod = 0;
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();
  final DateTime _selectedTime = DateTime.now();
  bool _emptyInputWarn = false;

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
    final pr = context.watch<PaipanProvider>();
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
          // 渲染检测条（仅调试模式显示）
          if (tp.renderDebug)
            Container(
              color: Colors.green.shade100,
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Text('渲染检测：页面正常',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade800)),
              ]),
            ),
          // Tab 行
          Container(
            decoration: BoxDecoration(color: c, border: Border(bottom: BorderSide(color: b))),
            child: Row(children: [
              _tabBtn('六爻（铜钱）', 0, p, isDark),
              _tabBtn('梅花易数', 1, p, isDark),
            ]),
          ),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _tabIndex == 0
                  ? _liuyaoContent(context, pr, p, t, b, c, isDark)
                  : _meihuaContent(context, pr, p, t, b, c, isDark),
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
        onTap: () {
          setState(() => _tabIndex = idx);
          _log.info('切换选项卡: ${idx == 0 ? "六爻" : "梅花"}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: sel ? p.withAlpha(20) : Colors.transparent,
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? p : t.withAlpha(160),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════ 六爻 ═══════════════════

  Widget _liuyaoContent(BuildContext context, PaipanProvider pr, Color p,
      Color t, Color b, Color c, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 方法选择
        Wrap(
          spacing: 8,
          children: List.generate(3, (i) {
            final cLabels = ['手工摇卦', '机器摇卦', '时间起卦'];
            final sel = _liuyaoMethod == i;
            return ChoiceChip(
              label: Text(cLabels[i], style: TextStyle(fontSize: 12, color: sel ? p : t)),
              selected: sel,
              onSelected: (v) => setState(() => _liuyaoMethod = i),
              selectedColor: p.withAlpha(40),
              backgroundColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
              side: BorderSide(color: sel ? p : b.withAlpha(80), width: sel ? 1.5 : 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 8),

        // 手工摇——爻位选择面板（国风卦签风格）
        if (_liuyaoMethod == 0) ..._buildManualPanel(p, t, b, c, dark),

        // 起卦按钮
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

        // 排盘结果
        if (pr.liuyaoResult != null) ...[
          _guaCard('本卦', pr.liuyaoResult!.benGua),
          if (pr.liuyaoResult!.bianGua != null)
            _guaCard('变卦', pr.liuyaoResult!.bianGua!),
          if (pr.liuyaoResult!.huGua != null)
            _guaCard('互卦', pr.liuyaoResult!.huGua!),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => pr.clearLiuyao(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('清空排盘'),
              style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
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
    pr.setLiuyaoResult(r);
    final names = ['手工摇卦', '机器摇卦', '时间起卦'];
    _log.info('六爻起卦: ${names[_liuyaoMethod]}', '${r.benGua.name}');
  }

  // ═══════════════════ 手工摇面板（国风卦签样式） ═══════════════════

  List<Widget> _buildManualPanel(Color p, Color t, Color b, Color c, bool dark) {
    final pos = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    final opts = [_YaoInput.shaoYin, _YaoInput.shaoYang, _YaoInput.laoYin, _YaoInput.laoYang];
    final lbs = ['少阴', '少阳', '老阴', '老阳'];

    return [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: b),
        ),
        child: Column(
          children: List.generate(6, (i) {
            final idx = 5 - i;
            final v = _manualYaos[idx];
            final mv = v == _YaoInput.laoYin || v == _YaoInput.laoYang;
            final yg = v == _YaoInput.shaoYang || v == _YaoInput.laoYang;
            final rowColor = i.isEven
                ? (dark ? Colors.white.withAlpha(8) : Colors.grey.shade50)
                : Colors.transparent;

            // 爻画颜色
            final yaoColor = mv
                ? (yg ? const Color(0xFFD4A574) : const Color(0xFF8B4513))
                : (yg ? const Color(0xFF3E2723) : const Color(0xFF8D6E63));

            return Container(
              decoration: BoxDecoration(color: rowColor),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  // 爻位名
                  SizedBox(width: 30,
                    child: Text(pos[i],
                        style: TextStyle(fontSize: 11, color: t, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 6),
                  // 分隔线
                  Container(width: 1, height: 20, color: b.withAlpha(80)),
                  const SizedBox(width: 8),
                  // 爻画（粗线条风格，模拟 GuaWidget 的视觉）
                  Container(
                    width: 44, height: 14,
                    decoration: BoxDecoration(
                      color: yaoColor,
                      borderRadius: BorderRadius.circular(2),
                      border: mv ? Border.all(color: const Color(0xFFD4A574).withAlpha(120), width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    child: mv
                        ? Text(v == _YaoInput.laoYang ? '⚊' : '⚋',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  // 动爻标记
                  if (mv)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574).withAlpha(30),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text('动', style: TextStyle(fontSize: 9, color: Color(0xFFD4A574), fontWeight: FontWeight.bold)),
                    )
                  else
                    const SizedBox(width: 18),
                  const Spacer(),
                  // 四型按钮组
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
                          border: Border.all(
                            color: s ? p : b.withAlpha(100),
                            width: s ? 1.5 : 1,
                          ),
                        ),
                        child: Text(lbs[j],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: s ? FontWeight.bold : FontWeight.normal,
                              color: s ? p : t.withAlpha(180),
                            )),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  // ═══════════════════ 梅花 ═══════════════════

  Widget _meihuaContent(BuildContext context, PaipanProvider pr, Color p,
      Color t, Color b, Color c, bool dark) {
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
              onSelected: (v) => setState(() {
                _meihuaMethod = i;
                _emptyInputWarn = false;
              }),
              selectedColor: p.withAlpha(30),
            );
          }),
        ),
        const SizedBox(height: 8),

        if (_meihuaMethod == 0) ...[
          Row(children: [
            _numField('A', _numACtrl, '数字1'),
            const SizedBox(width: 8),
            _numField('B', _numBCtrl, '数字2'),
            const SizedBox(width: 8),
            _numField('C', _numCCtrl, '数字3'),
          ]),
          if (_emptyInputWarn)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('⚠ 请填写数字后再起卦', style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
            ),
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

        if (pr.meihuaResult != null) ...[
          _guaCard('本卦', pr.meihuaResult!.benGua),
          if (pr.meihuaResult!.bianGua != null)
            _guaCard('变卦', pr.meihuaResult!.bianGua!),
          if (pr.meihuaResult!.huGua != null)
            _guaCard('互卦', pr.meihuaResult!.huGua!),
          if (pr.meihuaResult!.benGua.yaos.length >= 6)
            _buildTiYong(pr.meihuaResult!),
          Center(
            child: TextButton.icon(
              onPressed: () => pr.clearMeihua(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('清空排盘'),
              style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
            ),
          ),
        ] else
          _emptyHint(p, t),
      ],
    );
  }

  void _submitMeihua(PaipanProvider pr) {
    if (_meihuaMethod == 0) {
      final aText = _numACtrl.text.trim();
      final bText = _numBCtrl.text.trim();
      final cText = _numCCtrl.text.trim();
      if (aText.isEmpty || bText.isEmpty || cText.isEmpty) {
        setState(() => _emptyInputWarn = true);
        return;
      }
      setState(() => _emptyInputWarn = false);
      final a = int.tryParse(aText) ?? 0;
      final b = int.tryParse(bText) ?? 0;
      final c = int.tryParse(cText) ?? 0;
      pr.setMeihuaResult(MeihuaEngine.fromNumbers(a, b, c));
      _log.info('梅花起卦: 三数($a,$b,$c)');
    } else {
      pr.setMeihuaResult(MeihuaEngine.fromDateTime(_selectedTime));
      _log.info('梅花起卦: 日期${_selectedTime.year}${_selectedTime.month}${_selectedTime.day}');
    }
  }

  Widget _numField(String label, TextEditingController ctrl, String hint) {
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

  // ═══════════════════ 通用 ═══════════════════

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
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (tiYong.contains('比和')) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
    } else if (tiYong.contains('用生体') || tiYong.contains('进益')) {
      bgColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF2E7D32);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.trending_up;
    } else if (tiYong.contains('用克体') || tiYong.contains('凶险')) {
      bgColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFD32F2F);
      textColor = const Color(0xFFD32F2F);
      icon = Icons.warning_amber_outlined;
    } else if (tiYong.contains('体克用')) {
      bgColor = const Color(0xFFFFF3E0);
      borderColor = const Color(0xFFEF6C00);
      textColor = const Color(0xFFEF6C00);
      icon = Icons.auto_fix_high;
    } else {
      bgColor = const Color(0xFFF5F5F5);
      borderColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFF4A3728);
      icon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withAlpha(80)),
      ),
      child: Row(children: [
        Icon(icon, color: textColor, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(tiYong, style: TextStyle(fontSize: 13, color: textColor))),
      ]),
    );
  }

  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(60)),
        const SizedBox(height: 12),
        Text('选择排盘方式后点「起卦」', style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
      ]),
    );
  }
}
