// 排盘主页 — 全功能版
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/gua_screenshot_template.dart';
import '../../../shared/widgets/save_image_dialog.dart';
import '../../calendar/views/calendar_picker_dialog.dart';
import '../../reference/data/reference_data.dart';
import '../../reference/data/bazi_reference_data.dart';
import '../providers/paipan_provider.dart';
import '../providers/bazi_provider.dart';
import '../../cases/providers/case_provider.dart';
import '../../cases/models/case_models.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import '../models/gua_model.dart';
import '../models/yao_model.dart';
import '../models/bazi_models.dart';
import 'gua_widget.dart';
import 'xiaoliuren_page.dart';
import 'daliuren_page.dart';

// 卦名中文映射统一使用 case_models.dart 中的 guaNameCN

enum _YaoInput { shaoYin, shaoYang, laoYin, laoYang }

class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});
  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

class _PaipanPageState extends State<PaipanPage> with SingleTickerProviderStateMixin {
  final _log = Logger.instance;
  int _tabIndex = 0;
  int _liuyaoMethod = 0;
  LiuyaoSchool _liuyaoSchool = LiuyaoSchool.jingFangJianBan;
  final _manualYaos = List<_YaoInput>.filled(6, _YaoInput.shaoYin);
  int _meihuaMethod = 0;
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  final _liuyaoScreenshotKey = GlobalKey();
  final _meihuaScreenshotKey = GlobalKey();
  bool _emptyInputWarn = false;
  bool _isLoading = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400), value: 1.0);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScrolled) => [
          // ── AppBar 标题栏（沉浸模式隐藏）──
          if (!tp.immersiveMode)
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text('排盘 · ${_tabIndex == 0 ? "六爻" : _tabIndex == 1 ? "梅花" : _tabIndex == 2 ? "八字" : _tabIndex == 3 ? "小六壬" : "大六壬"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: Icon(tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      color: const Color(0xFFD4A574)),
                  onPressed: () => tp.toggleTheme(),
                ),
              ],
            ),
          // 渲染检测条（仅调试模式显示）
          if (tp.renderDebug && !tp.immersiveMode)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.green.shade100,
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text('渲染检测：页面正常',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade800)),
                ]),
              ),
            ),
          // Tab 行（分段式胶囊按钮，统一五个术数切换样式）
          if (!tp.immersiveMode)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: c,
                  border: Border(bottom: BorderSide(color: b.withAlpha(80))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _tabBtn('六爻', 0, p, isDark),
                    _tabBtn('梅花', 1, p, isDark),
                    _tabBtn('八字', 2, p, isDark),
                    _tabBtn('小六壬', 3, p, isDark),
                    _tabBtn('大六壬', 4, p, isDark),
                ]),
              ),
              ),
            ),
        ],
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 600 ? 32.0 : 12.0;
            final content = _tabIndex == 0
                ? _liuyaoContent(context, pr, p, t, b, c, isDark)
                : _tabIndex == 1
                    ? _meihuaContent(context, pr, p, t, b, c, isDark)
                    : _tabIndex == 2
                        ? const BaziPage()
                        : _tabIndex == 3
                            ? const XiaoLiuRenPage()
                            : const DaLiuRenPage();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              child: Center(
                // 桌面宽屏时限制最大宽度，避免文字行过长影响阅读
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width >= 1400 ? 1200.0 : double.infinity,
                  ),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
      // 沉浸式切换按钮（右下角）
      floatingActionButton: tp.immersiveMode
          ? FloatingActionButton.small(
              backgroundColor: p.withAlpha(200),
              onPressed: () => tp.setImmersiveMode(false),
              child: const Icon(Icons.fullscreen_exit, color: Colors.white),
            )
          : FloatingActionButton.small(
              backgroundColor: p.withAlpha(150),
              onPressed: () => tp.setImmersiveMode(true),
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
    );
  }

  Widget _tabBtn(String label, int idx, Color p, bool dark) {
    final sel = _tabIndex == idx;
    final txtColor = dark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final bg = dark ? const Color(0xFF2C2C2C) : Colors.white;
    final b = dark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          setState(() => _tabIndex = idx);
          const names = ['六爻', '梅花', '八字', '小六壬', '大六壬'];
          _log.info('切换选项卡: ${names.length > idx ? names[idx] : ""}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          decoration: BoxDecoration(
            color: sel ? p : bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? p : b.withAlpha(60), width: sel ? 1.5 : 1),
            boxShadow: sel
                ? [BoxShadow(color: p.withAlpha(40), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? Colors.white : txtColor.withAlpha(170),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════ 六爻 ═══════════════════

  Widget _liuyaoContent(BuildContext context, PaipanProvider pr, Color p,
      Color t, Color b, Color c, bool dark) {
    final lr = pr.liuyaoResult;
    final lrGuaCi = lr != null ? getGuaCi(lr.benGua.name) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 输入区（与八字 _buildInputCard 样式统一）
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        // 方法选择
        Wrap(
          spacing: 8,
          children: List.generate(4, (i) {
            final cLabels = ['手工摇卦', '机器摇卦', '时间起卦', '数字起卦'];
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
        // 时间起卦选择器（六爻）
        if (_liuyaoMethod == 2) ...[
          const SizedBox(height: 6),
          _buildTimePicker(p, t, b, dark),
        ],
        // 数字起卦输入（六爻）：两数定上下卦 + 动爻
        if (_liuyaoMethod == 3) ...[
          const SizedBox(height: 8),
          Row(children: [
            _numField('A', _numACtrl, '上卦数'),
            const SizedBox(width: 8),
            _numField('B', _numBCtrl, '下卦数'),
            const SizedBox(width: 8),
            _numField('C', _numCCtrl, '动爻 1-6'),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('动爻必填（1-6，余0按6取上爻）',
                style: TextStyle(fontSize: 10, color: t.withAlpha(140))),
          ),
        ],
        const SizedBox(height: 8),

        // 流派选择
        Row(
          children: [
            Icon(Icons.school_outlined, size: 14, color: p.withAlpha(180)),
            const SizedBox(width: 4),
            Text('流派: ', style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
            Expanded(
              child: ToggleButtons(
                isSelected: [
                  _liuyaoSchool == LiuyaoSchool.jingFangJianBan,
                  _liuyaoSchool == LiuyaoSchool.jingFangZhengZong,
                ],
                onPressed: (i) {
                  setState(() {
                    _liuyaoSchool = i == 0
                        ? LiuyaoSchool.jingFangJianBan
                        : LiuyaoSchool.jingFangZhengZong;
                  });
                },
                constraints: const BoxConstraints(minWidth: 80, minHeight: 28),
                textStyle: TextStyle(fontSize: 12, color: t),
                selectedColor: p,
                fillColor: p.withAlpha(20),
                color: t.withAlpha(150),
                borderRadius: BorderRadius.circular(6),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('京房简版')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('京房正宗')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 手工摇——爻位选择面板（国风卦签风格）
        if (_liuyaoMethod == 0) ..._buildManualPanel(p, t, b, c, dark),

        // 起卦按钮
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _submitLiuyao(pr),
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isLoading ? '排盘中…' : '排盘', style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
              ],  // Card 内 Column children
            ),  // Card 内 Column
          ),  // Padding
        ),  // Card
        const SizedBox(height: 12),

        // 排盘结果（淡入 + 上移动画）
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(_fadeAnim),
            child: lr != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // ── 装饰标题 ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.withAlpha(60))),
            ),
            child: Row(
              children: [
                Text('☯ ', style: TextStyle(fontSize: 18, color: p)),
                Text('六爻纳甲 · 排盘结果',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
              ],
            ),
          ),
          // ── 月令/日令/空亡/流派信息 ──
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: p.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.withAlpha(30)),
            ),
            child: Row(
              children: [
                if (pr.liuyaoResult!.monthGanZhi != null) ...[
                  _dateTag('月', pr.liuyaoResult!.monthGanZhi!, p, t),
                  const SizedBox(width: 8),
                ],
                if (pr.liuyaoResult!.dayGanZhi != null) ...[
                  _dateTag('日', pr.liuyaoResult!.dayGanZhi!, p, t),
                  const SizedBox(width: 8),
                ],
                if (pr.liuyaoResult!.kongWang != null) ...[
                  _dateTag('空', '旬空: ${pr.liuyaoResult!.kongWang!.join(" ")}', p, t),
                  const SizedBox(width: 8),
                ],
                _dateTag(
                  '派',
                  pr.liuyaoResult!.school == LiuyaoSchool.jingFangJianBan ? '京房简版' : '京房正宗',
                  p, t,
                ),
              ],
            ),
          ),
          // ── 六爻三卦 ──
          LayoutBuilder(
            builder: (ctx2, constraints) {
              final isWide = constraints.maxWidth >= 340;
              final cards = <Widget>[
                _miniGuaCard('本卦', pr.liuyaoResult!.benGua, p, t, c, dark),
                if (pr.liuyaoResult!.bianGua != null)
                  _miniGuaCard('变卦', pr.liuyaoResult!.bianGua!, p, t, c, dark),
                if (pr.liuyaoResult!.huGua != null)
                  _miniGuaCard('互卦', pr.liuyaoResult!.huGua!, p, t, c, dark),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards.expand((w) => [Expanded(child: w), const SizedBox(width: 8)]).toList()..removeLast(),
                );
              }
              return Column(
                children: cards.expand((w) => [w, const SizedBox(height: 8)]).toList()..removeLast(),
              );
            },
          ),
              ], // RepaintBoundary child column end
            ),
          ),
          // ── 藏爻（伏神） ──
          if (pr.liuyaoResult!.hiddenFuShen.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Row(children: [
                Icon(Icons.hide_source_outlined, size: 14, color: p.withAlpha(180)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '藏爻（伏神）：${pr.liuyaoResult!.hiddenFuShen.join('　')}',
                    style: TextStyle(fontSize: 12, color: t.withAlpha(190)),
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 12),
          // ── 操作按钮（2×2 四方格）──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => pr.clearLiuyao(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('清空排盘'),
                      style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _shareResult(context, pr.liuyaoResult!),
                      icon: const Icon(Icons.copy_outlined, size: 16),
                      label: const Text('复制结果'),
                      style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _saveCurrentResult(context, pr, pr.liuyaoResult!),
                      icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                      label: const Text('保存卦例'),
                      style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _saveImage(
                        _liuyaoScreenshotKey,
                        context,
                        guaName: guaNameCN[lr.benGua.name] ??
                            lr.benGua.name.name,
                      ),
                      icon: const Icon(Icons.image_outlined, size: 16),
                      label: const Text('保存图片'),
                      style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
                style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          ),

          // ── 截图专用紧凑模板（屏幕外，不影响页面显示；固定 400 宽+浅色国风）──
          ScreenshotSource(
            boundaryKey: _liuyaoScreenshotKey,
            child: LiuyaoScreenshotTemplate(
              timeText: formatCnTime(lr.paipanTime),
              infoTags: [
                if (lr.monthGanZhi != null) '月 ${lr.monthGanZhi}',
                if (lr.dayGanZhi != null) '日 ${lr.dayGanZhi}',
                if (lr.kongWang != null) '空 旬空:${lr.kongWang!.join(" ")}',
                if (lr.hiddenFuShen.isNotEmpty) '藏爻 ${lr.hiddenFuShen.join(" ")}',
                '派 ${lr.school == LiuyaoSchool.jingFangJianBan ? "京房简版" : "京房正宗"}',
              ],
              benGua: lr.benGua,
              bianGua: lr.bianGua,
              huGua: lr.huGua,
              explanationTitle: guaNameCN[lr.benGua.name],
              explanationCi: lrGuaCi?.ci,
              explanationXiang: lrGuaCi?.xiang,
              explanationJiXiong: lrGuaCi?.jiXiong,
            ),
          ),
        ],
      )
    : _emptyHint(p, t),
          ),  // SlideTransition
        ),
  ],
);
  }

  void _submitLiuyao(PaipanProvider pr) {
    if (_isLoading) return; // 防止重复点击
    setState(() => _isLoading = true);
    _animCtrl.reset();

    try {
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
        r = LiuYaoEngine.fromYaos(ys, time: _selectedTime, school: _liuyaoSchool);
      } else if (_liuyaoMethod == 1) {
        r = LiuYaoEngine.manual(school: _liuyaoSchool);
      } else if (_liuyaoMethod == 3) {
        // 数字起卦：两数定上下卦 + 动爻（1-6）
        final a = int.tryParse(_numACtrl.text.trim());
        final b = int.tryParse(_numBCtrl.text.trim());
        final cText = _numCCtrl.text.trim();
        if (a == null || b == null || cText.isEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入三个有效数字（动爻 1-6）'), duration: Duration(seconds: 2)),
          );
          return;
        }
        final c = int.parse(cText);
        r = LiuYaoEngine.byNumbers(a, b, c, school: _liuyaoSchool);
      } else {
        r = LiuYaoEngine.byTime(_selectedTime, school: _liuyaoSchool);
      }

      // 模拟短加载延迟（增强仪式感）
      Future.delayed(const Duration(milliseconds: 300), () {
        pr.setLiuyaoResult(r);
        _animCtrl.forward(from: 0); // 排盘结果出现动画（淡入+上移）
        setState(() => _isLoading = false);
        final names = ['手工摇卦', '机器摇卦', '时间起卦', '数字起卦'];
        _log.info('六爻起卦: ${names[_liuyaoMethod]}', '${r.benGua.name}');
      });
    } catch (e, st) {
      _log.error('六爻起卦失败', '$e\n$st');
      setState(() => _isLoading = false);
    }
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
        // 输入区（与八字 _buildInputCard 样式统一）
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        Wrap(
          spacing: 8,
          children: List.generate(3, (i) {
            final labels = ['三数起卦', '日期起卦', '物象起卦'];
            final sel = _meihuaMethod == i;
            return ChoiceChip(
              label: Text(labels[i], style: TextStyle(fontSize: 12, color: sel ? p : t)),
              selected: sel,
              onSelected: (v) => setState(() {
                _meihuaMethod = i;
                _emptyInputWarn = false;
              }),
              selectedColor: p.withAlpha(40),
              backgroundColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
              side: BorderSide(color: sel ? p : b.withAlpha(80), width: sel ? 1.5 : 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 8),

        // 梅花时间起卦选择器
        if (_meihuaMethod == 1) ...[
          _buildTimePicker(p, t, b, dark),
          const SizedBox(height: 8),
        ],

        // 梅花物象起卦输入：上下卦（1-8）+ 动爻
        if (_meihuaMethod == 2) ...[
          Row(children: [
            _numField('A', _numACtrl, '上卦 1-8'),
            const SizedBox(width: 8),
            _numField('B', _numBCtrl, '下卦 1-8'),
            const SizedBox(width: 8),
            _numField('C', _numCCtrl, '动爻 1-6'),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('1乾 2兑 3离 4震 5巽 6坎 7艮 8坤（动爻可省略，缺省取上卦数）',
                style: TextStyle(fontSize: 10, color: t.withAlpha(140))),
          ),
        ],

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
            onPressed: _isLoading ? null : () => _submitMeihua(pr),
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isLoading ? '排盘中…' : '排盘', style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
              ],  // Card 内 Column children
            ),  // Card 内 Column
          ),  // Padding
        ),  // Card
        const SizedBox(height: 12),

        // 梅花结果（淡入+上移，与六爻一致）
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(_fadeAnim),
            child: pr.meihuaResult != null
                ? _meihuaResultSection(context, pr, pr.meihuaResult!, p, t, b, c, dark)
                : _emptyHint(p, t),
          ),
        ),
      ],
    );
  }

  void _submitMeihua(PaipanProvider pr) {
    if (_isLoading) return; // 防止重复点击
    setState(() => _isLoading = true);
    _animCtrl.reset();

    try {
      if (_meihuaMethod == 0) {
        final aText = _numACtrl.text.trim();
        final bText = _numBCtrl.text.trim();
        final cText = _numCCtrl.text.trim();
        if (aText.isEmpty || bText.isEmpty || cText.isEmpty) {
          setState(() {
            _isLoading = false;
            _emptyInputWarn = true;
          });
          return;
        }
        setState(() => _emptyInputWarn = false);
        final a = int.tryParse(aText) ?? 0;
        final b = int.tryParse(bText) ?? 0;
        final c = int.tryParse(cText) ?? 0;
        Future.delayed(const Duration(milliseconds: 300), () {
          pr.setMeihuaResult(MeihuaEngine.fromNumbers(a, b, c));
          _animCtrl.forward();
          setState(() => _isLoading = false);
          _log.info('梅花起卦: 三数($a,$b,$c)');
        });
      } else if (_meihuaMethod == 2) {
        // 物象起卦：上下卦（1-8）+ 动爻（1-6，可省略→缺省取上卦数）
        final aText = _numACtrl.text.trim();
        final bText = _numBCtrl.text.trim();
        if (aText.isEmpty || bText.isEmpty) {
          setState(() {
            _isLoading = false;
            _emptyInputWarn = true;
          });
          return;
        }
        setState(() => _emptyInputWarn = false);
        final upper = (int.tryParse(aText) ?? 8).clamp(1, 8) - 1; // 1乾~8坤 → 0-7
        final lower = (int.tryParse(bText) ?? 8).clamp(1, 8) - 1;
        final cText = _numCCtrl.text.trim();
        final rawC = cText.isEmpty
            ? (int.tryParse(aText) ?? 1)
            : (int.tryParse(cText) ?? 1);
        final moving = (rawC % 6) == 0 ? 5 : (rawC % 6) - 1; // 余0→上爻
        Future.delayed(const Duration(milliseconds: 300), () {
          pr.setMeihuaResult(MeihuaEngine.fromTrigrams(upper, lower, moving));
          _animCtrl.forward();
          setState(() => _isLoading = false);
          _log.info('梅花起卦: 物象(上${upper + 1},下${lower + 1}) 动爻$rawC');
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          pr.setMeihuaResult(MeihuaEngine.fromDateTime(_selectedTime));
          _animCtrl.forward();
          setState(() => _isLoading = false);
          _log.info('梅花起卦: 日期${_selectedTime.year}${_selectedTime.month}${_selectedTime.day}');
        });
      }
    } catch (e, st) {
      _log.error('梅花起卦失败', '$e\n$st');
      setState(() => _isLoading = false);
    }
  }

  /// 截图排盘结果并保存（浮窗预览 → 文件名编辑 → 选择目录 → 写入）
  ///
  /// [guaName]：卦名中文（如 乾为天），用于默认文件名 {卦名}_时间戳.png
  Future<void> _saveImage(GlobalKey key, BuildContext ctx, {String? guaName}) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('截图失败：未找到排盘结果')),
          );
        }
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!ctx.mounted) return; // 截图/编码 await 后页面可能已销毁，避免跨 async 间隙使用 context

      // 先弹出预览浮窗（可编辑文件名），点保存后才选择目录并写入
      final savedPath = await saveImageWithDialog(
        context: ctx,
        pngBytes: pngBytes,
        defaultFileName:
            guaName != null ? buildImageFileName(guaName) : null,
      );
      if (savedPath == null) return; // 用户在浮窗或目录选择中取消，不写文件
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('截图已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
  }

  /// 构建时间选择器 — 与八字 _buildInputCard 样式统一
  Widget _buildTimePicker(Color p, Color t, Color b, bool dark) {
    const hours = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
    const timeRange = [
      '23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
      '11-13', '13-15', '15-17', '17-19', '19-21', '21-23',
    ];
    final hourIdx = (_selectedTime.hour == 23 || _selectedTime.hour == 0)
        ? 0 : ((_selectedTime.hour + 1) ~/ 2) % 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期选择（与八字一致：InkWell + 容器 + 下拉箭头）
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDialog<DateTime>(
                        context: context,
                        builder: (_) => const CalendarPickerDialog(),
                      );
                      if (picked != null && mounted) {
                        setState(() => _selectedTime = DateTime(
                          picked.year, picked.month, picked.day,
                          _selectedTime.hour, _selectedTime.minute,
                        ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: b.withAlpha(80)),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: p),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedTime.year} 年 ${_selectedTime.month} 月 ${_selectedTime.day} 日',
                          style: TextStyle(fontSize: 15, color: t),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: t.withAlpha(120)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 用当前时间
                InkWell(
                  onTap: () => setState(() => _selectedTime = DateTime.now()),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: p.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.withAlpha(60)),
                    ),
                    child: Icon(Icons.my_location, size: 18, color: p),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 时辰选择（与八字一致）
            Text('选择时辰', style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(12, (i) {
                final sel = hourIdx == i;
                return ChoiceChip(
                  label: Text(
                    '${hours[i]} ${timeRange[i]}',
                    style: TextStyle(fontSize: 11, color: sel ? p : t),
                  ),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    _selectedTime = DateTime(
                      _selectedTime.year, _selectedTime.month, _selectedTime.day,
                      i == 0 ? 23 : (i - 1) * 2 + 1, 0,
                    );
                  }),
                  selectedColor: p.withAlpha(40),
                  backgroundColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                  side: BorderSide(color: sel ? p : b.withAlpha(80), width: sel ? 1.5 : 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  visualDensity: VisualDensity.compact,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCurrentResult(BuildContext context, PaipanProvider pr, PaipanResult result, {CaseType? caseType}) {
    final guaNameStr = guaNameCN[result.benGua.name] ?? result.benGua.name.name;

    // Dialog 让用户输入标题
    final titleCtrl = TextEditingController(text: '$guaNameStr — ${methodToCN(result.method)}');
    final notesCtrl = TextEditingController();
    final askObjectCtrl = TextEditingController();
    final askEventCtrl = TextEditingController();
    // 断语已迁移到卦例详情页（人工断语编辑器），保存对话框不再提供断语输入
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存卦例'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: '标题', hintText: '为卦例取个名字'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: askObjectCtrl,
              decoration: const InputDecoration(labelText: '占问对象（可选）', hintText: '如：朋友 / 家人 / 工作 / 房贷'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: askEventCtrl,
              decoration: const InputDecoration(labelText: '占问事件（可选）', hintText: '如：是否应该换工作'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: '备注（可选）', hintText: '补充说明'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              try {
                final cm = CaseModel.fromPaipanResult(
                  result: result,
                  title: titleCtrl.text.trim(),
                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  askObject: askObjectCtrl.text.trim().isEmpty ? null : askObjectCtrl.text.trim(),
                  askEvent: askEventCtrl.text.trim().isEmpty ? null : askEventCtrl.text.trim(),
                  caseType: caseType,
                );
                context.read<CaseProvider>().addCase(cm);
                _log.info('保存卦例: ${cm.title}');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已保存到卦例库，可到卦例页查看详情和 AI 解卦'),
                      duration: Duration(seconds: 3)),
                );
              } catch (e, st) {
                _log.error('保存卦例失败', '$e\n$st');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('保存卦例失败: $e')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _shareResult(BuildContext ctx, PaipanResult result) {
    final gongCN = <GuaGong, String>{
      GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
      GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
      GuaGong.gen: '艮', GuaGong.kun: '坤',
    };
    final wxCN = <WuXing, String>{
      WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水', WuXing.huo: '火', WuXing.tu: '土',
    };

    final bn = guaNameCN[result.benGua.name] ?? result.benGua.name.name;
    final bg = gongCN[result.benGua.gong] ?? '';
    final bw = wxCN[result.benGua.wuXing] ?? '';
    final timeStr = '${result.paipanTime.year}/${result.paipanTime.month}/${result.paipanTime.day} ${result.paipanTime.hour}:${result.paipanTime.minute.toString().padLeft(2, '0')}';
    final yaosStr = result.benGua.yaos.map((y) =>
      '${y.positionName}爻 ${y.yinYang == YaoYinYang.yang ? '———' : '— —'}${y.isMoving ? ' ⚡动' : ''}'
    ).toList().reversed.join('\n');

    final buf = StringBuffer()
      ..writeln('【落·乾坤】排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('卦名：$bn')
      ..writeln('宫位：$bg宫 · 五行 $bw')
      ..writeln('方式：$result.method')
      ..writeln('时间：$timeStr')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln(yaosStr);
    if (result.bianGua != null) {
      final bn2 = guaNameCN[result.bianGua!.name] ?? result.bianGua!.name.name;
      buf.writeln('━━━━━━━━━━━━━━');
      buf.writeln('▸ 变卦：$bn2');
    }
    if (result.huGua != null) {
      final bn3 = guaNameCN[result.huGua!.name] ?? result.huGua!.name.name;
      buf.writeln('▸ 互卦：$bn3');
    }
    buf.writeln('━━━━━━━━━━━━━━');
    buf.writeln('—— 来自「落·乾坤」');

    Clipboard.setData(ClipboardData(text: buf.toString()));
    _log.info('排盘结果已复制到剪贴板: $bn');
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text('排盘结果已复制到剪贴板'),
          duration: const Duration(seconds: 2),
        ),
      );
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

  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(60)),
        const SizedBox(height: 12),
        Text('选择排盘方式后点「排盘」', style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
      ]),
    );
  }

  /// 梅花易数结果区域 — 三卦并排 + 体用生克
  Widget _meihuaResultSection(BuildContext context, PaipanProvider pr,
      PaipanResult result, Color p, Color t, Color b, Color c, bool dark) {
    final mhGuaCi = getGuaCi(result.benGua.name);
    final gongCN = <GuaGong, String>{
      GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
      GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
      GuaGong.gen: '艮', GuaGong.kun: '坤',
    };
    final wxCN = <WuXing, String>{
      WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水', WuXing.huo: '火', WuXing.tu: '土',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 装饰标题 ──
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.withAlpha(60))),
          ),
          child: Row(
            children: [
              Text('🔮 ', style: TextStyle(fontSize: 18, color: p)),
              Text('梅花易数 · 排盘结果',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
            ],
          ),
        ),

        // ── 三卦：宽屏并排 / 窄屏竖排 ──
        LayoutBuilder(
          builder: (ctx2, constraints) {
            final isWide = constraints.maxWidth >= 340;
            final cards = <Widget>[
              _miniGuaCard('本卦', result.benGua, p, t, c, dark),
              if (result.bianGua != null) ...[
                const SizedBox(width: 8),
                _miniGuaCard('变卦', result.bianGua!, p, t, c, dark),
              ],
              if (result.huGua != null) ...[
                const SizedBox(width: 8),
                _miniGuaCard('互卦', result.huGua!, p, t, c, dark),
              ],
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards.map((w) => w is SizedBox ? w : Expanded(child: w)).toList(),
              );
            } else {
              // 窄屏：竖排，去掉 SizedBox 间的 width
              return Column(
                children: cards.where((w) => w is! SizedBox).map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: w,
                )).toList(),
              );
            }
          },
        ),

        const SizedBox(height: 14),

        // ── 体用生克 ──
        if (result.benGua.yaos.length >= 6) ...[
          _buildTiYongEnhanced(result, p, t, c, gongCN, wxCN),
          const SizedBox(height: 12),
        ],

        // ── 操作按钮（2×2 四方格）──
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: TextButton.icon(
                  onPressed: () => pr.clearMeihua(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('清空排盘'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextButton.icon(
                  onPressed: () => _shareResult(context, result),
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('复制结果'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextButton.icon(
                  onPressed: () => _saveCurrentResult(context, pr, result, caseType: CaseType.meihua),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('保存卦例'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                )),
                const SizedBox(width: 8),
                Expanded(child: TextButton.icon(
                  onPressed: () => _saveImage(
                    _meihuaScreenshotKey,
                    context,
                    guaName: (guaNameCN[result.benGua.name] ??
                        result.benGua.name.name),
                  ),
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('保存图片'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                )),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
              style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        ),
      ],
      ),   // close child: Column(
      ),   // close RepaintBoundary( 显示

      // ── 截图专用紧凑模板（屏幕外，不影响页面显示；固定 400 宽+浅色国风）──
      ScreenshotSource(
        boundaryKey: _meihuaScreenshotKey,
        child: MeihuaScreenshotTemplate(
          timeText: formatCnTime(result.paipanTime),
          infoTags: ['方式 ${result.method}'],
          benGua: result.benGua,
          bianGua: result.bianGua,
          huGua: result.huGua,
          tiYongText: result.benGua.yaos.length >= 6
              ? MeihuaEngine.getTiYong(result)
              : null,
          explanationTitle: guaNameCN[result.benGua.name],
          explanationCi: mhGuaCi?.ci,
          explanationXiang: mhGuaCi?.xiang,
          explanationJiXiong: mhGuaCi?.jiXiong,
        ),
      ),
      ],
    );      // close 外层 Column
  }

  /// 月令/日令/空亡 等日期标签
  Widget _dateTag(String icon, String text, Color p, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: p.withAlpha(30)),
      ),
      child: Text('$icon $text',
        style: TextStyle(fontSize: 11, color: t.withAlpha(220)),),
    );
  }

  /// 迷你卦卡 — 用于梅花三卦并排
  Widget _miniGuaCard(String label, GuaModel gua, Color p, Color t, Color c, bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.withAlpha(60)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: GuaWidget(gua: gua, showFooter: false),
        ),
        const SizedBox(height: 4),
        Text(guaNameCN[gua.name] ?? gua.name.name,
          style: TextStyle(fontSize: 11, color: t.withAlpha(200)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 增强版体用生克卡片
  Widget _buildTiYongEnhanced(PaipanResult result, Color p, Color t, Color c,
      Map<GuaGong, String> gongCN, Map<WuXing, String> wxCN) {
    final desc = MeihuaEngine.getTiYong(result);

    Color bgC;
    Color borderC;
    Color txtC;
    IconData icon;
    String relationLabel;

    if (desc.contains('比和')) {
      bgC = const Color(0xFFE8F5E9);
      borderC = const Color(0xFF2E7D32);
      txtC = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
      relationLabel = '体用比和 · 顺遂';
    } else if (desc.contains('用生体') || desc.contains('进益')) {
      bgC = const Color(0xFFE8F5E9);
      borderC = const Color(0xFF2E7D32);
      txtC = const Color(0xFF2E7D32);
      icon = Icons.trending_up;
      relationLabel = '用生体 · 进益之喜';
    } else if (desc.contains('用克体') || desc.contains('凶险')) {
      bgC = const Color(0xFFFFEBEE);
      borderC = const Color(0xFFD32F2F);
      txtC = const Color(0xFFD32F2F);
      icon = Icons.warning_amber_outlined;
      relationLabel = '用克体 · 凶险多阻';
    } else if (desc.contains('体克用')) {
      bgC = const Color(0xFFFFF3E0);
      borderC = const Color(0xFFEF6C00);
      txtC = const Color(0xFFEF6C00);
      icon = Icons.auto_fix_high;
      relationLabel = '体克用 · 费力可成';
    } else if (desc.contains('体生用')) {
      bgC = const Color(0xFFE3F2FD);
      borderC = const Color(0xFF1565C0);
      txtC = const Color(0xFF1565C0);
      icon = Icons.call_made;
      relationLabel = '体生用 · 有耗损';
    } else {
      bgC = const Color(0xFFF5F5F5);
      borderC = const Color(0xFFE0E0E0);
      txtC = const Color(0xFF4A3728);
      icon = Icons.info_outline;
      relationLabel = desc;
    }

    // 解析体用字符串
    String tiPart = '';
    String yongPart = '';
    final tiMatch = RegExp(r'体卦：(.+?)[）)]').firstMatch(desc);
    final yongMatch = RegExp(r'用卦：(.+?)[—]').firstMatch(desc);
    if (tiMatch != null) tiPart = tiMatch.group(1) ?? '';
    if (yongMatch != null) yongPart = yongMatch.group(1) ?? '';
    // fallback
    if (tiPart.isEmpty && desc.contains('体卦：')) {
      tiPart = desc.split('体卦：')[1].split(' ')[0];
    }
    if (yongPart.isEmpty && desc.contains('用卦：')) {
      yongPart = desc.split('用卦：')[1].split(' —')[0];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderC.withAlpha(80), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: txtC, size: 20),
              const SizedBox(width: 8),
              Text('体用生克',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: txtC)),
            ],
          ),
          const SizedBox(height: 10),
          // 体卦 / 用卦 标签
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: txtC.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tiPart,
                    style: TextStyle(fontSize: 12, color: txtC, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz, color: txtC.withAlpha(120), size: 18),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: txtC.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(yongPart,
                    style: TextStyle(fontSize: 12, color: txtC, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(relationLabel,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: txtC)),
          ),
        ],
      ),
    );
  }




}
/// 八字排盘页面
class BaziPage extends StatefulWidget {
  const BaziPage({super.key});

  @override
  State<BaziPage> createState() => _BaziPageState();
}

class _BaziPageState extends State<BaziPage> {
  final _log = Logger.instance;
  final _baziScreenshotKey = GlobalKey();
  // 大运横向滚动控制器（供 Scrollbar 显示/拖拽滚动条）
  final _daYunScrollCtrl = ScrollController();
  DateTime? _birth;
  bool _isMale = true;
  int _hourIndex = 6; // 默认为午时 (索引6)

  static const _hourOptions = [
    '子时\n23-01', '丑时\n01-03', '寅时\n03-05', '卯时\n05-07',
    '辰时\n07-09', '巳时\n09-11', '午时\n11-13', '未时\n13-15',
    '申时\n15-17', '酉时\n17-19', '戌时\n19-21', '亥时\n21-23',
  ];

  @override
  void dispose() {
    _daYunScrollCtrl.dispose();
    super.dispose();
  }

  // 五行色
  static const _wxColors = <String, Color>{
    '木': Color(0xFF2E7D32),
    '火': Color(0xFFD32F2F),
    '土': Color(0xFFEF6C00),
    '金': Color(0xFFF9A825),
    '水': Color(0xFF1565C0),
  };

  // 天干五行
  static const _tianGanWx = {
    '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
    '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
  };

  // 地支五行
  static const _diZhiWx = {
    '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
    '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
  };

  /// 干支字符 → 五行名
  static String _ganZhiWx(String s) {
    if (s.isEmpty) return '';
    return _tianGanWx[s[0]] ?? _diZhiWx[s[0]] ?? '';
  }

  // 旺衰标签色
  static const _wangShuaiColors = <String, Color>{
    '旺': Color(0xFF2E7D32),
    '相': Color(0xFF558B2F),
    '休': Color(0xFFF57F17),
    '囚': Color(0xFFE65100),
    '死': Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BaziProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final p = theme.colorScheme.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    final c = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        child: bp.result != null
          ? KeyedSubtree(
              key: ValueKey('bazi_${bp.result!.dayZhu.ganZhi}'),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(p, t, b, isDark, bp),
                const SizedBox(height: 12),
                Expanded(
                  child: _baziResultSection(context, bp.result!, p, t, b, c, isDark),
                ),
              ],
            )
          )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(p, t, b, isDark, bp),
                  const SizedBox(height: 12),
                  _emptyHint(p, t),
                  const SizedBox(height: 60),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildInputCard(Color p, Color t, Color b, bool isDark, BaziProvider bp) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // 日期
                  InkWell(
                    onTap: () async {
                      _log.info('八字排盘', '打开日期选择器');
                      final d = await showDialog<DateTime>(
                        context: context,
                        useSafeArea: true,
                        builder: (_) => const CalendarPickerDialog(),
                      );
                      if (!mounted) return;
                      if (d != null) {
                        _log.info('八字排盘', '选择日期: $d');
                        setState(() => _birth = d);
                      } else {
                        _log.info('八字排盘', '取消日期选择');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: b.withAlpha(80)),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: p),
                        const SizedBox(width: 10),
                        Text(
                          _birth != null
                              ? '${_birth!.year} 年 ${_birth!.month} 月 ${_birth!.day} 日'
                              : '请选择出生日期',
                          style: TextStyle(fontSize: 15, color: t),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: t.withAlpha(120)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 使用当前时间起卦
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        final now = DateTime.now();
                        setState(() {
                          _birth = DateTime(now.year, now.month, now.day);
                          // 当前小时映射到时辰索引（23/0→子，1-2→丑…）
                          final h = now.hour;
                          _hourIndex =
                              (h == 23 || h == 0) ? 0 : ((h + 1) ~/ 2) % 12;
                        });
                        _log.info('八字排盘', '使用当前时间: ${now.year}-${now.month}-${now.day} ${now.hour}时');
                      },
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('使用当前时间', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 时辰选择
                  Text('选择时辰', style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(12, (i) {
                      final sel = _hourIndex == i;
                      return ChoiceChip(
                        label: Text(
                          _hourOptions[i].replaceAll('\n', ' '),
                          style: TextStyle(fontSize: 11, color: sel ? p : t),
                        ),
                        selected: sel,
                        onSelected: (_) => setState(() => _hourIndex = i),
                        selectedColor: p.withAlpha(40),
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFF9F6F2),
                        side: BorderSide(
                          color: sel ? p : b.withAlpha(80),
                          width: sel ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // 性别
                  Row(children: [
                    Text('性别：', style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('男',
                          style: TextStyle(fontSize: 12, color: _isMale ? p : t)),
                      selected: _isMale,
                      onSelected: (_) => setState(() => _isMale = true),
                      selectedColor: p.withAlpha(40),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF9F6F2),
                      side: BorderSide(
                        color: _isMale ? p : b.withAlpha(80),
                        width: _isMale ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('女',
                          style: TextStyle(fontSize: 12, color: !_isMale ? p : t)),
                      selected: !_isMale,
                      onSelected: (_) => setState(() => _isMale = false),
                      selectedColor: p.withAlpha(40),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF9F6F2),
                      side: BorderSide(
                        color: !_isMale ? p : b.withAlpha(80),
                        width: !_isMale ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // 排盘按钮
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _birth == null || bp.isCalculating
                          ? null
                          : () => _startPaipan(bp),
                      icon: bp.isCalculating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        bp.isCalculating ? '排盘中…' : '排盘',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 空状态提示
  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(80)),
        const SizedBox(height: 12),
        Text('选择出生信息后点击排盘',
            style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
      ]),
    );
  }

  /// 八字结果展示区

  /// 四柱地支刑冲合害分析（年/月/日/时）
  List<String> _analyzeDiZhiRelations(BaziResult r) {
    final zhizhis = [
      r.yearZhu.diZhiCN, r.monthZhu.diZhiCN, r.dayZhu.diZhiCN, r.hourZhu.diZhiCN
    ];
    final labels = ['年', '月', '日', '时'];
    const chongMap = {'子':'午','丑':'未','寅':'申','卯':'酉','辰':'戌','巳':'亥'};
    const heMap = {'子':'丑','寅':'亥','卯':'戌','辰':'酉','巳':'申','午':'未','丑':'子','亥':'寅','戌':'卯','酉':'辰','申':'巳','未':'午'};
    const haiMap = {'子':'未','丑':'午','寅':'巳','卯':'辰','申':'亥','酉':'戌','未':'子','午':'丑','巳':'寅','辰':'卯','亥':'申','戌':'酉'};
    const sanHeGroups = {'申子辰':'水局','亥卯未':'木局','寅午戌':'火局','巳酉丑':'金局'};

    String dz(int i) => zhizhis[i];
    final out = <String>[];
    for (var i = 0; i < 4; i++) {
      for (var j = i + 1; j < 4; j++) {
        final a = dz(i), b = dz(j);
        final pair = '${labels[i]}$a-${labels[j]}$b';
        if (chongMap[a] == b) out.add('$pair 相冲');
        if (heMap[a] == b) out.add('$pair 六合');
        if (haiMap[a] == b) out.add('$pair 相害');
      }
    }
    final uniqueDz = zhizhis.toSet().join('');
    for (final e in sanHeGroups.entries) {
      if (e.key.split('').every(uniqueDz.contains)) {
        out.add('含${e.key}三合${e.value}');
      }
    }
    const xingMap = {'寅巳申':'无恩之刑','丑戌未':'恃势之刑'};
    for (final e in xingMap.entries) {
      if (e.key.split('').every(uniqueDz.contains)) out.add('${e.key}${e.value}');
    }
    if (uniqueDz.contains('子') && uniqueDz.contains('卯')) out.add('子卯无礼之刑');
    if (out.isEmpty) out.add('四柱地支无明显刑冲合害');
    return out;
  }

  /// 地支关系卡片（摘要展示）
  Widget _diZhiRelationCard(BaziResult r, Color p, Color t, Color b, bool dark) {
    final rels = _analyzeDiZhiRelations(r);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: b.withAlpha(60)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: rels.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: t.withAlpha(8),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: t.withAlpha(20)),
          ),
          child: Text(s, style: TextStyle(fontSize: 11, color: t.withAlpha(200))),
        )).toList(),
      ),
    );
  }

  Widget _baziResultSection(BuildContext context,
      BaziResult r, Color p, Color t, Color b, Color c, bool dark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // ── 四柱卡片 ──
          Row(
            children: [
              _pillarCard('年柱', r.yearZhu, p, t, c, b, dark),
              const SizedBox(width: 4),
              _pillarCard('月柱', r.monthZhu, p, t, c, b, dark),
              const SizedBox(width: 4),
              _pillarCard('日柱', r.dayZhu, p, t, c, b, dark, isRiZhu: true),
              const SizedBox(width: 4),
              _pillarCard('时柱', r.hourZhu, p, t, c, b, dark),
            ],
          ),
          const SizedBox(height: 12),

          // ── 五行旺衰 ──
          _sectionHeader(p, '五行旺衰'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: r.wuXingWangShuai.entries.map((e) {
              final wc = _wxColors[e.key] ?? t;
              final sc = _wangShuaiColors[e.value] ?? t;
              return Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: wc.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: wc.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    Text(e.key,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: wc)),
                    const SizedBox(height: 2),
                    Text(e.value,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: sc)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── 五行数量 ──
          _sectionHeader(p, '五行统计'),
          _rowWrap(
            r.wuXingCounts.entries.map((e) {
              final wc = _wxColors[e.key] ?? t;
              return _tag('${e.key} ${e.value}', wc, t);
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── 胎元（月干+1、月支+3，安命之本） ──
          _sectionHeader(p, '胎元'),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: b.withAlpha(60)),
            ),
            child: Row(children: [
              const Icon(Icons.child_care_outlined, size: 16, color: Colors.teal),
              const SizedBox(width: 8),
              Text('胎元：', style: TextStyle(fontSize: 13, color: t)),
              Text(_calcTaiYuan(r),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(width: 8),
              Text('（月柱顺推：干+1、支+3）',
                  style: TextStyle(fontSize: 10, color: t.withAlpha(120))),
            ]),
          ),
          const SizedBox(height: 12),

          // ── 旬空（空亡） ──
          if (r.kongWang.isNotEmpty) ...[
            _sectionHeader(p, '旬空'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Row(children: [
                const Icon(Icons.block, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('空亡：', style: TextStyle(fontSize: 13, color: t)),
                Text(r.kongWang.join(' '),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              ]),
            ),
            const SizedBox(height: 12),
          ],

          // ── 藏干 ──
          _sectionHeader(p, '藏干'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cangGanRow('年柱', r.yearZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('月柱', r.monthZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('日柱', r.dayZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('时柱', r.hourZhu.cangGan, p, t),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 十神 ──
          _sectionHeader(p, '十神关系（以日干为基准）'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: r.shiShenMap.entries
                    .where((e) => e.key != '日主')
                    .map((e) {
                  final label = e.key.contains(':')
                      ? '${e.key.split(':')[0]}:${e.key.split(':')[1]}'
                      : e.key;
                  return _tag('$label → ${e.value}', p, t);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 大运 ──
          if (r.daYun.isNotEmpty) ...[
            // ── 地支刑冲合害 ──
          _sectionHeader(p, '地支刑冲合害'),
          _diZhiRelationCard(r, p, t, b, dark),
          const SizedBox(height: 12),

          _sectionHeader(p, '大运'),
            // 桌面/窄屏可横向滚动：允许鼠标/触控板拖拽 + 可见滚动条可拖拽拇指，
            // 避免外层垂直滚动吞掉水平滚动手势导致"显示不全且无法左右滑动"。
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ui.PointerDeviceKind.touch,
                  ui.PointerDeviceKind.mouse,
                  ui.PointerDeviceKind.stylus,
                  ui.PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _daYunScrollCtrl,
                thumbVisibility: true,
                interactive: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _daYunScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 当前虚岁 → 定位当前大运
                      ...(() {
                        final xuSui = DateTime.now().year - r.birth.year + 1;
                        final curIdx = r.daYun.lastIndexWhere((d) => d.startAge <= xuSui);
                        return r.daYun.asMap().entries.map((e) {
                          final i = e.key;
                          final dy = e.value;
                          final isCur = i == curIdx;
                          final ganWx = _ganZhiWx(dy.tianGan);
                          final ganColor = _wxColors[ganWx] ?? t;
                          return Container(
                            width: 76,
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isCur
                                  ? p.withAlpha(22)
                                  : (dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isCur ? p : ganColor.withAlpha(80),
                                  width: isCur ? 2 : 1),
                            ),
                            child: Column(
                              children: [
                                Text('${dy.startAge}岁',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isCur ? p : t.withAlpha(150),
                                        fontWeight: isCur ? FontWeight.bold : FontWeight.normal)),
                                const SizedBox(height: 2),
                                Text(dy.ganZhi,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ganColor)),
                                Text(isCur ? '● 当前运' : (dy.naYin ?? ''),
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: isCur ? p : t.withAlpha(130))),
                              ],
                            ),
                          );
                        });
                      })(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 大运五行走势图
            _DaYunTrendChart(
              daYun: r.daYun,
              plotColor: p,
              textColor: t,
            ),
            const SizedBox(height: 12),
          ],

          // ── 流年 ──
          if (r.liuNian != null) ...[
            _sectionHeader(p, '当年流年'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text('流年：', style: TextStyle(fontSize: 13, color: t)),
                Text(r.liuNian!,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: p)),
              ]),
            ),
            const SizedBox(height: 12),
          ],

              ],   // close inner children
            ),   // close inner Column
          ),   // close RepaintBoundary

          // ── 截图专用紧凑模板（屏幕外，不影响页面显示；固定 400 宽+浅色国风）──
          ScreenshotSource(
            boundaryKey: _baziScreenshotKey,
            child: BaziScreenshotTemplate(
              birthText: '${r.birth.year}年${r.birth.month}月${r.birth.day}日 '
                  '${_hourOptions[_hourIndex].replaceAll('\n', '（')} · ${r.isMale ? '男' : '女'}',
              result: r,
            ),
          ),

          // ── 操作按钮（2×2 四方格）──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: TextButton.icon(
                    onPressed: () => context.read<BaziProvider>().clear(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('清空排盘'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextButton.icon(
                    onPressed: () => _shareResult(context, r),
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('复制结果'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextButton.icon(
                    onPressed: () => _saveBaziResult(context, r),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('保存卦例'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextButton.icon(
                    onPressed: () => _saveImage(_baziScreenshotKey, context),
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('保存图片'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 保存引导提示 ──
          Center(
            child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
                style: TextStyle(fontSize: 12,
                    color: t.withAlpha(180),
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 四柱单张卡片
  Widget _pillarCard(String label, SiZhu zhu, Color p, Color t, Color c,
      Color b, bool dark, {bool isRiZhu = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isRiZhu
              ? p.withAlpha(15)
              : (dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRiZhu ? p : b.withAlpha(60),
            width: isRiZhu ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: t.withAlpha(120))),
            const SizedBox(height: 6),
            // 天干 + 地支（可点击查看参考）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showGanRef(context, zhu.tianGan, t, p, dark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isRiZhu ? p.withAlpha(20) : t.withAlpha(10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(zhu.tianGan,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isRiZhu ? p : t)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showZhiRef(context, zhu.diZhi, t, p, dark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(zhu.diZhi,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: t)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${zhu.tianGan}${zhu.diZhi} · ${zhu.wuXing}',
                style: TextStyle(fontSize: 11, color: t.withAlpha(150))),
            if (zhu.naYin != null) ...[
              const SizedBox(height: 2),
              Text('纳音 ${zhu.naYin}',
                  style: TextStyle(fontSize: 10, color: t.withAlpha(120))),
            ],
          ],
        ),
      ),
    );
  }

  /// 藏干行
  Widget _cangGanRow(String label, Map<String, String> cangGan, Color p, Color t) {
    final items = cangGan.entries
        .where((e) => e.value != '无' && e.value.isNotEmpty)
        .toList();
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p)),
        ),
        if (items.isEmpty)
          Expanded(
            child: Text('无',
                style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
          )
        else
          Expanded(
            child: Row(
              children: items.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('${e.key}:${e.value}',
                      style: TextStyle(fontSize: 12, color: t)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// 开始八字排盘（含日志记录）
  Future<void> _startPaipan(BaziProvider bp) async {
    _log.info('八字排盘', '开始排盘: 出生${_birth!.year}-${_birth!.month}-${_birth!.day} '
        '性别${_isMale ? "男" : "女"} 时辰索引$_hourIndex');
    try {
      await bp.calc(birth: _birth!, isMale: _isMale, hourIndex: _hourIndex);
      _log.info('八字排盘', '排盘完成');
    } catch (e) {
      _log.error('八字排盘失败', '$e');
    }
  }

  /// 截图排盘结果并保存（浮窗预览 → 文件名编辑 → 选择目录 → 写入）
  Future<void> _saveImage(GlobalKey key, BuildContext ctx) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('截图失败：未找到排盘结果')),
          );
        }
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!ctx.mounted) return; // 截图/编码 await 后页面可能已销毁，避免跨 async 间隙使用 context

      // 先弹出预览浮窗（可编辑文件名），点保存后才选择目录并写入
      final savedPath = await saveImageWithDialog(
        context: ctx,
        pngBytes: pngBytes,
        defaultFileName: buildImageFileName('八字排盘'),
      );
      if (savedPath == null) return; // 用户在浮窗或目录选择中取消，不写文件
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('截图已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
  }

  /// 保存八字结果到卦例库
  void _saveBaziResult(BuildContext context, BaziResult r) {
    final defaultTitle =
        '八字排盘 · ${r.yearZhu.ganZhi} ${r.monthZhu.ganZhi} ${r.dayZhu.ganZhi} ${r.hourZhu.ganZhi}';
    final titleCtrl = TextEditingController(text: defaultTitle);
    final notesCtrl = TextEditingController();
    final askObjectCtrl = TextEditingController();
    final askEventCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存排盘'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '为排盘取个名字',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: askObjectCtrl,
              decoration: const InputDecoration(
                labelText: '占问对象（可选）',
                hintText: '如：朋友 / 家人 / 工作 / 健康',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: askEventCtrl,
              decoration: const InputDecoration(
                labelText: '占问事件（可选）',
                hintText: '如：近期运势如何',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '补充说明',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final cm = CaseModel.fromBaziResult(
                result: r,
                title: titleCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty
                    ? null
                    : notesCtrl.text.trim(),
                askObject: askObjectCtrl.text.trim().isEmpty
                    ? null
                    : askObjectCtrl.text.trim(),
                askEvent: askEventCtrl.text.trim().isEmpty
                    ? null
                    : askEventCtrl.text.trim(),
              );
              context.read<CaseProvider>().addCase(cm);
              _log.info('保存八字排盘: ${cm.title}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已保存到卦例库，可到卦例页查看详情和 AI 解卦'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 分享/复制结果
  void _shareResult(BuildContext context, BaziResult r) {
    final sb = StringBuffer()
      ..writeln('【落·乾坤】八字排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('出生：${r.birth.year}/${r.birth.month}/${r.birth.day}'
          ' ${r.birth.hour}:${r.birth.minute.toString().padLeft(2, '0')}')
      ..writeln('性别：${r.isMale ? "男" : "女"}')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('年柱：${r.yearZhu.ganZhi}  ${r.yearZhu.wuXing}')
      ..writeln('月柱：${r.monthZhu.ganZhi}  ${r.monthZhu.wuXing}')
      ..writeln('日柱：${r.dayZhu.ganZhi}  ${r.dayZhu.wuXing}')
      ..writeln('时柱：${r.hourZhu.ganZhi}  ${r.hourZhu.wuXing}')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('五行旺衰：')
      ..writeln(r.wuXingWangShuai.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(' · '))
      ..writeln('━━━━━━━━━━━━━━');
    if (r.daYun.isNotEmpty) {
      sb.writeln(
          '大运：${r.daYun.map((d) => '${d.ganZhi}(${d.startAge}岁起)').join('，')}');
    }
    if (r.liuNian != null) {
      sb.writeln('流年：${r.liuNian}');
    }
    sb.writeln('—— 来自「落·乾坤」');

    // 复制到剪贴板
    final data = sb.toString();
    Clipboard.setData(ClipboardData(text: data));
    _log.info('八字排盘结果已复制到剪贴板');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结果已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }

  /// 区域标题
  /// 胎元：月柱天干顺推1位、地支顺推3位（安命之本，反映先天禀赋）
  String _calcTaiYuan(BaziResult r) {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    final monthGan = r.monthGan;
    final monthZhi = r.monthZhi;
    final gi = gan.indexOf(monthGan);
    final zi = zhi.indexOf(monthZhi);
    if (gi < 0 || zi < 0) return '—';
    return '${gan[(gi + 1) % 10]}${zhi[(zi + 3) % 12]}';
  }

  Widget _sectionHeader(Color p, String title) {    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: p)),
    );
  }

  /// 标签
  Widget _tag(String text, Color p, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.withAlpha(40)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: t.withAlpha(220))),
    );
  }

  /// Wrap 行
  Widget _rowWrap(List<Widget> children) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }

  /// 显示天干参考弹窗
  void _showGanRef(BuildContext ctx, String gan, Color t, Color p, bool dark) {
    TianGanInfo? temp;
    try {
      temp = tianGanList.firstWhere((g) => g.name == gan);
    } catch (_) {}
    if (temp == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('暂无「$gan」的参考资料', style: const TextStyle(fontSize: 13))),
      );
      return;
    }
    final info = temp;
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(info.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: p)),
          ),
          const SizedBox(width: 8),
          Text('天干', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _refRow('五行', info.wuXing, t),
              _refRow('阴阳', info.yinYang, t),
              _refRow('方位', info.direction, t),
              if (info.body.isNotEmpty) _refRow('对应身体', info.body, t),
              if (info.image.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('类象', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 2),
                Text(info.image, style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('关闭'))],
      ),
    );
  }

  /// 显示地支参考弹窗
  void _showZhiRef(BuildContext ctx, String zhi, Color t, Color p, bool dark) {
    DiZhiInfo? temp;
    try {
      temp = diZhiList.firstWhere((z) => z.name == zhi);
    } catch (_) {}
    if (temp == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('暂无「$zhi」的参考资料', style: const TextStyle(fontSize: 13))),
      );
      return;
    }
    final info = temp;
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(info.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: p)),
          ),
          const SizedBox(width: 8),
          Text('地支', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _refRow('五行', info.wuXing, t),
              _refRow('阴阳', info.yinYang, t),
              _refRow('方位', info.direction, t),
              _refRow('月份', info.month, t),
              _refRow('时辰', info.hourRange, t),
              _refRow('生肖', info.shengXiao, t),
              if (info.image.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('类象', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 2),
                Text(info.image, style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('关闭'))],
      ),
    );
  }

  /// 参考信息行
  Widget _refRow(String label, String value, Color t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text('$label：', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, color: t)),
          ),
        ],
      ),
    );
  }
}

/// 大运五行走势图（CustomPaint 折线图）
/// X 轴：8 步大运；Y 轴：天干五行（木1 火2 土3 金4 水5）
class _DaYunTrendChart extends StatelessWidget {
  final List<DaYun> daYun;
  final Color plotColor;
  final Color textColor;

  const _DaYunTrendChart({
    required this.daYun,
    required this.plotColor,
    required this.textColor,
  });

  static const _wxOrder = ['木', '火', '土', '金', '水'];

  String _ganWx(String gan) {
    const map = {
      '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
      '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
    };
    return map[gan] ?? '土';
  }

  @override
  Widget build(BuildContext context) {
    if (daYun.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFF9F6F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('五行走势',
              style: TextStyle(fontSize: 11, color: textColor.withAlpha(180))),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(
                values: daYun.map((dy) {
                  final wx = _ganWx(dy.tianGan);
                  return _wxOrder.indexOf(wx);
                }).toList(),
                wxs: daYun.map((dy) => _ganWx(dy.tianGan)).toList(),
                ages: daYun.map((dy) => dy.startAge).toList(),
                lineColor: plotColor,
                textColor: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 趋势折线图绘制器
class _TrendPainter extends CustomPainter {
  final List<int> values;      // 五行索引 0-4
  final List<String> wxs;      // 五行名
  final List<int> ages;        // 起运年龄
  final Color lineColor;
  final Color textColor;

  _TrendPainter({
    required this.values,
    required this.wxs,
    required this.ages,
    required this.lineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const wxColors = {
      '木': Color(0xFF2E7D32),
      '火': Color(0xFFD32F2F),
      '土': Color(0xFFEF6C00),
      '金': Color(0xFFF9A825),
      '水': Color(0xFF1565C0),
    };

    const padding = 20.0;
    final chartW = size.width - padding * 2;
    final chartH = size.height - padding * 2;
    final stepX = chartW / (values.length - 1);

    // 折线路径
    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = padding + i * stepX;
      final y = padding + chartH - (values[i] / 4.0) * chartH;
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 绘制填充区域（柔化）
    final fill = Path.from(path)
      ..lineTo(points.last.dx, padding + chartH)
      ..lineTo(points.first.dx, padding + chartH)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = lineColor.withAlpha(25),
    );

    // 折线
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // 数据点 + 五行色
    final dotPaint = Paint();
    for (int i = 0; i < points.length; i++) {
      final wx = wxs[i];
      dotPaint.color = wxColors[wx] ?? lineColor;
      canvas.drawCircle(points[i], 3.5, dotPaint);
    }

    // X 轴年龄标签
    final textStyle = TextStyle(fontSize: 8, color: textColor.withAlpha(160));
    for (int i = 0; i < ages.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: '${ages[i]}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[i].dx - tp.width / 2, padding + chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
