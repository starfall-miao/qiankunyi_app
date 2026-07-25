// 排盘主页 — 国风紧凑版
// 支持六爻（手工摇卦/机器摇卦/时间起卦）和梅花易数
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

/// 排盘主页
class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});

  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

/// 六爻手工输入中每一爻的状态
enum _YaoInput { shaoYin, shaoYang, laoYin, laoYang }

class _PaipanPageState extends State<PaipanPage> {
  int _tabIndex = 0;

  // 六爻 — 方法选择
  int _liuyaoMethod = 0; // 0=手工摇, 1=机器摇, 2=时间起卦

  // 六爻 — 手工输入六爻状态（初→上）
  final List<_YaoInput> _manualYaos =
      List.filled(6, _YaoInput.shaoYin);

  // 梅花 — 方法选择
  int _meihuaMethod = 0; // 0=三数起卦, 1=日期起卦

  // 梅花 — 数字输入
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();

  // 通用 — 时间选择
  DateTime _selectedTime = DateTime.now();

  @override
  void dispose() {
    _numACtrl.dispose();
    _numBCtrl.dispose();
    _numCCtrl.dispose();
    super.dispose();
  }

  // ── 构建 ──

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.watch<ThemeProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final primary = tp.colorSchemeType.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? null : primary,
        foregroundColor: isDark ? null : const Color(0xFFF5F0EB),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.change_circle_outlined, size: 20,
                    color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB)),
              ),
              const SizedBox(width: 8),
              Text('落·乾坤',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB))),
              Text(_tabIndex == 0 ? ' 六爻' : ' 梅花',
                  style: TextStyle(fontSize: 12,
                      color: isDark ? Colors.white54 : const Color(0xFFE0D5C8))),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? const Color(0xFFD4A574) : const Color(0xFFF5F0EB),
            ),
            tooltip: '切换主题',
            onPressed: () => tp.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        child: SafeArea(
          child: _tabIndex == 0
              ? _buildLiuyaoContent(context, isDark, primary)
              : _buildMeihuaContent(context, isDark, primary),
        ),
      ),
    );
  }

  // ── 便捷取色方法 ──

  Color _cardBg(bool isDark) => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color _border(bool isDark) => isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
  Color _text(bool isDark) => isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
  Color _muted(bool isDark) => isDark ? const Color(0xFF999999) : const Color(0xFF888888);

  Widget _buildTimePicker(BuildContext context, bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 14, color: primary),
          const SizedBox(width: 6),
          Text(
            '${_selectedTime.year}年${_selectedTime.month}月${_selectedTime.day}日 '
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 12, color: _text(isDark)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primary.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('修改', style: TextStyle(fontSize: 11, color: primary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab ──

  Widget _buildTabBar(bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          _tabItem('六爻（铜钱）', 0, isDark, primary),
          _tabItem('梅花易数', 1, isDark, primary),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index, bool isDark, Color primary) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primary.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? primary : _muted(isDark))),
        ),
      ),
    );
  }

  // ═══════════════════════ 六爻 ═══════════════════════

  Widget _buildLiuyaoContent(BuildContext context, bool isDark, Color primary) {
    final provider = context.watch<PaipanProvider>();
    return Column(
      children: [
        // 固定头部
        _buildTimePicker(context, isDark, primary),
        _buildTabBar(isDark, primary),
        // 可滚动内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              children: [
                _buildMethodSelector(isDark, primary),
                const SizedBox(height: 6),
                if (_liuyaoMethod == 0) _buildManualYaos(context, isDark, primary),
                if (_liuyaoMethod == 1) _buildMachineToss(isDark, primary),
                if (_liuyaoMethod == 2) _buildTimeToss(isDark, primary),
                const SizedBox(height: 8),
                _buildSubmitButton(context, isDark, primary, provider),
                const SizedBox(height: 8),
                if (provider.currentResult != null && _isLastResultLiuyao(provider))
                  ..._buildLiuyaoResult(provider.currentResult!, isDark, primary)
                else if (provider.currentResult == null)
                  _buildEmptyHint(primary, isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 六爻方法选择
  Widget _buildMethodSelector(bool isDark, Color primary) {
    final methods = ['手工摇卦', '机器摇卦', '时间起卦'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: List.generate(methods.length, (i) {
          final sel = _liuyaoMethod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _liuyaoMethod = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                margin: EdgeInsets.only(right: i < methods.length - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: sel ? primary.withAlpha(25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sel ? primary : _border(isDark).withAlpha(80)),
                ),
                child: Text(methods[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        color: sel ? primary : (isDark ? const Color(0xFFBBBBBB) : const Color(0xFF666666)))),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 手工摇卦 — 六爻逐爻输入 ──

  Widget _buildManualYaos(BuildContext context, bool isDark, Color primary) {
    final positions = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pan_tool_outlined, size: 14, color: primary),
              const SizedBox(width: 4),
              Text('逐爻选择（点击切换）',
                  style: TextStyle(fontSize: 12, color: _text(isDark), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          // 从初爻到上爻（从下到上）
          for (int i = 0; i < 6; i++)
            _buildYaoRow(i, positions[5 - i], isDark, primary, _text(isDark)),
        ],
      ),
    );
  }

  Widget _buildYaoRow(int index, String label, bool isDark, Color primary, Color tColor) {
    final val = _manualYaos[index];
    final options = [_YaoInput.shaoYin, _YaoInput.shaoYang, _YaoInput.laoYin, _YaoInput.laoYang];
    final labels = ['少阴', '少阳', '老阴', '老阳'];
    final syms = ['- -', '———', '- -×', '———○'];
    final isMoving = (val == _YaoInput.laoYin || val == _YaoInput.laoYang);
    final isYang = (val == _YaoInput.shaoYang || val == _YaoInput.laoYang);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(label, style: TextStyle(fontSize: 12, color: tColor)),
          ),
          // 爻符号
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              syms[index],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isMoving
                    ? (isYang ? const Color(0xFFD4A574) : const Color(0xFF8B4513))
                    : (isYang ? const Color(0xFF3E2723) : const Color(0xFF8D6E63)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 四个选项按钮
          Expanded(
            child: Row(
              children: List.generate(4, (j) {
                final sel = val == options[j];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _manualYaos[index] = options[j]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      margin: EdgeInsets.only(right: j < 3 ? 2 : 0),
                      decoration: BoxDecoration(
                        color: sel ? primary.withAlpha(25) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: sel ? primary : (isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8))),
                      ),
                      child: Text(labels[j],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10,
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              color: sel ? primary : (isDark ? Color(0xFF999999) : Color(0xFF888888)))),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── 机器摇卦 ──

  Widget _buildMachineToss(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.shuffle, size: 14, color: primary),
          const SizedBox(width: 4),
          Text('由系统模拟摇铜钱，随机生成六爻',
              style: TextStyle(fontSize: 12, color: _text(isDark))),
        ],
      ),
    );
  }

  // ── 时间起卦 ──

  Widget _buildTimeToss(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, size: 14, color: primary),
          const SizedBox(width: 4),
          Text('以当前选中时间的年月日时数字起卦',
              style: TextStyle(fontSize: 12, color: _text(isDark))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isDark, Color primary, PaipanProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_tabIndex == 0) {
            _onLiuyaoSubmit(context, provider);
          } else {
            _onMeihuaSubmit(context, provider);
          }
        },
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('起卦', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ── 六爻提交 ──

  void _onLiuyaoSubmit(BuildContext context, PaipanProvider provider) {
    PaipanResult result;
    if (_liuyaoMethod == 0) {
      // 手工摇卦 — 从 _manualYaos 构建 YaoModel
      final yaos = <YaoModel>[];
      for (int i = 0; i < 6; i++) {
        final val = _manualYaos[i];
        final isYang = (val == _YaoInput.shaoYang || val == _YaoInput.laoYang);
        final isMoving = (val == _YaoInput.laoYin || val == _YaoInput.laoYang);
        yaos.add(YaoModel(
          yinYang: isYang ? YaoYinYang.yang : YaoYinYang.yin,
          position: YaoPosition.values[5 - i],
          isMoving: isMoving,
        ));
      }
      result = LiuYaoEngine.fromYaos(yaos, time: _selectedTime);
    } else if (_liuyaoMethod == 1) {
      // 机器摇卦
      result = LiuYaoEngine.manual();
    } else {
      // 时间起卦
      result = LiuYaoEngine.byTime(_selectedTime);
    }
    provider.setResult(result, method: 'liuyao');
  }

  /// 判断当前结果是否为六爻生成
  bool _isLastResultLiuyao(PaipanProvider provider) {
    return provider.lastMethod == 'liuyao';
  }

  List<Widget> _buildLiuyaoResult(PaipanResult result, bool isDark, Color primary) {
    return [
      GuaWidget(gua: result.benGua),
      if (result.bianGua != null) ...[
        const SizedBox(height: 6),
        GuaWidget(gua: result.bianGua!),
      ],
      if (result.huGua != null) ...[
        const SizedBox(height: 6),
        GuaWidget(gua: result.huGua!),
      ],
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.read<PaipanProvider>().clearResult(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('清空排盘'),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  // ═══════════════════════ 梅花易数 ═══════════════════════

  Widget _buildMeihuaContent(BuildContext context, bool isDark, Color primary) {
    final provider = context.watch<PaipanProvider>();
    return Column(
      children: [
        // 固定头部
        _buildTimePicker(context, isDark, primary),
        _buildTabBar(isDark, primary),
        // 可滚动内容
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              children: [
                _buildMeihuaMethodSelector(isDark, primary),
                const SizedBox(height: 6),
                if (_meihuaMethod == 0) _buildMeihuaNumbers(isDark, primary),
                if (_meihuaMethod == 1) _buildMeihuaDate(isDark, primary),
                const SizedBox(height: 8),
                _buildSubmitButton(context, isDark, primary, provider),
                const SizedBox(height: 8),
                if (provider.currentResult != null && _isLastResultMeihua(provider))
                  MeihuaResultWidget(result: provider.currentResult!)
                else if (provider.currentResult == null)
                  _buildEmptyHint(primary, isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeihuaMethodSelector(bool isDark, Color primary) {
    final methods = ['三数起卦', '日期起卦'];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final sel = _meihuaMethod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _meihuaMethod = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                margin: EdgeInsets.only(right: i == 0 ? 4 : 0),
                decoration: BoxDecoration(
                  color: sel ? primary.withAlpha(25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sel ? primary : _border(isDark).withAlpha(80)),
                ),
                child: Text(methods[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        color: sel ? primary : (isDark ? Color(0xFFBBBBBB) : Color(0xFF666666)))),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMeihuaNumbers(bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.numbers, size: 14, color: primary),
              const SizedBox(width: 4),
              Text('输入三个数字', style: TextStyle(fontSize: 12,
                  color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728),
                  fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _numField('A', _numACtrl, '0~9'),
              const SizedBox(width: 6),
              _numField('B', _numBCtrl, '0~9'),
              const SizedBox(width: 6),
              _numField('C', _numCCtrl, '0~9'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeihuaDate(bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, size: 14, color: primary),
          const SizedBox(width: 4),
          Text('以当前选中时间的年月日数字起卦',
              style: TextStyle(fontSize: 12,
                  color: isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728))),
        ],
      ),
    );
  }

  void _onMeihuaSubmit(BuildContext context, PaipanProvider provider) {
    PaipanResult result;
    if (_meihuaMethod == 0) {
      final a = int.tryParse(_numACtrl.text) ?? 0;
      final b = int.tryParse(_numBCtrl.text) ?? 0;
      final c = int.tryParse(_numCCtrl.text) ?? 0;
      result = MeihuaEngine.fromNumbers(a, b, c);
    } else {
      result = MeihuaEngine.fromDateTime(_selectedTime);
    }
    provider.setResult(result, method: 'meihua');
  }

  bool _isLastResultMeihua(PaipanProvider provider) {
    return provider.lastMethod == 'meihua';
  }

  // ── 通用 ──

  Widget _buildEmptyHint(Color primary, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.auto_awesome, size: 48, color: primary.withAlpha(60)),
            const SizedBox(height: 12),
            Text('选择排盘方式后点「起卦」',
                style: TextStyle(fontSize: 14, color: _text(isDark).withAlpha(120))),
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl, String hint) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time == null) return;
    setState(() {
      _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }
}
